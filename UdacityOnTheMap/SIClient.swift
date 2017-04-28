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
    
    func getUserInfo(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let url = URL(string: "\(SIClient.Constants.UserInfoURL)/\(userId)")!
        let _ = SIClient.sharedInstance().taskForHttpRequest(url, method: SIClient.Constants.GetMethod, parameters: NSMutableDictionary(), jsonBody: "", needTrimData: true) { (result, error) in
            if (error != nil || result == nil) {
                return
            }
            
            let user = result?[SIClient.JSONResponseKeys.User] as? [String:AnyObject]
            self.firstName = user?[SIClient.JSONResponseKeys.FirstNameKey] as? String
            self.lastName = user?[SIClient.JSONResponseKeys.LastNameKey] as? String
        }
    }
    
    func getUserLocationInfo(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let urlString = "\(SIClient.Constants.StudentsLocationURL)?where={\"\(SIClient.JSONResponseKeys.UniqueKey)\":\"\(userId)\"}"
        let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: escapedUrlString!)!
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        
        let _ = SIClient.sharedInstance().taskForHttpRequest(url, method: SIClient.Constants.GetMethod, parameters: parameters, jsonBody: "", needTrimData: false) { (result, error) in
            if (error != nil || result == nil) {
                return
            }
            
            let results = result?[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]]
            if (results != nil && (results?.count)! > 0) {
                let firstResult = (results?[0])! as [String:AnyObject]
                self.objectId = firstResult[SIClient.JSONResponseKeys.ObjectId] as! String?
            }
        }
        
    }
    
    func taskForHttpRequest(_ url: URL, method: String, parameters: NSDictionary, jsonBody: String, needTrimData: Bool, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
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
            if (error != nil) {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            if (data == nil) {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
            if (needTrimData) {
                let range = Range(SIClient.Constants.UdacityDataTrimLength..<data!.count)
                newData = data!.subdata(in: range) /* subset response data! */
            }

            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(newData)'")
                sendError("Could not parse the data")
                return
            }
            
            completionHandlerForPOST(parsedResult as AnyObject?, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
}

func showSimpleErrorAlert(_message: String, _sender: AnyObject) {
    DispatchQueue.main.async {
        let alertController = UIAlertController.init(title: "Error", message: _message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction);
        _sender.present(alertController, animated: true, completion: nil);
    }
}

func openUrlWithSafari(_ urlString: String) {
    let url = URL.init(string: urlString)
    UIApplication.shared.openURL(url!)    
}

func getBaseParseParams() -> NSMutableDictionary {
    let parameters: NSMutableDictionary = NSMutableDictionary()
    parameters.setObject(SIClient.Constants.ParseApplicationID, forKey: SIClient.ParametersKey.ParseAppIdKey as NSCopying)
    parameters.setObject(SIClient.Constants.ParseApplicationKey, forKey: SIClient.ParametersKey.ParseApiKey as NSCopying)
    return parameters
}

