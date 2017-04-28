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
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.ParametersKey.Accept as NSCopying)
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.ParametersKey.ContentType as NSCopying)
        
        let body = "{\"\(SIClient.JSONResponseKeys.Udacity)\": {\"\(SIClient.JSONResponseKeys.Username)\": \"" + emailTextField.text! + "\", \"\(SIClient.JSONResponseKeys.Password)\": \"" + passwordTextField.text! + "\"}}"
        
        let _ = SIClient.sharedInstance().taskForHttpRequest(url!, method: SIClient.Constants.PostMethod, parameters: parameters, jsonBody: body, needTrimData: true) { (result, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            if (error != nil || result == nil) {
                showSimpleErrorAlert(_message: "\(SIClient.Constants.LoginFailMsg) \(error?.localizedDescription)", _sender: self)
                return
            }
            
            let status = result![SIClient.JSONResponseKeys.StatusCode] as? Int
            if ( status != nil && status != 200 ) {
                let errorMessage = result![SIClient.JSONResponseKeys.Error] as? String
                showSimpleErrorAlert(_message: "\(SIClient.Constants.LoginFailMsg) \(errorMessage)", _sender: self)
                return
            }

            //sucess
            let account = result![SIClient.JSONResponseKeys.Account] as? [String:AnyObject]
            let userId = account?[SIClient.JSONResponseKeys.AccountKey] as? String

            if (!(userId?.isEmpty)!) {
                SIClient.sharedInstance().userId = userId
                self.dismiss(animated: true, completion: nil)
            } else {
                showSimpleErrorAlert(_message: SIClient.Constants.LoginFailMsg, _sender: self)
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


