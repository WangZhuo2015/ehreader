//
//  PhotoServiceTests.swift
//  ehreader
//
//  Created by 周泽勇 on 16/1/18.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader
import RealmSwift

class PhotoServiceTests: XCTestCase, PhotoServiceProtocol {
    private var photoService:PhotoService!
    var expectation:XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        let realm = try! Realm()
        var gallery = realm.objects(Gallery.self).last
        if gallery == nil {
            gallery = createTestGallery()
        }
        self.photoService = PhotoService(gallery: gallery!)
    }
    
    func testLoading() {
        self.expectation = expectationWithDescription("start loading pages")
        
        self.photoService.startLoadingPhoto(1, delegate: self)
        waitForExpectationsWithTimeout(1000, handler: nil)
    }
    
    func onLoadingPagesProgress(photoService: PhotoService, gallery: Gallery, currentPage: Int, totoalPageCount: Int) {
        if currentPage == totoalPageCount {
            self.expectation?.fulfill()
        }
    }
}

extension PhotoServiceTests: BppDownloadFileDeletgate {
    func onDownloadFileProgress(downloadFile: BppDownloadFile, progress: Float, velocity: Float, remainTime: Float, totalLength: UInt64) {
        print("progress:\(progress), velocity:\(velocity), remainTime:\(remainTime), totoalLength:\(totalLength)")
    }
    
    func onDidDownloadFileFinished(downloadFile: BppDownloadFile) {
        self.expectation?.fulfill()
    }
    
    func onDidDownloadFileError(downloadFile: BppDownloadFile, downloadError: DownloadError, error: NSError?) {
        print(error)
        self.expectation?.fulfill()
    }
}
