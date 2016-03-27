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
        pageView.style = UIViewPagerStyle.Normal
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
    
    var functionButtons = ["搜索标签", "搜索标题", "搜索用户"]
    
    private lazy  var functionView:FunctionView = {
        let functionView = FunctionView(frame: CGRectZero)
        functionView.dataSource = self
        functionView.delegate = self
        functionView.backgroundColor = UIColor.clearColor()
        return functionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        addChildViewControllers()
        view.addSubview(self.functionView)
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
        self.functionView.reloadData()
        self.functionView.onButtonClick(0)
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
        case .Text:
            self.searchTitleResultViewController.startSearching(query, page: page, mode: .Text, order: order)
            self.currentWaterFlowViewController = searchTitleResultViewController
            break
        case .Tag:
            self.searchTitleResultViewController.startSearching(query, page: page, mode: .Tag, order: order)
            self.currentWaterFlowViewController = searchTitleResultViewController
            break
        case .Caption:
            self.searchUserResultViewController.startSearching(query, page: page, mode: .Caption, order: order)
            self.currentWaterFlowViewController = searchUserResultViewController
            break
        }
    }
    
    func addConstraints() {
        self.pageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.functionView.snp_bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        
        self.functionView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(FunctionViewHeight)
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
        self.functionView.onButtonClick(toIndex)
        
        
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

extension SearchResultViewController: FunctionViewDataSource, FunctionViewDelegate {
    func numberOfItemsInFunctionView(functionView: FunctionView) -> Int {
        return functionButtons.count
    }
    
    func functionView(functionView: FunctionView, titleForItemAtIndex index: Int) -> String? {
        return functionButtons[index]
    }
    
    func functionView(functionView: FunctionView, didClickAtIndex index: Int) {
        if index == 0 {
            self.currentMode = .ExactTag
        }else if index == 1 {
            self.currentMode = .Text
        }else if index == 2 {
            self.currentMode = .Caption
        }
        
        if let viewController = self.childViewControllers[index] as? SearchWaterFlowViewController {
            if !viewController.isFinishLoading {
                if let query = self.currentQuery, order = self.currentOrder{
                    viewController.startSearching(query, page: self.currentPage, mode: self.currentMode, order: order)
                }
            }
        }
        self.pageView.selectPage(index, animated: true)
        if index >= 0 && index < self.childViewControllers.count {
             self.currentWaterFlowViewController = self.childViewControllers[index] as? SearchWaterFlowViewController
        }
    }
}
