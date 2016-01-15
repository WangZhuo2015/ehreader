//
//  GalleryTableViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/14.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit

let GalleryDetailSegueIdentifier = "GalleryDetailSegueIdentifier"

class GalleryTableViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    private lazy  var backgroundView:BackgroundView = BackgroundView(frame: CGRectZero)
    
    let galleryService = GalleryService()
    private var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        backgroundView.status = BackgroundViewStatus.Loading
        backgroundView.addTarget(self, action: "startLoading", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backgroundView)
        startLoading()
        addConstraints()
    }
    
    private func addConstraints() {
        backgroundView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoading() {
        self.galleryService.startLoading(self.currentPage) { (galleries, error) -> Void in
            if error != nil && galleries.isEmpty {
                print("loading choice data failed:\(error!.localizedDescription)")
                self.backgroundView.status = BackgroundViewStatus.Failed
                return
            }
            
            self.tableView.reloadData()
            self.backgroundView.status = BackgroundViewStatus.Hidden
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == GalleryDetailSegueIdentifier {
            let detailViewController = segue.destinationViewController as! GalleryDetailViewController
            if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                let gallery = self.galleryService.getGallery(indexPath)
                detailViewController.gallery = gallery
            }
        }
    }
}


extension GalleryTableViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryService.count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GalleryTableViewCellIdentifier) as! GalleryTableViewCell
        let gallery = self.galleryService.getGallery(indexPath)
        cell.configCell(gallery)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
}