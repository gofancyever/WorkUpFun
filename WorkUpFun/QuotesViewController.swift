//
//  QuotesViewController.swift
//  WorkUpFun
//
//  Created by apple on 16/10/6.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa

typealias BtnBlock = (_ isShowWrire:Bool) -> Void
class QuotesViewController: NSViewController {

    var block: BtnBlock?
    var showWrite: Bool = false
    @IBOutlet weak var tf_content: NSTextField!
    @IBOutlet weak var tf_result: NSTextField!
    
    @IBOutlet weak var pop_time: NSPopUpButton!
    @IBOutlet weak var pop_level: NSPopUpButton!
    
    @IBOutlet weak var box_write: NSBox!
    @IBOutlet weak var box_night: NSBox!
    @IBOutlet weak var box_noon: NSBox!
    @IBOutlet weak var box_AM: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkWorkState()


    }
    
    func checkWorkState(){
        Tool.shareTool.seeWork(workType: .WorkupTimeAM) { [weak self](result) in
            if result {
                self?.box_AM.fillColor = NSColor(calibratedRed: 255/255.0, green: 0, blue: 0, alpha: 1)
            }
        }
        Tool.shareTool.seeWork(workType: .WorkupTimeNone) { [weak self](result) in
            if result {
                self?.box_AM.fillColor = NSColor(calibratedRed: 255/255.0, green: 0, blue: 0, alpha: 1)
            }
        }
        Tool.shareTool.seeWork(workType: .WorkupTimeNight) { [weak self](result) in
            if result {
                self?.box_AM.fillColor = NSColor(calibratedRed: 255/255.0, green: 0, blue: 0, alpha: 1)
            }
        }
        Tool.shareTool.seeWork(workType: .WorkupTimeWrite) { [weak self](result) in
            if result {
                self?.box_AM.fillColor = NSColor(calibratedRed: 255/255.0, green: 0, blue: 0, alpha: 1)
            }
        }
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
    }
    
}
