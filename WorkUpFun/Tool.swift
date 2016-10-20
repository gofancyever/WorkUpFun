//
//  Tool.swift
//  WorkUpFun
//
//  Created by apple on 16/10/7.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa
import Alamofire


let workUrl = "http://192.168.0.111:9696/main.asp"
let pattern = "<span id=\"daka_.*\">[\\s\\S]*?</span>"
let cookieUrl = "http://192.168.0.111:9696/?action=login"
let username = "gaof"
let password = "nongji36002nd"
let workReportUrl = "http://192.168.0.111:9696/worklog/add_ok.asp"


enum WorkResult:NSInteger {
    case WorkResultNone = 0
    case WorkResultNeedPunchCard
    case WorkResultNeedWrite
    
}

enum WorkupTime:String {
    case WorkupTimeNone = ""
    case WorkupTimeAM = "http://192.168.0.111:9696/daka/qd_sb.asp?st=sb1"
    case WorkupTimeNoon = "http://192.168.0.111:9696/daka/qd_sb.asp?st=sb2"
    case WorkupTimeNight = "http://192.168.0.111:9696/daka/qd_sb.asp?st=xb"
    case WorkupTimeWrite = "wrire"
    
}


typealias ResultBlock = (_ result:WorkResult) -> Void

private let sharedInstance = Tool()

class Tool: NSObject {
    class var shareTool : Tool{
        return sharedInstance
    }
    ///带Cooie 发送总结
    func toolSubmitWorkReport(model:OE_WorkReportModel){
        toolHaveCookieRequest {
            self.submitWorkReport(model: model)
        }
    }
    
    ///带Cooie 发送打卡
    func toolWorkupRequest(timeType:WorkupTime) {
        toolHaveCookieRequest {
            self.workupWithTime(timeType: timeType)
        }
    }
    
    
    /// 检测打卡 true 为需要打卡 false 为不需要
    func toolChecKWorkState(workType:WorkupTime,handle:@escaping (_ result:Bool)->()){
        toolHaveCookieRequest {
            self.seeWork(workType:workType) { (result) in
                handle(result)
            }
        }
    }
    
    /// 发送工作总结
    private func submitWorkReport(model:OE_WorkReportModel) {
        var parameter:[String:Any] = [String:Any]()
        parameter["gzall"] = 0
        parameter["tjdate"]  = model.dateStr
        parameter["dt"] = "tj"
        parameter["jjzy0"] = model.jjzy
        parameter["worktime0"] = model.workTime
        parameter["title0"] = model.title
        parameter["workcg0"] = model.workResult
        parameter["worknum0"] = 1
        parameter["worktime"] = 480
        parameter["zscg0"] = model.workResult?.characters.count
        parameter["zsms0"] = model.title?.characters.count
        Alamofire.request(workReportUrl, method: .post, parameters: parameter)
            .response { (response) in
                let cfEnc = CFStringEncodings.GB_18030_2000
                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                let content = String(data: response.data!, encoding: String.Encoding(rawValue: enc))
                print(content)
        }
        
    }
    
    /// 获取cookie 执行 方法
    private func toolHaveCookieRequest(requestFunc:@escaping ()->()){
        let parameter = ["username":username,
                         "password":password]
        Alamofire.request(cookieUrl, method: .post, parameters: parameter)
            .response { (resp) in
                print("获取到cookie...")
                requestFunc()
        }
    }
    
    
    /// 发送打卡
    private func workupWithTime(timeType:WorkupTime) {
        let url = timeType.rawValue;
        print(url)
        Alamofire.request(url).response { (response) in
            print("执行打卡完毕")
        }
    }
    
    
    
    func seeWork(workType:WorkupTime,handle:@escaping (_ result:Bool)->()) {
        
        Alamofire.request(workUrl).response { (response) in
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            let content = String(data: response.data!, encoding: String.Encoding(rawValue: enc))
            //            print(content!)
            //正则匹配
            let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
            let results = regular.matches(in: content!, options: .reportProgress , range: NSMakeRange(0, content!.characters.count))
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for resultRange in results {
                let resultStr = (content! as NSString).substring(with: resultRange.range)
                
                //1判断是否为写总结
                if workType == WorkupTime.WorkupTimeWrite {
                    if self.checkisWrite(content: resultStr) {
                        handle(self.checkNeedWrite(content: resultStr))
                    }
                }else{
                    let result = self.checkWorkTime(content: resultStr, workType: workType)
                    if result {
                        handle(self.checkNeedPunchCard(content: resultStr))
                    }
                }
            }
        }
    }
    func checkNeedPunchCard(content:String) ->Bool {
        let hrefPattern = "正常打卡"
        let resultHref = content.isMatched(hrefPattern)
        print("\(!resultHref)")
        return !resultHref
    }
    func checkNeedWrite(content:String)->Bool {
        let writePattern = "已写"
        return !content.isMatched(writePattern)
    }
    func checkisWrite(content:String) ->Bool {
        let writePattern = "总结"
        return content.isMatched(writePattern)
    }
    func checkWorkTime(content:String,workType:WorkupTime) ->Bool {
        var patternTime:String
        switch (workType) {
        case .WorkupTimeAM:
            patternTime = "daka_sb\\\""
            break;
        case .WorkupTimeNoon:
            patternTime = "daka_sb2\\\""
            break;
        case .WorkupTimeNight:
            patternTime = "st=xb"
            break;
        default:
            patternTime = "&&&&&"
            break;
        }
        
        let isMatch = content.isMatched(patternTime)
        return isMatch
        
    }
    
}
private extension String {
    func isMatched(_ pattern: String) -> Bool {
        let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
        let results = regular.matches(in: self, options: .reportProgress , range: NSMakeRange(0, self.characters.count))
        if results.count>0 {
            return true
        }else{
            return false
        }
    }
}
