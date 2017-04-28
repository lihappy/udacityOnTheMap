//
//  LoginViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class LoginViewController: LHBViewController {
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard !(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! else {
            showSimpleErrorAlert(_message: "Please enter the account and password.", _sender: self)
            return
        }
        
        self.activityIndicator.startAnimating()
        
        let url = URL(string: SIClient.Constants.AuthorizationURL)
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.Constants.Accept as NSCopying)
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.Constants.ContentType as NSCopying)
        
        let body = "{\"udacity\": {\"username\": \"" + emailTextField.text! + "\", \"password\": \"" + passwordTextField.text! + "\"}}"
        
        let _ = SIClient.sharedInstance().taskForHttpRequest(url!, method: "POST", parameters: parameters, jsonBody: body, needTrimData: true) { (result, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            if (error != nil || result == nil) {
                showSimpleErrorAlert(_message: "Login failed. \(error?.localizedDescription)", _sender: self)
                return
            }
            
            let status = result!["status"] as? Int
            if ( status != nil && status != 200 ) {
                var errorMessage = result!["error"] as? String
                errorMessage = errorMessage == nil ? "" : errorMessage!
                showSimpleErrorAlert(_message: "Login Failed. " + errorMessage!, _sender: self)
                return
            }

            //sucess
            let account = result!["account"] as? [String:AnyObject]
            let userId = account?["key"] as? String

            if (!(userId?.isEmpty)!) {
                SIClient.sharedInstance().userId = userId
                self.dismiss(animated: true, completion: nil)
            } else {
                showSimpleErrorAlert(_message: "Login failed. Please try again.", _sender: self)
            }

        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        openUrlWithSafari(SIClient.Constants.UdacityURL)
    }
    
   
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}


