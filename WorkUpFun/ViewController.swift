//
//  ViewController.swift
//  WorkUpFun
//
//  Created by apple on 16/10/6.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa
import Alamofire
class ViewController: NSViewController {
    
    @IBOutlet weak var tf_workResult: NSTextField!
    
    @IBOutlet weak var tf_workContent: NSTextField!
    
    @IBOutlet weak var submitClick: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func btn_submitClick(_ sender: AnyObject) {
        
        let content = tf_workContent.stringValue
        let result = tf_workResult.stringValue
        submitWorkContent(content: content,result: result)
    }
    
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    /// 提交工作总结
    func submitWorkContent(content:String,result:String) {
        
    }
    
    
}



