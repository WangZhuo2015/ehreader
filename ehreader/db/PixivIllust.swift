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
    
    public dynamic var stats:String?
    public dynamic var favorited_count:String?
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
}
