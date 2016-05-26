//
//  MainTabbarController.swift
//  client
//
//  Created by Sam on 15/12/16.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import SnapKit
import ionicons

class MainTabbarController: UITabBarController {
    private var customTabBar:MainTabbar?
    private var rankGalleryViewController:RankGalleryViewController!
    private var latestGalleryViewController:LatestGalleryViewController!
    private var searchViewController:SearchViewController!
    private var profileViewController:ProfileViewController!
    private var downloadManagerViewController:GalleryWaterFlowViewController!
    private var tabbarHeight:CGFloat = 49
    
    private var tabbarItems:[UITabBarItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabbars()
        addChildViewControllers()
        self.customTabBar?.reloadData()
        if let firstButton =  self.customTabBar?.buttons.first {
            self.customTabBar?.btnClick(firstButton)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeSystemTabbar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PixivLoginHelper.getInstance().checkLogin(self)
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
        let rankImage =  IonIcons.imageWithIcon("ion-ios-timer-outline", size: 29, color: UIColor.redColor())
        let rankImageHighlight =  IonIcons.imageWithIcon("ion-ios-timer", size: 29, color: UIColor.redColor())
        addChildViewController(rankGalleryViewController, titles: "排行", image: rankImage, selectImage: rankImageHighlight)
        
        latestGalleryViewController = LatestGalleryViewController()
        addChildViewController(latestGalleryViewController, titles: "新作", imageNamed: "tab_info", selectImageNamed: "tab_info_selected")
        
        searchViewController = SearchViewController()
        addChildViewController(searchViewController, titles: "搜索", imageNamed: "tab_explore", selectImageNamed: "tab_explore_selected")
        
        profileViewController = ProfileViewController()
        addChildViewController(profileViewController, titles: "我的", imageNamed: "tab_me", selectImageNamed: "tab_me_selected")
    }
    
    func addChildViewController(child:UIViewController ,titles:String ,imageNamed:String ,selectImageNamed:String){
        addChildViewController(child, titles:titles , image: UIImage(named: imageNamed), selectImage: UIImage(named: selectImageNamed))
    }
    
    func addChildViewController(child:UIViewController ,titles:String ,image:UIImage? ,selectImage:UIImage?) {
        child.tabBarItem.title = titles
        child.tabBarItem.image = image
        child.tabBarItem.selectedImage = selectImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
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

