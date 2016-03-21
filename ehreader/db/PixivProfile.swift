//
//  PixivProfile.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/18.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import Foundation

public class PixivProfile: NSObject {
    //basic
    public var account:String?
    public var name:String?
    public var id:Int = -1
    public var is_follower:Bool = false
    public var is_following:Bool = false
    public var is_friend:Bool = false
    public var is_premium:Bool = false
    
    public var profile_image_urls_px_16x16:String?
    public var profile_image_urls_px_50x50:String?
    public var profile_image_urls_px_170x170:String?
    
    public var favorites:Int = 0
    public var following:Int = 0
    public var friends:Int = 0
    public var works:Int = 0
    
    //profile
    public var birth_date:String?
    public var blood_type:String?
    public var contacts:[String:String]?
    public var gender:String?
    public var homepage:String?
    public var introduction:String?
    public var job:String?
    public var tags:String?
    public var location:String?
    
    //workspace
    public var chair:String?
    public var computer:String?
    public var image_url:String?
    public var image_urls:String?
    public var monitor:String?
    public var mouse:String?
    public var music:String?
    public var on_table:String?
    public var other:String?
    public var printer:String?
    public var scanner:String?
    public var software:String?
    public var table:String?
    public var tablet:String?
    
    public static func createProfile(dataSource:NSDictionary)->PixivProfile? {
        guard let id = dataSource.objectForKey("id") as? Int else {
            return nil
        }
        
        print(dataSource)
        
        let pixivProfile = PixivProfile()
        pixivProfile.account = dataSource.objectForKey("account") as? String
        pixivProfile.name = dataSource.objectForKey("name") as? String
        pixivProfile.id = id
        pixivProfile.is_follower = dataSource.objectForKey("is_follower") as? Bool ?? false
        pixivProfile.is_following = dataSource.objectForKey("is_following") as? Bool ?? false
        pixivProfile.is_friend = dataSource.objectForKey("is_friend") as? Bool ?? false
        pixivProfile.is_premium = dataSource.objectForKey("is_premium") as? Bool ?? false
        
        if let stats = dataSource.objectForKey("stats") as? NSDictionary {
            pixivProfile.favorites = stats.objectForKey("favorites") as? Int ?? 0
            pixivProfile.following = stats.objectForKey("following") as? Int ?? 0
            pixivProfile.friends = stats.objectForKey("friends") as? Int ?? 0
            pixivProfile.works = stats.objectForKey("works") as? Int ?? 0
        }
        
        if let profile_image_urls = dataSource.objectForKey("profile_image_urls") as? NSDictionary  {
            pixivProfile.profile_image_urls_px_16x16 = profile_image_urls.objectForKey("px_16x16") as? String
            pixivProfile.profile_image_urls_px_50x50 = profile_image_urls.objectForKey("px_50x50") as? String
            pixivProfile.profile_image_urls_px_170x170 = profile_image_urls.objectForKey("px_170x170") as? String
        }
        
        if let profile = dataSource.objectForKey("profile") as? NSDictionary  {
            pixivProfile.birth_date = profile.objectForKey("birth_date") as? String
            pixivProfile.blood_type = profile.objectForKey("blood_type") as? String
            pixivProfile.contacts = profile.objectForKey("contacts") as? [String:String]
            pixivProfile.gender = profile.objectForKey("gender") as? String
            pixivProfile.homepage = profile.objectForKey("homepage") as? String
            pixivProfile.introduction = profile.objectForKey("introduction") as? String
            pixivProfile.job = profile.objectForKey("job") as? String
            pixivProfile.location = profile.objectForKey("location") as? String
            pixivProfile.tags = profile.objectForKey("tags") as? String
        }
        
        return pixivProfile
    }
}
