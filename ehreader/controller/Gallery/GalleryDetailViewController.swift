//
//  GalleryDetailViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/15.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

class GalleryDetailViewController: UIViewController {
    @IBOutlet weak var contentImageView:UIImageView!
    @IBOutlet weak var visualEffectView:UIVisualEffectView!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var pageLabel:UILabel!
    @IBOutlet weak var ratingBar:RatingBar!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subTitleLabel:UILabel!
    @IBOutlet weak var readButton:UIButton!
    @IBOutlet weak var downloadButton:UIButton!
    @IBOutlet weak var starButton:UIButton!
    
    var gallery:Gallery?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gallery = self.gallery {

//            let beffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//            visualEffectView.effect = beffect
            
            if let thumbUri = gallery.thumbnail {
                imageView.kf_setImageWithURL(NSURL(string: thumbUri)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    gallery.image = image
                })
                
                contentImageView.kf_setImageWithURL(NSURL(string: thumbUri)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    gallery.image = image
                })
            }
            contentImageView.contentMode = UIViewContentMode.ScaleToFill
            pageLabel.text = "\(gallery.category) / \(gallery.count) page"
            ratingBar.rating = gallery.rating
            titleLabel.text = gallery.title
            subTitleLabel.text = gallery.subtitle
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
