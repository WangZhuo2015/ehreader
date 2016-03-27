//
//  SearchWaterFlowViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/23.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class SearchWaterFlowViewController: GalleryWaterFlowViewController {
    var currentPublicity:PixivPublicity = PixivPublicity.Public
    var isFinishLoading = false
    var currentQuery:String?
    var currentMode:PixivSearchMode = PixivSearchMode.ExactTag
    var currentOrder:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("deinit SearchWaterFlowViewController")
        KingfisherManager.sharedManager.cache.clearMemoryCache()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if let weakSelf = self {
                weakSelf.currentPage += 1
                if let query = weakSelf.currentQuery, order = weakSelf.currentOrder {
                    weakSelf.startSearching(query, page: weakSelf.currentPage, mode: weakSelf.currentMode, order: order)
                }
            }
        }
    }
    
    func startSearching(query:String, page:Int = 1, mode:PixivSearchMode = PixivSearchMode.ExactTag, order:String = "desc") {
        self.currentQuery = query
        self.currentPage = page
        self.currentMode = mode
        self.currentOrder = order
        isFinishLoading = false
        if self.isLoadingFinished {
            return
        }
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // Add search log
        SearchHistory.addHistory(query)
        
        pixivProvider.searchWorks(query, page: page, mode: mode, order: order) { (gallery, error) in
            if error != nil || gallery == nil{
                print("loading choice data failed:\(error?.localizedDescription)")
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
            self.isFinishLoading = true
            
            if let g = self.gallery {
                if g.next == -1 {
                    self.footerView.setNoMoreLoading()
                }
            }
        }
    }
}
