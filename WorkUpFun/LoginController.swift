//
//  LoginController.swift
//  WorkUpFun
//
//  Created by gaof on 16/10/19.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa



class LoginController: NSViewController {
    var block: BtnBlock?
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var passWord: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func btnDidClick(btnBlock: BtnBlock?) {
        if (btnBlock != nil) {
            self.block = btnBlock
        }
    }
    @IBAction func LoginClick(_ sender: NSButton) {
        let user = userName.stringValue
        let pwd = passWord.stringValue
        Tool.shareTool.toolSaveUserInfo(userName: user, passWord: pwd)
        Tool.shareTool.toolHaveCookieRequest {//获取request
            if (self.block != nil) {
                self.block!(true)
            }
        }
    }
    
}
