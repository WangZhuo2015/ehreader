//
//  ProfileViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/17.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

class ProfileViewController: UIViewController {
    lazy var profileView:ProfileView = {
        let profileView = ProfileView(frame: CGRectZero)
        return profileView
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero)
        return tableView
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    var user:PixivUser?
    var profile:PixivProfile?
    lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    
    override func viewDidLoad() {
        self.title = "我的主页"
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(profileView)
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(ProfileViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        
        addConstraints()
        startLoading()
    }
    
    private func addConstraints() {
        profileView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    func startLoading() {
        self.user = PixivUser.currentLoginUser()
        
        if let _user = self.user {
            self.pixivProvider.getUserInfomation(_user.id, complete: { (profile, error) in
                self.backgroundView.status = BackgroundViewStatus.Hidden
                self.profileView.setUser(profile!)
            })
        }else {
            // TODO: Login
        }
    }
}
