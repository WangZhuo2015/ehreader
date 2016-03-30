//
//  PixivImageUrls.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/30.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class PixivImageUrl: NSObject {
    public var large:String?
    public var medium:String?
    public var px_128x128:String?
    public var px_480mw:String?
    
    public init(source:NSDictionary) {
        super.init()
        large = source.objectForKey("large") as? String
        medium = source.objectForKey("medium") as? String
        px_128x128 = source.objectForKey("px_128x128") as? String
        px_480mw = source.objectForKey("px_480mw") as? String
    }
    
    public static func createImageUrls(source:NSArray)->[PixivImageUrl] {
        var array:[PixivImageUrl] = [];
        for value in source {
            if let image_urls = value.objectForKey("image_urls") as? NSDictionary {
                array.append(PixivImageUrl(source: image_urls))
            }
        }
        return array
    }
}
