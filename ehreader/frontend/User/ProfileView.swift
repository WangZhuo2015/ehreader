//
//  ProfileView.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

public class ProfileView: UIView {
    public lazy var backgroundImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        return imageView
    }()
    
    public lazy var avatarView:UIView = {
        let view = UIView(frame: CGRectZero)
        return view
    }()
    
    public lazy var descriptionView:UIView = {
        let view = UIView(frame: CGRectZero)
        return view
    }()
    
    public lazy var descriptionTitleLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor.whiteColor()
        label.text = "关于我"
        label.font = UIFont.systemFontOfSize(17)
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    public lazy var descriptionLabel:UITextView = {
        let textView = UITextView(frame: CGRectZero)
        textView.textColor = UIColor.whiteColor()
        textView.font = UIFont.systemFontOfSize(13)
        textView.textAlignment = NSTextAlignment.Center
        textView.editable = false
        textView.backgroundColor = UIColor.clearColor()
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    public lazy var avatarImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        return imageView
    }()
    
    public lazy var avatarButton:UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setBackgroundImage(UIImage(named:"profileFloBtn"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named:"profileFloBtn_pressed"), forState: UIControlState.Highlighted)
        button.setTitle("查看用户详情", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setImage(UIImage(named:"profileFloArrow"), forState: UIControlState.Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 90, 0, -90)
        return button
    }()
    
    public lazy var nameLable:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(17)
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    public lazy var locationLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    public lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView(frame: CGRectZero)
        scrollView.pagingEnabled = true
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var visualEffectView:UIVisualEffectView = {
        let beffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let visualEffectView = UIVisualEffectView(effect: beffect)
        return visualEffectView
    }()
    
    public lazy var pageControl:PageControl = {
        let pageControl = PageControl(frame: CGRectZero)
        pageControl.pointSize = CGSizeMake(5, 5)
        pageControl.showText = false
        pageControl.sliderSize = CGSizeMake(5, 5)
        pageControl.ellipseWidth = 8
        pageControl.sliderFillColor = UIColor.whiteColor()
        pageControl.pointColor = UIColor.createColor(214, green: 192, blue: 177, alpha: 1)
        return pageControl
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupProfileView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProfileView()
    }
    
    private func setupProfileView() {
        self.clipsToBounds = true
        addSubview(backgroundImageView)
        addSubview(scrollView)
        
        scrollView.addSubview(avatarView)
        scrollView.addSubview(descriptionView)
        scrollView.addSubview(pageControl)
        
        avatarView.addSubview(avatarImageView)
        avatarView.addSubview(nameLable)
        avatarView.addSubview(avatarButton)
        avatarView.addSubview(locationLabel)
        
        descriptionView.addSubview(descriptionTitleLabel)
        descriptionView.addSubview(descriptionLabel)
        
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.insertSubview(visualEffectView, atIndex: 0)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        pageControl.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
            make.height.equalTo(10)
        }
        
        avatarView.snp_makeConstraints { (make) in
            make.top.bottom.leading.equalTo(self.scrollView)
            make.width.equalTo(self)
            make.height.equalTo(self)
        }
        
        descriptionView.snp_makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(self.scrollView)
            make.leading.equalTo(self.avatarView.snp_trailing)
            make.width.equalTo(self)
            make.height.equalTo(self)
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.avatarView).offset(20)
            make.width.height.equalTo(50)
            make.centerX.equalTo(self.avatarView)
        }
        
        nameLable.snp_makeConstraints { (make) in
            make.top.equalTo(self.avatarImageView.snp_bottom).offset(10)
            make.centerX.equalTo(self.avatarView)
        }
        
        locationLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.nameLable.snp_bottom).offset(10)
            make.centerX.equalTo(self.avatarView)
        }
        
        avatarButton.snp_makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(30)
            make.bottom.equalTo(self.avatarView).offset(-25)
            make.centerX.equalTo(self.avatarView)
        }
        
        descriptionLabel.snp_makeConstraints { (make) in
            make.leading.trailing.equalTo(self.descriptionView)
            make.top.equalTo(self.descriptionTitleLabel.snp_bottom).offset(10)
            make.bottom.equalTo(self.descriptionView)
        }
        
        descriptionTitleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.descriptionView).offset(20)
            make.centerX.equalTo(self.descriptionView)
        }
        
        self.visualEffectView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.backgroundImageView)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        pageControl.pageCount = 2
        pageControl.refresh()
    }
    
    public func setUser(user:PixivProfile) {
        self.avatarImageView.kf_setImageWithURL(NSURL(string: user.profile_image_urls_px_170x170!)!, placeholderImage: nil)
        self.backgroundImageView.kf_setImageWithURL(NSURL(string: user.profile_image_urls_px_170x170!)!, placeholderImage: nil)
        self.nameLable.text = user.name
        self.locationLabel.text = user.location
        self.descriptionLabel.text = user.introduction
    }
}

extension ProfileView: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.scrollViewDidScroll(scrollView)
    }
}
