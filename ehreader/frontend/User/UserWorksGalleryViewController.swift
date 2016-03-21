//
//  UserWorksGalleryViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

protocol UserWorksGalleryViewControllerDelegate:NSObjectProtocol {
    func onLoadingFinished(viewController:UserWorksGalleryViewController)
    
    func onLoadLayoutFinished(collectionView: UICollectionView, contentSize:CGSize)
}

class UserWorksGalleryViewController: GalleryWaterFlowViewController {
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIConstants.GrayBackgroundColor
        super.viewDidLoad()
        backgroundView.addTarget(self, action: #selector(UserWorksGalleryViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        startLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.onLoadingFinished(self)
        
        footerView.refreshingBlock = { ()->() in
            self.currentPage += 1
            self.startLoading(self.currentPage)
        }
    }
    
    var profile:PixivProfile?
    
    weak var delegate:UserWorksGalleryViewControllerDelegate?
    
    func startLoading(page:Int = 1) {
        if let profile = self.profile {
            pixivProvider.usersWorks(profile.id, complete: { (gallery, error) in
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
                self.delegate?.onLoadingFinished(self)
                
                if self.footerView.loading {
                    self.footerView.stopRefreshing()
                }
            })
        }
    }
    
    func onLoadLayoutFinished(collectionView: UICollectionView, contentSize: CGSize) {
        self.delegate?.onLoadLayoutFinished(collectionView, contentSize: contentSize)
    }
}
