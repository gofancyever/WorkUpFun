//
//  AppDelegate.swift
//  WorkUpFun
//
//  Created by apple on 16/10/6.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa

let kAutoWorkupState = "autoWorkupState"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    let popover = NSPopover()
    
    var minute: UInt32 {
        let maxMinute: UInt32 = 25
        let minMinute: UInt32 = 15
        return arc4random_uniform(maxMinute - minMinute) + minMinute
    }
    
    var second: UInt32 {
        let maxSecond: UInt32 = 59
        let minSecond: UInt32 = 0
        return arc4random_uniform(maxSecond - minSecond) + minSecond
    }
    
    
    var quotesViewController:QuotesViewController {
        let contentVC = QuotesViewController(nibName: "QuotesViewController", bundle: nil)!
        popover.contentSize = NSSize(width: 126, height: 280)
        popover.behavior = .transient;
        contentVC.btnDidClick(btnBlock: { (isShowWrire) in
            self.popover.contentSize = NSSize(width:(isShowWrire ? 480 : 126), height: 280)
        })
        contentVC.btnLogoutDidClick { 
            self.popover.contentViewController = self.loginController
        }
        return contentVC
    }
    var loginController:LoginController {
        let contentVC = LoginController(nibName: "LoginController", bundle: nil)!
        popover.contentSize = NSSize(width: 245, height: 135)
        popover.behavior = .transient;
        contentVC.btnDidClick(btnBlock: { (startlogin) in
            self.popover.contentViewController = self.quotesViewController
        })
        return contentVC;
    }
    
    /// 启动
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //初始化界面
        initSubViews()
        //接收自动打卡通知
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.startAutoWorkup), name:notiWorkAuto , object: nil)
        
        //读取自动打卡通知
        let result = UserDefaults.standard.object(forKey: kAutoWorkupState)
        if (result != nil) {
            startWorkupFun()
        }
    
    }
    
    /// 退出
    func applicationWillTerminate(_ aNotification: Notification) {
        let result = UserDefaults.standard.object(forKey: KWorkState) as! Bool
        if result {
            self.showAlert()
        }
        
    }
    
    func initSubViews() {
        if let button = statusItem.button{
            button.title = "☀︎"
            button.action = #selector(AppDelegate.togglePopover)
        }
        
//        popover.contentViewController = self.loginController;
        popover.contentViewController = UserDefaults.standard.object(forKey: kUsername) != nil ? self.quotesViewController : self.loginController
        
    }
    
    //开启自动打卡通知
    func startAutoWorkup() {
        startWorkupFun()
        //保存状态
        UserDefaults.standard.set(true, forKey: kAutoWorkupState)
        UserDefaults.standard.synchronize()
    }
    
    func startWorkupFun() {
        let workTime2 = "13:\(minute):\(second)"
        let workTime3 = "18:\(minute):\(second)"
        
        print("打卡时间：\(workTime2)====\(workTime3)")
        Tool.shareTool.toolWorkupRequest(timeType: .WorkupTimeAM)//上班
        startTimeStr(startTimeStr: workTime2,timeType: .WorkupTimeNoon)//午班
        startTimeStr(startTimeStr: workTime3,timeType: .WorkupTimeNight)//下班
    }
    
    
    
    func startTimeStr(startTimeStr:String,timeType:WorkupTime) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let workDate = formatter.date(from: startTimeStr)
        var nowDate = Date()
        let nowStr = formatter.string(from: nowDate)
        nowDate = formatter.date(from: nowStr)!
        print(nowDate)
        let time = workDate?.timeIntervalSince(nowDate)
        print(time)
        if time!<0 { return }
        DispatchQueue.global().asyncAfter(deadline: .now()+time!) {
            Tool.shareTool.toolWorkupRequest(timeType: timeType)
        }
    }
    func showPopover(sender:AnyObject?){
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            
        }
    }
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showAlert() {
        let alert = NSAlert()
        alert.messageText = "好像事情没有做？"
        alert.addButton(withTitle: "呵呵哒")
        alert.addButton(withTitle: "去看看")
        alert.alertStyle = NSAlertStyle.warning
        let result = alert.runModal()
        if result == NSAlertSecondButtonReturn{
            let url = NSURL(string:workUrl)!
            let browserBundleIdentifier = "com.apple.Safari"
            NSWorkspace.shared().open([url as URL],
                                      withAppBundleIdentifier:browserBundleIdentifier,
                                      options:.andHide,
                                      additionalEventParamDescriptor:nil,
                                      launchIdentifiers:nil)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

