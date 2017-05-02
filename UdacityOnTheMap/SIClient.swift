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
    
    // MARK: Shared Instance
    class func sharedInstance() -> SIClient {
        struct Singleton {
            static var sharedInstance = SIClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
    func startHttpTask(_ url: URL, method: String, parameters: NSDictionary, jsonBody: String, needTrimData: Bool, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        for parameter in parameters {
            request.addValue(parameter.value as! String, forHTTPHeaderField: parameter.key as! String)
        }
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
//        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            
//            func sendError(_ error: String) {
//                print(error)
//                let userInfo = [NSLocalizedDescriptionKey : error]
//                completionHandlerForPOST(nil, NSError(domain: "startHttpTask", code: 1, userInfo: userInfo))
//            }
//            
//            /* GUARD: Was there an error? */
//            if (error != nil) {
//                sendError("There was an error with your request: \(error?.localizedDescription)")
//                return
//            }
//            
//            /* GUARD: Was there any data returned? */
//            if (data == nil) {
//                sendError("No data was returned by the request!")
//                return
//            }
//            
//            var newData = data
//            if (needTrimData) {
//                let range = Range(SIClient.Constants.UdacityDataTrimLength..<data!.count)
//                newData = data!.subdata(in: range) /* subset response data! */
//            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                NSLog("Could not parse the data as JSON: '\(newData)'")
//                sendError("Could not parse the data")
//                return
//            }
//            
//            completionHandlerForPOST(parsedResult as AnyObject?, nil)
//        }
//        
//        /* 7. Start the request */
//        task.resume()
        
        return self.taskForHttpRequest(request, needTrimData: needTrimData, completionHandlerForPOST: completionHandlerForPOST)
    }
    
    func taskForHttpRequest(_ request: NSMutableURLRequest, needTrimData: Bool, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForHttpRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            if (error != nil) {
                sendError("There was an error with your request: \(error?.localizedDescription)")
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
    
    func postLocation(_ sender: PostInfoViewController) {
        sender.activityIndicator.startAnimating()
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.ParametersKey.ContentType as NSCopying)
        
        var firstName = ""
        if (SIModel.sharedInstance().firstName != nil) {
            firstName = SIModel.sharedInstance().firstName!
        }
        var lastName = ""
        if (SIModel.sharedInstance().lastName != nil) {
            lastName = SIModel.sharedInstance().lastName!
        }
        
        let body = "{\"\(SIClient.JSONResponseKeys.UniqueKey)\": \"\(SIModel.sharedInstance().userId! as String)\", \"\(SIClient.JSONResponseKeys.FirstName)\": \"\(firstName)\", \"\(SIClient.JSONResponseKeys.LastName)\": \"\(lastName)\",\"\(SIClient.JSONResponseKeys.MapString)\": \"\(sender.mapString! as String)\", \"\(SIClient.JSONResponseKeys.MediaURL)\": \"\(sender.mediaUrl! as String)\",\"\(SIClient.JSONResponseKeys.Latitude)\": \(sender.latitude! as Double), \"\(SIClient.JSONResponseKeys.Longitude)\": \(sender.longtitute! as Double)}"
        
        var urlString: String = SIClient.Constants.StudentsLocationURL
        var method: String = SIClient.Constants.PostMethod
        
        var objectId: String = ""
        if (SIModel.sharedInstance().objectId != nil) {
            objectId = SIModel.sharedInstance().objectId!
        }
        var isPost: Bool = false
        isPost = objectId.isEmpty
        
        if (!isPost) {
            urlString = urlString + "/\(objectId)"
            method = SIClient.Constants.PutMethod
        }
        
        let _ = SIClient.sharedInstance().startHttpTask(URL(string: urlString)!, method: method, parameters: parameters, jsonBody: body, needTrimData: false) { (result, error) in
            
            DispatchQueue.main.async {
                sender.activityIndicator.stopAnimating()
            }
            
            if (error != nil) {
                showSimpleErrorAlert(_message: (error?.localizedDescription)!, _sender: sender)
                return
            }
            let postFailed: String = "Post failed."
            if (result == nil) {
                showSimpleErrorAlert(_message: postFailed, _sender: sender)
                return
            }
            let errorStatus = result?[SIClient.JSONResponseKeys.Error] as? String
            if (errorStatus != nil) {
                showSimpleErrorAlert(_message: "\(postFailed) \(errorStatus)", _sender: sender)
                return
            }
            
            var objectId: String?
            var updatedAt: String
            var isSucceeded: Bool = false
            if (isPost) {
                objectId = result?[SIClient.JSONResponseKeys.ObjectId] as? String
                if (!(objectId?.isEmpty)!) {
                    isSucceeded = true
                    SIModel.sharedInstance().objectId = objectId
                }
            } else {
                updatedAt = (result![SIClient.JSONResponseKeys.UpdatedAt] as? String)!
                if (!updatedAt.isEmpty) {
                    isSucceeded = true
                }
            }
            
            if (isSucceeded) {
                DispatchQueue.main.async {
                    sender.dismiss(animated: true, completion: nil)
                }
            } else {
                showSimpleErrorAlert(_message: postFailed, _sender: sender)
            }
        }
    }
    
    func login(_ sender: LoginViewController) {
        sender.activityIndicator.startAnimating()
        
        let url = URL(string: SIClient.Constants.AuthorizationURL)
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.ParametersKey.Accept as NSCopying)
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.ParametersKey.ContentType as NSCopying)
        
        let body = "{\"\(SIClient.JSONResponseKeys.Udacity)\": {\"\(SIClient.JSONResponseKeys.Username)\": \"" + sender.emailTextField.text! + "\", \"\(SIClient.JSONResponseKeys.Password)\": \"" + sender.passwordTextField.text! + "\"}}"
        
        let _ = SIClient.sharedInstance().startHttpTask(url!, method: SIClient.Constants.PostMethod, parameters: parameters, jsonBody: body, needTrimData: true) { (result, error) in
            DispatchQueue.main.async {
                sender.activityIndicator.stopAnimating()
            }
            
            if (error != nil || result == nil) {
                showSimpleErrorAlert(_message: "\(SIClient.Constants.LoginFailMsg) \(error?.localizedDescription)", _sender: sender)
                return
            }
            
            let status = result![SIClient.JSONResponseKeys.StatusCode] as? Int
            if ( status != nil && status != 200 ) {
                let errorMessage = result![SIClient.JSONResponseKeys.Error] as? String
                showSimpleErrorAlert(_message: "\(SIClient.Constants.LoginFailMsg) \(errorMessage)", _sender: sender)
                return
            }
            
            //sucess
            let account = result![SIClient.JSONResponseKeys.Account] as? [String:AnyObject]
            let userId = account?[SIClient.JSONResponseKeys.AccountKey] as? String
            
            if (!(userId?.isEmpty)!) {
                SIModel.sharedInstance().userId = userId
                sender.completeLogin()
            } else {
                showSimpleErrorAlert(_message: SIClient.Constants.LoginFailMsg, _sender: sender)
            }
            
        }
    }
    
    func logout(_ sender: OnTheMapViewController) {
        sender.activityIndicator.startAnimating()
        
        let request = NSMutableURLRequest(url: URL(string: SIClient.Constants.AuthorizationURL)!)
        request.httpMethod = SIClient.Constants.DeleteMethod
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == SIClient.ParametersKey.XsrfCookieName { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: SIClient.ParametersKey.XsrfCookieKey)
        }
        
        let _ = self.taskForHttpRequest(request, needTrimData: true) { (result, error) in
            DispatchQueue.main.async {
                sender.activityIndicator.stopAnimating()
            }

            if (error != nil) {
                showSimpleErrorAlert(_message: (error?.localizedDescription)!, _sender: sender)
                return
            }
            if (result == nil) {
                showSimpleErrorAlert(_message: SIClient.Constants.LogoutFailMsg, _sender: sender)
                return
            }
            
            let session = result![SIClient.JSONResponseKeys.Session] as? [String:AnyObject]
            let id = session?[SIClient.JSONResponseKeys.SessionID] as? String

            if (session != nil && id != nil) {
                SIModel.sharedInstance().userId = ""
                SIModel.sharedInstance().firstName = ""
                SIModel.sharedInstance().lastName = ""
                SIModel.sharedInstance().objectId = ""

                sender.dismiss(animated: true, completion: nil)
            } else {
                showSimpleErrorAlert(_message: SIClient.Constants.LogoutFailMsg, _sender: sender)
            }
        }
    }
    
    
    func requestStudentsInfo(_ sender: OnTheMapViewController) {
        sender.activityIndicator.startAnimating()
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        parameters.setObject("100", forKey: SIClient.JSONResponseKeys.Limit as NSCopying)
        parameters.setObject("-updatedAt", forKey: SIClient.JSONResponseKeys.Order as NSCopying)
        
        let url = URL(string: SIClient.Constants.StudentsLocationURL)!
        
        let _ = SIClient.sharedInstance().startHttpTask(url, method: SIClient.Constants.GetMethod, parameters: parameters, jsonBody: "", needTrimData: false) { (result, error) in
            DispatchQueue.main.async {
                sender.activityIndicator.stopAnimating()
            }
            if (error != nil) {
                showSimpleErrorAlert(_message: (error?.localizedDescription)!, _sender: sender)
                return
            }
            let errorMsg: String = "Failed to download students info."
            if (result == nil) {
                showSimpleErrorAlert(_message: errorMsg, _sender: sender)
                return
            }
            
            let errorStatus = result?[SIClient.JSONResponseKeys.Error] as? String
            if (errorStatus != nil) {
                showSimpleErrorAlert(_message: "\(errorMsg) \(errorStatus)", _sender: sender)
                return
            }
            
            if (result != nil) {
                DispatchQueue.main.async {
                    sender.activityIndicator.stopAnimating()
                }
                
                sender.saveStudentsInfo(result!)
                
                // Refresh map and list with the new data
                sender.updateData()
            }
        }
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

