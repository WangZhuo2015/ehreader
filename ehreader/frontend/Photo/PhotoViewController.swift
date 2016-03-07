//
//  PhotoViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/16.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Alamofire

private let ProgressHeight:CGFloat = 1

class PhotoViewController: UIViewController {
    var imageSize:CGSize = CGSizeZero
    
    internal lazy var imageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.backgroundColor = UIColor.createColor(130, green: 187, blue: 220, alpha: 1)
        return imageView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRectZero)
        return progressView
    }()
    
    internal lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView(frame: CGRectZero)
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    var imageViewContentRect:CGRect {
        let scale = self.imageSize.width/self.view.frame.width
        let height = self.imageSize.height/scale
        return CGRectMake(0, 64, self.view.frame.width, height)
    }
    
    
    var photoUrl:String?
    var filename:NSURL!
    
    private lazy var starBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: #selector(PhotoViewController.onBookmark(_:)))
        return button
    }()
    
    private lazy var edgePanGestureRecognizer:UIScreenEdgePanGestureRecognizer = {
        let edgePanGuestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(PhotoViewController.edgePanGesture(_:)))
        edgePanGuestureRecognizer.edges = UIRectEdge.Left
        return edgePanGuestureRecognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = self.starBarButton
        self.scrollView.addSubview(self.imageView)
        //self.scrollView.addSubview(self.progressView)
        self.view.addSubview(self.scrollView)
        self.view.addGestureRecognizer(self.edgePanGestureRecognizer)
        addConstraints()
    }
    
    private var originalNaivgationControllerDelegate:UINavigationControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(self.imageView.frame)
        
        self.originalNaivgationControllerDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(self.imageView.frame)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationController?.delegate = self.originalNaivgationControllerDelegate
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func addConstraints() {
        self.scrollView.snp_makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
        
        let height = self.imageViewContentRect.height
        //self.scrollView.contentSize = CGSizeMake( self.imageViewContentRect.size.width,  self.imageViewContentRect.size.height + 400)
        
        self.imageView.snp_makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(self.scrollView)
            make.height.equalTo(height)
            make.width.equalTo(self.view)
        }
        
//        self.progressView.snp_makeConstraints { (make) in
//            make.top.equalTo(self.snp_topLayoutGuideBottom)
//            make.leading.equalTo(self.view)
//            make.trailing.equalTo(self.view)
//            make.height.equalTo(ProgressHeight)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onBookmark(sender:UIBarButtonItem) {
    }
    
    func startLoading(photoUrl:String, thumbUrl:String, imageSize:CGSize) {
        self.imageSize = imageSize
        self.photoUrl = photoUrl
        self.imageView.kf_setImageWithURL(NSURL(string:photoUrl)!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
            let progress = Float(receivedSize)/Float(totalSize)
            self.progressView.progress = progress
        }) { (image, error, cacheType, imageURL) in
            //TODO: save the image
        }
    }
    
    private var percentDrivenTransition:UIPercentDrivenInteractiveTransition?
    
    func edgePanGesture(recognizer:UIScreenEdgePanGestureRecognizer) {
        //计算手指滑的物理距离（滑了多远，与起始位置无关）
        var progress = recognizer.translationInView(self.view).x/view.bounds.width
        //把这个百分比限制在0~1之间
        progress = min(1.0, max(0.0, progress))
        if recognizer.state == UIGestureRecognizerState.Began {
            //当手势刚刚开始，我们创建一个 UIPercentDrivenInteractiveTransition 对象
            percentDrivenTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewControllerAnimated(true)
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            //当手慢慢划入时，我们把总体手势划入的进度告诉 UIPercentDrivenInteractiveTransition 对象。
            self.percentDrivenTransition?.updateInteractiveTransition(progress)
        }else if recognizer.state == UIGestureRecognizerState.Ended || recognizer.state == UIGestureRecognizerState.Cancelled {
            if progress >= 0.1 {
                self.percentDrivenTransition?.finishInteractiveTransition()
            }else {
                self.percentDrivenTransition?.cancelInteractiveTransition()
            }
        }
    }
}

extension PhotoViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKindOfClass(GalleryWaterFlowViewController) {
            let popTransition = PopTransition()
            return popTransition
        }else {
            return nil
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController.isKindOfClass(PopTransition) {
            return self.percentDrivenTransition
        }else {
            return nil
        }
    }
}
