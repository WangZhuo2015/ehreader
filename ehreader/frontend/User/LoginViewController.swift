//
//  LoginViewController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/3.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import RNLoadingButton_Swift
import RKDropdownAlert

private let Padding:CGFloat = 16

class LoginViewController: UIViewController {
    private lazy var accountTextField:UITextField = {
        let textField = UITextField(frame: CGRectZero)
        textField.backgroundColor = UIColor.clearColor();
        textField.delegate = self;
        textField.autoresizingMask = UIViewAutoresizing.FlexibleHeight;
        textField.keyboardType = UIKeyboardType.Default;
        textField.returnKeyType = UIReturnKeyType.Next
        textField.autocapitalizationType = UITextAutocapitalizationType.None;
        textField.textColor = UIConstants.EmptyTextColor;
        textField.placeholder = "用户名";
        textField.font = UIFont.systemFontOfSize(15);
        return textField
    }()
    
    private lazy var passwordTextField:UITextField = {
        let textField = UITextField(frame: CGRectZero)
        textField.backgroundColor = UIColor.clearColor();
        textField.delegate = self;
        textField.autoresizingMask = UIViewAutoresizing.FlexibleHeight;
        textField.keyboardType = UIKeyboardType.Default;
        textField.returnKeyType = UIReturnKeyType.Done
        textField.autocapitalizationType = UITextAutocapitalizationType.None;
        textField.textColor = UIConstants.EmptyTextColor;
        textField.placeholder = "请输入密码";
        textField.secureTextEntry = true
        textField.font = UIFont.systemFontOfSize(15);
        return textField
    }()
    
    private lazy var loginButton:RNLoadingButton = {
        let button = RNLoadingButton(type: UIButtonType.Custom)
        let tintColor = UIConstants.GrapefruitColor
        button.setTitle("登陆", forState: UIControlState.Normal)
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.layer.borderColor = tintColor.CGColor
        button.setTitleColor(UIConstants.LightGray, forState: UIControlState.Normal)
        button.setBackgroundImage(tintColor.createImage(2, height: 50), forState: UIControlState.Normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(LoginViewController.onLoginButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        button.hideTextWhenLoading = false
        button.loading = false
        button.activityIndicatorAlignment = RNActivityIndicatorAlignment.Left
        button.activityIndicatorEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        button.setTitle("登陆中...", forState: UIControlState.Disabled)
        return button
    }()
    
    private lazy var registerButton:UIButton = {
        let button = RNLoadingButton(type: UIButtonType.Custom)
        let tintColor = UIConstants.GrapefruitColor
        button.setTitle("没有Pixiv账号，前往Pixiv注册", forState: UIControlState.Normal)
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.layer.borderColor = tintColor.CGColor
        button.setTitleColor(UIConstants.GrapefruitColor, forState: UIControlState.Normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(LoginViewController.registerPixivAccount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    private lazy var backgroundView:UIImageView = {
        let backgroundView = UIImageView(image:UIImage(named: "loginBg"))
        backgroundView.hidden = true
        return backgroundView
    }()
    
    private lazy var topBackgroundView:UIImageView = {
        let backgroundView = UIImageView(image:UIImage(named: "guaide_background"))
        return backgroundView
    }()
    
    private lazy var lineView1:UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.createColor(200, green: 200, blue: 200, alpha: 0.5)
        return view
    }()
    
    private lazy var lineView2:UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.createColor(200, green: 200, blue: 200, alpha: 0.5)
        return view
    }()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(backgroundView)
        view.addSubview(topBackgroundView)
        view.addSubview(accountTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(lineView1)
        view.addSubview(lineView2)
        addConstraints()
    }
    
    private func addConstraints() {
        backgroundView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        accountTextField.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(Padding)
            make.trailing.equalTo(self.view).offset(-Padding)
            make.top.equalTo(self.topBackgroundView.snp_bottom).offset(10)
            make.height.equalTo(50)
        }
        
        lineView1.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(1)
            make.top.equalTo(self.accountTextField.snp_bottom)
        }
        
        passwordTextField.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(Padding)
            make.trailing.equalTo(self.view).offset(-Padding)
            make.top.equalTo(self.accountTextField.snp_bottom).offset(10)
            make.height.equalTo(50)
        }
        
        lineView2.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(1)
            make.top.equalTo(self.passwordTextField.snp_bottom)
        }
        
        loginButton.snp_makeConstraints { (make) in
            make.top.equalTo(self.passwordTextField.snp_bottom).offset(30)
            make.leading.equalTo(self.view).offset(Padding)
            make.trailing.equalTo(self.view).offset(-Padding)
            make.height.equalTo(50)
        }
        
        registerButton.snp_makeConstraints { (make) in
            make.top.equalTo(self.loginButton.snp_bottom).offset(30)
            make.leading.equalTo(self.view).offset(Padding)
            make.trailing.equalTo(self.view).offset(-Padding)
            make.height.equalTo(50)
        }
        
        
        if let image = self.topBackgroundView.image {
            let scale = image.size.height/image.size.width
            let height = self.view.frame.width * scale
            print(height)
            topBackgroundView.snp_makeConstraints { (make) in
                make.leading.top.trailing.equalTo(self.view)
                make.height.equalTo(height)
            }
        }else {
            topBackgroundView.snp_makeConstraints { (make) in
                make.leading.top.trailing.equalTo(self.view)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Event Response
    func onLoginButtonClicked(button:UIButton)  {
        guard let account = self.accountTextField.text else {
            displayMessage("账号不能为空", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
            return
        }
        
        guard let password = self.passwordTextField.text else {
            displayMessage("密码不能为空", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
            return
        }
        login(account, password: password)
    }
    
    func login( username:String, password:String) {
        if username.isEmpty {
            displayMessage("账号不能为空", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
            return
        }
        
        if password.isEmpty {
            displayMessage("密码不能为空", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
            return
        }
        
        let _username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let _password = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        loginButton.loading = true
        loginButton.enabled = false
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            do {
                if try PixivProvider.getInstance().login(_username, password: _password) != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.loginButton.loading = false
                        self?.loginButton.enabled = true
                        PixivLoginHelper.getInstance().isLoginPresented = false
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.loginButton.loading = false
                        self?.loginButton.enabled = true
                        self?.displayMessage("账号或者密码错误", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
                    })
                }
                
            }catch let error as NSError  {
                print(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self?.loginButton.loading = false
                    self?.loginButton.enabled = true
                    self?.displayMessage("网络或者数据错误", backgroundColor: UIConstants.GrapefruitColor, textColor: UIConstants.LightGray)
                })
            }
        }
    }
    
    func registerPixivAccount(button:UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://touch.pixiv.net/signup.php")!)
    }
    
    func displayMessage(message:String, backgroundColor:UIColor, textColor:UIColor) {
        RKDropdownAlert.title(nil, message: message, backgroundColor: backgroundColor, textColor: textColor)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.passwordTextField.resignFirstResponder()
        self.accountTextField.resignFirstResponder()
        if textField == self.accountTextField {
            self.passwordTextField.becomeFirstResponder()
        }else if textField == self.passwordTextField {
            self.onLoginButtonClicked(self.loginButton)
        }
        return true
    }
}