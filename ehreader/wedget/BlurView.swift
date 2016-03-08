//
//  BlurView.swift
//  client
//
//  Created by 周泽勇 on 16/2/23.
//  Copyright © 2016年 kuaiyong. All rights reserved.
//

import UIKit

class BlurView: UIView {
    private var toolBar:UIToolbar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeViews()
    }
    
    func makeViews() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        toolBar = UIToolbar(frame: self.bounds)
        self.layer.insertSublayer(toolBar.layer, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        toolBar.frame = self.bounds
    }
    
}
