//
//  MainTabbarController.swift
//  client
//
//  Created by Sam on 15/12/16.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController,MainTabbarDeleaget {

    private var customTabBar:MainTabbar?
    private var waterFlowViewController:GalleryWaterFlowViewController!
    private var installedApplicationsViewController:GalleryWaterFlowViewController!
    private var appVc3:GalleryWaterFlowViewController!
    private var appVc4:GalleryWaterFlowViewController!
    private var downloadManagerViewController:GalleryWaterFlowViewController!
    private var tabbarHeight:CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabbar()
        addChildVc()

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeSystemTabbar()
        self.tabbarHeight = self.tabBar.frame.height
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
            UIView.animateWithDuration(0.3, animations: {
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
            UIView.animateWithDuration(0.3, animations: {
                self.tabBar.frame = CGRectMake(0, self.view.frame.height - self.tabbarHeight, self.view.frame.width, self.tabbarHeight)
            }) { (finished:Bool) in
            }
        }else {
            self.tabBar.frame = CGRectMake(0, self.view.frame.height - self.tabbarHeight, self.view.frame.width, self.tabbarHeight)
        }
    }
    
    func addTabbar(){
        customTabBar = MainTabbar.init(frame: self.tabBar.bounds)
        customTabBar?.delegate = self
        self.tabBar.addSubview(customTabBar!)
    }
    
    func addChildVc(){
        waterFlowViewController = GalleryWaterFlowViewController()
        addChildViewController(waterFlowViewController, titles: "排行", image: "tab_huaban", selectImage: "tab_huaban_selected")
        
        installedApplicationsViewController = GalleryWaterFlowViewController()
        addChildViewController(installedApplicationsViewController, titles: "新作", image: "tab_info", selectImage: "tab_info_selected")
        
        appVc3 = GalleryWaterFlowViewController()
        addChildViewController(appVc3, titles: "搜索", image: "tab_explore", selectImage: "tab_explore_selected")
        
        appVc4 = GalleryWaterFlowViewController()
        addChildViewController(appVc4, titles: "我的", image: "tab_me", selectImage: "tab_me_selected")
        
    }
    
    func addChildViewController(child:UIViewController ,titles:String ,image:String ,selectImage:String){
        child.tabBarItem.title = titles
        child.tabBarItem.image = UIImage(named: image)
        child.tabBarItem.selectedImage = UIImage(named: selectImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        child.title = titles as String
        
        let navigationController = CustomNavigationController(rootViewController: child)
        self.addChildViewController(navigationController)
    
        customTabBar?.addTabBarButtonWithItem(child.tabBarItem)
    }
   
    func tabBar(tabBar: MainTabbar, didSelectButton from: Int, to: Int) {
        self.selectedIndex = to
    }
    
    func findScrollView(rootView:UIView)->UIScrollView? {
        if rootView.isKindOfClass(UIScrollView) {
            return rootView as? UIScrollView
        }
        for subview in rootView.subviews {
            return findScrollView(subview)
        }
        return nil
    }
}

