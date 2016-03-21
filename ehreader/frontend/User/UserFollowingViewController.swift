//
//  UserFollowingViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/21.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

private let Padding:CGFloat = 5
private let ColumnCount:CGFloat = 2

class UserFollowingViewController: UIViewController {
    lazy var collectionView:UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        view.collectionViewLayout = layout
        view.backgroundColor = UIConstants.GrayBackgroundColor
        view.registerClass(FollowingCollectionViewCell.self, forCellWithReuseIdentifier: FollowingCollectionViewCellIdentifier)
        return view
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    var profile:PixivProfile?
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
        guard let profile = self.profile else {
            return
        }
        do {
            try PixivProvider.getInstance().loginIfNeeded("zzycami", password: "13968118472q")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        PixivProvider.getInstance().usersFollowing(profile.id) { (profiles, pagination, error) in
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

extension UserFollowingViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FollowingCollectionViewCellIdentifier, forIndexPath: indexPath) as! FollowingCollectionViewCell
        let profile = self.profiles[indexPath.row]
        cell.configCell(profile)
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
