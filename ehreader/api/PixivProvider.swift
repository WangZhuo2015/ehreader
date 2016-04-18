//
//  PixivProvider.swift
//  ehreader
//
//  Created by yrtd on 16/1/20.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire

/// NSOperatioinQueue maxConcurrentOperationCount define
public let MaxConCurrentOperationCount:Int = 2

/// API fetch timeout
public let MaxPixivAPIFetchTimeout:NSTimeInterval = 3000

/// return value if a intger field is NSNull
public let PixivIntInvalid = -1

/// Auth key for NSUserDefaults
public let PixivAuthStorageKey = "PixivAPI_Auth"

/// API URLs
public let PixivLoginRoot = "https://oauth.secure.pixiv.net/auth/token"
public let PixivSAPIRoot = "http://spapi.pixiv.net/iphone/"
public let PixivPAPIRoot = "https://public-api.secure.pixiv.net/v1/"

public let PixivDefaultHeaders = [
    "Referer": "http://spapi.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.1.1",
    "Content-Type": "application/x-www-form-urlencoded"
]

private let ErrorDomainPixivProvider = "PixivProvider"

public enum PixivError:ErrorType {
    case AccessTokenEmpty
    case SessionEmpty
    case ResultFormatInvalid
}

public enum PixivRankingMode:String {
    case Daily = "daily"
    case Weekly = "weekly"
    case Monthly = "monthly"
    case Male = "male"
    case Female = "female"
    case Rookie = "rookie"
    case DailyR18 = "daily_r18"
    case WeeklyR18 = "weekly_r18"
    case MaleR18 = "male_r18"
    case FemaleR18 = "female_r18"
    case R18g = "r18g"
}

var RankingTypes:[PixivRankingMode:String] = [
    PixivRankingMode.Daily: "每日",
    PixivRankingMode.Weekly:"每周",
    PixivRankingMode.Monthly:"每月",
    PixivRankingMode.Male:"最受男生欢迎",
    PixivRankingMode.Female:"最受女生欢迎",
    PixivRankingMode.Rookie:"Rookie",
    PixivRankingMode.DailyR18:"每日R18",
    PixivRankingMode.WeeklyR18:"每周R18",
    PixivRankingMode.MaleR18:"最受男生欢迎R18",
    PixivRankingMode.FemaleR18:"最受女生欢迎R18",
    PixivRankingMode.R18g:"R18g"]

public enum PixivSearchMode:String {
    case ExactTag = "exact_tag"
    case Text = "text"
    case Tag = "tag"
    case Caption = "caption"
}

public enum PixivRankingType:String {
    case All = "all"
    case Illust = "illust"
    case Manga = "manga"
    case Ugoira = "ugoira"
}

public enum PixivPublicity:String {
    case Public = "public"
    case Private = "private"
}

public struct Pagination {
    public var current:Int = 0
    public var next:Int?
    public var pages:Int = 0
    public var per_page:Int = 0
    public var previous:Int?
    public var total:Int = 0
}

private struct ResponseWrapper {
    var header:[NSObject : AnyObject]
    var data:NSData?
    var payload:String?
    
    init(header:[NSObject : AnyObject], responseData:NSData?) {
        self.header = header
        self.data = responseData
        if responseData != nil {
            self.payload = String(data: responseData!, encoding: NSUTF8StringEncoding)
        }
    }
    
    func isValid()->Bool {
        return self.data != nil
    }
}

public typealias GalleryCompleteClosure = (gallery:PixivIllustGallery?, error:NSError?)->Void

private extension Dictionary {
    func buildUrlParameters()->String? {
        var parts:[String] = []
        for (key, value) in self {
            let encodedKey = (key as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let encodedValue = (value as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            if encodedKey == nil || encodedValue == nil {
                continue
            }
            parts.append("\(encodedKey!)=\(encodedValue!)")
        }
        if parts.count > 0 {
            return (parts as NSArray).componentsJoinedByString("&")
        }else {
            return nil
        }
    }
}


public class PixivProvider: NSObject {
    public var accessToken:String? {
        return self.user?.access_token
    }
    
    public var refreshToken:String? {
        return self.user?.refresh_token
    }
    
    public var session:String?
    
    public var userId:String? {
        return self.user?.id
    }
    
    public var user:PixivUser?
    
    private var loginRoot:String = PixivLoginRoot
    private var sapiRoot:String = PixivSAPIRoot
    private var papiRoot:String = PixivPAPIRoot
    private var defaultHeaders:[String:String] = PixivDefaultHeaders
    
    public lazy var operationQueue:NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = MaxConCurrentOperationCount
        return queue
    }()
    
    public static func getInstance()->PixivProvider {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: PixivProvider = PixivProvider()
    }
    
    override init() {
        super.init()
        self.user = PixivUser.currentLoginUser()
        self.session = self.user?.session
    }
    
    /**
     Login to the server, use oauth2.0. the response example like:
     {"response":{"access_token":"P7xGYwAmksSI-ZLPteTESgT4SIH1NVWTctOf0kzSnGU","expires_in":3600,"token_type":"bearer","scope":"unlimited","refresh_token":"YHTOSLhPJTylNUyP6ntiI6CyNohlyd7AH-xhMasxs4o","user":{"profile_image_urls":{"px_16x16":"http:\\source.pixiv.net/common/images/no_profile_ss.png","px_50x50":"http:/\\/source.pixiv.net/common/images/no_profile_s.png","px_170x170":"http://source.pixiv.net/common/images/no_profile.png"},"id":"8701294","name":"zzycami","account":"zzycami"}}}
     
     - parameter username:
     - parameter password:
     
     - returns: user information
     */
    public func login(username:String, password:String)throws->PixivUser? {
        let url = self.loginRoot
        let loginHeader:[String:String] = [
            "Referer": "http://www.pixiv.net/"
        ]
        
        let data = [
            "username": username,
            "password": password,
            //// OAuth login from PixivIOSApp/5.1.1
            "grant_type": "password",
            "client_id": "bYGKuGVw91e0NMfPGp44euvGt59s",
            "client_secret": "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"
        ]
        
        let result = try requestUrl("POST", url: url, headers: loginHeader, parameters: nil, content: data)
        if !result.isValid() {
            return nil
        }
        guard let jsonResult = try NSJSONSerialization.JSONObjectWithData(result.data!, options: NSJSONReadingOptions.AllowFragments) as? [NSObject:AnyObject] else{
            return nil
        }
        
        guard let response = jsonResult["response"] as? [NSObject:AnyObject] else {
            return nil
        }
        
        // from response.header["Set-Cookie"] get PHPSESSID, etc. PHPSESSID=8701294_6bb2ade181198118ee95e1f2217d56c6; expires=Thu, 21-Jan-2016 04:11:32 GMT; Max-Age=3600; path=/; domain=.pixiv.net; secure
        let rawCookie = result.header["Set-Cookie"] as! String
        let rawCookies = (rawCookie as NSString).componentsSeparatedByString("; ")
        for cookie in rawCookies {
            if let equalPos = cookie.rangeOfString("=") {
                var key = cookie.substringToIndex(equalPos.startIndex)
                key = key.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                var value = cookie.substringFromIndex(equalPos.endIndex)
                value = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if key == "PHPSESSID" {
                    self.session = value
                }
            }
        }
        
        self.user = PixivUser.createPixivUser(response, session: self.session, password: password)
        
        return self.user
    }
    
    public func loginIfNeeded(username:String, password:String)throws->Bool {
        if PixivUser.isLoginExpires(username) {
            // Auth expired, call login:
            let user = try login(username, password: password)
            if user != nil {
                return true
            }else {
                return false
            }
        }else {
            // load auth success
            return true
        }
    }
    
    /**
     Fetch the ranking for now or past
     
     - parameter mode:  [daily, weekly, monthly, rookie, original, male, female, daily_r18, weekly_r18, male_r18, female_r18, r18g]
                        for 'illust' & 'manga': [daily, weekly, monthly, rookie, daily_r18, weekly_r18, r18g]
                        for 'ugoira': [daily, weekly, daily_r18, weekly_r18],
     - parameter rankingType: [all, illust, manga, ugoira]
     - parameter page:        [1-n]
     - parameter complete:
     */
    public func getRankingAll(mode:PixivRankingMode, rankingType:PixivRankingType = PixivRankingType.All, page:Int, complete:GalleryCompleteClosure?) {
        
        let url = PixivPAPIRoot + "ranking/\(rankingType.rawValue).json"
        let parameters:[String:AnyObject] = [
            "mode": mode.rawValue,
            "page": page,
            "per_page": 50,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "include_stats": "true",
            "include_sanity_level": "true"
        ]
        
//        if date != nil {
//            //date: '2015-04-01' (仅过去排行榜)
//            parameters["date"] = date
//        }
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), { 
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), { 
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func getLastWorks(page:Int = 1, perPage:Int = 30, includeStatus:Bool = true, includeSanityLevel:Bool = true, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "works.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "include_stats": includeStatus ? "true" : "false",
            "include_sanity_level": includeSanityLevel ? "true" : "false"
        ]
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func meFeed(showR18:Bool, maxId:Int?, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "me/feeds.json"
        var parameters:[String:AnyObject] = [
            "relation": "all",
            "type": "touch_nottext",
            "show_r18": showR18 ? "1" : "0"
        ]
        if let maxId = maxId {
            parameters["max_id"] = maxId
        }
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(result, options: NSJSONWritingOptions.PrettyPrinted)
                    if let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                        print(jsonStr)
                    }
                }catch let error as NSError {
                    print(error)
                }
                
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func usersFavoriteWorks(userId:Int, page:Int = 1, perPage:Int = 30, includeSanityLevel:Bool = true, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "users/\(userId)/favorite_works.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "include_sanity_level": includeSanityLevel ? "true" : "false"
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func meFavoriteWorksAdd(workId:Int, publicity:PixivPublicity, complete:((success:Bool, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "me/favorite_works.json"
        let parameters:[String:AnyObject] = [
            "work_id": workId,
            "publicity": publicity.rawValue,
        ]
         var error:NSError?
        authrizonRequest(.POST, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(success: false, error: response.result.error)
                return
            }
            guard let value = response.result.value as? NSDictionary else {
                complete?(success: false, error: response.result.error)
                return
            }
            if value.objectForKey("status") as! String == "success" {
                complete?(success: true, error: nil)
            }
        }
        if error != nil {
            complete?(success: false, error: error)
        }
    }
    
    public func meFavoriteWorksDelete(ids:[Int], publicity:PixivPublicity, complete:((success:Bool, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "me/favorite_works.json"
        var workId = ""
        if ids.count == 1 {
            workId = "\(ids[0])"
        }else if ids.count > 1 {
            workId = (ids as NSArray).componentsJoinedByString(",")
        }
        let parameters:[String:AnyObject] = [
            "ids": workId,
            "publicity": publicity.rawValue,
        ]
        var error:NSError?
        authrizonRequest(.DELETE, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(success: false, error: response.result.error)
                return
            }
            guard let value = response.result.value as? NSDictionary else {
                complete?(success: false, error: response.result.error)
                return
            }
            if value.objectForKey("status") as! String == "success" {
                complete?(success: true, error: nil)
            }
        }
        if error != nil {
            complete?(success: false, error: error)
        }
    }
    
    public func meFavoriteWorks(page:Int = 1, perPage:Int = 50, publicity:PixivPublicity, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "me/favorite_works.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "publicity": publicity.rawValue
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    /**
     关注的新作品
     
     - parameter page:     请求的页
     - parameter perPage:  每页多少
     - parameter complete: 完成的回调
     */
    public func meFollowingWorks(page:Int = 1, perPage:Int = 30, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "me/following/works.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "include_stats": "true",
            "include_sanity_level": "true"
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func usersWorks(userId:Int, page:Int = 1, perPage:Int = 50, complete:GalleryCompleteClosure?) {
        let url = PixivPAPIRoot + "users/\(userId)/works.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
            "profile_image_sizes": "px_170x170,px_50x50",
            "include_stats": "true",
            "include_sanity_level": "true"
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    
    public func meFollowing(page:Int = 1, perPage:Int = 50, publicity:PixivPublicity, complete:((profiles:[PixivProfile], pagination:Pagination?, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "me/following.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "profile_image_sizes": "px_170x170,px_50x50",
            "publicity": publicity.rawValue
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(profiles: [], pagination: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            guard let paginationJson = result["pagination"] as? NSDictionary else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            guard let profilesArray = result["response"] as? NSArray else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            let pagination = self.createPagination(paginationJson)
            var profiles:[PixivProfile] = []
            for profileJson in profilesArray {
                if let profile  = PixivProfile.createProfile(profileJson as! NSDictionary){
                    profiles.append(profile)
                }
            }
            
            complete?(profiles: profiles, pagination: pagination, error: nil)
        }
        if error != nil {
            complete?(profiles: [], pagination: nil, error: error)
        }
    }
    
    public func usersFollowing(userId:Int, page:Int = 1, perPage:Int = 50,complete:((profiles:[PixivProfile], pagination:Pagination?, error:NSError?)->Void)?){
        let url = PixivPAPIRoot + "users/\(userId)/following.json"
        let parameters:[String:AnyObject] = [
            "page": page,
            "per_page": perPage,
            "profile_image_sizes": "px_170x170,px_50x50"
        ]
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(profiles: [], pagination: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            guard let paginationJson = result["pagination"] as? NSDictionary else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            guard let profilesArray = result["response"] as? NSArray else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(profiles: [], pagination: nil, error: error)
                return
            }
            
            let pagination = self.createPagination(paginationJson)
            var profiles:[PixivProfile] = []
            for profileJson in profilesArray {
                if let profile  = PixivProfile.createProfile(profileJson as! NSDictionary){
                    profiles.append(profile)
                }
            }
            
            complete?(profiles: profiles, pagination: pagination, error: nil)
        }
        if error != nil {
            complete?(profiles: [], pagination: nil, error: error)
        }
    }
    
    /**
     关注用户
     
     - parameter userId:    用户ID
     - parameter publicity: 是否公开关注
     - parameter complete:  完成回调
     */
    public func meFavoriteUsersFollow(userId:Int, publicity:PixivPublicity, complete:((success:Bool, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "me/favorite-users.json"
        let parameters:[String:AnyObject] = [
            "target_user_id": userId,
            "publicity": publicity.rawValue
        ]
        var error:NSError?
        authrizonRequest(.POST, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(success: false, error: response.result.error)
                return
            }
            guard let value = response.result.value as? NSDictionary else {
                complete?(success: false, error: response.result.error)
                return
            }
            print(value)
            if value.objectForKey("status") as! String == "success" {
                complete?(success: true, error: nil)
            }
        }
        if error != nil {
            complete?(success: false, error: error)
        }
    }
    
    /**
     解除关注用户
     
     - parameter userIds:   用户id组成的数组，可以一次性取消多人关注
     - parameter publicity: 是否公开
     - parameter complete:  完成回调
     */
    public func meFavoriteUsersUnfollow(userIds:[Int], publicity:PixivPublicity, complete:((success:Bool, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "me/favorite-users.json"
        var userId = ""
        if userIds.count == 1 {
            userId = "\(userIds[0])"
        }else if userIds.count > 1 {
            userId = (userIds as NSArray).componentsJoinedByString(",")
        }
        let parameters:[String:AnyObject] = [
            "delete_ids": userId,
            "publicity": publicity.rawValue,
            ]
        var error:NSError?
        authrizonRequest(.DELETE, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(success: false, error: response.result.error)
                return
            }
            guard let value = response.result.value as? NSDictionary else {
                complete?(success: false, error: response.result.error)
                return
            }
            if value.objectForKey("status") as! String == "success" {
                complete?(success: true, error: nil)
            }
        }
        if error != nil {
            complete?(success: false, error: error)
        }
    }
    
    /**
     搜索作品
     
     - parameter query:    搜索的文字
     - parameter page:     page 的范围为1~n
     - parameter perPage:  每页显示的数目，默认为30
     - parameter mode:     搜索模式：text - 标题/描述， tag - 非精确标签， exact_tag - 精确标签， caption - 描述
     - parameter period:   only applies to asc order， all - 所有，day - 一天之内，week - 一周之内，month - 一月之内
     - parameter order:    desc - 新顺序，asc - 旧顺序
     - parameter sort:     排序方式，目前只有date
     - parameter complete: 完成回调
     */
    public func searchWorks(query:String, page:Int = 1, perPage:Int = 30, mode:PixivSearchMode = PixivSearchMode.ExactTag, period:String = "all", order:String = "desc", sort:String = "date", complete:GalleryCompleteClosure?) {
        
        let url = PixivPAPIRoot + "search/works.json"
        let parameters:[String:AnyObject] = [
            "q": query,
            "page": page,
            "per_page": perPage,
            "period": period,
            "order": order,
            "sort": sort,
            "mode": mode.rawValue,
            "types": "illustration,manga,ugoira",
            "include_stats": "true",
            "include_sanity_level": "true",
            "image_sizes": "medium,small,px_128x128,px_480mw,large",
        ]
        
        print(parameters)
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func searchUsers(query:String, page:Int = 1, perPage:Int = 30, complete:GalleryCompleteClosure?) {
        
        let url = PixivSAPIRoot + "search_user.php"
        let parameters:[String:AnyObject] = [
            "nick": query,
            "p": page
        ]
        
        print(parameters)
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            dispatch_async(dispatch_get_global_queue(0, 0), {
                if response.result.error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: response.result.error)
                    })
                    return
                }
                
                guard let result = response.result.value as? [NSObject:AnyObject] else {
                    let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        complete?(gallery: nil, error: error)
                    })
                    return
                }
                
                let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete?(gallery: gallery, error: nil)
                })
            })
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func getWorkInformation(illustId:Int, complete:((illust:PixivIllust?, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "works/\(illustId).json"
        let parameters:[String:AnyObject] = [
            "profile_image_sizes": "px_170x170,px_50x50",
            "image_sizes": "px_128x128,small,medium,large,px_480mw",
            "include_stats": 1,
        ]
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(illust: nil, error: response.result.error)
                return
            }
            
            guard let value = response.result.value as? NSDictionary else {
                complete?(illust: nil, error: nil)
                return
            }
            
            
            guard let responses = value.objectForKey("response") as? NSArray else {
                complete?(illust: nil, error: nil)
                return
            }
            
            guard let source = responses.firstObject as? NSDictionary else {
                complete?(illust: nil, error: nil)
                return
            }
            
            guard let illustId = PixivIllust.createPixivIllust(source, isWork: true) else {
                complete?(illust: nil, error: nil)
                return
            }
            let illust = PixivIllust.getIllustWithId(illustId)
            complete?(illust:illust, error:nil)
        }
        if error != nil {
            complete?(illust:nil, error:error)
        }
    }
    
    public func getUserInfomation(userId:Int, complete:((profile:PixivProfile?, error:NSError?)->Void)?) {
        let url = PixivPAPIRoot + "users/\(userId).json"
        let parameters:[String:AnyObject] = [
            "profile_image_sizes": "px_170x170,px_50x50",
            "image_sizes": "px_128x128,small,medium,large,px_480mw",
            "include_stats": 1,
            "include_profile": 1,
            "include_workspace": 1,
            "include_contacts": 1,
        ]
        
        var error:NSError?
        self.authrizonRequest(.GET, url: url, parameters:parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(profile: nil, error: response.result.error)
                return
            }
            
            guard let value = response.result.value as? NSDictionary else {
                complete?(profile: nil, error: nil)
                return
            }
            
            guard let responses = value.objectForKey("response") as? NSArray else {
                complete?(profile: nil, error: nil)
                return
            }
            
            guard let response = responses.firstObject as? NSDictionary else {
                complete?(profile: nil, error: nil)
                return
            }
            
            let profile = PixivProfile.createProfile(response)
            complete?(profile: profile, error: nil)
        }
        if error != nil {
            complete?(profile: nil, error: error)
        }
    }
}

extension PixivProvider {
    private func createPagination(source:NSDictionary)->Pagination {
        var pagination = Pagination()
        pagination.per_page = source["per_page"] as? Int ?? -1
        pagination.total = source["total"] as? Int ?? -1
        pagination.current = source["current"] as? Int ?? -1
        pagination.next = source["next"] as? Int ?? -1
        pagination.previous = source["previous"] as? Int ?? -1
        return pagination
    }
    
    public func authrizonRequest(method: Alamofire.Method, url:String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = ParameterEncoding.URL, inout error:NSError?, completionHandler: Response<AnyObject, NSError> -> Void) {
        guard let accessToken = self.accessToken else {
            error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.AccessTokenEmpty._code, userInfo: [NSLocalizedDescriptionKey:"Authentication required! Call login: or set_session: first!"])
            return
        }
        
        guard let session = self.session else {
            error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.SessionEmpty._code, userInfo: [NSLocalizedDescriptionKey:"Authentication required! Call login: or set_session: first!"])
            return
        }
        
        var headers = PixivDefaultHeaders
        headers["Authorization"] = "Bearer \(accessToken)"
        headers["Cookie"] = "PHPSESSID=\(session)"
        
        request(method, url, parameters: parameters, encoding: encoding, headers: headers).responseJSON(completionHandler: completionHandler)
    }
    
    private func requestUrl(method:String = "GET", url:String, headers:[String:String]?, parameters:[String:String]?, content:[String:String]?)throws->ResponseWrapper {
        let request = NSMutableURLRequest()
        request.HTTPMethod = method
        request.timeoutInterval = MaxPixivAPIFetchTimeout
        
        //headers
        for (key, value) in self.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let _headers = headers {
            for (key, value) in _headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // url
        var requestUrl = url
        if let urlParameters = parameters?.buildUrlParameters() {
            requestUrl = "\(requestUrl)?\(urlParameters)"
        }
        request.URL = NSURL(string: requestUrl)
        
        //body
        if let payload = content?.buildUrlParameters() {
            request.HTTPBody = payload.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        // request
        var response:NSURLResponse?
        let responseData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        let httpResponse = response as! NSHTTPURLResponse
        return ResponseWrapper(header: httpResponse.allHeaderFields, responseData: responseData)
    }
}
