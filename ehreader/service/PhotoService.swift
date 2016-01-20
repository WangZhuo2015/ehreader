//
//  PhotoService.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/16.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire

public protocol PhotoServiceProtocol {
    /**
     When starting load the photo to local, this func will tell current downloading progress
     
     - parameter photoService:    @Class PhotoService
     - parameter currentPage:     current download page
     - parameter totoalPageCount: total page count at this gallery
     */
    func onLoadingPagesProgress(photoService:PhotoService, gallery:Gallery, currentPage:Int, totoalPageCount:Int)
}

/// Load the image to local, provide image to view controller
public class PhotoService: NSObject {
    private var gallery:Gallery
    
    public var pageCount:Int {
        get {
            return self.gallery.count
        }
    }
    
    private var photoes:[Photo] = []
    
    public var delegate:PhotoServiceProtocol?
    
    private var dataLoader:DataLoader = DataLoader.getInstance()
    
    init(gallery:Gallery) {
        self.gallery = gallery
        super.init()
    }
    
    /**
     Create a fold to download the gallery images
     */
    private func createGalleryDocument()throws->NSURL {
        let documentName = "\(self.gallery.id)"
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let path = directoryURL.URLByAppendingPathComponent(documentName)
        if !fileManager.fileExistsAtPath(path.absoluteString) {
            try NSFileManager.defaultManager().createDirectoryAtURL(path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
    
    public func startLoadingPhotoes() {
        //first you should fill all the information of this gallery
        let pageCount = self.pageCount
        var galleryDocument:NSURL!
        do {
            galleryDocument = try self.createGalleryDocument()
        }catch let error as NSError {
            print("createGalleryDocument :" + error.localizedDescription)
        }
        
        for page in 1...pageCount {
            dataLoader.getPhotoInfo(self.gallery, page: page, complete: { (photo, error) -> Void in
                if let imageUri = photo?.src, pageNumber = photo?.page {
                    let ext = imageUri.pathExtension
                    let filename = galleryDocument.URLByAppendingPathComponent("\(pageNumber).\(ext)")
                    print("start loading filename:\(filename)")
                    
                    do {
                        let request = NSURLRequest(URL: NSURL(string: imageUri)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: DefaultNetworkTimeInterval)
                        var response:NSURLResponse?
                        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                        print("loading filename:\(filename)")
                        let document = galleryDocument.URLByAppendingPathComponent(filename.absoluteString)
                        if data.writeToURL(document, atomically: true) {
                            print("write image to path:\(document)")
                        }
                        self.delegate?.onLoadingPagesProgress(self, gallery:self.gallery, currentPage: page, totoalPageCount: pageCount)
                    }catch let error as NSError {
                        print("PhotoService load error:\(error.localizedDescription)")
                    }
                }
            })
        }
        
    }
}
