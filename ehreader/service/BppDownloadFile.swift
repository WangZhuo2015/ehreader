//
//  BppDownloadFile.swift
//  client
//
//  Created by yrtd on 15/10/21.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import CryptoSwift

@objc
public enum DownloadError:Int {
    case Net = 1000
    case NoFreeSpace = 1001
    case FileException = 1002
    case FileMd5Exception = 10021
    case FileLocalWriteException = 1003
    case FileLengthException = 1004
    case DownloadTypeToGetAppInfo = 1005
}

private let ProgressKey = "progress"
private let SpeedKey = "speed"
private let remainTime = "remainTime"
private let totalLengthKey = "totalLength"
private let userInfoKey = "userInfo"


@objc
public protocol BppDownloadFileDeletgate:NSObjectProtocol {
    /**
     文件下载进度 (timer线程通知)
     
     - parameter downloadFile: 通知发起的下载器引用
     - parameter progress:     下载进度
     - parameter velocity:     下载的平均速度
     - parameter remainTime:   估算的剩余下载时间
     - parameter totalLength:  文件总共的长度
     */
    optional func onDownloadFileProgress(downloadFile:BppDownloadFile, progress:Float, velocity:Float, remainTime:Float, totalLength:UInt64)
    
    /**
     下载完成 (download线程通知)
     
     - parameter downloadFile:
     */
    optional func onDidDownloadFileFinished(downloadFile:BppDownloadFile)
    
    /**
     MD5检测中  (download线程通知)
     
     - parameter downloadFile:
     */
    optional func onDownloadFileMD5Checking(downloadFile:BppDownloadFile)
    
    /**
     下载Error (download线程通知)
     
     - parameter downloadFile:
     */
    optional func onDidDownloadFileError(downloadFile:BppDownloadFile, downloadError:DownloadError, error:NSError?)
}

public class BppDownloadFile: NSObject {
    public var url:NSURL
    
    public var fileMD5:String?
    
    public weak var delegate:BppDownloadFileDeletgate?
    
    /// 最终保存的文件路径
    public var filePath:String
    
    /// 临时保存的文件路径
    public var tempFilePath:String
    
    /// 要下载文件的总长度
    public var fileLength:UInt64 = 0
    
    /// 需要自定义设置的请求头部
    public var httpHeaders:[String:String] = [String:String]()
    
    /// 下载的时候发生的跳转地址
    public var jumpAddress:String?
    
    /// 如果http服务器支持断点续传的话那么不会返回206错误
    public var isSupport206:Bool = true
    
    public var responseCode:Int = 0
    
    /// 已下载的长度(包括临时文件大小)
    public var downloadFileLength:UInt64 = 0
    private var begingDownloadFileLength:UInt64 = 0
    
    private var urlConnection:NSURLConnection?
    private var retryCount:Int = 0
    private var retryCountCauseFileNotFull:Int = 0
    private var retryCountCauseMD5Error:Int = 0
    private var totalReceiveDataLength:Int = 0
    private var tempBeginReceiveDataTime:NSTimeInterval = 0
    private var tempCurrentReceiveDateTime:NSTimeInterval = 0
    private var downloadRunLoopRef:CFRunLoopRef?
    private var timerRunLoopRef:CFRunLoopRef?
    private var timer:NSTimer?
    private var recursiveLock:NSRecursiveLock = NSRecursiveLock()
    
    
    public init(url:NSURL, savePath:String) {
        self.retryCount = 0
        self.url = url
        self.filePath = savePath
        self.tempFilePath = savePath.stringByAppendingString(".tmp")
        self.fileLength = 0
        super.init()
        
    }
    
    public func startDownload() {
        if NSFileManager.defaultManager().fileExistsAtPath(self.filePath) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate?.onDidDownloadFileFinished?(self)
            })
        }
        
        do {
            self.downloadFileLength = try self.fileSize(self.tempFilePath)
            self.begingDownloadFileLength = try self.fileSize(self.tempFilePath)
        }catch let error as NSError {
            print(error.localizedDescription)
            self.downloadFileLength = 0
            self.begingDownloadFileLength = 0
        }
        
        // 开始一条后台的执行的异步线程来进行下载以及发送进度跟新
        self.performSelectorInBackground(#selector(BppDownloadFile.onThreadMainMethod), withObject: nil)
        self.performSelectorInBackground(#selector(BppDownloadFile.onThreadTimerMethod), withObject: nil)
    }
    
    public func restartDownload() {
        self.urlConnection?.cancel()
        do {
            self.downloadFileLength = try self.fileSize(self.tempFilePath)
            self.begingDownloadFileLength = try self.fileSize(self.tempFilePath)
        }catch let error as NSError {
            print(error.localizedDescription)
            self.downloadFileLength = 0
            self.begingDownloadFileLength = 0
        }
        let request = self.createDownloadRequest()
        request.HTTPShouldHandleCookies = false
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookiesForURL(self.url) ?? []
        for cookie in cookies {
            cookieStorage.deleteCookie(cookie)
        }
        
        NSThread.sleepForTimeInterval(NSTimeInterval(1 + self.retryCount))
        if self.urlConnection != nil {
            self.urlConnection = NSURLConnection(request: request, delegate: self)
        }
    }
    
    public func stopDownload() {
        self.urlConnection?.cancel()
        self.urlConnection = nil
        if let downloadRunLoopRef = self.downloadRunLoopRef {
            CFRunLoopStop(downloadRunLoopRef)
            self.downloadRunLoopRef = nil
        }
        
        self.timer?.invalidate()
        self.timer = nil
        if let timerRunLoopRef = self.timerRunLoopRef {
            CFRunLoopStop(timerRunLoopRef)
            self.timerRunLoopRef = nil
        }
    }
    
    private func fileSize(filename:String)throws->UInt64 {
        let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filename) as NSDictionary
        return attributes.fileSize()
    }
    
    private func writeDataToFile(data:NSData, filePath:String)->Bool {
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            return data.writeToFile(filePath, atomically: true)
        }
        let fileHandle = NSFileHandle(forWritingAtPath: filePath)
        fileHandle?.seekToEndOfFile()
        fileHandle?.writeData(data)
        fileHandle?.closeFile()
        return fileHandle != nil
    }
    
    func onThreadMainMethod() {
        NSThread.currentThread().name = "download"
        let request = self.createDownloadRequest()
        self.urlConnection = NSURLConnection(request: request, delegate: self)
        self.downloadRunLoopRef = NSRunLoop.currentRunLoop().getCFRunLoop()
        NSRunLoop.currentRunLoop().run()
    }
    
    func onThreadTimerMethod() {
        NSThread.currentThread().name = "timer"
        self.timer = NSTimer(timeInterval: 0.01, target: self, selector: #selector(BppDownloadFile.onTimerTick), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        self.timer?.fire()
        self.timerRunLoopRef = NSRunLoop.currentRunLoop().getCFRunLoop()
        NSRunLoop.currentRunLoop().run()
    }
    
    func onTimerTick() {
        self.recursiveLock.lock()
        let velocity = self.calculateVelocity()
        var progress:Float = 0
        var remainTime:Float = 0
        if self.fileLength != 0 {
            progress = Float(self.downloadFileLength)/Float(self.fileLength)
        }
        if velocity > 0 && self.fileLength > self.downloadFileLength {
            remainTime = fabs(Float(self.fileLength - self.downloadFileLength))/1024.0/velocity
        }
        self.delegate?.onDownloadFileProgress?(self, progress: progress, velocity: velocity, remainTime: remainTime, totalLength: self.fileLength)
        self.recursiveLock.unlock()
    }
    
    private func calculateVelocity()->Float {
        var velocity:Float = 0
        self.tempCurrentReceiveDateTime = NSDate().timeIntervalSince1970
        if self.tempCurrentReceiveDateTime > self.tempBeginReceiveDataTime {
            velocity = Float(self.totalReceiveDataLength)/Float(self.tempCurrentReceiveDateTime - self.tempBeginReceiveDataTime)/1024.0
        }
        return velocity
    }
    
    private func createDownloadRequest()->NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: self.url)
        if self.downloadFileLength > 0 {
            request.setValue("bytes=\(self.downloadFileLength)-", forHTTPHeaderField: "Range")
        }
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        request.setValue("bppstore kuaiyong ios", forHTTPHeaderField: "User-Agent")
        request.networkServiceType = .NetworkServiceTypeVoIP
        
        for (key, value) in self.httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
    
    func getFileMD5Value(filename:String)->String? {
        guard let handle = NSFileHandle(forReadingAtPath: filename) else {
            return nil
        }
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.alloc(sizeof(CC_MD5_CTX))
        CC_MD5_Init(context);
        
        var done = false
        while !done {
            let fileData = handle.readDataOfLength(1024*1024*1)
            CC_MD5_Update(context, fileData.bytes, UInt32(fileData.length));
            if fileData.length <= 0 {
                done = true
            }
        }
        
        let length = Int(CC_MD5_DIGEST_LENGTH) * sizeof(UInt8)
        let output = UnsafeMutablePointer<UInt8>.alloc(length)
        CC_MD5_Final(output, context);
        
        let outData = NSData(bytes: output, length: Int(CC_MD5_DIGEST_LENGTH))
        output.destroy()
        context.destroy()
        
        //withUnsafePointer
        return outData.toHexString()
    }
}

extension BppDownloadFile:NSURLConnectionDataDelegate {
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        do {
            let freeDiskspace = try getFreeDiskspace()/1024/1024
            if freeDiskspace < 5 {
                let error = NSError(domain: "BppDownloadFile", code: DownloadError.NoFreeSpace.rawValue, userInfo: [NSLocalizedDescriptionKey:"Low free disk space"])
                self.connection(connection, didFailWithError: error)
                return
            }
        }catch {
            print("Get free disk space exception")
        }
        
        self.retryCount = 0
        self.downloadFileLength += UInt64(data.length)
        if !self.writeDataToFile(data, filePath: self.tempFilePath) {
            self.stopDownload()
            self.delegate?.onDidDownloadFileError?(self, downloadError: DownloadError.FileLocalWriteException, error: nil)
            return
        }
        
        self.recursiveLock.lock()
        if self.tempBeginReceiveDataTime == 0 {
            self.tempBeginReceiveDataTime = NSDate().timeIntervalSince1970
        }
        
        self.totalReceiveDataLength += data.length
        self.recursiveLock.unlock()
    }
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            return
        }
        responseCode = httpResponse.statusCode
        if let responseHost = httpResponse.URL?.host {
            if self.url.host == responseHost {
                self.jumpAddress = responseHost
            }
        }
        if responseCode == 206 {
            self.isSupport206 = true
        }else {
            self.isSupport206 = false
            //不支持断点续传
            do {
                try NSFileManager.defaultManager().removeItemAtPath(self.tempFilePath)
                self.downloadFileLength = 0
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        //兼容CDN，没有Content-Length时，expectedContentLength 返回-1, "Content-Range" = "bytes 1035276-198225938/198225939";
        var expectedContentLength:Int64 = Int64(httpResponse.expectedContentLength)
        if expectedContentLength < 0 {
            let contentRange = httpResponse.allHeaderFields["Content-Range"]
            let values = contentRange?.componentsSeparatedByString("/")
            let totalLength = Int64(values![1])
            expectedContentLength = totalLength! - Int64(self.downloadFileLength)
        }
        self.fileLength = UInt64(expectedContentLength) + self.downloadFileLength
        
        //判断文件是否已经下载， 通过大小判断
        do {
            let fileSize = try self.fileSize(self.filePath)
            if fileSize == self.fileLength {
                self.stopDownload()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.onDidDownloadFileFinished?(self)
                })
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        self.stopDownload()
        var downloadSuccess = true
        //检测下载是否完整
        do {
            let length = try self.fileSize(self.tempFilePath)
            if length != self.fileLength {
                if self.retryCountCauseFileNotFull < 2 {
                    self.restartDownload()
                    self.retryCountCauseFileNotFull += 1
                    return
                }else {
                    self.delegate?.onDidDownloadFileError?(self, downloadError: DownloadError.FileLengthException, error: nil)
                    downloadSuccess = false
                    return
                }
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        if let fileMD5 = self.fileMD5 {
            self.delegate?.onDownloadFileMD5Checking?(self)
            guard let md5Value = self.getFileMD5Value(self.tempFilePath) else {
                self.stopDownload()
                self.delegate?.onDidDownloadFileError?(self, downloadError: DownloadError.FileMd5Exception, error: nil)
                return
            }
            
            
            if downloadSuccess && md5Value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                if fileMD5 != md5Value {
                    if self.retryCountCauseMD5Error < 1 {
                        self.retryCountCauseMD5Error += 1
                        try! NSFileManager.defaultManager().removeItemAtPath(self.tempFilePath)
                        self.restartDownload()
                        return
                    }else {
                        self.stopDownload()
                        self.delegate?.onDidDownloadFileError?(self, downloadError: DownloadError.FileMd5Exception, error: nil)
                        return
                    }
                }
            }
        }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            if fileManager.fileExistsAtPath(self.filePath) {
                try fileManager.removeItemAtPath(self.filePath)
            }
            try fileManager.moveItemAtPath(self.tempFilePath, toPath: self.filePath)
        }catch let error as NSError {
            print(error.localizedDescription)
            self.delegate?.onDidDownloadFileError?(self, downloadError: DownloadError.FileException, error: error)
            return
        }
        
        self.delegate?.onDidDownloadFileFinished?(self)
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if self.retryCount < 3 {
            self.restartDownload()
            self.retryCount += 1
            return
        }
        self.stopDownload()
        let errorType = error.code == DownloadError.NoFreeSpace.rawValue ? DownloadError.NoFreeSpace : DownloadError.Net
        self.delegate?.onDidDownloadFileError?(self, downloadError: errorType, error: error)
    }
    
    // 以下这两个方法是为了规避一些https的网站没有证书的时候能够保证下载正常
    public func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    
    public func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            challenge.sender?.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!), forAuthenticationChallenge: challenge)
        }
        challenge.sender?.continueWithoutCredentialForAuthenticationChallenge(challenge)
    }
}
