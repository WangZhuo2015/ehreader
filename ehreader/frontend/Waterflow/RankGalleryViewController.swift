//
//  RankGalleryViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class RankGalleryViewController: GalleryWaterFlowViewController {
    private lazy var arrowTitleView:UIArrowTitleView = {
        let titleView = UIArrowTitleView(frame: CGRectZero)
        titleView.addTarget(self, action: #selector(RankGalleryViewController.onPresentPixivRanking(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return titleView
    }()
    
    private lazy var pixivRankingViewController:PixivRankingViewController = {
        let viewController = PixivRankingViewController()
        viewController.delegate = self
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrowTitleView.titleLabel.text = self.title
        self.navigationItem.titleView = self.arrowTitleView
        startLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.refreshingBlock = { ()->() in
            self.startLoading(self.rankingMode, page: self.currentPage)
        }
        
        footerView.refreshingBlock = { ()->() in
            self.currentPage += 1
            self.startLoading(self.rankingMode, page: self.currentPage)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationBar = self.navigationController?.navigationBar {
            let width = self.arrowTitleView.arrowTitleViewWidth
            let startX = (navigationBar.frame.width - width)/2
            let frame = CGRectMake(startX, 0, width, navigationBar.frame.height)
            arrowTitleView.frame = frame
        }
        
    }
    
    func startLoading(rankingMode:PixivRankingMode = PixivRankingMode.Daily, page:Int = 1) {
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        pixivProvider.getRankingAll(rankingMode, page: page) { (gallery, error) in
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
    
    func onPresentPixivRanking(sender:UIArrowTitleView) {
        if sender.arrowStatus == UIArrowTitleViewState.Down {
            presentDropdownController(self.pixivRankingViewController, height: self.view.frame.height, foldControl: sender, animated: false)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.hideTabbar(true)
            }
        }else {
            dismissDropdownController(self.pixivRankingViewController, height: self.view.frame.height, foldControl: sender, animated: true)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.displayTabbar(true)
            }
        }
    }
}


extension RankGalleryViewController: PixivRankingViewControllerDelegate {
    func pixivRankingViewController(viewController: PixivRankingViewController, didSelectRankingMode rankingMode: PixivRankingMode,rankingName:String?) {
        self.gallery = nil
        self.collectionView.contentOffset = CGPointZero
        self.arrowTitleView.arrowStatus = .Up
        self.arrowTitleView.titleLabel.text = rankingName
        self.arrowTitleView.triggerButtonEvent()
        self.viewDidLayoutSubviews()
        self.startLoading(rankingMode)
        self.rankingMode = rankingMode
    }
}
