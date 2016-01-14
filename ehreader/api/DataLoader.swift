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
    case showpage = "showpage"
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
    
    public func callApi(method:ApiMethod, parameter:AnyObject, completionHandler: Response<AnyObject, NSError> -> Void) {
        let url = isLoggedIn() ? API_URL_EX : API_URL
        
        let parameters:[String:AnyObject] = [
            "method": method.rawValue,
            "gidlist": parameter
        ]
        
        httpManager.request(.POST, url, parameters: parameters, encoding: ParameterEncoding.JSON, headers: nil).responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            completionHandler(response)
        }
    }
    
    /**
     Fetch the gallery list, this method will cached the data
     
     - parameter base:     The base url
     - parameter page:     page of the gallery
     - parameter complete: complete closure
     */
    public func getGallery(base:String, page:Int, complete:((galleries:[Gallery])->Void)?) {
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
    
    /**
     When you know the gid list, you can call the this method to get the gallery list, it will cahce the data automatically
     
     - parameter gidlist:
     - parameter complete: complete closure
     */
    public func getGalleryList(gidlist:[[String]], complete:((galleries:[Gallery])->Void)?) {
        if gidlist.isEmpty {
            complete?(galleries: [])
        }
        self.callApi(ApiMethod.gdata, parameter: gidlist) { (response:Response<AnyObject, NSError>) -> Void in
            let realm = try! Realm()
            var galleries:[Gallery] = []
            if let result = response.result.value as? [NSObject:AnyObject] {
                if let error = result["error"] as? String {
                    print(error)
                    complete?(galleries: [])
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
            complete?(galleries: galleries)
        }
    }
    
    /**
     account to the gallery id to get all the photo list
     
     - parameter galleryId: gallery id
     - parameter page:
     - parameter complete:
     */
    public func getPhotoList(galleryId:Int, page:Int, complete:((photos:[Photo])->Void)?) {
        let realm = try! Realm()
        if let gallery = realm.objects(Gallery).filter("id = \(galleryId)").first {
            getPhotoListWithGallery(gallery, page: page, complete: complete)
        }else {
            complete?(photos: [])
        }
    }
    
    /**
     According to the gallery to get all the photo list
     
     - parameter gallery:  gallery model from the database
     - parameter page:
     - parameter complete: 
     */
    public func getPhotoListWithGallery(gallery:Gallery, page:Int, complete:((photos:[Photo])->Void)?) {
        let uri = gallery.getUri(page, ex: isLoggedIn())
        print("request uri:\(uri)")

        httpManager.request(.GET, uri).responseString { (response:Response<String, NSError>) -> Void in
            let photoes:[Photo] = []
            if let responseString = response.result.value {
                print(responseString)
                let regex = try! RegexHelper(pattern: pPhotoUrl)
                let matches = regex.matches(responseString)
                //here the result is like [0] : "http://g.e-hentai.org/s/11a30da13e/893685-1"
                // [1] : "g.e-"
                // [2] : "11a30da13e"  this is token
                // [3] : "893685"
                // [4] : "1" this is photo page
                for result in matches {
                    let token = result[2]
                    if let  photoPage = Int(result[4]) {
                        print("Photo found: {galleryId: \(gallery.id), token: \(token), page: \(photoPage)}")
                        let realm = try! Realm()
                        if let photo = self.getPhotoFromCacheWithGallery(gallery, photoPage: photoPage) {
                            try! realm.write({ () -> Void in
                                photo.token = token
                            })
                        }else {
                            let photo = Photo()
                            photo.token = token
                            photo.page = photoPage
                            photo.downloaded = false
                            photo.bookmarked = false
                            photo.invalid = false
                            gallery.photos.append(photo)
                            try! realm.write {
                                realm.add(photo)
                            }
                            
                        }
                    }//if
                }//for
            }//if
            complete?(photos: photoes)
        }
    }
    
    /**
     Fetch the photo from database
     
     - parameter galleryId:
     - parameter photoId:
     
     - returns: photo
     */
    public func getPhotoFromCacheWithGalleryId(galleryId:Int, photoPage:Int)->Photo? {
        let realm = try! Realm()
        if let gallery = realm.objects(Gallery).filter("id = \(galleryId)").first {
            for photo in gallery.photos {
                if photo.page == photoPage {
                    return photo
                }
            }
        }
        return nil
    }
    
    public func getPhotoFromCacheWithGallery(gallery:Gallery, photoPage:Int)->Photo? {
        for photo in gallery.photos {
            if photo.page == photoPage {
                return photo
            }
        }
        return nil
    }
    
    public func getPhotoInfo() {
    }
}
