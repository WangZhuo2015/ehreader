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
import JTSImageViewController

private let ProgressHeight:CGFloat = 1
private let IllustTagCellIdentifer = "IllustTagCellIdentifer"

class PhotoViewController: UIViewController {
    var imageSize:CGSize = CGSizeZero
    
    internal lazy var imageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.backgroundColor = UIColor.createColor(130, green: 187, blue: 220, alpha: 1)
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.checkLargeImage(_:)))
        imageView.addGestureRecognizer(tapGuesture)
        imageView.userInteractionEnabled = true
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
        let button = UIBarButtonItem(image: UIImage(named:"ic_navibar_download"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoViewController.downloadImage(_:)))
        return button
    }()
    
    private lazy var checkLargeImage:UIBarButtonItem = {
        let customButton = UIButton(frame: CGRectMake(0, 0, 70, 25))
        customButton.setBackgroundImage(UIColor.redColor().createImage(), forState: UIControlState.Normal)
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
        tableView.delegate = self
        return tableView
    }()
    
    lazy var avatarImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.layer.cornerRadius = AvatarWidth/2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIConstants.GrayBackgroundColor.CGColor
        imageView.layer.borderWidth = 0.5
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.openUserDetail))
        imageView.addGestureRecognizer(tapGuesture)
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    lazy var usernameLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.openUserDetail))
        label.addGestureRecognizer(tapGuesture)
        label.userInteractionEnabled = true
        return label
    }()
    
    lazy var lineView:UIView = {
        let line = UIView(frame:CGRectZero)
        line.backgroundColor = UIConstants.GrayBackgroundColor
        return line
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
        self.scrollView.addSubview(self.avatarImageView)
        self.scrollView.addSubview(self.usernameLabel)
        self.scrollView.addSubview(self.lineView)
        self.view.addGestureRecognizer(self.edgePanGestureRecognizer)
        addConstraints()
    }
    
    deinit {
        print("deinit PhotoViewController")
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
            make.trailing.equalTo(self.view)
        }
        
        self.shareButton.snp_makeConstraints { (make) in
            make.trailing.equalTo(self.scrollView).offset(-10)
            make.width.height.equalTo(32)
            make.bottom.equalTo(self.lineView.snp_top).offset(-5)
        }
        
        self.tableView.snp_makeConstraints { (make) in
            make.leading.equalTo(self.scrollView)
            make.trailing.equalTo(self.scrollView)
            make.top.equalTo(self.lineView.snp_bottom)
            make.bottom.equalTo(self.scrollView)
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.leading.equalTo(self.scrollView).offset(10)
            make.width.height.equalTo(AvatarWidth)
            make.top.equalTo(self.titleLabel.snp_bottom).offset(10)
        }
        
        usernameLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.avatarImageView.snp_trailing).offset(10)
            make.centerY.equalTo(self.avatarImageView)
            make.trailing.equalTo(self.shareButton.snp_leading)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.scrollView)
            make.height.equalTo(0.5)
            make.top.equalTo(self.avatarImageView.snp_bottom).offset(10)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if let count = self.illust?.getTagArray().count {
            if count > 0 && self.scrollView.subviews.contains(self.tableView) {
                self.tableView.snp_remakeConstraints { (make) in
                    make.leading.equalTo(self.scrollView)
                    make.trailing.equalTo(self.scrollView)
                    make.top.equalTo(self.lineView.snp_bottom)
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
        if let illust = self.illust {
            PixivProvider.getInstance().meFavoriteWorksAdd(illust.illust_id, publicity: PixivPublicity.Public) { (success, error) in
                if success {
                    sender.image = UIImage(named: "ic_navibar_liked")
                }else {
                    //TODO: Give failed hint
                }
            }
        }
        
    }
    
    func checkLargeImage(sender:UIBarButtonItem) {
        guard let largeImageUrl = self.illust?.url_large else {
            return
        }
        guard let imageUrl = self.photoUrl else {
            return
        }
        
        guard let illustId = illust?.illust_id else {
            return
        }
        
        if let largeImage = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(largeImageUrl) {
            displayImageViewer(largeImage, imageUrl: largeImageUrl, placeholderImageKey: imageUrl)
        }else {
            // download the image
            for subview in self.imageView.subviews {
                if subview.isKindOfClass(UCZProgressView) {
                    return
                }
            }
            let imageProgressView = UCZProgressView(frame: CGRectMake(0, 0, imageView.bounds.width, imageView.bounds.height))
            imageProgressView.frame = imageView.bounds
            imageProgressView.showsText = true
            imageProgressView.indeterminate = true
            imageProgressView.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            imageProgressView.usesVibrancyEffect = true
            imageProgressView.lineWidth = 1
            imageProgressView.radius = 20
            imageProgressView.textSize = 12
            imageProgressView.alpha = 0.9
            imageView.addSubview(imageProgressView)
            
            
            KingfisherManager.sharedManager.downloader.requestModifier = {(request:NSMutableURLRequest)->Void in
                let refrer = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=\(illustId)"
                let agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4"
                request.setValue(refrer, forHTTPHeaderField: "Referer")
                request.setValue(agent, forHTTPHeaderField: "User-Agent")
            }
            
            let placeholderImage = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(imageUrl)
            
            self.imageView.kf_setImageWithURL(NSURL(string:largeImageUrl)!, placeholderImage: placeholderImage, optionsInfo: nil, progressBlock: {(receivedSize, totalSize)  in
                let progress = CGFloat(receivedSize)/CGFloat(totalSize)
                imageProgressView.progress = progress
            }) {[weak self] (image, error, cacheType, imageURL) in
                if image != nil {
                    imageProgressView.progress = 1
                    imageProgressView.progressAnimiationDidStop({
                        self?.displayImageViewer(image!, imageUrl: largeImageUrl, placeholderImageKey: imageUrl)
                    })
                    imageProgressView.removeFromSuperview()
                }
            }
        }
    }
    
    func displayImageViewer(image:UIImage, imageUrl:String, placeholderImageKey:String) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = image
        imageInfo.imageURL = NSURL(string: imageUrl)
        if let image = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(placeholderImageKey) {
            imageInfo.placeholderImage = image
        }
        imageInfo.referenceRect = self.imageView.frame
        imageInfo.referenceView = self.imageView.superview
        imageInfo.referenceContentMode = self.imageView.contentMode
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    func downloadImage(sender:UIBarButtonItem) {
        guard let imageUrl = self.photoUrl else {
            return
        }
        if let largeImageUrl = self.illust?.url_large {
            if let image = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(largeImageUrl) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(PhotoViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                return
            }
        }
        
        if let image = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(imageUrl) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(PhotoViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(image:UIImage, didFinishSavingWithError:NSError, contextInfo:UnsafeMutablePointer<Void>) {
        print("save complete")
    }
    
    func openUserDetail() {
        if let userId = self.illust?.author_id {
            let otherProfileViewController = OtherProfileViewController()
            otherProfileViewController.userId = userId
            self.navigationController?.pushViewController(otherProfileViewController, animated: true)
        }
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
        self.photoUrl = illust.getMediaImageUrl()
        self.illust = illust
        if illust.favorite_id > 0 {
            self.starBarButton.image = UIImage(named: "ic_navibar_liked")
        }else {
            self.starBarButton.image = UIImage(named: "ic_navibar_like")
        }
        self.tableView.reloadData()
        self.updateViewConstraints()
        self.titleLabel.text = illust.title
        self.avatarImageView.kf_setImageWithURL(NSURL(string: illust.profile_url_px_50x50!)!, placeholderImage: nil)
        self.usernameLabel.text = illust.name
        
        
        if let largeImageUrl = illust.url_large {
            if let largeImage = ImageCache.defaultCache.retrieveImageInDiskCacheForKey(largeImageUrl) {
                self.imageView.image = largeImage
            }
        }
        if self.imageView.image == nil {
            self.imageView.kf_setImageWithURL(NSURL(string:self.photoUrl!)!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
                let progress = Float(receivedSize)/Float(totalSize)
                self.progressView.progress = progress
            }) { (image, error, cacheType, imageURL) in
                self.progressView.progress = 0
                self.progressView.hidden = true
            }
        }
        
        loadIllustDetail()
    }
    
    func loadIllustDetail() {
        guard let illustId = self.illust?.illust_id else {
            return
        }
        PixivProvider.getInstance().getWorkInformation(illustId) { (illust, error) in
            self.illust = illust
            if self.illust == nil {
                return
            }
            if illust!.favorite_id > 0 {
                self.starBarButton.image = UIImage(named: "ic_navibar_liked")
            }else {
                self.starBarButton.image = UIImage(named: "ic_navibar_like")
            }
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
        if toVC.isKindOfClass(GalleryWaterFlowViewController)
            || (toVC.isKindOfClass(OtherProfileViewController) && operation == .Pop)
            || (toVC.isKindOfClass(SearchResultViewController) && operation == .Pop){
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
        return self.illust?.getTagArray().count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(IllustTagCellIdentifer)!
        cell.textLabel?.text = self.illust?.getTagArray()[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        cell.imageView?.image = UIImage(named: "ico_tag")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchResultViewController = SearchResultViewController()
        if let query = self.illust?.getTagArray()[indexPath.row] {
            searchResultViewController.startSearching(query)
        }
        self.navigationController?.pushViewController(searchResultViewController, animated: true)
    }
}
