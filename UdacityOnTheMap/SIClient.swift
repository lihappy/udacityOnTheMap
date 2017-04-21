//
//  SIClient.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/21/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class SIClient: NSObject {
    
    // Shared session
    var session = URLSession.shared
    
    // Shared student list
    var studentArray = [StudentInformation]()
    
//    // Current user
//    var student = StudentInformation()?
    
    
    // Shared use id
    var userId: String? {
        didSet {
            // Get user info from Udacity
            self.getUserInfo(userId!)
            
            // Get user objectId in Parse if have
            self.getUserLocationInfo(userId!)
            
        }
    }
    var firstName: String?
    var lastName: String?
    
    var objectId: String?
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> SIClient {
        struct Singleton {
            static var sharedInstance = SIClient()
        }
        return Singleton.sharedInstance
    }
    
//    override func setUserId(_ userId: String) {
//        self.userId = userId
//        
//        // Get user info from Udacity
//        self.requestUserInfo(userId)
//        
//        // Get user's objectId from parse
//    }
    
    func getUserInfo(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            //            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            let user = parsedResult["user"] as? [String:AnyObject]
            let firstName = user?["first_name"] as? String
            let lastName = user?["last_name"] as? String
            
            self.firstName = firstName
            self.lastName = lastName
        }
        task.resume()
    }
    
    func getUserLocationInfo(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where={\"uniqueKey\":\"\(userId)\"}"
        let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: escapedUrlString!)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            let results = parsedResult[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]]
            if ((results?.count)! > 0) {
                let firstResult = (results?[0])! as [String:AnyObject]
                self.objectId = firstResult["objectId"] as! String?
            }
            
        }
        task.resume()
    }
    
    func taskForHttpRequest(_ url: URL, method: String, parameters: NSDictionary, jsonBody: String, needConvertData: Bool, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        for parameter in parameters {
            request.addValue(parameter.value as! String, forHTTPHeaderField: parameter.key as! String)
        }
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForHttpRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if (needConvertData) {
//                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    sendError("Could not parse the data as JSON: '\(data)'")
//                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
//                    completionHandlzerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
                }
                completionHandlerForPOST(parsedResult, nil)
            } else {
                completionHandlerForPOST(data as AnyObject?, nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // given raw JSON, return a usable Foundation object
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
//        print(parsedResult);
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}

func showSimpleErrorAlert(_message: String, _sender: AnyObject) {
    let alertController = UIAlertController.init(title: "Error", message: _message, preferredStyle: UIAlertControllerStyle.alert)
    let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    alertController.addAction(alertAction);
    _sender.present(alertController, animated: true, completion: nil);
}

func openUserUrl(_ urlString: String) {
    let url = URL.init(string: urlString)
    UIApplication.shared.openURL(url!)    
}
