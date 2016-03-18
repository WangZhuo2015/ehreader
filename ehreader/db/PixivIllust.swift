//
//  PixivIllust.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import RealmSwift

public class PixivIllust: Object {
    public dynamic var illust_id:Int = -1
    public dynamic var title:String?
    public dynamic var type:String?
    public dynamic var page_count:Int = 0
    
    public dynamic var tags:String?
    public dynamic var caption:String?
    public dynamic var tools:String?
    
    public dynamic var age_limit:String?
    public dynamic var publicity:Int = 0
    public dynamic var is_manga:Bool = false
    
    public dynamic var favorited_private:Int = 0
    public dynamic var favorited_public:Int = 0
    public dynamic var views_count:Int = 0
    public dynamic var score:Int = 0
    public dynamic var scored_count:Int = 0
    public dynamic var commented_count:Int = 0
    
    public dynamic var favorite_id:Int = 0
    public dynamic var is_liked:Bool = false
    
    public dynamic var image_urls:String?
    public dynamic var url_px_128x128:String?
    public dynamic var url_px_480mw:String?
    public dynamic var url_large:String?
    public dynamic var url_small:String?
    public dynamic var url_medium:String?
    
    public dynamic var width:Int = 0
    public dynamic var height:Int = 0
    
    public dynamic var user:String?
    public dynamic var author_id:Int = -1
    public dynamic var account:String?
    public dynamic var name:String?
    public dynamic var is_friend:Bool = false
    public dynamic var is_following:Bool = false
    public dynamic var is_follower:Bool = false
    public dynamic var profile_image_urls:String?
    public dynamic var profile_url_px_50x50:String?
    public dynamic var profile_url_px_170x170:String?
    
    public dynamic var created_time:String?
    public dynamic var reuploaded_time:String?
    public dynamic var book_style:String?
    
    public dynamic var metadata:String?
    public dynamic var pages:String?
    
    public dynamic var true_url_large:String?
    
    public override static func primaryKey() -> String? {
        return "illust_id"
    }
    
    public func imageSize()->CGSize {
        return CGSizeMake(CGFloat(self.width), CGFloat(self.height))
    }
    
    public func getTags()->[String] {
        return self.tags?.componentsSeparatedByString(",") ?? []
    }
    
    public func getMediaImageUrl()->String? {
        if self.url_medium != nil && !self.url_medium!.isEmpty {
            return self.url_medium
        }
        return self.url_px_480mw
    }
    
    public static func createPixivIllust(source:NSDictionary, isWork:Bool)->PixivIllust? {
        var data:NSDictionary?
        print(source)
        if isWork {
            data = source
        }else {
            if let work = source["work"] as? NSDictionary {
                data = work
            }
        }
        if data == nil {
            print("unknow data: \(source)")
            return nil
        }
        if data!["id"] == nil || data!["title"] == nil {
            print("data.id or data.title not found")
            return nil
        }
        let illust = PixivIllust()
        illust.publicity = data!.objectForKey("publicity") as? Int ?? 0
        if let isManga = data!.objectForKey("is_manga")?.boolValue {
            illust.is_manga = isManga
        }else {
            illust.is_manga = false
        }
        if let stats = data?.objectForKey("stats") as? NSDictionary {
            if let favorited_count = stats.objectForKey("favorited_count") as? NSDictionary {
                illust.favorited_private = favorited_count.objectForKey("private") as? Int ?? 0
                illust.favorited_public = favorited_count.objectForKey("public") as? Int ?? 0
            }
            illust.score = stats.objectForKey("score") as? Int ?? 0
            illust.views_count = stats.objectForKey("views_count") as? Int ?? 0
            illust.scored_count = stats.objectForKey("scored_count") as? Int ?? 0
            illust.commented_count = stats.objectForKey("commented_count") as? Int ?? 0
        }
        illust.favorite_id = data?.objectForKey("favorite_id") as? Int ?? 0
        if let tags = data?.objectForKey("tags") as? NSArray {
            let tagString = tags.componentsJoinedByString(",")
            illust.tags = tagString
        }
        illust.type = data?.objectForKey("type") as? String
        illust.is_liked = data?.objectForKey("is_liked")?.boolValue ?? false
        illust.page_count = data?.objectForKey("page_count") as? Int ?? 0
        if let imageUrls = data?.objectForKey("image_urls") as? NSDictionary {
            illust.url_small = imageUrls.objectForKey("small") as? String
            illust.url_large = imageUrls.objectForKey("large") as? String
            illust.url_px_128x128 = imageUrls.objectForKey("px_128x128") as? String
            illust.url_medium = imageUrls.objectForKey("medium") as? String
            illust.url_px_480mw = imageUrls.objectForKey("px_480mw") as? String
        }
        illust.height = data?.objectForKey("height") as? Int ?? 0
        illust.caption = data?.objectForKey("caption") as? String
        if let tools = data?.objectForKey("tools") as? NSArray {
            illust.tools = tools.componentsJoinedByString(" ")
        }
        if let user = data?.objectForKey("user") as? NSDictionary {
            illust.account = user.objectForKey("account") as? String
            illust.name = user.objectForKey("name") as? String
            illust.is_friend = user.objectForKey("is_friend")?.boolValue ?? false
            illust.is_follower = user.objectForKey("is_follower")?.boolValue ?? false
            illust.is_following = user.objectForKey("is_following")?.boolValue ?? false
            illust.author_id = user.objectForKey("author_id")?.integerValue ?? 0
            if let profileImageUrls = user.objectForKey("profile_image_urls") as? NSDictionary {
                illust.profile_url_px_50x50 = profileImageUrls.objectForKey("px_50x50") as? String
                illust.profile_url_px_170x170 = profileImageUrls.objectForKey("px_170x170") as? String
            }
        }
        illust.reuploaded_time = data?.objectForKey("reuploaded_time") as? String
        illust.created_time = data?.objectForKey("created_time") as? String
        illust.title = data?.objectForKey("title") as? String
        illust.illust_id = data!.objectForKey("id")!.integerValue
        illust.book_style = data?.objectForKey("book_style") as? String
        illust.age_limit = data?.objectForKey("age_limit") as? String
        illust.width = data?.objectForKey("width")?.integerValue ?? 0
        if let metadata = data?.objectForKey("metadata") as? NSDictionary {
            if let pages = metadata.objectForKey("pages") as? NSArray {
                let firstObject = pages.firstObject as? NSDictionary
                let imageUrls = firstObject?.objectForKey("image_urls") as? NSDictionary
                illust.true_url_large = imageUrls?.objectForKey("large") as? String
            }
        }
        if illust.true_url_large == nil {
            if illust.page_count > 0 {
                if let url = illust.url_large {
                    if url.containsString("_p0") {
                        illust.true_url_large = illust.url_large
                    }else {
                        let ext = NSURL(string: url)!.pathExtension
                        let base = NSURL(string: url)!.URLByDeletingPathExtension?.absoluteString
                        illust.true_url_large = "\(base!)_p0\(ext!)"
                    }
                }
            }
        }
        return illust
    }
}
