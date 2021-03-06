//
//  OtherProfileViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import ViewPagerSwift
import Kingfisher
import SnapKit

class OtherProfileViewController: UIViewController {
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        return tableView
    }()
    
    private lazy  var functionView:FunctionView = {
        let functionView = FunctionView(frame: CGRectZero)
        functionView.dataSource = self
        functionView.delegate = self
        functionView.backgroundColor = UIColor.clearColor()
        return functionView
    }()
    
    lazy var profileView:ProfileView = {
        let profileView = ProfileView(frame: CGRectZero)
        
        profileView.onAvatarButtonClickedClosure = {[weak self](profileView:ProfileView, button:UIButton)->Void in
            if let weakSelf = self {
                weakSelf.userFollowingViewController.profile = weakSelf.profile
                weakSelf.navigationController?.pushViewController(weakSelf.userFollowingViewController, animated: true)
            }
        }
        
        return profileView
    }()
    
    lazy var followButtonItem:UIBarButtonItem = {
        let button = UIBarButtonItem(title: "关注", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OtherProfileViewController.followUser(_:)))
        return button
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    var userId:Int = -1
    var profile:PixivProfile? {
        didSet {
            self.userWorksGalleryViewController.profile = profile
            self.userFavoriteWorksViewController.profile = profile
        }
    }
    
    var functionButtons = ["作品一栏", "他的收藏"]
    
    var currentDisplayViewController:UIViewController?
    var prevDisplayViewController:UIViewController?
    
    lazy var userWorksGalleryViewController:UserWorksGalleryViewController = {
        let viewController = UserWorksGalleryViewController()
        viewController.profile = self.profile
        viewController.collectionView.scrollEnabled = false
        viewController.delegate = self
        return viewController
    }()
    
    lazy var userFavoriteWorksViewController:UserFavoriteWorksViewController = {
        let viewController = UserFavoriteWorksViewController()
        viewController.profile = self.profile
        viewController.delegate = self
        viewController.collectionView.scrollEnabled = false
        return viewController
    }()
    
    lazy var userFollowingViewController:UserFollowingViewController = {
        let viewController = UserFollowingViewController()
        viewController.profile = self.profile
        viewController.delegate = self
        return viewController
    }()
    
    override func viewDidLoad() {
        self.title = "我的主页"
        super.viewDidLoad()
        currentDisplayViewController = userWorksGalleryViewController
        
        self.automaticallyAdjustsScrollViewInsets = true
        self.view.backgroundColor = UIConstants.GrayBackgroundColor
        self.navigationItem.rightBarButtonItem = self.followButtonItem
        
        profileView.frame = CGRectMake(0, 0, view.frame.width, 200)
        tableView.tableHeaderView = profileView
        view.addSubview(tableView)
        
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(ProfileViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)

        addConstraints()
        startLoading()
        addViewControllers()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    deinit {
        print("deinit OtherProfileViewController")
        //fix crash bug in ios8 http://stackoverflow.com/questions/26103756/uiscrollview-internal-consistency-crash
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
    }
    
    private var originalNaivgationControllerDelegate:UINavigationControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideMainTabbar(true)
        self.originalNaivgationControllerDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = self
        
        if let viewController = self.currentDisplayViewController as? GalleryWaterFlowViewController {
            viewController.footerView = CurveRefreshFooterView(associatedScrollView: self.tableView, withNavigationBar: true)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        KingfisherManager.sharedManager.cache.clearMemoryCache()
        super.navigationController?.delegate = self.originalNaivgationControllerDelegate
    }
    
    private func addViewControllers() {
        addChildViewController(self.userWorksGalleryViewController)
        addChildViewController(self.userFavoriteWorksViewController)
    }
    
    private func addConstraints() {
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    func startLoading() {
        if userId != -1 {
            PixivProvider.getInstance().getUserInfomation(userId, complete: { (profile, error) in
                if profile == nil {
                    return
                }
                self.backgroundView.status = BackgroundViewStatus.Hidden
                self.profileView.setUser(profile!)
                self.profile = profile
                if let _profile = profile {
                    self.changeFollowingButton(_profile.is_following)
                }
                if let name = profile?.name {
                    self.title = name + "的主页"
                }
                
                self.tableView.reloadData()
                self.functionView.reloadData()
                self.functionView.onButtonClick(0)
                self.userWorksGalleryViewController.startLoading()
            })
        }
    }
    
    func changeFollowingButton(isFollowing:Bool) {
        if isFollowing {
            self.followButtonItem.title = "取消关注"
            self.followButtonItem.action = #selector(OtherProfileViewController.unfollowUser(_:))
        }else {
            self.followButtonItem.title = "关注"
            self.followButtonItem.action = #selector(OtherProfileViewController.followUser(_:))
        }
    }
    
    func followUser(sender:UIBarButtonItem)  {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "关注", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) in
            self.followUserInternal(PixivPublicity.Public)
        }))
        
        alertController.addAction(UIAlertAction(title: "悄悄关注", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) in
            self.followUserInternal(PixivPublicity.Private)
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        //http://stackoverflow.com/questions/25639883/runtime-exception-coming-when-show-uialertcontrolleractionsheet-ios8
        alertController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func followUserInternal(publicity:PixivPublicity) {
        guard let profile = self.profile else {
            return
        }
        PixivProvider.getInstance().meFavoriteUsersFollow(profile.id, publicity: publicity) { (success, error) in
            if success {
                profile.is_following = true
                self.changeFollowingButton(true)
            }
        }
    }
    
    func unfollowUser(sender:UIBarButtonItem) {
        unfollowUserInternal(PixivPublicity.Public)
    }
    
    func unfollowUserInternal(publicity:PixivPublicity) {
        guard let profile = self.profile else {
            return
        }
        PixivProvider.getInstance().meFavoriteUsersUnfollow([profile.id], publicity: publicity) { (success, error) in
            if success {
                profile.is_following = false
                self.changeFollowingButton(false)
            }
        }
    }
}

extension OtherProfileViewController: UIViewPagerDataSource, UIViewPagerDelegate {
    func numberOfItems(viewPager: UIViewPager) -> Int {
        return self.childViewControllers.count
    }
    
    func controller(viewPager: UIViewPager, index: Int) -> UIViewController {
        return self.childViewControllers[index]
    }
    
    func didMove(viewPager: UIViewPager, fromIndex: Int, toIndex: Int) {
        self.tableView.reloadData()
        self.functionView.onButtonClick(toIndex)
    }
}

extension OtherProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FunctionViewHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRectMake(0, 0, tableView.frame.width, FunctionViewHeight)
        functionView.frame = frame
        return functionView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let viewController = self.currentDisplayViewController as? GalleryWaterFlowViewController {
            let height = viewController.maxScrollViewHeight
            if height > self.view.frame.height {
                return height
            }
        }else if let viewController = self.currentDisplayViewController as? UserFollowingViewController {
            let height = viewController.maxScrollViewHeight
            if height > self.view.frame.height {
                return height
            }
        }
        return self.view.frame.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if currentDisplayViewController == prevDisplayViewController {
            return cell
        }
        
        if let viewController = self.currentDisplayViewController {
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            let view = viewController.view
            cell.contentView.addSubview(view)
            viewController.didMoveToParentViewController(self)
            view.snp_makeConstraints { (make) in
                make.edges.equalTo(cell.contentView)
            }
        }
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //self.onScrollViewScrollingWithTabbar(scrollView)
    }
}

extension OtherProfileViewController: FunctionViewDataSource, FunctionViewDelegate {
    func numberOfItemsInFunctionView(functionView: FunctionView) -> Int {
        return functionButtons.count
    }
    
    func functionView(functionView: FunctionView, titleForItemAtIndex index: Int) -> String? {
        return functionButtons[index]
    }
    
    func functionView(functionView: FunctionView, didClickAtIndex index: Int) {
        if index >= 0 && index < self.childViewControllers.count {
            self.currentDisplayViewController = self.childViewControllers[index]
            self.currentDisplayViewController?.automaticallyAdjustsScrollViewInsets = false
        }
        self.userFollowingViewController.footerView.removeFromSuperview()
        self.userWorksGalleryViewController.footerView.removeFromSuperview()
        if let viewController = self.currentDisplayViewController as? GalleryWaterFlowViewController {
            viewController.footerView = CurveRefreshFooterView(associatedScrollView: self.tableView, withNavigationBar: true)
            if viewController.isLoadingFinished {
                viewController.footerView.setNoMoreLoading()
            }
        }
        self.tableView.reloadData()
    }
}

extension OtherProfileViewController: UserWorksGalleryViewControllerDelegate {
    
    func onLoadLayoutFinished(collectionView: UICollectionView, contentSize: CGSize) {
        self.tableView.reloadData()
    }
}

extension OtherProfileViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKindOfClass(PhotoViewController) && operation == .Push {
            let pushTransition = PushTransition()
            return pushTransition
        }else {
            return nil
        }
    }
}

extension OtherProfileViewController:TransitionDelegate {
    func currentSelectedCellForAnimation() -> GalleryCell? {
        if let viewController = self.currentDisplayViewController as? GalleryWaterFlowViewController {
            return viewController.currentSelectedCell
        }
        return nil
    }
}
