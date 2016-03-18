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
import Alamofire

let GalleryCellIdentifier = "GalleryCell"
typealias TouchEventClosure = (sender:UIButton)->Void

let CellWidth:CGFloat = 200
let AvatarWidth:CGFloat = 24
let CellFooterContainerViewHeight:CGFloat = 20 + AvatarWidth + 0.5 + 80 + 10

class GalleryCell: UICollectionViewCell {
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.backgroundColor = UIColor.createColor(130, green: 187, blue: 220, alpha: 1)
        return imageView
    }()
    
    lazy var imageBackgroundView:UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.createColor(130, green: 187, blue: 220, alpha: 1)
        return view
    }()
    
    lazy var titleLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.createColor(100, green: 100, blue: 100, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var lineView:UIView = {
        let line = UIView(frame:CGRectZero)
        line.backgroundColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1)
        return line
    }()
    
    lazy var avatarImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.layer.cornerRadius = AvatarWidth/2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1).CGColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    lazy var usernameLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    lazy var progressView:UIProgressView = {
        let progressView = UIProgressView(frame: CGRectZero)
        progressView.progressTintColor = UIColor.redColor()
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGalleryCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGalleryCell()
    }
    
    func setupGalleryCell() {
        self.backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 5
        self.clipsToBounds = true
        
        addSubview(imageBackgroundView)
        addSubview(imageView)
        addSubview(self.titleLabel)
        addSubview(lineView)
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(progressView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        imageView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.top.equalTo(self)
        }
        
        imageBackgroundView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.imageView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp_bottom).offset(10)
            make.leading.equalTo(self).offset(8)
            make.trailing.equalTo(self).offset(-8)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(0.5)
            make.top.equalTo(self.titleLabel.snp_bottom).offset(10)
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.leading.equalTo(self).offset(8)
            make.width.height.equalTo(AvatarWidth)
            make.bottom.equalTo(self).offset(-10)
            make.top.equalTo(self.lineView.snp_bottom).offset(10)
        }
        
        usernameLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.avatarImageView.snp_trailing).offset(10)
            make.centerY.equalTo(self.avatarImageView)
            make.trailing.equalTo(self)
        }
        
        progressView.snp_makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp_bottom)
            make.leading.equalTo(self.imageView)
            make.trailing.equalTo(self.imageView)
            make.height.equalTo(1)
        }
    }
    
    func configCell(gallery:Gallery, collectionView:UICollectionView) {
        imageView.image = gallery.image
        titleLabel.text = gallery.title
    }
    
    
    func configCellWithPxiv(illust:PixivIllust) -> Void {
        self.imageView.alpha = 0
        self.progressView.hidden = false
        self.progressView.progress = 0
        self.titleLabel.text = illust.title
        self.titleLabel.numberOfLines = 0
        self.avatarImageView.kf_setImageWithURL(NSURL(string: illust.profile_url_px_50x50!)!, placeholderImage: nil)
        self.usernameLabel.text = illust.name
        
        KingfisherManager.sharedManager.cache.clearMemoryCache()
        KingfisherManager.sharedManager.downloader.requestModifier = {(request:NSMutableURLRequest)->Void in
            let refrer = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=\(illust.illust_id)"
            let agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4"
            request.setValue(refrer, forHTTPHeaderField: "Referer")
            request.setValue(agent, forHTTPHeaderField: "User-Agent")
        }
        
        self.imageView.kf_setImageWithURL(NSURL(string: illust.getMediaImageUrl()!)!, placeholderImage: nil, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) in
            let progress = Float(receivedSize)/Float(totalSize)
            self.progressView.progress = progress
        }) { (image, error, cacheType, imageURL) in
            self.progressView.progress = 0
            self.progressView.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                self.imageView.alpha = 1
            })
        }
    }
}
