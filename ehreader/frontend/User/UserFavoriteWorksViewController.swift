//
//  UserFavoriteWorksViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class UserFavoriteWorksViewController: GalleryWaterFlowViewController {
    var currentPublicity:PixivPublicity = PixivPublicity.Public
    
    weak var delegate:UserWorksGalleryViewControllerDelegate?
    
    var profile:PixivProfile?
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        startLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.currentPage += 1
                self!.startLoading(self!.currentPage)
            }
        }
    }
    
    deinit {
        print("deinit UserFavoriteWorksViewController")
    }
    
    func startLoading(page:Int = 1) {
        guard let profile = self.profile else {
            return
        }
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if self.isLoadingFinished {
            return
        }
        
        pixivProvider.usersFavoriteWorks(profile.id, page: page) { (gallery, error) in
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
            
            if let g = self.gallery {
                if g.next == -1 {
                    self.footerView.setNoMoreLoading()
                }
            }
        }
    }
    
    func onLoadLayoutFinished(collectionView: UICollectionView, contentSize: CGSize) {
        self.delegate?.onLoadLayoutFinished(collectionView, contentSize: contentSize)
    }
}
