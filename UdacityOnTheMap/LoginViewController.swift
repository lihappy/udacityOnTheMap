//
//  LoginViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard !(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! else {
            showSimpleErrorAlert(_message: "Please enter the account and password.", _sender: self)
            return
        }
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.startAnimating()
        
//        let url = URL(string: "https://www.udacity.com/api/session")
//        let parameters: NSMutableDictionary = NSMutableDictionary()
//        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.Constants.Accept as NSCopying)
//        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.Constants.ContentType as NSCopying)
//        
//        let body = "{\"udacity\": {\"username\": \"" + emailTextField.text! + "\", \"password\": \"" + passwordTextField.text! + "\"}}"
//        
//        SIClient.sharedInstance().taskForHttpRequest(url!, method: "POST", parameters: parameters, jsonBody: body, needConvertData: false) { (result, error) in
//            
//            let range = Range(5..<result!.count)
//            let newData = (result as? Data)?.subdata(in: range) /* subset response data! */
////            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
//            
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                NSLog("Could not parse the data as JSON: '\(result)'")
//                showSimpleErrorAlert(_message: "Login failed", _sender: self)
//                return
//            }
//            
//            let status = parsedResult["status"] as? String
//            if ( status == "400" ) {
//                let errorMessage = parsedResult["error"] as? String
//                showSimpleErrorAlert(_message: "Login Failed. \(errorMessage)", _sender: self);
//                return
//            }
//            
//            //sucess
//            let session = parsedResult["session"] as? [String:AnyObject]
//            let sessionId = session?["id"] as? String
//            //            if (!(sessionId?.isEmpty)!) {
//            //                self.dismiss(animated: true, completion: nil)
//            //            }
//            let account = parsedResult["account"] as? [String:AnyObject]
//            let userId = account?["key"] as? String
//            
//            
//            if (!(userId?.isEmpty)!) {
//                SIClient.sharedInstance().userId = userId
//                self.dismiss(animated: true, completion: nil)
//            }
//
//        }
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"udacity\": {\"username\": \"" + emailTextField.text! + "\", \"password\": \"" + passwordTextField.text! + "\"}}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if error != nil {
                showSimpleErrorAlert(_message: "Login failed. \(error?.localizedDescription)", _sender: self)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(data)'")
                showSimpleErrorAlert(_message: "Login failed", _sender: self)
                return
            }
            
            let status = parsedResult["status"] as? String
            if ( status == "400" ) {
                let errorMessage = parsedResult["error"] as? String
                showSimpleErrorAlert(_message: "Login Failed. \(errorMessage)", _sender: self);
                return
            }
            
            //sucess
            let session = parsedResult["session"] as? [String:AnyObject]
            let sessionId = session?["id"] as? String
//            if (!(sessionId?.isEmpty)!) {
//                self.dismiss(animated: true, completion: nil)
//            }
            let account = parsedResult["account"] as? [String:AnyObject]
            let userId = account?["key"] as? String

            
            if (!(userId?.isEmpty)!) {
                SIClient.sharedInstance().userId = userId
                let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "navigationViewController")
//                self.present(navigationVC!, animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
        task.resume()
        
        
    }
    
    @IBAction func signUp(_ sender: Any) {
    }
    
    
    


}


