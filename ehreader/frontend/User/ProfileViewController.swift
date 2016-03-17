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
    
    var user:PixivUser?
    
    override func viewDidLoad() {
        self.title = "我的主页"
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(profileView)
        addConstraints()
        
        startLoading()
    }
    
    private func addConstraints() {
        profileView.snp_makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(250)
        }
    }
    
    func startLoading() {
        self.user = PixivUser.currentLoginUser()
        
        if let _user = self.user {
            self.profileView.setUser(_user)
        }
    }
}
