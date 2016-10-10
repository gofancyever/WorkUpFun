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
    
    
    
    func toolReviewWork(workType: WorkupTime) {
        
        let parameter = ["username":username,
                         "password":password]
        Alamofire.request(cookieUrl, method: .post, parameters: parameter)
            .response { (resp) in
                self.seeWork(workType: workType, handle: { (result) in
                    print(result)
                })
        }
    }
    
    func toolWorkupRequest(timeType:WorkupTime) {
        let parameter = ["username":username,
                         "password":password]
        Alamofire.request(cookieUrl, method: .post, parameters: parameter)
            .response { (resp) in
                self.workupWithTime(timeType: timeType)
        }
    }
    
    func workupWithTime(timeType:WorkupTime) {
        let url = timeType.rawValue;
        print(url)
        Alamofire.request(url).response { (response) in
            print("打开成功")
        }
    }
    
    
    
    func seeWork(workType:WorkupTime,handle:@escaping (_ result:Bool)->()) {
        //        getCookie()
        
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
                    if self.checkNeedWrite(content: resultStr) {
                        handle(true)
                    }
                }else{
                    let result = self.checkWorkTime(content: resultStr, workType: workType)
                    if !result { break }//如果不是指定时间跳过
                    if self.checkNeedPunchCard(content: resultStr){
                        handle(true)
                    }
                }
            }
            
        }
        
    }
    
    func checkNeedPunchCard(content:String) ->Bool {
        let hrefPattern = "<a href=.*>.*</a>"
        let pred = NSPredicate(format: "SELF MATCHES \(hrefPattern)", 0)
        let isHaveHref = pred.evaluate(with: content)
        return isHaveHref
    }
    func checkNeedWrite(content:String) ->Bool {
        let writePattern = "未写总结"
        let pred = NSPredicate(format: "SELF MATCHES \(writePattern)", 0)
        let isNoneWirte = pred.evaluate(with: content)
        return isNoneWirte
    }
    func checkWorkTime(content:String,workType:WorkupTime) ->Bool {
        var patternTime:String
        switch (workType) {
        case .WorkupTimeAM:
            patternTime = "daka_sb"
            break;
        case .WorkupTimeNoon:
            patternTime = "daka_sb2"
            break;
        case .WorkupTimeNight:
            patternTime = "daka_xb"
            break;
        default:
            patternTime = "&&&&&"
            break;
        }
        let pred = NSPredicate(format: "SELF MATCHES \(patternTime)", 0)
        let isMatch = pred.evaluate(with: content)
        return isMatch
        
    }
    
}
