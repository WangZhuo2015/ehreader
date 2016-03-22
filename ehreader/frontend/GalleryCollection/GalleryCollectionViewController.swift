//
//  GalleryCollectionViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/2/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

private let GalleryPadding:CGFloat = 2.5
private let GalleryColumnCount:CGFloat = 3

class GalleryCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView:UICollectionView!
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    private lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    
    private var gallery:PixivIllustGallery?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(GalleryCollectionViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        
        let flowLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
    }

}

extension GalleryCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gallery?.illusts.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryCollectionViewCellIdentifer, forIndexPath: indexPath) as! GalleryCollectionViewCell
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                collectionCell.imageView.kf_setImageWithURL(NSURL(string: illust.url_px_128x128!)!)
            }
        }
        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let frame = collectionView.frame
        let width = (frame.width - 2*GalleryPadding*(GalleryColumnCount - 1)) / GalleryColumnCount
        return CGSizeMake(width, width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return GalleryPadding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return GalleryPadding*2
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoViewController = PhotoViewController()
        if let illustId = self.gallery?.illusts[indexPath.row] {
            if let illust = PixivIllust.getIllustWithId(illustId) {
                photoViewController.startLoading(illust.url_px_480mw!, thumbUrl: illust.url_px_128x128!, imageSize: CGSizeZero)
            }
        }
        
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }
}

