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

private let ProfileTableViewCellIdentifier = "ProfileTableViewCellIdentifier"

private var bookmarkTitles:[String] = ["收藏的书签", "非公开书签"]

private var followingTitles:[String] = ["关注的用户", "悄悄关注的用户", "互相关注的朋友"]

private var titleValues:[[String]] = [bookmarkTitles, followingTitles]

private let titles:[String] = ["书签", "关注"]

class ProfileViewController: UIViewController {
    lazy var profileView:ProfileView = {
        let profileView = ProfileView(frame: CGRectZero)
        return profileView
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ProfileTableViewCellIdentifier)
        return tableView
    }()
    
    lazy var settingBarButtonItem:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named:"setting"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ProfileViewController.openSetting(_:)))
        return barButtonItem
    }()
    
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    var user:PixivUser?
    var profile:PixivProfile?
    lazy var pixivProvider:PixivProvider = PixivProvider.getInstance()
    
    override func viewDidLoad() {
        self.title = "我的主页"
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = self.settingBarButtonItem
        
        view.addSubview(profileView)
        view.addSubview(tableView)
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: #selector(ProfileViewController.startLoading), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        
        addConstraints()
        startLoading()
        self.displayMainTabbar(true)
    }
    
    private func addConstraints() {
        profileView.snp_makeConstraints { (make) in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(self.profileView.snp_bottom)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    func startLoading() {
        self.user = PixivUser.currentLoginUser()
        
        if let _user = self.user {
            self.pixivProvider.getUserInfomation(Int(_user.id)!, complete: { (profile, error) in
                self.backgroundView.status = BackgroundViewStatus.Hidden
                self.profileView.setUser(profile!)
            })
        }else {
            // TODO: Login
        }
    }
    
    func openSetting(sender:UIBarButtonItem) {
        
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titleValues.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleValues[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProfileTableViewCellIdentifier)!
        cell.textLabel?.text = titleValues[indexPath.section][indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let favoriteWorksViewController = MeFavoriteWorksViewController()
            favoriteWorksViewController.title = titleValues[indexPath.section][indexPath.row]
            favoriteWorksViewController.currentPublicity = PixivPublicity.Public
            self.navigationController?.pushViewController(favoriteWorksViewController, animated: true)
        }else if indexPath.section == 0 && indexPath.row == 1 {
            let favoriteWorksViewController = MeFavoriteWorksViewController()
            favoriteWorksViewController.title = titleValues[indexPath.section][indexPath.row]
            favoriteWorksViewController.currentPublicity = PixivPublicity.Private
            self.navigationController?.pushViewController(favoriteWorksViewController, animated: true)
        }else if indexPath.section == 1 && indexPath.row == 0 {
            let meFollowingViewController = MeFollowingViewController()
            meFollowingViewController.publicity = PixivPublicity.Public
            meFollowingViewController.title = titleValues[indexPath.section][indexPath.row]
            self.navigationController?.pushViewController(meFollowingViewController, animated: true)
        }else if indexPath.section == 1 && indexPath.row == 1 {
            let meFollowingViewController = MeFollowingViewController()
            meFollowingViewController.publicity = PixivPublicity.Private
            meFollowingViewController.title = titleValues[indexPath.section][indexPath.row]
            self.navigationController?.pushViewController(meFollowingViewController, animated: true)
        }
    }
}
