//
//  PixivUser.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import RealmSwift

public class PixivUser: Object {
    public dynamic var id:String = "-1"
    
    public dynamic var access_token:String?
    
    public dynamic var expires_in:NSDate = NSDate()
    
    public dynamic var token_type:String?
    
    public dynamic var scope:String?
    
    public dynamic var refresh_token:String?
    
    public dynamic var profile_image_urls_px_16x16:String?
    
    public dynamic var profile_image_urls_px_50x50:String?
    
    public dynamic var profile_image_urls_px_170x170:String?
    
    public dynamic var name:String?
    
    public dynamic var account:String?
    
    public dynamic var session:String?
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    static func createPixivUser(source:[NSObject:AnyObject], session:String?)->PixivUser {
        let pixivUser = PixivUser()
        pixivUser.access_token = source["access_token"] as? String
        pixivUser.session = session
        let expiresIn = source["expires_in"] as? NSTimeInterval ?? 0
        pixivUser.expires_in = NSDate().dateByAddingTimeInterval(expiresIn)
        pixivUser.token_type = source["token_type"] as? String
        pixivUser.scope = source["scope"] as? String
        pixivUser.refresh_token = source["refresh_token"] as? String
        if let user = source["user"] as? [NSObject:AnyObject] {
            pixivUser.id = user["id"] as? String ?? "-1"
            pixivUser.name = user["name"] as? String
            pixivUser.account = user["account"] as? String
            if let profile_image_urls = user["profile_image_urls"] as? [String: String] {
                pixivUser.profile_image_urls_px_16x16 = profile_image_urls["px_16x16"]
                pixivUser.profile_image_urls_px_170x170 = profile_image_urls["px_170x170"]
                pixivUser.profile_image_urls_px_50x50 = profile_image_urls["px_50x50"]
            }
        }
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            realm.create(PixivUser.self, value: pixivUser, update: true)
        })
        return pixivUser
    }
    
    static func isLoginExpires(username:String)->Bool {
        let realm = try! Realm()
        if let user = realm.objects(PixivUser).filter("account='\(username)'").first {
            if user.session == nil || user.access_token == nil {
                return true
            }
            print(user.expires_in.timeIntervalSinceNow)
            if user.expires_in.timeIntervalSinceNow < 0 {
                return true
            }
            return false
        }
        return true
    }
    
    static func currentLoginUser()->PixivUser? {
        let realm = try! Realm()
        
        let users = realm.objects(PixivUser)
        return users[0]
    }
}
