//
//  DataLoader.swift
//  ehreader
//
//  Created by yrtd on 15/11/16.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

public let pGalleryUrl = "http://(g\\.e-|ex)hentai\\.org/g/(\\d+)/(\\w+)"
public let pPhotoUrl = "http://(g\\.e-|ex)hentai\\.org/s/(\\w+?)/(\\d+)-(\\d+)"
public let pShowkey = "var showkey.*=.*\"([\\w-]+?)\";"
public let pImageSrc = "<img id=\"img\" src=\"(.+)/(.+?)\""
public let pGalleryURL = "<a href=\"http://(g\\.e-|ex)hentai\\.org/g/(\\d+)/(\\w+)/\" onmouseover"

public enum ApiError:ErrorType {
    case GALLERY_NOT_EXIST
    case PHOTO_NOT_EXIST
    case PHOTO_DATA_REQUIRED
    case SHOWKEY_INVALID
    case SHOWKEY_NOT_FOUND
    case API_ERROR
    case IO_ERROR
    case JSON_ERROR
    case PHOTO_NOT_FOUND
    case TOKEN_NOT_FOUND
    case TOKEN_OR_PAGE_INVALID
    case TOKEN_INVALID
    case SHOWKEY_EXPIRED
    case GALLERY_PINNED
}

/**
 to see http://ehwiki.org/wiki/API
 
 - gdata:
 - gtoken:
 */
public enum ApiMethod:String {
    case gdata = "gdata"
    case gtoken = "gtoken"
}

public class DataLoader: NSObject {
    public static func getInstance()->DataLoader {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: DataLoader = DataLoader()
    }
    
    public override init() {
        httpManager = Manager.sharedInstance
        loginHelper = LoginHelper.getInstance()
        super.init()
    }
    
    private let httpManager:Manager
    private let loginHelper:LoginHelper
    
    
    private func setupHttpContext() {
    }
    
    public func isLoggedIn()->Bool {
        return loginHelper.isLoggedIn()
    }
    
    public func callApi(method:ApiMethod, gidlist:[[String]], completionHandler: Response<AnyObject, NSError> -> Void) {
        let url = isLoggedIn() ? API_URL_EX : API_URL
        
        let parameters:[String:AnyObject] = [
            "method": method.rawValue,
            "gidlist": gidlist
        ]
        
        httpManager.request(.POST, url, parameters: parameters, encoding: ParameterEncoding.JSON, headers: nil).responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            completionHandler(response)
        }
    }
    
    public func getGallery(base:String, page:Int, complete:(galleries:[Gallery])->Void) {
        let url = "\(base)?page=\(page)"
        httpManager.request(.GET, url).responseString { (response:Response<String, NSError>) -> Void in
            var gidlist:[[String]] = []
            if let responseString = response.result.value {
                print(responseString)
                let regex = try! RegexHelper(pattern: pGalleryURL)
                let results = regex.matches(responseString)
                for result in results {
                    let id = result[2]
                    let token = result[3]
                    gidlist.append([id, token])
                }
                self.getGalleryList(gidlist, complete: complete)
            }
        }
    }
    
    public func getGalleryList(gidlist:[[String]], complete:(galleries:[Gallery])->Void) {
        if gidlist.isEmpty {
            complete(galleries: [])
        }
        self.callApi(ApiMethod.gdata, gidlist: gidlist) { (response:Response<AnyObject, NSError>) -> Void in
            let realm = try! Realm()
            var galleries:[Gallery] = []
            if let result = response.result.value as? [NSObject:AnyObject] {
                if let error = result["error"] as? String {
                    print(error)
                    complete(galleries: [])
                }
                if let gmetadata = result["gmetadata"] as? [[String:AnyObject]] {
                    for values in gmetadata {
                        if let id = values["gid"]?.longValue {
                            if values["expunged"]?.boolValue ?? false {
                                continue
                            }
                            realm.objects(Gallery).filter("id = \(id)")
                            
                            var gallery = realm.objects(Gallery).filter("id = \(id)").first
                            if gallery == nil {
                                gallery = Gallery()
                                gallery!.id = id
                            }
                            
                            gallery!.fillValues(values)
                            try! realm.write {
                                realm.add(gallery!, update: true)
                            }
                            galleries.append(gallery!)
                        }
                    }
                }
            }
            complete(galleries: galleries)
        }
    }
    
    public func getPhotoList(galleryId:Int, page:Int, complete:(photos:[Photo])->Void) {
        let realm = try! Realm()
        if let gallery = realm.objects(Gallery).filter("id = \(galleryId)").first {
            getPhotoListWithGallery(gallery, page: page, complete: complete)
        }else {
            complete(photos: [])
        }
    }
    
    public func getPhotoListWithGallery(gallery:Gallery, page:Int, complete:(photos:[Photo])->Void) {
        let uri = gallery.getUri(page, ex: isLoggedIn())

        httpManager.request(.GET, uri).responseString { (response:Response<String, NSError>) -> Void in
            if let responseString = response.result.value {
                print(responseString)
                let regularExpression = try! NSRegularExpression(pattern: pPhotoUrl, options: NSRegularExpressionOptions.AllowCommentsAndWhitespace)
                let range = NSRange(location: 0, length: responseString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                let matches = regularExpression.matchesInString(responseString, options: NSMatchingOptions.Anchored, range: range)
                for result in matches {
                    result.rangeAtIndex(2)
                }
            }
        }
    }
}
