//
//  PixivIllustGallery.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class PixivIllustGallery: NSObject {
    public var count:Int = 0
    public var illusts:[PixivIllust] = []
    
    public var per_page:Int = 0
    public var total:Int = 0
    public var pages:Int = 0
    public var current:Int = 0
    public var next:Int = 0
    public var previous:Int = 0
    public var mergePages:[Int] = []
    
    public func addIllusts(gallery:PixivIllustGallery) {
        if self.current == gallery.current {
            return
        }
        if self.mergePages.contains(gallery.current) {
            return
        }
        self.illusts.appendContentsOf(gallery.illusts)
        self.mergePages.append(gallery.current)
    }
    
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
        gallery.mergePages.append(gallery.current)
        
        let responseList:[NSDictionary]?
        if let list = response.first?.objectForKey("works") as? [NSDictionary]{
            responseList = list
        }else {
            responseList = response
        }
        
        if let illustGallery = responseList {
            for value in illustGallery {
                if let illust = PixivIllust.createPixivIllust(value, isWork: isWork) {
                    gallery.illusts.append(illust)
                }
            }
        }
        
        return gallery
    }
}
