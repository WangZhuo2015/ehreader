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
        collectionWaterfallLayout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        collectionWaterfallLayout.headerHeight = 10
        collectionWaterfallLayout.footerHeight = 10
        collectionWaterfallLayout.minimumColumnSpacing = 10
        collectionWaterfallLayout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionWaterfallLayout)
        collectionView.collectionViewLayout = collectionWaterfallLayout
        collectionView.backgroundColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1)
        collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: GalleryCellIdentifier)
        return collectionView
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    let galleryService = GalleryService()
    private lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    private var gallery:PixivIllustGallery?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(GalleryCollectionViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        
        addConstraints()
        startLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoading() {
        do {
            try pixivProvider.loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        pixivProvider.getRankingAll(PixivRankingMode.Daily, page: 1) { (gallery, error) in
            if error != nil || gallery == nil{
                print("loading choice data failed:\(error!.localizedDescription)")
                self.backgroundView.status = BackgroundViewStatus.Failed
                return
            }
            
            self.gallery = gallery
            
            self.collectionView.reloadData()
            self.backgroundView.status = BackgroundViewStatus.Hidden
        }
    }
    
    private func addConstraints() {
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        self.collectionView.snp_makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.leading.trailing.bottom.equalTo(self.view)
        }
    }
}

extension GalleryWaterFlowViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gallery?.illusts.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryCellIdentifier, forIndexPath: indexPath) as! GalleryCell
        let illust = self.gallery!.illusts[indexPath.row]
        cell.configCellWithPxiv(illust)
        return cell
    }
}

extension GalleryWaterFlowViewController: UICollectionViewDelegate, CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let illust = self.gallery!.illusts[indexPath.row]
        let size = CGSizeMake(CGFloat(illust.width), CGFloat(illust.height))
        return size
    }
}

