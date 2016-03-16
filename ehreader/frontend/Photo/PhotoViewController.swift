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
private let IllustTagCellIdentifer = "IllustTagCellIdentifer"

class PhotoViewController: UIViewController {
    var imageSize:CGSize = CGSizeZero
    
    internal lazy var imageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.backgroundColor = UIColor.createColor(130, green: 187, blue: 220, alpha: 1)
        return imageView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRectZero)
        progressView.progressTintColor = UIColor.redColor()
        return progressView
    }()
    
    internal lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView(frame: CGRectZero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    var imageViewContentRect:CGRect {
        let scale = self.imageSize.width/self.view.frame.width
        let height = self.imageSize.height/scale
        return CGRectMake(0, 64, self.view.frame.width, height)
    }
    
    
    var photoUrl:String?
    var filename:NSURL!
    var illust:PixivIllust?
    
    private lazy var starBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named:"ic_navibar_like"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoViewController.onBookmark(_:)))
        return button
    }()
    
    private lazy var downloadButton:UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named:"ic_navibar_download"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoViewController.checkLargeImage(_:)))
        return button
    }()
    
    private lazy var checkLargeImage:UIBarButtonItem = {
        let customButton = UIButton(frame: CGRectMake(0, 0, 70, 25))
        customButton.backgroundColor = UIColor.redColor()
        customButton.clipsToBounds = true
        customButton.layer.cornerRadius = 4
        customButton.setTitle("查看大图", forState: UIControlState.Normal)
        customButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        customButton.addTarget(self, action: #selector(PhotoViewController.checkLargeImage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let button = UIBarButtonItem(customView: customButton)
        return button
    }()
    
    private lazy var shareButton:UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setImage(UIImage(named:"ic_sendto"), forState: UIControlState.Normal)
        return button
    }()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var edgePanGestureRecognizer:UIScreenEdgePanGestureRecognizer = {
        let edgePanGuestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(PhotoViewController.edgePanGesture(_:)))
        edgePanGuestureRecognizer.edges = UIRectEdge.Left
        return edgePanGuestureRecognizer
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: IllustTagCellIdentifer)
        tableView.dataSource = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItems = [self.checkLargeImage, self.downloadButton, self.starBarButton]
        self.progressView.hidden = false
        self.scrollView.addSubview(self.imageView)
        self.scrollView.addSubview(self.progressView)
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.titleLabel)
        self.scrollView.addSubview(self.shareButton)
        self.scrollView.addSubview(self.tableView)
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
        //self.hideMainTabbar(true)
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
        
        self.imageView.snp_makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.scrollView)
            make.height.equalTo(height)
            make.width.equalTo(self.view)
        }
        
        self.progressView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(ProgressHeight)
        }
        
        self.titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp_bottom).offset(10)
            make.leading.equalTo(self.scrollView).offset(10)
            make.trailing.equalTo(self.shareButton.snp_leading)
        }
        
        self.shareButton.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.scrollView).offset(-10)
            make.top.equalTo(self.imageView.snp_bottom).offset(10)
            make.width.height.equalTo(32)
        }
        
        self.tableView.snp_makeConstraints { (make) in
            make.leading.equalTo(self.scrollView)
            make.trailing.equalTo(self.scrollView)
            make.top.equalTo(self.titleLabel.snp_bottom).offset(10)
            make.bottom.equalTo(self.scrollView)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if let count = self.illust?.getTags().count {
            if count > 0 && self.scrollView.subviews.contains(self.tableView) {
                self.tableView.snp_remakeConstraints { (make) in
                    make.leading.equalTo(self.scrollView)
                    make.trailing.equalTo(self.scrollView)
                    make.top.equalTo(self.titleLabel.snp_bottom).offset(10)
                    make.bottom.equalTo(self.scrollView)
                    make.height.equalTo(44*count)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onBookmark(sender:UIBarButtonItem) {
    }
    
    func checkLargeImage(sender:UIBarButtonItem) {
        
    }
    
    func downloadImage(sender:UIBarButtonItem) {
        
    }
    
    func startLoading(photoUrl:String, thumbUrl:String, imageSize:CGSize) {
        self.imageSize = imageSize
        self.photoUrl = photoUrl
        self.imageView.kf_setImageWithURL(NSURL(string:photoUrl)!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
            let progress = Float(receivedSize)/Float(totalSize)
            self.progressView.progress = progress
        }) { (image, error, cacheType, imageURL) in
            self.progressView.progress = 0
            self.progressView.hidden = true
        }
    }
    
    func startLoading(illust:PixivIllust) {
        self.imageSize = illust.imageSize()
        self.photoUrl = illust.url_medium
        self.illust = illust
        self.tableView.reloadData()
        self.updateViewConstraints()
        self.titleLabel.text = illust.title
        self.imageView.kf_setImageWithURL(NSURL(string:self.photoUrl!)!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
            let progress = Float(receivedSize)/Float(totalSize)
            self.progressView.progress = progress
        }) { (image, error, cacheType, imageURL) in
            self.progressView.progress = 0
            self.progressView.hidden = true
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

extension PhotoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        onScrollViewScrollingWithTabbar(scrollView)
    }
}

extension PhotoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.illust?.getTags().count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(IllustTagCellIdentifer)!
        cell.textLabel?.text = self.illust?.getTags()[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        cell.imageView?.image = UIImage(named: "ico_tag")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}
