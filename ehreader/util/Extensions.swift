//
//  Extensions.swift
//  lab
//
//  Created by 周泽勇 on 15/7/4.
//  Copyright (c) 2015年 studyinhand. All rights reserved.
//


import UIKit

public extension UIDevice {
    public class func systemVersionFloatValue()->Float {
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue;
    }
}

public extension CGRect {
    var x:CGFloat {
        get {
            return origin.x;
        }
        set {
            origin.x = newValue;
        }
    }
    
    var y:CGFloat {
        get {
            return origin.y;
        }
        set {
            origin.y = newValue;
        }
    }
}

public extension UIViewController {
    
    /**
    Add the keyboard notification to current view that when keyboard showing, the view will shift to make the first responder view can be seen.
    */
    public func bindKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
    }
    
    /**
    When the keyboard show, make the view shit so that the responder text field can be seen. IOS7 and IOS8 have some diffirent in rect of the views at diffirent orientation.
    
    - parameter notification:
    */
    func keyboardWillShow(notification:NSNotification) {
        let firstResponder = self.view.findFirstResponderView();
        if firstResponder == nil {
            return;
        }
        if !firstResponder!.isKindOfClass(UITextField.classForCoder()) {
            return;
        }
        let window = UIApplication.sharedApplication().keyWindow;
        if window == nil {
            return;
        }
        
        var responderFrame = window?.convertRect(firstResponder!.frame, fromView: firstResponder?.superview);
        
        var userInfo = notification.userInfo;
        let value: NSValue = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue;
        var keyboardRect = value.CGRectValue();
        let animationDurationValue: NSValue = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSValue;
        var animationDuration:NSTimeInterval = 0;
        animationDurationValue.getValue(&animationDuration);
        
        
        let width = window!.frame.width;
        let height = window!.frame.height;
        var x:CGFloat = 0;
        var y:CGFloat = 0;
        
        if UIDevice.systemVersionFloatValue() > 8.0 {
            x = (keyboardRect.x == 0) ?0:(keyboardRect.x - responderFrame!.x - responderFrame!.height);
            y = (keyboardRect.y == 0) ?0:(keyboardRect.y - responderFrame!.y - responderFrame!.height);
            x = x > 0 ?0:x;
            y = y > 0 ?0:y;
        }else {
            let orientation = UIApplication.sharedApplication().statusBarOrientation;
            if orientation == UIInterfaceOrientation.PortraitUpsideDown {
                x = 0;
                y = responderFrame!.y - keyboardRect.height;
            }else if orientation == UIInterfaceOrientation.LandscapeLeft {
                x = keyboardRect.width - responderFrame!.x;
                y = 0;
            }else if orientation == UIInterfaceOrientation.LandscapeRight {
                x = responderFrame!.x - keyboardRect.width;
                y = 0;
            }else if orientation == UIInterfaceOrientation.Portrait {
                x = 0;
                y = keyboardRect.height - responderFrame!.y;
            }
        }
        
        let rect = CGRectMake(x, y, width, height);
        view.layoutIfNeeded();
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            window!.frame = rect;
        });
    }
    
    /**
    Reset the view controller's view
    
    - parameter notification:
    */
    func keyboardWillHide(notification:NSNotification) {
        let window = UIApplication.sharedApplication().keyWindow;
        if window == nil {
            return;
        }
        var userInfo = notification.userInfo!;
        let animationDurationValue:NSValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSValue;
        var animationDuration:NSTimeInterval = 0;
        animationDurationValue.getValue(&animationDuration);
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            window!.frame = CGRectMake(0, 0, window!.frame.width, window!.frame.height)
        });
    }
}

public extension UIScrollView {
    public func bindKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let firstResponder = self.findFirstResponderView();
        if firstResponder == nil {
            return;
        }
        if !firstResponder!.isKindOfClass(UITextField.classForCoder()) {
            return;
        }
        
        let respnderFrame = self.convertRect(firstResponder!.frame, fromView: firstResponder!.superview);
        self.scrollRectToVisible(respnderFrame, animated: true);
    }
}

public extension UIColor {
    public class func colorWithRGB(value:Int)->UIColor {
        let redValue = CGFloat((value & 0xFF0000) >> 16)/255.0;
        let greenValue = CGFloat((value & 0x00FF00) >> 8)/255.0;
        let blueValue = CGFloat(value & 0x0000FF)/255.0;
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1);
    }
    
    public class func createColor(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)->UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}

extension UIView {
    /**
    Find the first responder sub view
    
    - returns: the first responder view.
    */
    public func findFirstResponderView()->UIView? {
        if self.isFirstResponder() {
            return self;
        }
        
        for subView in self.subviews {
            let view = subView.findFirstResponderView();
            if view != nil {
                return view;
            }
        }
        return nil;
    }
}

public extension NSString {
    class public func isEmpty(string: NSString?)->Bool {
        if string == nil {
            return true;
        }
        
        if !string!.isKindOfClass(NSString.classForCoder()) {
            if string!.isKindOfClass(NSNull.classForCoder()) {
                return true;
            }else {
                return false;
            }
        }
        
        if string!.trim().length == 0 {
            return true;
        }
        return false;
    }
    
    public func trim()->NSString {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
}

public extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
            let subEnd = subStart.advancedBy(r.endIndex - r.startIndex, limit: self.endIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    
    subscript (index: Int) -> Character {
        get {
            let subIndex = self.startIndex.advancedBy(index, limit: self.endIndex)
            return self[subIndex];
        }
    }
    
    func substring(from: Int) -> String {
        let end = self.characters.count
        return self[from..<end]
    }
    
    func substring(from: Int, length: Int) -> String {
        let end = from + length
        return self[from..<end]
    }
    
    
    public func contentRect(font:UIFont, maxSize:CGSize)->CGRect {
        let attrStr = NSAttributedString(string: self)
        var range = NSMakeRange(0, attrStr.length)
        let dic = attrStr.attributesAtIndex(0, effectiveRange: &range)
        let str = self as NSString
        let rect = str.boundingRectWithSize(maxSize, options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: dic, context: nil)
        return rect
    }
    
    public var stringByDeletingLastPathComponent:String {
        return NSURL(string: self)!.URLByDeletingLastPathComponent!.absoluteString
    }
    
    public var pathExtension:String {
        return NSURL(string: self)!.pathExtension!
    }
    
    public func stringByAppendingPathComponent(pathComponent:String)->String {
        return NSURL(string: self)!.URLByAppendingPathComponent(pathComponent).absoluteString
    }
    
    public func stringByAppendingPathExtension(ext:String)->String {
        return NSURL(string: self)!.URLByAppendingPathExtension(ext).absoluteString
    }
    
    public func lastPathComponent()->String? {
        return NSURL(string: self)?.lastPathComponent
    }
    
    public func replaceUnicode()throws->String {
        let tempStr1 = self.stringByReplacingOccurrencesOfString("\\u", withString: "\\U")
        let tempStr2 = tempStr1.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        let tempStr3 = "\"\(tempStr2)\""
        if let data = tempStr3.dataUsingEncoding(NSUTF8StringEncoding) {
            let result = try NSPropertyListSerialization.propertyListWithData(data, options: .Immutable, format: nil)
            return result.stringByReplacingOccurrencesOfString("\\r\\n", withString: "\n")
        }
        return self
    }
}

extension NSURL {
    public func parseQuery()->[String:String] {
        var queryDict = [String:String]()
        if let query = self.query {
            let keyValuePairs = query.componentsSeparatedByString("&")
            for keyValuePair in keyValuePairs {
                var element = keyValuePair.componentsSeparatedByString("=")
                if element.count != 2 {
                    continue
                }
                let key = element[0]
                let value = element[1]
                if key.isEmpty {
                    continue
                }
                queryDict[key] = value
            }
        }
        return queryDict
    }
}

extension NSFileManager {
    func attributeOfItemAtPath(path:String, key:String)->AnyObject? {
        do {
            let values = try self.attributesOfItemAtPath(path)
            if let value = values[key] {
                return value
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func isDirectoryItemAtPath(path:String)->Bool {
        if let fileType =  attributeOfItemAtPath(path, key: NSFileType) as? String {
            if fileType == NSFileTypeDirectory {
                return true
            }
        }

        return false
    }
    
    func isFileItemAtPath(path:String)->Bool {
        if let fileType =  attributeOfItemAtPath(path, key: NSFileType) as? String {
            if fileType == NSFileTypeRegular {
                return true
            }
        }
        return false
    }
    
    func listItemsInDirectoryAtPath(path:String, deep:Bool, error:NSErrorPointer)->[String] {
        do {
            let subPaths = deep ? try self.subpathsOfDirectoryAtPath(path) : try self.contentsOfDirectoryAtPath(path)
            var absolutePaths:[String] = []
            let relativeSubPaths = subPaths
            for subPath in relativeSubPaths {
                let absolutePath = NSURL(string: path)!.URLByAppendingPathComponent(subPath).absoluteString
                absolutePaths.append(absolutePath)
            }
            return absolutePaths
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
    func listItemsInDirectoryAtPath(path:String, deep:Bool)->[String]  {
        return listItemsInDirectoryAtPath(path, deep: deep, error: nil)
    }
}


public extension NSDictionary {
    public func jsonString()->String? {
        var err: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions())
            let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
            if let value = jsonStr {
                return value
            }
            throw err
        } catch let error as NSError {
            err = error
            print(err.localizedDescription)
        }
        return nil
    }
}

public extension NSArray {
    public func jsonString()->String? {
        var err: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions())
            let jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
            if let value = jsonStr {
                return value
            }
        } catch let error as NSError {
            err = error
            print(err.localizedDescription)
        }
        return nil
    }
}

public extension String {
    public func jsonValue()->AnyObject? {
        if let jsonData = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var jsonObject: AnyObject?
            do {
                jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                print(error.localizedDescription)
                jsonObject = nil
            }
            if let value = jsonObject {
                return value
            }
        }
        return nil
    }
}


public class Cookie: NSHTTPCookie {
    init?(name:String, value:String, loggedIn:Bool) {
        let domain = loggedIn ? "exhentai.org" : "e-hentai.org"
        let properties = [
            NSHTTPCookieDomain: domain,
            NSHTTPCookiePath: "/",
            NSHTTPCookieName: name,
            NSHTTPCookieValue: value,
        ]
        super.init(properties: properties)
    }
}


public extension UIImage {
    public func createImageWithColor(width:CGFloat = 1, height:CGFloat = 1, color:UIColor)->UIImage {
        let rect = CGRectMake(0.0, 0.0, width, height)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}