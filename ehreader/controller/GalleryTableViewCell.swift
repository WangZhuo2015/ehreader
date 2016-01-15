//
//  GalleryTableViewCell.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/15.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

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

}
