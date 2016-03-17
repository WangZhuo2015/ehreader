//
//  MainTabbarController.swift
//  client
//
//  Created by Sam on 15/12/16.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import SnapKit

class MainTabbarController: UITabBarController {

    private var customTabBar:MainTabbar?
    private var rankGalleryViewController:RankGalleryViewController!
    private var latestGalleryViewController:LatestGalleryViewController!
    private var searchViewController:SearchViewController!
    private var appVc4:GalleryWaterFlowViewController!
    private var downloadManagerViewController:GalleryWaterFlowViewController!
    private var tabbarHeight:CGFloat = 50
    
    private var tabbarItems:[UITabBarItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabbars()
        addChildViewControllers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeSystemTabbar()
        self.tabbarHeight = self.tabBar.frame.height
        self.customTabBar?.reloadData()
        if let firstButton =  self.customTabBar?.buttons.first {
            self.customTabBar?.btnClick(firstButton)
        }
    }
    
    
    func removeSystemTabbar () {
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            for subView in self.tabBar.subviews{
                if subView.isKindOfClass(UIControl){
                    subView.removeFromSuperview()
                }
            }

        }
    }
    
    func hideTabbar(animated:Bool) {
        if tabbarHeight <= 0 {
            return
        }
        if animated {
            UIView.animateWithDuration(0.2, animations: {
                self.tabBar.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.tabbarHeight)
            }) { (finished:Bool) in
                self.tabBar.hidden = true
            }
        }else {
            self.tabBar.hidden = true
        }
    }
    
    func  displayTabbar(animated:Bool) {
        if tabbarHeight <= 0 {
            return
        }
        self.tabBar.hidden = false
        if animated {
            UIView.animateWithDuration(0.2, animations: {
                self.tabBar.frame = CGRectMake(0, self.view.frame.height - self.tabbarHeight, self.view.frame.width, self.tabbarHeight)
            }) { (finished:Bool) in
            }
        }else {
            self.tabBar.frame = CGRectMake(0, self.view.frame.height - self.tabbarHeight, self.view.frame.width, self.tabbarHeight)
        }
    }
    
    func addTabbars(){
        customTabBar = MainTabbar(frame: self.tabBar.bounds)
        customTabBar?.delegate = self
        customTabBar?.dataSource = self
        self.tabBar.addSubview(customTabBar!)
        customTabBar?.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(self.tabBar)
        })
    }
    
    func addChildViewControllers(){
        rankGalleryViewController = RankGalleryViewController()
        addChildViewController(rankGalleryViewController, titles: "排行", image: "tab_huaban", selectImage: "tab_huaban_selected")
        
        latestGalleryViewController = LatestGalleryViewController()
        addChildViewController(latestGalleryViewController, titles: "新作", image: "tab_info", selectImage: "tab_info_selected")
        
        searchViewController = SearchViewController()
        addChildViewController(searchViewController, titles: "搜索", image: "tab_explore", selectImage: "tab_explore_selected")
        
        appVc4 = GalleryWaterFlowViewController()
        addChildViewController(appVc4, titles: "我的", image: "tab_me", selectImage: "tab_me_selected")
        
    }
    
    func addChildViewController(child:UIViewController ,titles:String ,image:String ,selectImage:String){
        child.tabBarItem.title = titles
        child.tabBarItem.image = UIImage(named: image)
        child.tabBarItem.selectedImage = UIImage(named: selectImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        child.title = titles as String
        self.tabbarItems.append(child.tabBarItem)
        
        let navigationController = CustomNavigationController(rootViewController: child)
        self.addChildViewController(navigationController)
    }
}

extension MainTabbarController:MainTabbarDelegate, MainTabbarDataSource {
    func tabBar(tabBar: MainTabbar, didSelectButton from: Int, to: Int) {
        self.selectedIndex = to
    }
    
    func numberOfTabbarItem(tabbar: MainTabbar) -> Int {
        return self.tabbarItems.count
    }
    
    func mainTabbar(tabbar: MainTabbar, tabbarItemForIndex index: Int) -> UITabBarItem {
        return tabbarItems[index]
    }
}

