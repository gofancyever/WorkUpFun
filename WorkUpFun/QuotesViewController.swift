//
//  QuotesViewController.swift
//  WorkUpFun
//
//  Created by apple on 16/10/6.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa

let KWorkState = "worKState"
let notiWorkAuto = Notification.Name("notiWorkAuto")
typealias BtnBlock = (_ isShowWrire:Bool) -> Void
typealias BtnLogOutBlock = () -> Void

class QuotesViewController: NSViewController {
    var clickLazyNum:Int = 0
    var block: BtnBlock?
    var logoutBlock:BtnLogOutBlock?
    var haveNeedWorkup:Bool = false;
    var showWrite: Bool = false
    @IBOutlet weak var tf_content: NSTextField!
    @IBOutlet weak var tf_result: NSTextField!
    
    @IBOutlet weak var btn_lazyWork: NSButton!
    
    @IBOutlet weak var pop_time: NSPopUpButton!
    @IBOutlet weak var pop_level: NSPopUpButton!
    
    @IBOutlet weak var box_write: NSBox!
    @IBOutlet weak var box_night: NSBox!
    @IBOutlet weak var box_noon: NSBox!
    @IBOutlet weak var box_AM: NSBox!
    
    @IBOutlet weak var Cbox_workType: NSComboBox!
    @IBOutlet weak var Cbox_workTime: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkWorkState()

    }
    
    override func viewDidDisappear() {
        UserDefaults.standard.set(haveNeedWorkup, forKey: KWorkState)
        UserDefaults.standard.synchronize()
    }

    @IBAction func lab_lazyWork(_ sender: NSButton) {
    
        if clickLazyNum>6 {
            clickLazyNum = 0
        }
        clickLazyNum += 1
        print(clickLazyNum)
        if clickLazyNum == 6 {
            sender.title = "♺"
            NotificationCenter.default.post(name: notiWorkAuto, object: nil)
        }
        else if clickLazyNum == 4 {
            UserDefaults.standard.removeObject(forKey: kAutoWorkupState)
            UserDefaults.standard.synchronize()
        }
        else{
            sender.title = "=.="
        }
    }
    @IBAction func btn_AM(_ sender: NSButton) {
        Tool.shareTool.toolWorkupRequest(timeType: .WorkupTimeAM)
    }
    @IBAction func btn_noon(_ sender: NSButton) {
        Tool.shareTool.toolWorkupRequest(timeType: .WorkupTimeNoon)
    }
    @IBAction func btn_night(_ sender: NSButton){
        Tool.shareTool.toolWorkupRequest(timeType: .WorkupTimeNight)
    }
    
    /// 检测状态
    @IBAction func btn_checkWorkState(_ sender: NSButton) {
        checkWorkState()
    }
    
    @IBAction func btn_writeClick(_ sender: NSButton) {
        self.showWrite = !self.showWrite
        sender.title = self.showWrite ? "收起" : "写总结"
        if (block != nil) {
            block!(self.showWrite)
        }
    }
    func btnDidClick(btnBlock: BtnBlock?) {
        if (btnBlock != nil) {
            self.block = btnBlock
        }
    }
    @IBAction func submitClick(_ sender: AnyObject) {
        
        let model = OE_WorkReportModel()
        model.jjzy = "\(4 - self.Cbox_workType.indexOfSelectedItem)"
        model.workTime = self.Cbox_workTime.objectValueOfSelectedItem as? String
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        model.dateStr = dateStr
        model.title = self.tf_content.stringValue
        model.workResult = self.tf_result.stringValue
        
        Tool.shareTool.toolSubmitWorkReport(model: model)
    }

    @IBAction func btn_logoutClick(_ sender: NSButton) {
        Tool.shareTool.toolRemoveUserInfo()
        Tool.shareTool.toolLogoutRequest()//清除cookie
        if (self.logoutBlock != nil) {
            self.logoutBlock!()
        }
    }
    
    func btnLogoutDidClick(block:BtnLogOutBlock?){
        if (block != nil) {
            self.logoutBlock = block;
        }
    }
    //MARK: 自定义方法
    ///检测打卡状态
    func checkWorkState(){
        
        Tool.shareTool.toolChecKWorkState(workType: .WorkupTimeAM) { [weak self] (result) in
            print("获取上班时间success \(result)需要打卡")
            print(Thread.current);
            if (result){
                self?.box_AM.fillColor = NSColor(calibratedRed: 232/255.0, green: 101/255.0, blue: 83/255.0, alpha: 1)
            }else{
                self?.box_AM.fillColor = NSColor(calibratedRed: 88/255.0, green: 232/255.0, blue: 109/255.0, alpha: 1)
            }
            self?.haveNeedWorkup = result
        }
        
        Tool.shareTool.toolChecKWorkState(workType: .WorkupTimeNoon) { [weak self] (result) in
            print("获取午班时间success")
            if (result){
                self?.box_noon.fillColor = NSColor(calibratedRed: 232/255.0, green: 101/255.0, blue: 83/255.0, alpha: 1)
                
            }else{
                self?.box_noon.fillColor = NSColor(calibratedRed: 88/255.0, green: 232/255.0, blue: 109/255.0, alpha: 1)
            }
            self?.haveNeedWorkup = result;
            
        }
        
        Tool.shareTool.toolChecKWorkState(workType: .WorkupTimeNight) { [weak self] (result) in
            if (result){
                print("获取晚班时间success")
                self?.box_night.fillColor = NSColor(calibratedRed: 232/255.0, green: 101/255.0, blue: 83/255.0, alpha: 1)
                
            }else{
                self?.box_night.fillColor = NSColor(calibratedRed: 88/255.0, green: 232/255.0, blue: 109/255.0, alpha: 1)
            }
            self?.haveNeedWorkup = result;
        }
        
        Tool.shareTool.toolChecKWorkState(workType: .WorkupTimeWrite) { [weak self] (result) in
            if (result){
                print("获取工作总结success")
                self?.box_write.fillColor = NSColor(calibratedRed: 232/255.0, green: 101/255.0, blue: 83/255.0, alpha: 1)
                
            }else{
                self?.box_write.fillColor = NSColor(calibratedRed: 88/255.0, green: 232/255.0, blue: 109/255.0, alpha: 1)
            }
            self?.haveNeedWorkup = result;
        }
    }
    
    
}

