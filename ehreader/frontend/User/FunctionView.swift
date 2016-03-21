//
//  FunctionView.swift
//  client
//
//  Created by yrtd on 15/12/9.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

@objc
public protocol FunctionViewDataSource:NSObjectProtocol {
    func numberOfItemsInFunctionView(functionView:FunctionView)->Int
    optional func functionView(functionView:FunctionView, imageForItemAtIndex index:Int)->UIImage?
    func functionView(functionView:FunctionView, titleForItemAtIndex index:Int)->String?
}

@objc
public protocol FunctionViewDelegate:NSObjectProtocol {
    optional func functionView(functionView:FunctionView, didClickAtIndex index:Int)
}

public class FunctionView: UIView {
    public weak var dataSource:FunctionViewDataSource?
    
    public weak var delegate:FunctionViewDelegate?
    
    private var buttons:[UIButton] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupFunctionView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFunctionView()
    }
    
    lazy var backgroundView:BlurView = {
        let backgroundView = BlurView(frame: CGRectZero)
        return backgroundView
    }()
    
    func setupFunctionView() {
        //add background
        self.backgroundView.removeFromSuperview()
        addSubview(backgroundView)
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
    
    public func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        let count = dataSource.numberOfItemsInFunctionView(self)
        if count <= 0 {
            return
        }
        for button in self.buttons {
            button.removeFromSuperview()
        }
        self.buttons.removeAll()
        
        var preView:UIView?
        for index in 0..<count {
            let title = dataSource.functionView(self, titleForItemAtIndex: index)
            let button = UIButton(frame: CGRectZero)
            button.setTitle(title, forState: UIControlState.Normal)
            button.setBackgroundImage(UIConstants.GrayBackgroundColor.createImage(), forState: UIControlState.Selected)
            button.setImage(dataSource.functionView?(self, imageForItemAtIndex: index), forState: UIControlState.Normal)
            button.backgroundColor = UIColor.clearColor()
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(UIColor.createColor(102, green: 102, blue: 102, alpha: 1), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(FunctionView.onButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = index
            button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            buttons.append(button)
            self.addSubview(button)
            button.snp_makeConstraints(closure: { (make) -> Void in
                if let view = preView {
                    make.leading.equalTo(view.snp_trailing)
                    make.width.equalTo(view)
                }else {
                    make.leading.equalTo(self)
                }
                make.top.equalTo(self)
                make.bottom.equalTo(self)
                if index == (count - 1) {
                    make.trailing.equalTo(self)
                }
            })
            preView = button
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func onButtonClicked(button:UIButton) {
        for b in self.buttons {
            b.selected = false
        }
        button.selected = true
        self.delegate?.functionView?(self, didClickAtIndex: button.tag)
    }
    
    public func onButtonClick(index:Int) {
        if index < 0 || index >= self.buttons.count {
            return
        }
        for b in self.buttons {
            b.selected = false
        }
        self.buttons[index].selected = true
    }
}
