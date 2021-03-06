//
//  MeFollowingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

private let Padding:CGFloat = 5
private let ColumnCount:CGFloat = 2

class MeFollowingViewController: UIViewController {
    lazy var collectionView:UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        view.collectionViewLayout = layout
        view.backgroundColor = UIConstants.GrayBackgroundColor
        view.registerClass(FollowingCollectionViewCell.self, forCellWithReuseIdentifier: FollowingCollectionViewCellIdentifier)
        return view
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    var profiles:[PixivProfile] = []
    var pagination:Pagination = Pagination()
    var currentPage:Int = 1
    var publicity:PixivPublicity = PixivPublicity.Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        view.addSubview(self.collectionView)
        startLoading()
        
        self.view.backgroundColor = UIConstants.GrayBackgroundColor
        self.automaticallyAdjustsScrollViewInsets = true
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(MeFollowingViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        
        addConstraints()
    }
    
    func startLoading(page:Int = 1) {
        if !PixivLoginHelper.getInstance().checkLogin(self.tabBarController!) {
            return
        }
        
        PixivProvider.getInstance().meFollowing(publicity: self.publicity) { (profiles, pagination, error) in
            if error != nil {
                print("loading choice data failed:\(error?.localizedDescription)")
                self.backgroundView.status = BackgroundViewStatus.Failed
                return
            }
            self.pagination = pagination ?? Pagination()
            self.profiles = profiles
            self.collectionView.reloadData()
            self.backgroundView.status = BackgroundViewStatus.Hidden
        }
    }
    
    private func addConstraints() {
        collectionView.snp_makeConstraints { (make) in
            make.top.equalTo(self.view).offset(Padding*2)
            make.leading.equalTo(self.view).offset(Padding*2)
            make.trailing.equalTo(self.view).offset(-Padding*2)
            make.bottom.equalTo(self.view)
        }
        
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
}

extension MeFollowingViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FollowingCollectionViewCellIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        let profile = self.profiles[indexPath.row]
        cell.configCell(profile)
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let frame = collectionView.frame
        let width = (frame.width - 2*Padding*(ColumnCount - 1)) / ColumnCount
        return CGSizeMake(width, 180)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Padding
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Padding*2
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let profile = self.profiles[indexPath.row]
        let otherProfileViewController = OtherProfileViewController()
        otherProfileViewController.userId = profile.id
        self.navigationController?.pushViewController(otherProfileViewController, animated: true)
    }
}

extension MeFollowingViewController: FollowingCollectionViewCellDelegate {
    func onFollowingUser(cell: FollowingCollectionViewCell) {
        if let indexPath = self.collectionView.indexPathForCell(cell) {
            let profile = self.profiles[indexPath.row]
            self.followUser(profile, cell: cell)
        }
    }
    
    func followUser(profile:PixivProfile, cell: FollowingCollectionViewCell)  {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "关注", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) in
            self.followUserInternal(profile, publicity: PixivPublicity.Public, cell: cell)
        }))
        
        alertController.addAction(UIAlertAction(title: "悄悄关注", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) in
            self.followUserInternal(profile, publicity: PixivPublicity.Private, cell: cell)
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.popoverPresentationController?.sourceView = cell.followButton
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func followUserInternal(profile:PixivProfile ,publicity:PixivPublicity, cell: FollowingCollectionViewCell) {
        PixivProvider.getInstance().meFavoriteUsersFollow(profile.id, publicity: publicity) { (success, error) in
            if success {
                profile.is_following = true
                cell.setFollowing(true)
            }
        }
    }
}
