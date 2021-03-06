//
//  UIArrowTitleView.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/8.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit

public enum UIArrowTitleViewState:Int {
    case Up
    case Down
}

public class UIArrowTitleView: UIControl {
    public var titleLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.boldSystemFontOfSize(17)
        label.textColor = UIColor.redColor()
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    public var arrowImageView:UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_explore_down"))
        return imageView
    }()
    
    public var arrowStatus:UIArrowTitleViewState = UIArrowTitleViewState.Down
    
    public var arrowTitleViewWidth:CGFloat {
        if let title = self.titleLabel.text {
            let height = self.frame.height
            let width = title.widthWithConstrainedHeight(height, font: UIFont.boldSystemFontOfSize(17))
            //print("title:\(title) width:\(width)")
            return width  + 20
        }
        return 50
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIArrowTitleView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIArrowTitleView()
    }
    
    private func setupUIArrowTitleView() {
        addSubview(titleLabel)
        addSubview(arrowImageView)
        
        titleLabel.snp_makeConstraints { (make) in
            make.leading.top.bottom.equalTo(self)
        }
        
        arrowImageView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.width.equalTo(20)
            make.leading.equalTo(self.titleLabel.snp_trailing)
        }
    }
    
    public func triggerButtonEvent() {
        if self.arrowStatus == .Down {
            UIView.animateWithDuration(0.3, animations: {
                self.arrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }) { (finished:Bool) in
                self.arrowStatus = UIArrowTitleViewState.Up
            }
        }else {
            UIView.animateWithDuration(0.3, animations: {
                self.arrowImageView.transform = CGAffineTransformMakeRotation(0)
            }) { (finished:Bool) in
                self.arrowStatus = UIArrowTitleViewState.Down
            }
        }
        
        sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        triggerButtonEvent()
    }
}
