//
//  APIHandler.swift
//  PublicEye
//
//  Created by Sudhakar Dasari on 15/01/18.
//  Copyright © 2018 Sudhakar Dasari. All rights reserved.
//

import UIKit
import Alamofire

class APIHandler: NSObject {
    
    static let sharedInstance = APIHandler()
    
    func requestGET(serviceUrl : String, params : [String : Any]?, success:@escaping (Any,Int?) -> Void, failure:@escaping (Error,String,[String : AnyObject],Int?) -> Void) {
        
        Alamofire.request(serviceUrl, method: .get, parameters: params).validate().responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                let httpSuccessStatusCode = response.response?.statusCode
                if let data = response.result.value{
                    //print(data)
                    success(data as Any,httpSuccessStatusCode)
                }
                break
                
            case .failure(_):
                //print(response.result.error!)
                
                let httpFailureStatusCode = response.response?.statusCode
                let errorResponseString = String(data: response.data!, encoding: String.Encoding.utf8)!
                var errorResponseDic = [String : AnyObject]()
                do {
                    errorResponseDic = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : AnyObject]
                } catch let error as NSError {
                    print(error)
                }
                failure(response.result.error!,errorResponseString,errorResponseDic,httpFailureStatusCode)
                
                break
            }
        }
    }
    
}

