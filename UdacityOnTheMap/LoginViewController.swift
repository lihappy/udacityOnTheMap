//
//  LoginViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: Any) {
        
        guard !(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! else {
            showSimpleErrorAlert(_message: "Please enter the account and password.", _sender: self)
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"udacity\": {\"username\": \"" + emailTextField.text! + "\", \"password\": \"" + passwordTextField.text! + "\"}}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
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
                self.dismiss(animated: true, completion: nil)
            }
//            self.getUserInfo(userId!)
            
            
        }
        task.resume()
        
        
    }
    
    @IBAction func signUp(_ sender: Any) {
    }
    
//    func postData{
//        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
//        request.httpMethod = "POST"
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: String.Encoding.utf8)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest) { data, response, error in
//            if error != nil { // Handle error…
//                return
//            }
//            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//        }
//        task.resume()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func getUserInfo(_ userId: String){
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
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func showSimpleErrorAlert(_message: String, _sender: AnyObject) {
    let alertController = UIAlertController.init(title: "Error", message: _message, preferredStyle: UIAlertControllerStyle.alert)
    let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    alertController.addAction(alertAction);
    _sender.present(alertController, animated: true, completion: nil);
}
