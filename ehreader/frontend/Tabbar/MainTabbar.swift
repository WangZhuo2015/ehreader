//
//  MainTabbar.swift
//  client
//
//  Created by Sam on 15/12/16.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import SnapKit

@objc public protocol MainTabbarDelegate:NSObjectProtocol {
    func tabBar(tabBar:MainTabbar, didSelectButton from:Int, to:Int) ->Void
}

@objc public protocol MainTabbarDataSource:NSObjectProtocol {
    func numberOfTabbarItem(tabbar:MainTabbar)->Int
    func mainTabbar(tabbar:MainTabbar, tabbarItemForIndex index:Int)->UITabBarItem
}

public class MainTabbar: UIView {
    public weak var delegate:MainTabbarDelegate?
    
    public weak var dataSource:MainTabbarDataSource?
    
    private var selectBtn:MainTabBarButton?
    
    public var buttons:[MainTabBarButton] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        //reloadData()
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let tabBarButtonCount = dataSource.numberOfTabbarItem(self)
        buttons.removeAll()
        var prevView:UIView?
        for index in 0..<tabBarButtonCount {
            let tabbarItem = dataSource.mainTabbar(self, tabbarItemForIndex: index)
            let tabbarButton = MainTabBarButton(frame: CGRectZero)
            tabbarButton.item = tabbarItem
            tabbarButton.addTarget(self, action:#selector(MainTabbar.btnClick(_:)), forControlEvents: UIControlEvents.TouchDown)
            tabbarButton.tag = index
            addSubview(tabbarButton)
            tabbarButton.snp_makeConstraints(closure: { (make) in
                if let view = prevView {
                    make.leading.equalTo(view.snp_trailing)
                    make.width.equalTo(view)
                }else {
                    make.leading.equalTo(self)
                }
                
                make.top.bottom.equalTo(self)
                if index == tabBarButtonCount - 1 {
                    make.trailing.equalTo(self)
                }
            })
            buttons.append(tabbarButton)
            prevView = tabbarButton
        }
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
