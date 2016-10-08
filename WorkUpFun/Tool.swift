//
//  Tool.swift
//  WorkUpFun
//
//  Created by apple on 16/10/7.
//  Copyright © 2016年 Gaooof. All rights reserved.
//

import Cocoa
import Alamofire

let workUrl = "http://example.com"
let pattern = "<div class=\"uk-grid\">[\\s\\S]*?</div>"
let cookieUrl = ""


enum WorkResult {
    case WorkResultNone
    case WorkResultNeedPunchCard
    case WorkResultNeedWrite
    
}
typealias ResultBlock = (_ result:WorkResult) -> Void

private let sharedInstance = Tool()

class Tool: NSObject {
    class var shareTool : Tool{
        return sharedInstance
    }
    
    func test(block:@escaping ResultBlock){
        let queue = DispatchQueue.main
        queue.async {
            sleep(1)
            block(WorkResult.WorkResultNeedPunchCard)
        }
        
    }
    
    func loadCookie() {
        
//        let parameter = ["username":"",
//                         "password":""]
        Alamofire.request("https://www.baidu.com/", method: .get).response { (resp) in
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: resp.response?.allHeaderFields as! [String: String], for: (resp.response?.url!)!)
            print(cookies)
        }
        

        
        
//        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(fileURLWithPath: workUrl), mainDocumentURL: nil)
        
    }
    
    let queue = DispatchQueue(label: "seeWork")
    let group = DispatchGroup()
    
    func seeWork()->WorkResult? {
        
        //        getCookie()
        
        var result:WorkResult?
        
            Alamofire.request("http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000").response { (response) in
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
                    
                    let results = regular.matches(in: utf8Text, options: .reportProgress , range: NSMakeRange(0, utf8Text.characters.count))
                    
                    //输出截取结果
                    print("符合的结果有\(results.count)个")
                    for result in results {
                        print((utf8Text as NSString).substring(with: result.range))
                    }
                    
                    
                }
                result = WorkResult.WorkResultNeedPunchCard
                self.group.leave()
            }
        
        return result
    }
    
}
