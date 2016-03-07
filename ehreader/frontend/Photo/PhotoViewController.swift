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
        return imageView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRectZero)
        return progressView
    }()
    
    
    var photoUrl:String?
    var filename:NSURL!
    
    private lazy var starBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: #selector(PhotoViewController.onBookmark(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = self.starBarButton
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.progressView)
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
        let scale = self.imageSize.width/self.view.frame.width
        let height = self.imageSize.height/scale
        self.imageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.progressView.snp_bottom)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(height)
        }
        
        self.progressView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(ProgressHeight)
        }
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
}
