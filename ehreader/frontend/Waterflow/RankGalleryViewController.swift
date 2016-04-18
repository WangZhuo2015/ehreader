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
    
    private lazy var pixivRankingViewController:SimpleListViewController = {
        let viewController = SimpleListViewController()
        viewController.delegate = self
        viewController.dataSource = self
        return viewController
    }()
    
    private var rankingKeys:[PixivRankingMode] = [PixivRankingMode.Daily, PixivRankingMode.Weekly, PixivRankingMode.Monthly, PixivRankingMode.Male, PixivRankingMode.Female, PixivRankingMode.Rookie, PixivRankingMode.DailyR18, PixivRankingMode.WeeklyR18, PixivRankingMode.MaleR18, PixivRankingMode.FemaleR18, PixivRankingMode.R18g]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = RankingTypes[PixivRankingMode.Daily]
        self.arrowTitleView.titleLabel.text = self.title
        self.navigationItem.titleView = self.arrowTitleView
        self.setupDropdownViewEvent(self.arrowTitleView, action: #selector(arrowTitleView.triggerButtonEvent))
        
        startLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.startLoading(self!.rankingMode, page: self!.currentPage)
            }
        }
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if self != nil {
                self!.currentPage += 1
                self!.startLoading(self!.rankingMode, page: self!.currentPage)
            }
        }
        if isLoginFailed {
            isLoginFailed = false
            startLoading()
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
    
    /// If login failed, then login success, wes hould load the view
    var isLoginFailed:Bool = false
    
    
    func startLoading(rankingMode:PixivRankingMode = PixivRankingMode.Daily, page:Int = 1) {
        if self.isLoadingFinished {
            return
        }
        if !PixivLoginHelper.getInstance().checkLogin(self.tabBarController!) {
            isLoginFailed = true
            return
        }
        
        pixivProvider.getRankingAll(rankingMode, page: page) { (gallery, error) in
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
    
    func onPresentPixivRanking(sender:AnyObject?) {
        if self.arrowTitleView.arrowStatus == UIArrowTitleViewState.Down {
            presentDropdownController(self.pixivRankingViewController, height: self.pixivRankingViewController.preferredContentSize.height, foldControl: self.arrowTitleView, animated: false)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.hideTabbar(true)
            }
        }else {
            dismissDropdownController(self.pixivRankingViewController, height: self.pixivRankingViewController.preferredContentSize.height, foldControl: self.arrowTitleView, animated: true)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.displayTabbar(true)
            }
        }
    }
}


extension RankGalleryViewController: SimpleListViewControllerDelegate, SimpleListViewControllerDataSource {
    func simpleListViewController(viewController: SimpleListViewController, didSelectIndex index: Int) {
        self.rankingMode = rankingKeys[index]
        self.gallery = nil
        self.collectionView.contentOffset = CGPointZero
        self.arrowTitleView.arrowStatus = .Up
        self.arrowTitleView.titleLabel.text = RankingTypes[rankingKeys[index]]
        self.arrowTitleView.triggerButtonEvent()
        self.viewDidLayoutSubviews()
        self.startLoading(rankingMode)
        self.rankingMode = rankingMode
    }
    
    func numberOfItemsForSimpleList(viewController: SimpleListViewController) -> Int {
        return rankingKeys.count
    }
    
    func simpleListViewController(viewController: SimpleListViewController, titleForItemIndex index: Int) -> String {
        return RankingTypes[rankingKeys[index]] ?? ""
    }
}
