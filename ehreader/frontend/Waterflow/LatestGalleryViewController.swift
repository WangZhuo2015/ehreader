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
    
    private lazy var dropdownViewController:UITableViewController = {
        let viewController = UITableViewController()
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "新作"
        self.arrowTitleView.titleLabel.text = self.title
        self.navigationItem.titleView = self.arrowTitleView
        
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
    
    func onPresentLatestType(sender:UIArrowTitleView) {
        if sender.arrowStatus == UIArrowTitleViewState.Down {
            presentDropdownController(self.dropdownViewController, height: self.view.frame.height, foldControl: sender, animated: false)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.hideTabbar(true)
            }
        }else {
            dismissDropdownController(self.dropdownViewController, height: self.view.frame.height, foldControl: sender, animated: true)
            if let mainTabbarController = self.tabBarController as? MainTabbarController {
                mainTabbarController.displayTabbar(true)
            }
        }
    }
    
    func startLoading(page:Int = 1) {
        if self.isLoadingFinished {
            return
        }
        
        if !PixivLoginHelper.getInstance().checkLogin(self.tabBarController!) {
            return
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
