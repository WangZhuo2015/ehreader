//
//  Constants.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/13.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit


public let ApplicationSupportDirectory:String? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

public let CachesDirectory:String? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

public let DocumentDirectory:String? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

public let LibraryDirectory:String? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

public let TemporaryDirectory:String = NSTemporaryDirectory()

public let MainBundleDirectory:String? = NSBundle.mainBundle().resourcePath

func autoCalculateCapacity(capacity:Int)->String {
    if capacity < 1024 {
        return "\(capacity) B"
    }else if capacity < 1024*1024 {
        let size = capacity/1024
        return "\(size) K"
    }else if capacity < 1024*1024*1024 {
        let size = capacity/1024/1024
        return "\(size) M"
    }else {
        let size = capacity/1024/1024/1024
        return "\(size) G"
    }
}

/**
 获取当前设备的剩余的磁盘空间大小
 
 - returns: 剩余的磁盘空间大小
 */
public func getFreeDiskspace()throws->Float {
    var totalFreeSpace:Float = 0
    let atrributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(DocumentDirectory!)
    if let freeFileSystemSizeInBytes = atrributes[NSFileSystemFreeSize] as? NSNumber {
        totalFreeSpace = freeFileSystemSizeInBytes.floatValue
    }
    return totalFreeSpace
}


let API_URL = "http://g.e-hentai.org/api.php"
let API_URL_EX = "http://exhentai.org/api.php"

let BASE_URL = "http://g.e-hentai.org"
let BASE_URL_EX = "http://exhentai.org"

let GALLERY_URL = "http://g.e-hentai.org/g/%d/%@"
let GALLERY_URL_EX = "http://exhentai.org/g/%d/%@"

let PHOTO_URL = "http://g.e-hentai.org/s/%@/%d-%d"
let PHOTO_URL_EX = "http://exhentai.org/s/%@/%d-%d"

let IMAGE_SEARCH_URL = "http://ul.e-hentai.org/image_lookup.php"
let IMAGE_SEARCH_URL_EX = "http://ul.exhentai.org/image_lookup.php"

let HATHDL_URL = "http://g.e-hentai.org/hathdler.php?gid=%d&t=%@"
let THUMBNAIL_URL = "http://ehgt.org/t/%s/%s/%s_l.jpg"

let PHOTO_PER_PAGE = 40


let DefaultNetworkTimeInterval:NSTimeInterval = 20

extension UIViewController {
    private struct AssociatedKeys {
        static var lastPositionKey = "UIViewController.lastPosition"
    }

    private var lastPosition:CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastPositionKey) as? CGFloat ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastPositionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func onScrollViewScrollingWithTabbar(scrollView:UIScrollView) {
        guard let mainTabbarController = self.tabBarController as? MainTabbarController else {
            return
        }
        let currentPosition = scrollView.contentOffset.y
        if currentPosition - lastPosition > 20 && currentPosition > 0 {
            lastPosition = currentPosition
            mainTabbarController.hideTabbar(true)
        }else if (lastPosition - currentPosition > 20) && (currentPosition < scrollView.contentSize.height - scrollView.bounds.height - 20) {
            lastPosition = currentPosition
            mainTabbarController.displayTabbar(true)
        }
    }
    
    func hideMainTabbar(animated:Bool) {
        guard let mainTabbarController = self.tabBarController as? MainTabbarController else {
            return
        }
        mainTabbarController.hideTabbar(animated)
    }
    
    func displayMainTabbar(animated:Bool) {
        guard let mainTabbarController = self.tabBarController as? MainTabbarController else {
            return
        }
        mainTabbarController.displayTabbar(animated)
    }
}

public struct UIConstants {
    public static let DefaultBlackTextColor:UIColor = UIColor.createColor(30, green: 30, blue: 30, alpha: 1)
    public static let GrayBackgroundColor:UIColor = UIColor.createColor(220, green: 220, blue: 224, alpha: 1)
    public static let DisableBackgroundColor:UIColor = UIColor.createColor(239, green: 239, blue: 239, alpha: 1)
}
