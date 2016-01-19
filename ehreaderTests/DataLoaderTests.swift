//
//  DataLoaderTests.swift
//  ehreader
//
//  Created by yrtd on 15/11/18.
//  Copyright © 2015年 bravedefault. All rights reserved.
//

import XCTest
@testable import ehreader
import Alamofire
import RealmSwift

/**
 id = 871296
 token = "0b2eac8c77"
 title = "(C86) [Hikalphilia (Monatsu)] Euphoria (Touhou Project) [Chinese] [烂肉×伞尖]"
 subtitle = "(C86) [ヒカルフィリア (もなつ)] ユーフォリア (東方Project) [中国翻訳]"
 category = "Doujinshi"
 count = 43
 thumbnail = "http://gt0.ehgt.org/02/4c/024c800dea9727bb1746113035f5ee0cb56c8c9f-104812-1413-2000-jpg_l.jpg"
 starred = false
 rating = 4.5
 created = nil
 lastread = nil
 tags = "chinese|translated|touhou project|maribel han|renko usami|females only|yuri|hikalphilia|monatsu"
 uploader = "lanxin1128"
 progress = 0
 showkey = nil
 size = 30270574
 */
func createTestGallery()->Gallery {
    let gallery = Gallery()
    gallery.id = 893685
    gallery.token = "21d9c55d71"
    gallery.title = "(C86) [Batsu Jirushi (Batsu)] x Yuubari (Kantai Collection -KanColle-) [Korean]"
    gallery.subtitle = "(C86) [Batsu Jirushi (Batsu)] x Yuubari (Kantai Collection -KanColle-) [Korean]"
    gallery.category = galleryCategoryName(GalleryCategory.Doujinshi)
    gallery.count = 22
    gallery.thumbnail = "http://gt1.ehgt.org/11/a3/11a30da13e6fd8497b54ae5a04cc108c85756c59-1045755-2110-3000-jpg_l.jpg"
    gallery.starred = false
    gallery.rating = 4.5
    gallery.tags = "chinese|translated|touhou project|maribel han|renko usami|females only|yuri|hikalphilia|monatsu"
    gallery.uploader = "lanxin1128"
    gallery.progress = 0
    gallery.size = 44604817
    
    let realm = try! Realm()
    try! realm.write { () -> Void in
        realm.add(gallery, update: true)
    }
    
    return gallery
}

class DataLoaderTests: XCTestCase {
    let dataLoader = DataLoader.getInstance()
    
    func testGetGallery() {
        //Given
        let expectation = expectationWithDescription("The data result should not be null")
        var gallery:[Gallery] = []
        let baseUrl = LoginHelper.getInstance().isLoggedIn() ? BASE_URL_EX : BASE_URL
        
        //When
        dataLoader.getGallery(baseUrl, page: 0) { (galleries, error) -> Void in
            gallery = galleries
            expectation.fulfill()
            XCTAssertNil(error)
        }
        
        
        //Then
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        XCTAssertNotNil(gallery, "gallery should not null")
        if gallery.count == 0 {
            XCTAssert(false)
        }
    }
    
    func testCallApi() {
        //Given
        let expectation = expectationWithDescription("The data result should not be null")
        let gidlist:[[String]] = [["618395","0439fa3666"], ["618395","0439fa3666"]]
        var galleries:[AnyObject] = []
        let parameters = ["gidlist":gidlist];
        
        //When
        dataLoader.callApi(ApiMethod.gdata, parameter: parameters) { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess {
                if let result = response.result.value as? [NSObject:AnyObject] {
                    if let error = result["error"] as? String {
                        print(error)
                        XCTAssert(false, error)
                    }
                    if let gmetadata = result["gmetadata"] as? [AnyObject] {
                        galleries = gmetadata
                    }else {
                        XCTAssert(false)
                    }
                }else {
                    XCTAssert(false)
                }
                expectation.fulfill()
            }else {
                XCTAssert(false)
            }
        }
        
        //Then
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        if galleries.count > 0 {
            XCTAssert(true)
        }else {
            XCTAssert(false)
        }
    }

    
    func testGetPhotoListWithGallery() {
        //Given
        let gallery = createTestGallery()
        let expectation = expectationWithDescription("The data result should not be null")
        var testPhotos:[Photo]?
        
        //When
        dataLoader.getPhotoListWithGallery(gallery, page: 0) { (photos, error) -> Void in
            testPhotos = photos
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        //Then
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        XCTAssertNotNil(testPhotos, "photo should not null")
        if gallery.count == 0 {
            XCTAssert(false)
        }
    }
    
    func testGetPhotoInfo() {
        //Given
        let gallery = createTestGallery()
        if gallery.photos.count <= 0 {
            self.testGetPhotoListWithGallery()
        }
        
        //When
        for photo in gallery.photos {
            let expectation = expectationWithDescription("The data result should not be null")
            dataLoader.getPhotoInfo(gallery, photo: photo) { (photo) -> Void in
                expectation.fulfill()
            }
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            XCTAssertNotNil(photo.src)
            XCTAssertNotNil(photo.filename)
        }
    }
    
    func testGetPhotoInfoAll() {
        let gallery = createTestGallery()
        for page in 0..<gallery.count {
            let expectation = expectationWithDescription("The data result should not be null")
            dataLoader.getPhotoInfo(gallery, page: page, complete: { (photo, error) -> Void in
                XCTAssertNotNil(photo)
                XCTAssertNotNil(photo!.src)
                XCTAssertNotNil(photo!.filename)
                XCTAssertNil(error)
                expectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        }
    }
}
