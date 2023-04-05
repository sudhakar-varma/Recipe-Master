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
        
      
        /* With URLEncoding
         
        AF.request(serviceUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseJSON(completionHandler: { response in

            switch response.result {
            case .success:

                let httpSuccessStatusCode = response.response?.statusCode
                if let data = response.value {
                    //print(data)
                    success(data as Any,httpSuccessStatusCode)
                }
                break

            case .failure(_):

                let httpFailureStatusCode = response.response?.statusCode
                let errorResponseString = String(data: response.data!, encoding: String.Encoding.utf8)!
                var errorResponseDic = [String : AnyObject]()
                do {
                    errorResponseDic = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : AnyObject]
                } catch let error as NSError {
                    print(error)
                }
                failure(response.error!, errorResponseString, errorResponseDic, httpFailureStatusCode)

            }
        })
         */

        // Alamofire 5.6.1 Swift Concurrency
        
        AF.request("https://ifsc.razorpay.com/KARB0000001", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).validate().response { response in
            
            switch(response.result) {
            case .success(_):
                let httpSuccessStatusCode = response.response?.statusCode
                if let data = response.value {
                    
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: data!)
                        
                        print(asJSON)
                        
                        success(asJSON,httpSuccessStatusCode)
    
                    } catch {
                        print("Error while decoding response: \(error) from: \(String(data: data!, encoding: .utf8) ?? "")")
                    }
                    
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
                failure(response.error!, errorResponseString, errorResponseDic, httpFailureStatusCode)

                break
            }
            
        }
        
        /*
         
        AF.request(serviceUrl, method: .get, parameters: params).validate().responseJSON { (response:DataResponse<Any>) in

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
         */
        
    }
    
}

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

struct URLConstants {
    
    private  static let baseURL = "http://www.recipepuppy.com/api/"
    
    static func getRecipeListing(with ingredients:String,pageNumber:Int) -> String {
        return "\(URLConstants.baseURL)?i=\(ingredients)&p=\(pageNumber)"
    }
}
