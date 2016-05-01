//
//  ViewController.swift
//  ehreader
//
//  Created by yrtd on 15/11/16.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit

class AdvertisementViewController: UIViewController {
    var nativeAdvertisement:GDTNativeAd = GDTNativeAd(appkey: appKey, placementId: splashPlacementId)
    var currentAdvertisemntData:GDTNativeAdData?
    
    private var advertisementView:UIView = {
        let view = UIView(frame: CGRectZero)
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nativeAdvertisement.controller = self
        nativeAdvertisement.delegate = self
        nativeAdvertisement.loadAd(1)
        
        view.addSubview(advertisementView)
        addConstraints()
    }
    
    func addConstraints() {
        advertisementView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension AdvertisementViewController:GDTNativeAdDelegate {
    internal func nativeAdSuccessToLoad(nativeAdDataArray: [AnyObject]!) {
        print(nativeAdDataArray)
    }
    
    internal func nativeAdFailToLoad(error: NSError!) {
        
    }
    
    internal func nativeAdWillPresentScreen() {
        
    }
    
    internal func nativeAdApplicationWillEnterBackground() {
        
    }
    
    internal func nativeAdClosed() {
        
    }
}

