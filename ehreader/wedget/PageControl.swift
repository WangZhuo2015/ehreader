//
//  PageControl.swift
//  client
//
//  Created by yrtd on 15/12/2.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

public class PageControl: UIView {
    private var sliderShapeLayer:CAShapeLayer = CAShapeLayer()
    private var textLayer:CATextLayer = CATextLayer()
    private var pointShapes:[CAShapeLayer] = []
    // The start x value of the first point
    private var startX:CGFloat = 0
    
    /// Distance between points
    public var pointSpacing:CGFloat = 15
    public var ellipseWidth:CGFloat = 10;
    public var pointSize:CGSize = CGSizeMake(10, 10);
    public var sliderSize:CGSize = CGSizeMake(10, 10)
    
    public var showText:Bool = false {
        didSet {
            if showText {
                if let subLayers = self.sliderShapeLayer.sublayers {
                    if !subLayers.contains(self.textLayer) {
                        self.sliderShapeLayer.addSublayer(self.textLayer)
                    }
                }
            }else {
                self.textLayer.removeFromSuperlayer()
                self.sliderShapeLayer.strokeColor = UIColor.clearColor().CGColor
                self.sliderShapeLayer.lineWidth = 0
            }
        }
    }
    public var colors:[UIColor]?
    
    /// Color of the main slider
    public var sliderStrokeColor:UIColor = UIColor.createColor(222, green: 53, blue: 46, alpha: 1)
    public var sliderFillColor:UIColor = UIColor.whiteColor()
    public var pointColor:UIColor = UIColor.createColor(84, green: 80, blue: 85, alpha: 1)
    
    public var currentPage:Int = 0
    
    /// Total page count
    public var pageCount:Int = 0
    
    private var contentWidth:CGFloat {
        return  CGFloat(pageCount)*pointSize.width + CGFloat(pageCount - 1)*pointSpacing
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupPageControl()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPageControl()
    }
    
    private func setupPageControl() {
        backgroundColor = UIColor.clearColor()
        sliderShapeLayer.anchorPoint = CGPointMake(0.5, 0.5)
        sliderShapeLayer.fillColor = sliderFillColor.CGColor
        if showText {
            sliderShapeLayer.lineWidth = 1
            sliderShapeLayer.strokeColor = self.sliderStrokeColor.CGColor
        }
        
        textLayer.string = "1"
        textLayer.foregroundColor = UIColor.redColor().CGColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.fontSize = sliderSize.width - 2
        let width = max(self.ellipseWidth, sliderSize.width)
        textLayer.frame = CGRectMake(0, 0, width, sliderSize.height)
        if showText {
            self.sliderShapeLayer.addSublayer(textLayer)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        refresh()
    }
    
    public func refresh() {
        if ellipseWidth < sliderSize.width {
            ellipseWidth = sliderSize.width
        }

        startX = (bounds.width - contentWidth)/2
        let layerPath = UIBezierPath(roundedRect: CGRectMake(0, 0, pointSize.width, pointSize.height), cornerRadius: pointSize.height)
        let sliderPath = UIBezierPath(roundedRect: CGRectMake(0, 0, self.ellipseWidth, sliderSize.height), cornerRadius: sliderSize.height)
        
        // Set the slide shape
        sliderShapeLayer.anchorPoint = CGPointMake(0.5, 0.5)
        sliderShapeLayer.strokeColor = sliderStrokeColor.CGColor
        sliderShapeLayer.fillColor = sliderFillColor.CGColor
        sliderShapeLayer.path = sliderPath.CGPath
        sliderShapeLayer.frame = CGRectMake(startX - (ellipseWidth - sliderSize.width)/2, (bounds.height - sliderSize.height)/2, sliderSize.width, sliderSize.height)
        if let sublayers = layer.sublayers {
            if !sublayers.contains(sliderShapeLayer) {
                layer.addSublayer(sliderShapeLayer)
            }
        }else {
            layer.addSublayer(sliderShapeLayer)
        }
        
        // Set the points
        for pointShape in pointShapes {
            pointShape.removeFromSuperlayer()
        }
        pointShapes.removeAll()
        for index in 0..<pageCount {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = layerPath.CGPath
            shapeLayer.fillColor = pointColor.CGColor
            shapeLayer.anchorPoint = CGPointMake(0.5, 0.5)
            let frame = CGRectMake(startX + (pointSize.width + pointSpacing)*CGFloat(index), (bounds.height - pointSize.height)/2, pointSize.width, pointSize.height)
            shapeLayer.frame = frame
            pointShapes.append(shapeLayer)
            layer.insertSublayer(shapeLayer, below: sliderShapeLayer)
        }
        
    }
}

extension PageControl {
    public func scrollViewDidScroll(scrollView:UIScrollView) {
        self.scrollViewDidScroll(scrollView.contentOffset.x, scrollWidth: scrollView.bounds.width)
    }
    
    /**
     When the scorllview(or some thing like that) scrolling, call this method
     
     - parameter offset:      the scroll offset to the x value
     - parameter scrollWidth: single page width of scroll view(or some thing like that)
     */
    public func scrollViewDidScroll(offset:CGFloat, scrollWidth:CGFloat) {
        let percent = offset/scrollWidth
        currentPage = Int(percent)
        let singleWidth = pointSize.width + pointSpacing
        let totolWidth = contentWidth - pointSize.width/2
        // positionX is current x-alias position of slider, (startX + pointSize.width/2) is the center of the first point
        var positionX = startX + percent*singleWidth + pointSize.width/2
        if offset > CGFloat(pageCount - 1)*scrollWidth {
            positionX = startX + (1 - (percent - floor(percent)))*totolWidth + pointSize.width/2
        }else if offset < 0 {
            positionX = startX - percent*totolWidth + pointSize.width/2
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        sliderShapeLayer.position = CGPointMake(positionX, bounds.height/2)
        CATransaction.commit()
        
        // When the slider insects with the normal point, change the shape of the slider
        if  offset > CGFloat(pageCount - 1)*scrollWidth || offset < 0 {
            return
        }
        for shapeLayer in pointShapes {
            if CGRectIntersectsRect(shapeLayer.frame, sliderShapeLayer.frame) {
                // calculate the length between x-alias position of current intersects shape layer with slider shape and xalis position of slider
                let length = fabs(shapeLayer.position.x - positionX)
                if (length >= 0 && length <= (self.ellipseWidth - self.pointSize.width)) {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    let offsetX = (self.ellipseWidth - self.sliderSize.width - length)/2;
                    sliderShapeLayer.path = UIBezierPath(roundedRect: CGRectMake(-offsetX, 0, self.ellipseWidth - length, self.sliderSize.height), cornerRadius: self.sliderSize.height).CGPath
                    CATransaction.commit()
                }else {
                    let sliderPath = UIBezierPath(roundedRect: CGRectMake(0, 0, sliderSize.width, sliderSize.height), cornerRadius: sliderSize.height)
                    sliderShapeLayer.path = sliderPath.CGPath
                }
                if showText {
                    textLayer.string = String.init(format: "%.0f", arguments: [percent + 1])
                }
            }
        }
        
    }
}
