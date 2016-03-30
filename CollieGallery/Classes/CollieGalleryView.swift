//
//  CollieGalleryView.swift
//
//  Copyright (c) 2016 Guilherme Munhoz <g.araujo.munhoz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import UCZProgressView
import Kingfisher

internal class CollieGalleryView: UIView, UIScrollViewDelegate {
    
    // MARK: - Internal properties
    var delegate: CollieGalleryViewDelegate?
    var picture: CollieGalleryPicture!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var activityIndicator: UCZProgressView!
    
    
    // MARK: - Private properties
    private var options: CollieGalleryOptions!
    private var theme: CollieGalleryTheme!
    private var scrollFrame: CGRect {
        get {
            return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        }
    }
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(picture: CollieGalleryPicture, frame: CGRect, options: CollieGalleryOptions, theme: CollieGalleryTheme) {
        self.init(frame: frame)
        
        self.picture = picture
        self.options = options
        self.theme = theme
        
        self.setupView()
        self.setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // MARK: - Private functions
    private func setupView() {
        self.backgroundColor = UIColor.clearColor()
        
        self.setupScrollView()
        self.setupImageView()
        self.setupActivityIndicatorView()
    }

    private func setupScrollView() {
        self.scrollView = UIScrollView(frame: self.scrollFrame)
        self.scrollView.delegate = self
        self.scrollView.contentSize = self.frame.size
        self.scrollView.bounces = false
        self.scrollView.scrollEnabled = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = self.options.maximumZoomScale
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = self.options.enableZoom
        
        self.addSubview(self.scrollView)
    }
    
    private func setupImageView() {
        self.imageView = UIImageView(frame: self.scrollFrame)
        self.imageView.contentMode = UIViewContentMode.ScaleToFill
        self.imageView.backgroundColor = UIColor.clearColor()
        
        self.scrollView.addSubview(self.imageView)
    }
    
    private func setupActivityIndicatorView() {
        activityIndicator = UCZProgressView(frame: CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        activityIndicator.frame = imageView.bounds
        activityIndicator.showsText = true
        activityIndicator.indeterminate = true
        activityIndicator.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        activityIndicator.usesVibrancyEffect = true
        activityIndicator.lineWidth = 1
        activityIndicator.radius = 20
        activityIndicator.textSize = 12
        activityIndicator.alpha = 0.9
        
        self.addSubview(self.activityIndicator)
    }

    private func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CollieGalleryView.viewTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CollieGalleryView.viewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CollieGalleryView.viewPressed(_:)))
        longPressRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(longPressRecognizer)
        
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
    }
    
    private func zoomToScale(newZoomScale: CGFloat, pointInView: CGPoint) {
        let scrollViewSize = self.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, width, height);
        
        self.scrollView.zoomToRect(rectToZoomTo, animated: true)
    }

    private func centerImageViewToSuperView() {
        var zoomFrame = self.imageView.frame
        
        if(zoomFrame.size.width < scrollView.bounds.size.width) {
            zoomFrame.origin.x = (scrollView.bounds.size.width - zoomFrame.size.width) / 2.0
            
        } else {
            zoomFrame.origin.x = 0.0
            
        }
        
        if(zoomFrame.size.height < scrollView.bounds.size.height) {
            zoomFrame.origin.y = (scrollView.bounds.size.height - zoomFrame.size.height) / 2.0
            
        } else {
            zoomFrame.origin.y = 0.0
            
        }
        
        self.imageView.frame = zoomFrame
    }
    
    private func updateImageViewSize() {
        if let image = self.imageView.image {
            var imageSize = CGSizeMake(image.size.width / image.scale, image.size.height / image.scale)
            
            let widthRatio = imageSize.width / self.bounds.size.width
            let heightRatio = imageSize.height / self.bounds.size.height
            let imageScaleRatio = max(widthRatio, heightRatio)
            
            imageSize = CGSizeMake(imageSize.width / imageScaleRatio, imageSize.height / imageScaleRatio)
            
            self.imageView.frame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)
            
            self.restoreZoom(false)
            self.centerImageViewToSuperView()
        }
    }
    
    
    // MARK: - Internal functions
    func zoomToPoint(pointInView: CGPoint) {
        var newZoomScale = self.scrollView.minimumZoomScale
        
        if self.scrollView.zoomScale < (self.scrollView.maximumZoomScale / 2) {
            newZoomScale = self.options.maximumZoomScale
        }
        
        self.zoomToScale(newZoomScale, pointInView: pointInView)
    }

    func restoreZoom(animated: Bool = true) {
        if animated {
            self.zoomToScale(self.scrollView.minimumZoomScale, pointInView: CGPointZero)
        } else {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        }
    }
    
    func loadImage() {
        if self.imageView.image == nil {
            if let image = self.picture.image {
                self.imageView.image = image
                self.updateImageViewSize()
                
            } else if let url = self.picture.url {
                
                
                KingfisherManager.sharedManager.downloader.requestModifier = {(request:NSMutableURLRequest)->Void in
                    for (field, value) in self.picture.httpHeader {
                        request.setValue(value, forHTTPHeaderField: field)
                    }
                }
                
                self.imageView.kf_setImageWithURL(NSURL(string:url)!, placeholderImage: self.picture.placeholder, optionsInfo: nil, progressBlock: {[weak self](receivedSize, totalSize)  in
                    let progress = CGFloat(receivedSize)/CGFloat(totalSize)
                    self?.activityIndicator.progress = progress
                }) {[weak self] (image, error, cacheType, imageURL) in
                    if image != nil {
                        self?.imageView.image = image
                        self?.updateImageViewSize()
                        self?.activityIndicator.progress = 1
                        self?.activityIndicator.progressAnimiationDidStop({
                            self?.activityIndicator.removeFromSuperview()
                        })
                    }
                }
            }
        }
    }
    
    func clearImage() {
        self.imageView.image = nil
    }

    
    // MARK: - UIView methods
    override func layoutSubviews() {
        self.scrollView.frame = self.scrollFrame
        self.scrollView.contentSize = self.scrollView.frame.size
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        self.updateImageViewSize()
    }
    
    
    // MARK: - UIGestureRecognizer handlers
    func viewPressed(recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            if let delegate = self.delegate {
                delegate.galleryViewPressed(self)
            }
        }
    }
    
    func viewTapped(recognizer: UITapGestureRecognizer) {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.restoreZoom()
            
        }
        
        if let delegate = self.delegate {
            delegate.galleryViewTapped(self)
        }
    }

    func viewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomToPoint(pointInView)
    }
    
    
    //  MARK: - UIScrollView delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        if (self.scrollView.zoomScale > self.scrollView.maximumZoomScale) {
            self.scrollView.zoomScale = self.scrollView.maximumZoomScale
        }

        self.centerImageViewToSuperView()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if let delegate = self.delegate {
            if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
                delegate.galleryViewDidRestoreZoom(self)
                
            } else {
                delegate.galleryViewDidZoomIn(self)
                
            }
        }
        
        let oldState = self.scrollView.scrollEnabled
        
        self.scrollView.scrollEnabled = (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        
        if let delegate = self.delegate where self.scrollView.scrollEnabled != oldState {
            if self.scrollView.scrollEnabled {
                delegate.galleryViewDidEnableScroll(self)
            } else {
                delegate.galleryViewDidDisableScroll(self)
            }
        }
    }
}
