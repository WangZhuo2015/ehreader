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

let GalleryPageCount = 20

public class GalleryService: NSObject {
    private var galleries:[Gallery] = []
    
    public override init() {
        super.init()
    }
    
    public func startLoading(page:Int = 0, completeHandler:((galleries:[Gallery], error:NSError?)->Void)?) {
        let baseUrl = LoginHelper.getInstance().isLoggedIn() ? BASE_URL_EX : BASE_URL
        DataLoader.getInstance().getGallery(baseUrl, page: page) { (galleries, error) -> Void in
            if error != nil {
                //Can't fetch data from web, we load the local cache
                let realm = try! Realm()
                let galleriesCache = realm.objects(Gallery.self)
                for index in 0..<GalleryPageCount {
                    let gallery = galleriesCache[index]
                    self.galleries.append(gallery)
                }
                completeHandler?(galleries:self.galleries, error:error)
                return
            }
            self.galleries = galleries
            completeHandler?(galleries: self.galleries, error: error)
        }
    }
    
    public func count(page:Int = 0)->Int {
        return galleries.count
    }
    
    public func getGallery(indexPath:NSIndexPath)->Gallery {
        return galleries[indexPath.row]
    }
}
