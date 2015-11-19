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

class DataLoaderTests: XCTestCase {
    let dataLoader = DataLoader.getInstance()
    
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
    func testGetGallery() {
        //Given
        let expectation = expectationWithDescription("The data result should not be null")
        var gallery:[Gallery] = []
        let baseUrl = LoginHelper.getInstance().isLoggedIn() ? BASE_URL_EX : BASE_URL
        
        //When
        dataLoader.getGallery(baseUrl, page: 0) { (galleries) -> Void in
            gallery = galleries
            expectation.fulfill()
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
        
        //When
        dataLoader.callApi(ApiMethod.gdata, gidlist: gidlist) { (response:Response<AnyObject, NSError>) -> Void in
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
}
