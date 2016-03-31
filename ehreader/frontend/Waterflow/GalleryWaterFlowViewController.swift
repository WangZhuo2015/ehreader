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
    lazy var collectionWaterfallLayout:CollectionViewWaterfallLayout = {
        let collectionWaterfallLayout:CollectionViewWaterfallLayout = CollectionViewWaterfallLayout()
        collectionWaterfallLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionWaterfallLayout.headerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionWaterfallLayout.headerHeight = 0
        collectionWaterfallLayout.footerHeight = 0
        collectionWaterfallLayout.minimumColumnSpacing = 10
        collectionWaterfallLayout.minimumInteritemSpacing = 10
        return collectionWaterfallLayout
    }()
    
    lazy var collectionView:UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionWaterfallLayout)
        collectionView.collectionViewLayout = self.collectionWaterfallLayout
        collectionView.backgroundColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1)
        collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: GalleryCellIdentifier)
        return collectionView
    }()
    
    var currentSelectedCell:GalleryCell?
    
    var isLoadingFinished:Bool {
        if let g = self.gallery where (g.next == -1) {
            return true
        }
        return false
    }
    
    var maxScrollViewHeight:CGFloat {
        return CGFloat(self.collectionWaterfallLayout.maxHeight())
    }
    
    lazy var headerView:CurveRefreshHeaderView = {
        let headerView = CurveRefreshHeaderView(associatedScrollView: self.collectionView, withNavigationBar: true)
        return headerView
    }()
    
    lazy var footerView:CurveRefreshFooterView = {
        let footerView = CurveRefreshFooterView(associatedScrollView: self.collectionView, withNavigationBar: true)
        return footerView
    }()
    
    lazy var backgroundView:BackgroundView = {
        let backgroundView = BackgroundView(frame: CGRectZero)
        return backgroundView
    }()
    
    let galleryService = GalleryService()
    lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    var gallery:PixivIllustGallery?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
        view.addSubview(backgroundView)
        backgroundView.status = BackgroundViewStatus.Loading

        addViewConstraints()
    }
    
    deinit {
        print("deint GalleryWaterFlowViewController")
        self.currentSelectedCell = nil
        self.gallery = nil
        //fix crash bug in ios8 http://stackoverflow.com/questions/26103756/uiscrollview-internal-consistency-crash
        self.collectionView.delegate = nil;
        self.collectionView.dataSource = nil;
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
    
    private weak var originalNaivgationControllerDelegate:UINavigationControllerDelegate?
    
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
        cell.delegate = self
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                cell.configCellWithPxiv(illust)
            }
        }
        return cell
    }
}

extension GalleryWaterFlowViewController: UICollectionViewDelegate, CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                let size = CGSizeMake(CGFloat(illust.width), CGFloat(illust.height))
                return size
            }
        }
        return CGSizeZero
    }
    
    func extenalHeightForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath, calculateSize: CGSize) -> Float {
        return bottomHeight(indexPath, calculateSize: calculateSize)
    }
    
    func bottomHeight(indexPath:NSIndexPath, calculateSize: CGSize) -> Float {
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                let normalHeight = 20 + AvatarWidth + 0.5 + 20 + 10
                if let text = illust.title {
                    let titleWidth = calculateSize.width - 16
                    let titleHeight = text.heightWithConstrainedWidth(titleWidth, font: UIFont.systemFontOfSize(12))
                    let detailHeight = "\(illust.page_count) 页".heightWithConstrainedWidth(titleWidth, font: UIFont.systemFontOfSize(10))
                    
                    return Float(titleHeight + detailHeight + normalHeight)
                }
                return Float(normalHeight) + 24
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.currentSelectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? GalleryCell
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                let photoViewController = PhotoViewController()
                photoViewController.startLoading(illust)
                self.navigationController?.pushViewController(photoViewController, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.onScrollViewScrollingWithTabbar(scrollView)
    }
}

extension GalleryWaterFlowViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKindOfClass(PhotoViewController) && operation == .Push {
            let pushTransition = PushTransition()
            return pushTransition
        }else {
            return nil
        }
    }
}

extension GalleryWaterFlowViewController: TransitionDelegate {
    func currentSelectedCellForAnimation() -> GalleryCell? {
        return self.currentSelectedCell
    }
}

extension GalleryWaterFlowViewController: GalleryCellDelegate {
    func onUserAvatarClicked(cell: GalleryCell) {
        if let indexPath = self.collectionView.indexPathForCell(cell), illustId = self.gallery?.illusts[indexPath.row] {
            if let userId = PixivIllust.getIllustWithId(illustId)?.author_id {
                let otherProfileViewController = OtherProfileViewController()
                otherProfileViewController.userId = userId
                self.navigationController?.pushViewController(otherProfileViewController, animated: true)
            }
        }
        
    }
}

