//
//  LatestGalleryViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class LatestGalleryViewController: GalleryWaterFlowViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "新作"
        backgroundView.addTarget(self, action: #selector(LatestGalleryViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        startLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.startLoading(self!.currentPage)
            }
        }
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.currentPage += 1
                self!.startLoading(self!.currentPage)
            }
        }
    }
    
    func startLoading(page:Int = 1) {
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        pixivProvider.getLastWorks(page) { (gallery, error) in
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
            
            if let g = self.gallery {
                if g.next == -1 {
                    self.footerView.setNoMoreLoading()
                }
            }
        }
    }
}
