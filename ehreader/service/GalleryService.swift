//
//  GalleryService.swift
//  ehreader
//
//  Created by yrtd on 15/11/20.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

public class GalleryService: NSObject {
    private var galleries:[Gallery] = []
    
    public override init() {
        super.init()
    }
    
    public func startLoading(page:Int = 0, completeHandler:()->Void) {
        let baseUrl = LoginHelper.getInstance().isLoggedIn() ? BASE_URL_EX : BASE_URL
        DataLoader.getInstance().getGallery(baseUrl, page: page) { (galleries) -> Void in
            let realm = try! Realm()
//            for gallery in realm.objects(Gallery) {
//                //Get the cache image
//                if let thumbnail = gallery.thumbnail {
//                    KingfisherManager.sharedManager.retrieveImageWithURL(NSURL(string: thumbnail)!, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
//                        gallery.image = image
//                        self.galleries.append(gallery)
//                        completeHandler()
//                    })
//                    
//                }
//            }
        
        }
    }
    
    public func count(page:Int = 0)->Int {
        return galleries.count
    }
    
    public func getGallery(indexPath:NSIndexPath)->Gallery {
        return galleries[indexPath.row]
    }
}
