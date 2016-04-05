//
//  PixivLoginHelper.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/5.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class PixivLoginHelper: NSObject {
    
    public static func getInstance()->PixivLoginHelper {
        return Inner.instance
    }
    
    private struct Inner {
        static let instance: PixivLoginHelper = PixivLoginHelper()
    }
    
    let loginViewController = LoginViewController()
    var isLoginPresented:Bool = false
    
    
    public func checkLogin(viewController:UIViewController)->Bool {
        if isLoginPresented {
            return false
        }
        do {
            if let user = PixivUser.currentLoginUser(), account = user.account, password = user.password {
                if try PixivProvider.getInstance().loginIfNeeded(account, password: password) {
                    return true
                }else {
                    self.luanchLoginViewController(viewController)
                    return false
                }
            }else {
                self.luanchLoginViewController(viewController)
                return false
            }
            
        }catch let error as NSError {
            print(error.localizedDescription)
            self.luanchLoginViewController(viewController)
            return false
        }
    }
    
    public func luanchLoginViewController(viewController:UIViewController) {
        //Check login
        isLoginPresented = true
        viewController.presentViewController(loginViewController, animated: true, completion: nil)
    }
}
