//
//  OnTheMapViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class OnTheMapViewController: UITabBarController {
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Redirect users to login page
        self.openLoginPage()
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        
        // Load data
        self.requestStudentsInfo()
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.requestStudentsInfo()
    }

    @IBAction func logout(_ sender: Any) {
        self.activityIndicator.startAnimating()
        
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
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            self.activityIndicator.stopAnimating()
            
            if (error != nil || data == nil) {
                showSimpleErrorAlert(_message: SIClient.Constants.LogoutFailMsg, _sender: self)
                return
            }
            let range = Range(SIClient.Constants.UdacityDataTrimLength..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(newData)'")
                showSimpleErrorAlert(_message: SIClient.Constants.LogoutFailMsg, _sender: self)
                return
            }
            
            let session = parsedResult![SIClient.JSONResponseKeys.Session] as? [String:AnyObject]
            let id = session?[SIClient.JSONResponseKeys.SessionID] as? String
            
            if (session != nil && id != nil) {
                self.openLoginPage()
                SIClient.sharedInstance().userId = ""
                SIClient.sharedInstance().firstName = ""
                SIClient.sharedInstance().lastName = ""
                SIClient.sharedInstance().objectId = ""
            } else {
                showSimpleErrorAlert(_message: SIClient.Constants.LogoutFailMsg, _sender: self)
            }
            
        }
        task.resume()
    }
    
    @IBAction func postInfo(_ sender: Any) {
        let postInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "postInfoViewController") as! PostInfoViewController
        self.present(postInfoViewController, animated: true, completion: nil);
    }
    
    func openLoginPage() {
        // Redirect users to login page
        DispatchQueue.main.async {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
            self.navigationController?.present(loginViewController, animated: false, completion: nil);
        }
    }
    
    func requestStudentsInfo() {
        self.activityIndicator.startAnimating()
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        parameters.setObject("100", forKey: SIClient.JSONResponseKeys.Limit as NSCopying)
        parameters.setObject("-updatedAt", forKey: SIClient.JSONResponseKeys.Order as NSCopying)
        
        let url = URL(string: SIClient.Constants.StudentsLocationURL)!
        
        let _ = SIClient.sharedInstance().taskForHttpRequest(url, method: SIClient.Constants.GetMethod, parameters: parameters, jsonBody: "", needTrimData: false) { (result, error) in
            if (error != nil || result == nil) {
                showSimpleErrorAlert(_message: "Failed to download students info.", _sender: self)
            }
            
            if (result != nil) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                self.saveStudentsInfo(result!)
                
                // Refresh map and list with the new data
                self.updateData()
            }
        }
    }
    
    func updateData() {
        let rootVC = self.navigationController?.viewControllers.first as! OnTheMapViewController
        
        let viewControllers: [UIViewController] = (rootVC.viewControllers)!
        if (viewControllers.count >= 2) {
            let listVC = viewControllers[1] as! ListTableViewController
            listVC.tableView.reloadData()
            
            let mapVC = viewControllers[0] as! MapViewController
            mapVC.updateAnnotations()
            
        }
    }
    
    func saveStudentsInfo(_ results: AnyObject) {
        guard let studentList = results[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
            return
        }
        
        SIClient.sharedInstance().studentArray = StudentInformation.studentsInfoFromResults(studentList)
    }

}
