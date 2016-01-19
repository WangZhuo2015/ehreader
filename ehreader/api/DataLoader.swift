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

private let TimeoutInterval:NSTimeInterval = 10

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
    case GIDLIST_EMPTY
    case NETWORK_ERROR
}

let DataLoaderErrorDomain = "DataLoaderErrorDomain"

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
    
    public func callApi(method:ApiMethod, parameter:[String:AnyObject], completionHandler: Response<AnyObject, NSError> -> Void) {
        let url = isLoggedIn() ? API_URL_EX : API_URL
        
        var parameters:[String:AnyObject] = parameter
        parameters["method"] = method.rawValue
        
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
    public func getGallery(base:String, page:Int = 0, complete:((galleries:[Gallery], error:NSError?)->Void)?) {
        let url = "\(base)?page=\(page)"
        httpManager.request(.GET, url).responseString { (response:Response<String, NSError>) -> Void in
            if response.result.error != nil {
                complete?(galleries:[], error: response.result.error)
            }
            
            var gidlist:[[String]] = []
            if let responseString = response.result.value {
                //print(responseString)
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
    public func getGalleryList(gidlist:[[String]], complete:((galleries:[Gallery], error:NSError?)->Void)?) {
        if gidlist.isEmpty {
            let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.GIDLIST_EMPTY._code, userInfo: [NSLocalizedDescriptionKey:"gid list is empty"])
            complete?(galleries: [], error:error)
        }
        
        let parameter = ["gidlist":gidlist]
        self.callApi(ApiMethod.gdata, parameter: parameter) { (response:Response<AnyObject, NSError>) -> Void in
            let realm = try! Realm()
            var galleries:[Gallery] = []
            
            if response.result.error != nil {
                complete?(galleries:galleries, error: response.result.error)
                return
            }
            
            guard let result = response.result.value as? [NSObject:AnyObject] else{
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.API_ERROR._code, userInfo: [NSLocalizedDescriptionKey:"response is empty"])
                complete?(galleries: galleries, error:error)
                return
            }
            
            if let errorStr = result["error"] as? String {
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.API_ERROR._code, userInfo: [NSLocalizedDescriptionKey:errorStr])
                complete?(galleries: galleries, error:error)
            }
            
            guard let gmetadata = result["gmetadata"] as? [[String:AnyObject]] else{
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.API_ERROR._code, userInfo: [NSLocalizedDescriptionKey:"gmetadata is empty"])
                complete?(galleries: galleries, error:error)
                return
            }
            
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
            complete?(galleries: galleries, error:nil)
        }
    }
    
    /**
     account to the gallery id to get all the photo list
     
     - parameter galleryId: gallery id
     - parameter page:
     - parameter complete:
     */
    public func getPhotoList(galleryId:Int, page:Int, complete:((photos:[Photo], error:NSError?)->Void)?) {
        let realm = try! Realm()
        if let gallery = realm.objects(Gallery).filter("id = \(galleryId)").first {
            getPhotoListWithGallery(gallery, page: page, complete: complete)
        }else {
            let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.GALLERY_NOT_EXIST._code, userInfo: [NSLocalizedDescriptionKey:"gallery with galler id:\(galleryId) not exist"])
            complete?(photos: [], error:error)
        }
    }
    
    /**
     According to the gallery to get all the photo list
     
     - parameter gallery:  gallery model from the database
     - parameter page: note this page is not the normal photo page number, page = photoPage/PHOTO_PER_PAGE
     - parameter complete: The complete closure
     */
    public func getPhotoListWithGallery(gallery:Gallery, page:Int, complete:((photos:[Photo], error:NSError?)->Void)?) {
        let uri = gallery.getUri(page, ex: isLoggedIn())
        print("request uri:\(uri)")

        httpManager.request(.GET, uri).responseString { (response:Response<String, NSError>) -> Void in
            var photoes:[Photo] = []
            
            if response.result.error != nil {
                complete?(photos: photoes, error: response.result.error)
                return
            }
            
            guard let responseString = response.result.value else{
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.API_ERROR._code, userInfo: [NSLocalizedDescriptionKey:"response is empty"])
                complete?(photos: photoes, error: error)
                return
            }
            
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
//                        try! realm.write({ () -> Void in
//                            photo.token = token
//                        })
                        photoes.append(photo)
                    }else {
                        let photo = Photo()
                        photo.token = token
                        photo.page = photoPage
                        photo.downloaded = false
                        photo.bookmarked = false
                        photo.invalid = false
                        
                        try! realm.write {
                            realm.add(photo, update: true)
                            gallery.photos.append(photo)
                        }
                        photoes.append(photo)
                    }
                    
                }//if
            }//for
            complete?(photos: photoes, error:nil)
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
    
    /**
     Fetch the single photo information from api
     
     - parameter gallery:   gallery of this photoes
     - parameter page: the real page number
     - parameter complete:  complet closure
     */
    public func getPhotoInfo(gallery:Gallery, page:Int, complete:((photo:Photo?, error:NSError?)->Void)?) {
        var photo = self.getPhotoFromCacheWithGallery(gallery, photoPage: page)
        if photo != nil {
            return getPhotoInfo(gallery, photo: photo!, complete: complete)
        }
        
        let galleryPage = page/PHOTO_PER_PAGE
        self.getPhotoListWithGallery(gallery, page: galleryPage) { (photos, error) -> Void in
            if photos.isEmpty {
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.PHOTO_NOT_EXIST._code, userInfo: [NSLocalizedDescriptionKey:"can' t find this page's photo"])
                complete?(photo: nil, error: error)
                return
            }
            var index = (page - 1)%PHOTO_PER_PAGE
            
            index = (index >= photos.count) ? (photos.count - 1) : index
            index = (index < 0) ? 0 : index
            
            photo = photos[index]
            if photo != nil {
                return self.getPhotoInfo(gallery, photo: photo!, complete: complete)
            }else {
                let error = NSError(domain: DataLoaderErrorDomain, code: ApiError.PHOTO_NOT_EXIST._code, userInfo: [NSLocalizedDescriptionKey:"can' t find this page's photo"])
                complete?(photo: nil, error: error)
            }
        }
    }
    
    /**
     Update the photo information, include the photo's src, filename, file size
     
     - parameter gallery:
     - parameter photo:
     - parameter complete:
     */
    public func getPhotoInfo(gallery:Gallery, photo:Photo, complete:((photo:Photo?, error:NSError?)->Void)?) {
        if photo.src != nil && !photo.src!.isEmpty && !photo.invalid {
            complete?(photo:photo, error:nil)
            return
        }
        
        var showKey:String!
        
        do {
            showKey = try self.getShowkey(gallery)
        }catch let error as NSError {
            print("get photo error, show key does not exist")
            complete?(photo: photo, error: error)
            return
        }
        
        var parameter:[String:AnyObject] = [String:AnyObject]()
        parameter["gid"] = gallery.id
        parameter["page"] = photo.page
        parameter["imgkey"] = photo.token
        parameter["showkey"] = showKey
        callApi(ApiMethod.showpage, parameter: parameter) { (response:Response<AnyObject, NSError>) -> Void in
            if let result = response.result.value as? [NSObject:AnyObject] {
                let content = result["i3"] as! String
                
                var filename:String = ""
                var src:String = ""
                let regex = try! RegexHelper(pattern: pImageSrc)
                let matches = regex.matches(content)
                for match in matches {
                    filename = match[2]
                    src = match[1] + "/" + filename
                }
                
                
                if filename.isEmpty || src.isEmpty {
                    let error = NSError(domain: "getPhotoInfo", code: ApiError.PHOTO_NOT_FOUND._code, userInfo: [NSLocalizedDescriptionKey:"get photo source failed"])
                    complete?(photo:nil, error: error)
                    return
                }
                
                let realm = try! Realm()
                try! realm.write({ () -> Void in
                    photo.src = src
                    photo.filename = filename
                    photo.width = Int(result["x"] as! String)!
                    photo.height = Int(result["y"] as! String)!
                    photo.invalid = false
                })
                
                complete?(photo:photo, error:nil)
            }
        }
    }
    
    private func generalImageSource(content:String)->(String?, String?) {
        let regex = try! RegexHelper(pattern: pImageSrc)
        let matches = regex.matches(content)
        for match in matches {
            let filename = match[2]
            let src = match[1] + "/" + filename
            return (filename, src)
        }
        return (nil, nil)
    }
    
    /**
     Get the show key for the gallery, without this key, you can not get the detail photoes
     
     - parameter gallery:
     
     - returns: The show key, it will update the gallery automatically
     */
    public func getShowkey(gallery:Gallery)throws->String {
        guard let photo = gallery.photos.first else {
            throw ApiError.PHOTO_NOT_FOUND
        }
        
        let url = photo.getUrl()!
        print("Get show key url:\(url)")
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: TimeoutInterval)
        var response:NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        guard let content = String(data: data, encoding: NSUTF8StringEncoding) else{
            throw ApiError.IO_ERROR
        }
        print("Get show key callback:\(content)")
        if content.containsString("This gallery is pining for the fjords") {
            throw ApiError.GALLERY_PINNED
        }else if content.containsString("Invalid page.") {
            //TODO retry
        }
        let regex = try RegexHelper(pattern: pShowkey)
        guard let matches = regex.matches(content).first else{
            throw ApiError.SHOWKEY_NOT_FOUND
        }
        var showKey = ""
        if matches.count >= 2 {
            showKey = matches[1]
        }else {
            throw ApiError.SHOWKEY_NOT_FOUND
        }
        
        //update gallery
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            gallery.showkey = showKey
        })
        return showKey
    }
}
