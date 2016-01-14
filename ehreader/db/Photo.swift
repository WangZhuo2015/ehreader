//
//  Photo.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import Foundation
import RealmSwift

public class Photo: Object {
    public dynamic var page:Int = 0
    
    public dynamic var token:String = ""
    
    public dynamic var bookmark:String?
    
    public dynamic var filename:String?
    
    public dynamic var width:Int = 0
    
    public dynamic var height:Int = 0
    
    public dynamic var src:String?
    
    public dynamic var downloaded:Bool = false
    
    public dynamic var invalid:Bool = false
    
    public dynamic var bookmarked:Bool = false
    
    public var gallery:[Gallery] {
        return linkingObjects(Gallery.self, forProperty: "photos")
    }
    
    public override static func primaryKey() -> String? {
        return "token"
    }
    
    public func getUri(ex:Bool = false)->String {
        let base = ex ? PHOTO_URL_EX : PHOTO_URL
        //A photo add to cache, it must have to link to a gallery
        let galleryId = self.gallery.first!.id
        return String(format: base, arguments: [self.token, galleryId, self.page])
    }
    
    public func getUrl(ex:Bool = false)->NSURL? {
        return NSURL(string: self.getUri(ex))
    }
}
