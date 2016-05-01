//
//  AdvertisementManager.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/18.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit

public let splashPlacementId = "8050513034297590"
public let appKey = "1105250707"

public class AdvertisementManager: NSObject {
    public static func getInstance()->AdvertisementManager {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: AdvertisementManager = AdvertisementManager()
    }
    
    private var splashAdertisement:GDTSplashAd?
    private var nativeAdvertisement:GDTNativeAd?
    private var advertisementViewController:AdvertisementViewController = AdvertisementViewController()
    
    public func displaySplashAdvertisement(window:UIWindow) {
//        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
//            let splashAdertisement = GDTSplashAd(appkey: appKey, placementId: splashPlacementId)
//            splashAdertisement.delegate = self
//            
//            splashAdertisement.fetchDelay = 3
//            
//            let bottomView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 160))
//            let logoImageView = UIImageView(image: UIImage(named: "auspicious"))
//            bottomView.backgroundColor = UIColor.createColor(233, green: 62, blue: 83, alpha: 1)
//            bottomView.addSubview(logoImageView)
//            logoImageView.snp_makeConstraints(closure: { (make) in
//                make.width.height.equalTo(150)
//                make.trailing.bottom.equalTo(bottomView)
//            })
//            splashAdertisement.loadAdAndShowInWindow(window, withBottomView: bottomView)
//            self.splashAdertisement = splashAdertisement
//        }
        let nativeAdvertisement = GDTNativeAd(appkey: appKey, placementId: splashPlacementId)
        nativeAdvertisement.controller = advertisementViewController
        nativeAdvertisement.delegate = self
        
    }
    
    
}

extension AdvertisementManager: GDTSplashAdDelegate, GDTNativeAdDelegate {
    public func splashAdSuccessPresentScreen(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdClosed(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdDidDismissFullScreenModal(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdClicked(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdWillPresentFullScreenModal(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdApplicationWillEnterBackground(splashAd: GDTSplashAd!) {
        
    }
    
    public func splashAdFailToPresent(splashAd: GDTSplashAd!, withError error: NSError!) {
        
    }
    
//    /**
//     *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
//     */
//    -(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray;
//    
//    /**
//     *  原生广告加载广告数据失败回调
//     */
//    -(void)nativeAdFailToLoad:(NSError *)error;
//    
//    @optional
//    /**
//     *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
//     */
//    - (void)nativeAdWillPresentScreen;
//    
//    /**
//     *  原生广告点击之后应用进入后台时回调
//     */
//    - (void)nativeAdApplicationWillEnterBackground;
//    
//    /**
//     * 原生广告点击以后，内置AppStore或是内置浏览器被关闭时回调
//     */
//    - (void)nativeAdClosed;
    public func nativeAdSuccessToLoad(nativeAdDataArray: [AnyObject]!) {
        
    }
    
    public func nativeAdFailToLoad(error: NSError!) {
        
    }
    
    public func nativeAdWillPresentScreen() {
        
    }
    
    public func nativeAdApplicationWillEnterBackground() {
        
    }
    
    public func nativeAdClosed() {
        
    }
}
