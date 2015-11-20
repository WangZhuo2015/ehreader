//
//  GalleryCell.swift
//  ehreader
//
//  Created by yrtd on 15/11/19.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

let GalleryCellIdentifier = "GalleryCell"
typealias TouchEventClosure = (sender:UIButton)->Void

let CellWidth:CGFloat = 200
let CellFooterContainerViewHeight:CGFloat = 40

class GalleryCell: UICollectionViewCell {
    
    var imageView:UIImageView = UIImageView(frame: CGRectZero)
    var footerContainerView:UIView = UIView(frame: CGRectZero)
    var titleLabel:UILabel = UILabel(frame: CGRectZero)
    var subTitleLabel:UILabel = UILabel(frame: CGRectZero)
    var downloadButton:UIButton = UIButton(frame: CGRectZero)
    
    var onDownloadButtonClicked: TouchEventClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGalleryCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGalleryCell()
    }
    
    func setupGalleryCell() {
        // Add some shadow to self
        self.layer.shadowColor = UIColor.purpleColor().CGColor
        self.layer.shadowOffset = CGSizeMake(2, 3)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
        
        self.addSubview(imageView)
        imageView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.top.equalTo(self)
        }
        
        self.addSubview(footerContainerView)
        footerContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imageView.snp_bottom)
            make.bottom.leading.trailing.equalTo(self)
            make.height.equalTo(CellFooterContainerViewHeight)
        }
        
        footerContainerView.addSubview(downloadButton)
        downloadButton.setTitle("DOWNLOAD", forState: UIControlState.Normal)
        downloadButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        downloadButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        downloadButton.addTarget(self, action: "downloadButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        downloadButton.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(60)
            make.height.equalTo(footerContainerView)
            make.trailing.equalTo(footerContainerView).offset(-5)
            make.bottom.equalTo(footerContainerView).offset(-5)
        }
        
        footerContainerView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFontOfSize(13)
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(footerContainerView)
            make.leading.equalTo(footerContainerView)
            make.trailing.equalTo(downloadButton.snp_leading)
        }
        
        footerContainerView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        subTitleLabel.textAlignment = NSTextAlignment.Left
        subTitleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel).offset(5)
            make.leading.equalTo(footerContainerView)
            make.bottom.equalTo(footerContainerView)
            make.trailing.equalTo(downloadButton.snp_leading)
        }
    }
    
    func configCell(gallery:Gallery, collectionView:UICollectionView) {
//        if let thumbUri = gallery.thumbnail {
//            imageView.kf_setImageWithURL(NSURL(string: thumbUri)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
//                gallery.image = image
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    collectionView.reloadData()
//                })
//            })
//        }
        imageView.image = gallery.image
        titleLabel.text = gallery.title
        subTitleLabel.text = gallery.subtitle
    }
    
    func downloadButtonClicked(sender:UIButton) {
        self.onDownloadButtonClicked?(sender: sender)
    }
}
