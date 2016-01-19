//
//  PhotoService.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/16.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public protocol PhotoServiceProtocol {
    /**
     When service have already load page for 5, user can start to read the gallery, otherwise, the loading will be continue
     
     - parameter photoService:    @Class PhotoService
     - parameter loadedPageCount: already loaded count
     - parameter totoalPageCount: totol page count at this gallery
     */
    func onReadingPagesReady(photoService:PhotoService, loadedPageCount:Int, totoalPageCount:Int)
}

/// Load the image to local, provide image to view controller
public class PhotoService: NSObject {
    private var gallery:Gallery
    
    public var pageCount:Int {
        return self.gallery.count
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
    private func createGalleryDocument()throws->String {
        let documentName = "\(self.gallery.id)"
        let path = DocumentDirectory!.stringByAppendingPathComponent(documentName)
        try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        return path
    }
    
    public func startLoadingPhotoes() {
        //first you should fill all the information of this gallery
        let pageCount = self.pageCount
        var galleryDocument:String!
        do {
            galleryDocument = try self.createGalleryDocument()
        }catch let error as NSError {
            
        }
    }
}
