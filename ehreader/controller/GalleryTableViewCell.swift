//
//  GalleryTableViewCell.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/15.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Kingfisher

let GalleryTableViewCellIdentifier = "GalleryTableViewCell"

class GalleryTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var galleryTitleLabel:UILabel!
    @IBOutlet weak var japaneseTitleLabel:UILabel!
    @IBOutlet weak var pageLabel:UILabel!
    @IBOutlet weak var sizeLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(gallery:Gallery) {
        thumbnailImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        if let thumbUri = gallery.thumbnail {
            thumbnailImageView.kf_setImageWithURL(NSURL(string: thumbUri)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                gallery.image = image
            })
        }
        
        galleryTitleLabel.text = gallery.title
        japaneseTitleLabel.text = gallery.subtitle
        pageLabel.text = "\(gallery.count) Page"
        sizeLabel.text = "\(gallery.size) kb"
    }

}
