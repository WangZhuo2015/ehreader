//
//  SearchResultViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/23.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import ViewPagerSwift
import Kingfisher

class SearchResultViewController: UIViewController {
    private lazy var pageView:UIViewPager = {
        let pageView = UIViewPager(frame: CGRectZero)
        pageView.style = UIViewPagerStyle.TabHost
        pageView.dataSource = self
        pageView.delegate = self
        pageView.contentView.scrollEnabled = false
        pageView.backgroundColor = UIColor.clearColor()
        return pageView
    }()
    
    var currentQuery:String?
    var currentPage:Int = 1
    var currentMode:PixivSearchMode = PixivSearchMode.ExactTag
    var currentOrder:String?
    
    var currentWaterFlowViewController:SearchWaterFlowViewController?
    
    lazy var searchTagResultViewController:SearchWaterFlowViewController = {
        let viewController = SearchWaterFlowViewController()
        viewController.title = "搜索标签"
        return viewController
    }()
    
    lazy var searchTitleResultViewController:SearchWaterFlowViewController = {
        let viewController = SearchWaterFlowViewController()
        viewController.title = "搜索标题"
        return viewController
    }()
    
    lazy var searchUserResultViewController:SearchWaterFlowViewController = {
        let viewController = SearchWaterFlowViewController()
        viewController.title = "搜索用户"
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        addChildViewControllers()
        view.addSubview(self.pageView)
        addConstraints()
    }
    
    private var originalNaivgationControllerDelegate:UINavigationControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideMainTabbar(true)
        self.originalNaivgationControllerDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = self
        self.pageView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        KingfisherManager.sharedManager.cache.clearMemoryCache()
        super.navigationController?.delegate = self.originalNaivgationControllerDelegate
    }
    
    func startSearching(query:String, page:Int = 1, mode:PixivSearchMode = PixivSearchMode.ExactTag, order:String = "desc") {
        self.currentQuery = query
        self.currentPage = page
        self.currentMode = mode
        self.currentOrder = order
        
        self.title = query
        
        switch mode {
        case .ExactTag:
            self.searchTagResultViewController.startSearching(query, page: page, mode: .ExactTag, order: order)
            self.currentWaterFlowViewController = searchTagResultViewController
            break
        case .Title:
            self.searchTitleResultViewController.startSearching(query, page: page, mode: .Title, order: order)
            self.currentWaterFlowViewController = searchTitleResultViewController
            break
        case .Text:
            self.searchUserResultViewController.startSearching(query, page: page, mode: .Text, order: order)
            self.currentWaterFlowViewController = searchUserResultViewController
        }
    }
    
    func addConstraints() {
        self.pageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }
    
    func addChildViewControllers() {
        addChildViewController(self.searchTagResultViewController)
        addChildViewController(self.searchTitleResultViewController)
        addChildViewController(self.searchUserResultViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SearchResultViewController: UIViewPagerDataSource, UIViewPagerDelegate {
    func numberOfItems(viewPager: UIViewPager) -> Int {
        return self.childViewControllers.count
    }
    
    func controller(viewPager: UIViewPager, index: Int) -> UIViewController {
        return self.childViewControllers[index]
    }
    
    func titleForItem(viewPager: UIViewPager, index: Int) -> String {
        return self.childViewControllers[index].title ?? ""
    }
    
    func didMove(viewPager: UIViewPager, fromIndex: Int, toIndex: Int) {
        if toIndex < 0 || toIndex >= self.childViewControllers.count {
            return
        }
        
        if toIndex == 0 {
            self.currentMode = .ExactTag
        }else if toIndex == 1 {
            self.currentMode = .Title
        }else if toIndex == 2 {
            self.currentMode = .Text
        }
        
        self.currentWaterFlowViewController = self.childViewControllers[toIndex] as? SearchWaterFlowViewController
        if let viewController = self.childViewControllers[toIndex] as? SearchWaterFlowViewController {
            if !viewController.isFinishLoading {
                if let query = self.currentQuery, order = self.currentOrder{
                    viewController.startSearching(query, page: self.currentPage, mode: self.currentMode, order: order)
                }
            }
        }
    }
}

extension SearchResultViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKindOfClass(PhotoViewController) && operation == .Push {
            let pushTransition = PushTransition()
            return pushTransition
        }else {
            return nil
        }
    }
}


extension SearchResultViewController:TransitionDelegate {
    func currentSelectedCellForAnimation() -> GalleryCell? {
        return self.currentWaterFlowViewController?.currentSelectedCell
    }
}
