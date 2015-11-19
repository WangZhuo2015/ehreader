//
//  GalleryViewController.swift
//  ehreader
//
//  Created by yrtd on 15/11/19.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import Alamofire
import Kingfisher

class GalleryViewController: UIViewController {
    var imageView:UIImageView = UIImageView(frame: CGRectZero)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        let realm = try! Realm()
        
        self.view.addSubview(imageView)
        imageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        let gallery = realm.objects(Gallery)[1]
        imageView.kf_setImageWithURL(NSURL(string: gallery.thumbnail!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            print("Image Size:\(image?.size.width), \(image?.size.height)")
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
