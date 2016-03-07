//
//  Gallery.swift
//  ehreader
//
//  Created by yrtd on 15/11/17.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import Foundation
import RealmSwift

public enum GalleryCategory:String {
    case Doujinshi = "Doujinshi"
    case Manga = "Manga"
    case ArtistCG = "Artist CG Sets"
    case GameCG = "Game CG Sets"
    case Western = "Western"
    case NonH = "Non-H"
    case ImageSet = "Image Sets"
    case Cosplay = "Cosplay"
    case AsianPorn = "Asian Porn"
    case Misc = "Misc"
}

public func galleryCategoryName(category:GalleryCategory)->String {
    switch category {
    case .Doujinshi:
        return "Doujinshi"
    case .Manga:
        return "Manga"
    case .ArtistCG:
        return "Artist CG Sets"
    case .GameCG:
        return "Game CG Sets"
    case .Western:
        return "Western"
    case .NonH:
        return "Non-H"
    case .ImageSet:
        return "Image Sets"
    case .Cosplay:
        return "Cosplay"
    case .AsianPorn:
        return "Asian Porn"
    default:
        return "Misc"
    }
}

public class Gallery: Object {
    public dynamic var id = 0
    
    public dynamic var token:String = ""
    
    public dynamic var title:String?
    
    public dynamic var subtitle:String?
    
    public dynamic var category:String = GalleryCategory.Misc.rawValue
    
    public dynamic var count:Int = 0
    
    public dynamic var thumbnail:String?
    
    public dynamic var starred:Bool = false
    
    public dynamic var rating:Float = 0
    
    public dynamic var created:NSDate?
    
    public dynamic var lastread:NSDate?
    
    public dynamic var tags:String?
    
    public dynamic var uploader:String?
    
    public dynamic var progress:Int = 0
    
    public dynamic var showkey:String?
    
    public dynamic var size:Int = 0
    
    public dynamic var image:UIImage?
    
    public let photos = List<Photo>()
    
    override public static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    public func getUri(page:Int = 0, ex:Bool = false)->String {
        let base = ex ? GALLERY_URL_EX : GALLERY_URL
        let uri = String(format: base, arguments: [self.id, self.token])
        return "\(uri)?p=\(page)"
    }
    
    public func createTags(tags:[String]) {
        self.tags = tags.joinWithSeparator("|")
    }
    
    public func fillValues(values:[String:AnyObject]) {
        let realm = try! Realm()
        try! realm.write {
            self.token = values["token"] as! String
            self.title = values["title"] as? String
            self.subtitle = values["title_jpn"] as? String
            self.category = values["category"] as? String ?? GalleryCategory.Misc.rawValue
            self.thumbnail = values["thumb"] as? String
            self.count = values["filecount"]?.integerValue ?? 0
            self.rating = values["rating"]?.floatValue ?? 0
            self.uploader = values["uploader"] as? String
            if let tags = values["tags"] as? [String] {
                self.createTags(tags)
            }
            if let timeinterval = values["posted"]!.longValue {
                let posted = NSDate(timeIntervalSince1970: NSTimeInterval(timeinterval))
                self.created = posted
            }
            self.size = values["filesize"]?.longValue ?? 0
        }
    }
}


