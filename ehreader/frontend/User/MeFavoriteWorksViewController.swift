//
//  MeFavoriteWorksViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/18.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Kingfisher

class MeFavoriteWorksViewController: GalleryWaterFlowViewController {
    var currentPublicity:PixivPublicity = PixivPublicity.Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backgroundView.addTarget(self, action: #selector(LatestGalleryViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        startLoading(publicity: self.currentPublicity)
    }
    
    deinit {
        print("deinit MeFavoriteWorksViewController")
        KingfisherManager.sharedManager.cache.clearMemoryCache()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.refreshingBlock = { [weak self] ()->() in
            if self != nil {
                self!.startLoading(self!.currentPage, publicity: self!.currentPublicity)
            }
            
        }
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.currentPage += 1
                self!.startLoading(self!.currentPage, publicity: self!.currentPublicity)
            }
        }
    }
    
    func startLoading(page:Int = 1, publicity:PixivPublicity) {
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        pixivProvider.meFavoriteWorks(publicity: publicity) { (gallery, error) in
            if error != nil || gallery == nil{
                print("loading choice data failed:\(error!.localizedDescription)")
                self.backgroundView.status = BackgroundViewStatus.Failed
                return
            }
            
            if self.gallery == nil {
                self.gallery = gallery
            }else {
                self.gallery?.addIllusts(gallery!)
            }
            
            self.collectionView.reloadData()
            self.backgroundView.status = BackgroundViewStatus.Hidden
            
            if self.footerView.loading {
                self.footerView.stopRefreshing()
            }
            
            if self.headerView.loading {
                self.headerView.stopRefreshing()
            }
        }
    }
}
