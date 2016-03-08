//
//  PixivIllustGallery.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import RealmSwift

public class PixivIllustGallery: Object {
    public dynamic var count:Int = 0
    public let illusts = List<PixivIllust>()
    
    public dynamic var per_page:Int = 0
    public dynamic var total:Int = 0
    public dynamic var pages:Int = 0
    public dynamic var current:Int = 0
    public dynamic var next:Int = 0
    public dynamic var previous:Int = 0
    
    public static func createPixivIllustGallery(source:NSDictionary, isWork:Bool)->PixivIllustGallery? {
        guard let count = source["count"] as? Int else {
            return nil
        }
        
        guard let response = source["response"] as? [NSDictionary] else {
            return nil
        }
        
        guard let pagination = source["pagination"] as? NSDictionary else {
            return nil
        }
        
        let gallery = PixivIllustGallery()
        gallery.count = count
        gallery.per_page = pagination["per_page"] as? Int ?? 0
        gallery.total = pagination["total"] as? Int ?? 0
        gallery.current = pagination["current"] as? Int ?? 0
        gallery.next = pagination["next"] as? Int ?? 0
        gallery.previous = pagination["previous"] as? Int ?? 0
        
        let responseList:[NSDictionary]?
        if let list = response.first?.objectForKey("works") as? [NSDictionary]{
            responseList = list
        }else {
            responseList = response
        }
        
        let realm = try! Realm()
        try! realm.write { () -> Void in
            realm.create(PixivIllustGallery.self, value: gallery, update: false)
            if let illustGallery = responseList {
                for value in illustGallery {
                    if let illust = PixivIllust.createPixivIllust(value, isWork: isWork) {
                        realm.create(PixivIllust.self, value: illust, update: true)
                        gallery.illusts.append(illust)
                    }
                }
            }
        }
        
        return gallery
    }
}
