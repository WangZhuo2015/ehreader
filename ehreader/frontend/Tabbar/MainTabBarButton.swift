//
//  MainTabBarButton.swift
//  client
//
//  Created by Sam on 15/12/17.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

public class MainTabBarButton: UIButton {
    var item:UITabBarItem! {
        didSet {
            self.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.New, context:nil)
            self.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.New, context: nil)
            self.addObserver(self, forKeyPath: "selectedImage", options: NSKeyValueObservingOptions.New, context: nil)
            self.addObserver(self, forKeyPath: "badgeValue", options: NSKeyValueObservingOptions.New, context: nil)
            self.observeValueForKeyPath(nil, ofObject: nil, change: nil, context: nil)
        }
    }
    
    deinit{
        self.removeObserver(self, forKeyPath: "title");
        self.removeObserver(self, forKeyPath: "image");
        self.removeObserver(self, forKeyPath: "selectedImage");
        self.removeObserver(self, forKeyPath: "badgeValue");
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.setTitle(item.title, forState: .Normal)
        self.setImage(item.image, forState: .Normal)
        self.setImage(item.selectedImage, forState: .Selected)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        if let image:UIImage = self.imageForState(.Normal){
            let titleY = image.size.height
            let titleHeight = self.bounds.size.height - titleY
            return CGRectMake(0, titleY+1, self.bounds.size.width,  titleHeight)
        } else {
            return contentRect
        }
    }
    
    override public func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        if let image:UIImage = self.imageForState(.Normal) {
            return CGRectMake(0, 0, contentRect.size.width, image.size.height + 5);
        }else {
            return contentRect
        }
    }
    
    func createUI(){
        self.imageView?.contentMode = UIViewContentMode.Center
        self.titleLabel?.textAlignment = .Center
        self.titleLabel?.font = UIFont.systemFontOfSize(11)
        self.setTitleColor(UIColor.createColor(123.0, green: 123.0, blue: 123.0, alpha: 1.0), forState: .Normal)
        self.setTitleColor(UIColor.createColor(47.0, green: 131.0, blue: 245.0, alpha: 1.0), forState: .Selected)
    }
}
