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

class GalleryViewController: UIViewController {
    var collectionView:UICollectionView!
    var collectionWaterfallLayout:CollectionViewWaterfallLayout = CollectionViewWaterfallLayout()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    let galleryService = GalleryService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        
        collectionWaterfallLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionWaterfallLayout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        collectionWaterfallLayout.headerHeight = 10
        collectionWaterfallLayout.footerHeight = 10
        collectionWaterfallLayout.minimumColumnSpacing = 10
        collectionWaterfallLayout.minimumInteritemSpacing = 10
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionWaterfallLayout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = collectionWaterfallLayout
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: GalleryCellIdentifier)
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
        self.activityIndicator.startAnimating()
        self.galleryService.startLoading { () -> Void in
//            if !self.activityIndicator.hidden {
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.hidden = true
//                
//                self.view.addSubview(self.collectionView)
//                self.collectionView.snp_makeConstraints { (make) -> Void in
//                    make.edges.equalTo(self.view)
//                }
//            }
//            self.collectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryService.count()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryCellIdentifier, forIndexPath: indexPath) as! GalleryCell
        let gallery = galleryService.getGallery(indexPath)
        cell.configCell(gallery, collectionView: collectionView)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate, CollectionViewWaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let gallery = galleryService.getGallery(indexPath)
        var size = CGSizeZero
        if let thumbImage = gallery.image {
            size = thumbImage.size
        }else {
            size = CGSizeMake(CellWidth, 150)
        }
        size.height = size.height + CellFooterContainerViewHeight
        return size
    }
}
