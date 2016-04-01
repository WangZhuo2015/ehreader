//
//  UgoiraHelper.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/31.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive

/// The ugoira type gallery is a animation type photo, we need download it and parse it
public class UgoiraHelper: NSObject {
    private var illust:PixivIllust
    
    private weak var imageView:UIImageView?
    
    var filename:String?
    
    var delayTimes:[NSTimeInterval] = []
    
    public init(illust:PixivIllust, imageView:UIImageView) {
        self.illust = illust
        self.imageView = imageView
        super.init()
    }
    
    public func startLoadingUgoira(progressClosure:((progress:CGFloat)->Void)?, completeClosure:((error:NSError?)->Void)?) {
        self.delayTimes = self.illust.frames
        
        guard let zipUrlString = self.illust.zipUrls.first else {
            return
        }
        
        let illustId = illust.illust_id

        
        let header = [
            "Referer":"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=\(illustId)",
            "User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4"
        ]
        
        var isFileExist:Bool = false
        let zipUrl = NSURL(string: zipUrlString)!
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first, lastPathComponent = zipUrl.lastPathComponent {
            filename = directoryURL.URLByAppendingPathComponent(lastPathComponent).path
            if let zipFilename = filename where NSFileManager.defaultManager().isFileItemAtPath(zipFilename) {
                completeClosure?(error:nil)
                isFileExist = true
            }
        }
        
        if !isFileExist {
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            download(.GET, zipUrl, parameters: nil, headers: header, destination: destination).progress {(bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                print(totalBytesRead)
                let progress = CGFloat(totalBytesRead)/CGFloat(totalBytesExpectedToRead)
                dispatch_async(dispatch_get_main_queue()) {
                    if progressClosure != nil {
                        progressClosure?(progress:progress)
                    }
                }
            }.response { _, _, _, error in
                if completeClosure != nil {
                    completeClosure?(error:error)
                }
            }
        }
        
    }
    
    deinit {
        print("deinit UgoiraHelper")
    }
    
    public func unzipUgoira() {
        guard let filename = self.filename else {
            return
        }
        if delayTimes.count <= 0 {
            return
        }
        let fileUrl = NSURL(string: filename)!
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let destinationUrl = documentsDirectory.URLByAppendingPathComponent(fileUrl.URLByDeletingPathExtension!.lastPathComponent!)
        
        SSZipArchive.unzipFileAtPath(fileUrl.path!, toDestination: destinationUrl.path!, overwrite: false, password: nil, progressHandler: { (entry, zipInfo, entryNumber, total) in
            print("entryNumber:\(entryNumber), total:\(total)")
        }, completionHandler: {[weak self] (path, succeeded, error) in
            if succeeded {
                print(path)
                var images:[CGImageRef] = []
                let paths = NSFileManager.defaultManager().listItemsInDirectoryAtPath(destinationUrl.path!, deep: false)
                for file in paths {
                    print(file)
                    if let image = UIImage(contentsOfFile:file)?.CGImage {
                        images.append(image)
                    }
                }
                print(images.count)
                self?.frames = images
                self?.startAnimation()
            }
        })
    }
    
    private var frames:[CGImageRef] = []
    
    let AnimationKey = "GIFAnimation"
    
    public func startAnimation() {
        var totalTime:NSTimeInterval = 0
        for value  in delayTimes {
            totalTime += value
        }
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var currentTime:NSTimeInterval = 0
        let frameCount = frames.count
        var times:[NSNumber] = []
        for index in 0..<frameCount {
            times.append(NSNumber(float: Float(currentTime/totalTime)))
            currentTime += delayTimes[index]
        }
        animation.keyTimes = times
        animation.values = frames
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = totalTime
        animation.delegate = self
        animation.repeatCount = MAXFLOAT
        
        self.imageView?.layer.addAnimation(animation, forKey: AnimationKey)
    }
    
    public func stopAnimation() {
        self.imageView?.stopAnimating()
        self.imageView?.layer.removeAnimationForKey(AnimationKey)
    }
}
