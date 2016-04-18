//
//  LatestGalleryViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class LatestGalleryViewController: GalleryWaterFlowViewController {
    private lazy var arrowTitleView:UIArrowTitleView = {
        let titleView = UIArrowTitleView(frame: CGRectZero)
        titleView.addTarget(self, action: #selector(LatestGalleryViewController.onPresentLatestType(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return titleView
    }()
    
    private lazy var dropdownViewController:SimpleListViewController = {
        let viewController = SimpleListViewController()
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()
    
    private var topOptions:[String] = ["我关注的新作", "一般新作"]
    private var currentOptionIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = topOptions.first
        self.arrowTitleView.titleLabel.text = self.title
        self.navigationItem.titleView = self.arrowTitleView
        self.setupDropdownViewEvent(self.arrowTitleView, action: #selector(arrowTitleView.triggerButtonEvent))
        
        backgroundView.addTarget(self, action: #selector(LatestGalleryViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        startLoading()
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headerView.refreshingBlock = {[weak self] ()->() in
            if let weakSelf = self {
                self!.startLoading(weakSelf.currentPage, optionIndex: weakSelf.currentOptionIndex)
            }
        }
        
        footerView.refreshingBlock = {[weak self] ()->() in
            if let weakSelf = self {
                weakSelf.currentPage += 1
                weakSelf.startLoading(self!.currentPage, optionIndex: weakSelf.currentOptionIndex)
            }
        }
    }
    
    func onPresentLatestType(sender:UIArrowTitleView) {
        let height = self.dropdownViewController.preferredContentSize.height
        if sender.arrowStatus == UIArrowTitleViewState.Down {
            presentDropdownController(self.dropdownViewController, height: height, foldControl: sender, animated: false)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.hideTabbar(true)
            }
        }else {
            dismissDropdownController(self.dropdownViewController, height: height, foldControl: sender, animated: true)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.displayTabbar(true)
            }
        }
    }
    
    func startLoading(page:Int = 1, optionIndex:Int = 0) {
        if self.isLoadingFinished {
            return
        }
        
        if !PixivLoginHelper.getInstance().checkLogin(self.tabBarController!) {
            return
        }
        
        let completeClosure:GalleryCompleteClosure = { (gallery, error) in
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
        if optionIndex == 1 {
            pixivProvider.getLastWorks(page, complete: completeClosure)
        }else if optionIndex == 0 {
            pixivProvider.meFollowingWorks(page, complete: completeClosure)
        }
        
    }
}

extension LatestGalleryViewController: SimpleListViewControllerDataSource, SimpleListViewControllerDelegate {
    func numberOfItemsForSimpleList(viewController: SimpleListViewController) -> Int {
        return topOptions.count
    }
    
    func simpleListViewController(viewController: SimpleListViewController, titleForItemIndex index: Int) -> String {
        return topOptions[index]
    }
    
    func simpleListViewController(viewController: SimpleListViewController, didSelectIndex index: Int) {
        self.currentOptionIndex = index
        self.gallery = nil
        self.arrowTitleView.titleLabel.text = self.topOptions[index]
        self.startLoading(self.currentPage, optionIndex: index)
        self.arrowTitleView.triggerButtonEvent()
    }
}
