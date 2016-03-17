//
//  GalleryViewController.swift
//  ehreader
//
//  Created by yrtd on 15/11/19.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import Alamofire
import Kingfisher

class GalleryWaterFlowViewController: UIViewController {
    var collectionView:UICollectionView = {
        let collectionWaterfallLayout:CollectionViewWaterfallLayout = CollectionViewWaterfallLayout()
        collectionWaterfallLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionWaterfallLayout.headerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionWaterfallLayout.headerHeight = 0
        collectionWaterfallLayout.footerHeight = 0
        collectionWaterfallLayout.minimumColumnSpacing = 10
        collectionWaterfallLayout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionWaterfallLayout)
        collectionView.collectionViewLayout = collectionWaterfallLayout
        collectionView.backgroundColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1)
        collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: GalleryCellIdentifier)
        return collectionView
    }()
    
    
    lazy var headerView:CurveRefreshHeaderView = {
        let headerView = CurveRefreshHeaderView(associatedScrollView: self.collectionView, withNavigationBar: true)
        return headerView
    }()
    
    lazy var footerView:CurveRefreshFooterView = {
        let footerView = CurveRefreshFooterView(associatedScrollView: self.collectionView, withNavigationBar: true)
        return footerView
    }()
    
    lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    let galleryService = GalleryService()
    lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    var gallery:PixivIllustGallery?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.title = rankingTypes[PixivRankingMode.Daily]
        
        self.view.addSubview(collectionView)
        backgroundView.status = BackgroundViewStatus.Loading
        view.addSubview(backgroundView)

        addViewConstraints()
    }
    
    func addViewConstraints() {
        backgroundView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        self.collectionView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view)
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }
    
    private var originalNaivgationControllerDelegate:UINavigationControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.originalNaivgationControllerDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        super.navigationController?.delegate = self.originalNaivgationControllerDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var rankingMode:PixivRankingMode = PixivRankingMode.Daily
    var currentPage:Int = 1
    
}

extension GalleryWaterFlowViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gallery?.illusts.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryCellIdentifier, forIndexPath: indexPath) as! GalleryCell
        if let illust = self.gallery?.illusts[indexPath.row] {
            cell.configCellWithPxiv(illust)
        }
        return cell
    }
}

extension GalleryWaterFlowViewController: UICollectionViewDelegate, CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let illust = self.gallery!.illusts[indexPath.row]
        let size = CGSizeMake(CGFloat(illust.width), CGFloat(illust.height))
        return size
    }
    
    func extenalHeightForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath, calculateSize: CGSize) -> Float {
        return bottomHeight(indexPath, calculateSize: calculateSize)
    }
    
    func bottomHeight(indexPath:NSIndexPath, calculateSize: CGSize) -> Float {
        let illust = self.gallery!.illusts[indexPath.row]
        let normalHeight = 20 + AvatarWidth + 0.5 + 20
        if let text = illust.title {
            let titleWidth = calculateSize.width - 16
            let titleHeight = text.contentRect(UIFont.systemFontOfSize(12), maxSize: CGSizeMake(titleWidth, CGFloat(MAXFLOAT))).height
            return Float(titleHeight + normalHeight)
        }
        return Float(normalHeight) + 24
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoViewController = PhotoViewController()
        let illust = self.gallery!.illusts[indexPath.row]
        photoViewController.startLoading(illust)
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.onScrollViewScrollingWithTabbar(scrollView)
    }
}

extension GalleryWaterFlowViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKindOfClass(PhotoViewController) {
            let pushTransition = PushTransition()
            return pushTransition
        }else {
            return nil
        }
    }
}


