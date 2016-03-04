//
//  MainTabbar.swift
//  client
//
//  Created by Sam on 15/12/16.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

@objc
public protocol MainTabbarDeleaget:NSObjectProtocol {
    func tabBar(tabBar:MainTabbar, didSelectButton from:Int, to:Int) ->Void
}

public class MainTabbar: UIView {
    
    public weak var delegate:MainTabbarDeleaget?
    private var tabBarButtonCount:Int = 0
    private var selectBtn:MainTabBarButton?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
      
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func addTabBarButtonWithItem(item:UITabBarItem){
        if tabBarButtonCount >= 4{
            return
        }
        let btn:MainTabBarButton = MainTabBarButton()
        
        let btnH = self.frame.size.height
        let btnW = self.frame.size.width/4
        let btnX = btnW * CGFloat(tabBarButtonCount)
        
        btn.frame = CGRectMake(btnX, 0, btnW, btnH);
        
        btn.item = item
        
        btn.addTarget(self, action:#selector(MainTabbar.btnClick(_:)), forControlEvents: UIControlEvents.TouchDown);
        
        btn.tag = tabBarButtonCount
        if btn.tag == 0{
            btnClick(btn)
        }
        addSubview(btn)
        tabBarButtonCount += 1
    }
    
    func btnClick(sender:MainTabBarButton){
        var from:Int = -1
        if (selectBtn != nil) {
            from = (selectBtn?.tag)!
        }
        self.delegate?.tabBar(self, didSelectButton: from, to: sender.tag)
        
        selectBtn?.selected = false
        sender.selected = true
        selectBtn = sender
    }
}
