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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

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
