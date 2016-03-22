//
//  FollowingCollectionViewCell.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

private let ImageViewWidth:CGFloat = 85

let FollowingCollectionViewCellIdentifier = "FollowingCollectionViewCellIdentifier"

protocol FollowingCollectionViewCellDelegate:NSObjectProtocol {
    func onFollowingUser(cell:FollowingCollectionViewCell)
}

class FollowingCollectionViewCell: UICollectionViewCell {
    weak var delegate:FollowingCollectionViewCellDelegate?
    
    var imageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.layer.cornerRadius = ImageViewWidth/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIConstants.GrayBackgroundColor.CGColor
        return imageView
    }()
    
    var nameLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    var accountLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    var lineView:UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIConstants.GrayBackgroundColor
        return view
    }()
    
    var followButton:UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setImage(UIImage(named:"timeline_relationship_icon_addattention"), forState: UIControlState.Normal)
        button.setTitle("关注", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setBackgroundImage(UIConstants.DisableBackgroundColor.createImage(), forState: UIControlState.Disabled)
        return button
    }()
    
    func onFollowingUser(sender:UIButton) {
        self.delegate?.onFollowingUser(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFollowingCollectionViewCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFollowingCollectionViewCell()
    }
    
    private func setupFollowingCollectionViewCell() {
        self.followButton.addTarget(self, action: #selector(FollowingCollectionViewCell.onFollowingUser(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 5
        self.clipsToBounds = true
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(accountLabel)
        addSubview(lineView)
        addSubview(followButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.centerX.equalTo(self)
            make.width.height.equalTo(ImageViewWidth)
        }
        
        nameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp_bottom).offset(10)
            make.centerX.equalTo(self)
        }
        
        accountLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp_bottom).offset(5)
            make.centerX.equalTo(self)
        }
        
        followButton.snp_makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(30)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.bottom.equalTo(self.followButton.snp_top)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
    
    func configCell(profile:PixivProfile) {
        if let urlString =  profile.profile_image_urls_px_170x170 {
            imageView.kf_setImageWithURL(NSURL(string: urlString)!, placeholderImage: nil)
        }
        
        nameLabel.text = profile.name
        accountLabel.text = profile.account
        self.setFollowing(profile.is_following)
    }
    
    func setFollowing(following:Bool) {
        if following {
            self.followButton.enabled = false
            self.followButton.setImage(nil, forState: UIControlState.Normal)
            self.followButton.setTitle("已关注", forState: UIControlState.Normal)
        }else {
            self.followButton.setImage(UIImage(named:"timeline_relationship_icon_addattention"), forState: UIControlState.Normal)
            self.followButton.setTitle("关注", forState: UIControlState.Normal)
        }
    }
}
