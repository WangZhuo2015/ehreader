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

public enum PixivSearchMode:String {
    case ExactTag = "exact_tag"
    case Text = "text"
    case Title = "title"
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
        
        self.user = PixivUser.createPixivUser(response, session: self.session)
        
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
    public func getRankingAll(mode:PixivRankingMode, rankingType:PixivRankingType = PixivRankingType.All, page:Int, complete:((gallery:PixivIllustGallery?, error:NSError?)->Void)?) {
        
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
            if response.result.error != nil {
                complete?(gallery: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(gallery: nil, error: error)
                return
            }
            
            let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
            complete?(gallery: gallery, error: nil)
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func getLastWorks(page:Int = 1, perPage:Int = 30, includeStatus:Bool = true, includeSanityLevel:Bool = true, complete:((gallery:PixivIllustGallery?, error:NSError?)->Void)?) {
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
            if response.result.error != nil {
                complete?(gallery: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(gallery: nil, error: error)
                return
            }
            
            let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
            complete?(gallery: gallery, error: nil)
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func usersFavoriteWorks(userId:Int, page:Int = 1, perPage:Int = 30, includeSanityLevel:Bool = true, complete:((gallery:PixivIllustGallery?, error:NSError?)->Void)?) {
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
            if response.result.error != nil {
                complete?(gallery: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(gallery: nil, error: error)
                return
            }
            
            let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
            complete?(gallery: gallery, error: nil)
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
    
    public func meFavoriteWorks(page:Int = 1, perPage:Int = 50, publicity:PixivPublicity, complete:((gallery:PixivIllustGallery?, error:NSError?)->Void)?) {
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
            if response.result.error != nil {
                complete?(gallery: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(gallery: nil, error: error)
                return
            }
            
            let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: false)
            complete?(gallery: gallery, error: nil)
        }
        if error != nil {
            complete?(gallery: nil, error: error)
        }
    }
    
    public func searchWorks(query:String, page:Int = 1, perPage:Int = 30, mode:PixivSearchMode = PixivSearchMode.ExactTag, period:String = "all", order:String = "desc", sort:String = "date", complete:((gallery:PixivIllustGallery?, error:NSError?)->Void)?) {
        
        let url = PixivPAPIRoot + "works.json"
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
        
        var error:NSError?
        authrizonRequest(.GET, url: url, parameters: parameters, error: &error) { (response:Response<AnyObject, NSError>) in
            if response.result.error != nil {
                complete?(gallery: nil, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else {
                let error = NSError(domain: ErrorDomainPixivProvider, code: PixivError.ResultFormatInvalid._code, userInfo: [NSLocalizedDescriptionKey:"Result format is not right"])
                complete?(gallery: nil, error: error)
                return
            }
            
            let gallery = PixivIllustGallery.createPixivIllustGallery(result, isWork: true)
            complete?(gallery: gallery, error: nil)
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
            
            let illust = PixivIllust.createPixivIllust(source, isWork: true)
            complete?(illust:illust, error:nil)
        }
        if error != nil {
            complete?(illust:nil, error:error)
        }
    }
    
    public func getUserInfomation(userId:String, complete:((profile:PixivProfile?, error:NSError?)->Void)?) {
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
