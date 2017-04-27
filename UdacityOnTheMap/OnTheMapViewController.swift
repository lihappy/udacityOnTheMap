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
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.navigationController?.present(loginViewController, animated: false, completion: nil);
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        
        // Load data
        self.requestStudentsInfo()
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.requestStudentsInfo()
    }

    @IBAction func postInfo(_ sender: Any) {
        let postInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "postInfoViewController") as! PostInfoViewController
        self.present(postInfoViewController, animated: true, completion: nil);
    }
    
    func requestStudentsInfo() {
        self.activityIndicator.startAnimating()
        
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(SIClient.Constants.ParseApplicationID, forKey: SIClient.ParametersKey.ParseAppIdKey as NSCopying)
        parameters.setObject(SIClient.Constants.ParseApplicationKey, forKey: SIClient.ParametersKey.ParseApiKey as NSCopying)
        parameters.setObject("100", forKey: "limit" as NSCopying)
        parameters.setObject("-updatedAt", forKey: "order" as NSCopying)
        
        let url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
        
        SIClient.sharedInstance().taskForHttpRequest(url, method: "GET", parameters: parameters, jsonBody: "", needConvertData: true) { (result, error) in
            if (result != nil) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                self.saveStudentsInfo(result!)
                self.updateData()
            }
        }
    }
    
    func updateData() {
        let rootVC = self.navigationController?.viewControllers.first as! OnTheMapViewController
        
        let viewControllers: [UIViewController] = (rootVC.viewControllers)!
        if (viewControllers != nil && viewControllers.count >= 2) {
            let listVC = viewControllers[1] as! ListTableViewController
            listVC.tableView.reloadData()
            
            let mapVC = viewControllers[0] as! MapViewController
            mapVC.updateAnnotations()
            
        }
    }
    
//    func requestUserInfo() {
//        let userId: String = SIClient.sharedInstance().userId!
//        
//        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest) { data, response, error in
//            if error != nil { // Handle error...
//                return
//            }
//            let range = Range(5..<data!.count)
//            let newData = data?.subdata(in: range) /* subset response data! */
////            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
//            
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                NSLog("Could not parse the data as JSON: '\(data)'")
//                showSimpleErrorAlert(_message: "Login failed", _sender: self)
//                return
//            }
//
//            let user = parsedResult["user"] as? [String:AnyObject]
//            let firstName = user?["first_name"] as? String
//            let lastName = user?["last_name"] as? String
//            
//            SIClient.sharedInstance().firstName = firstName
//            SIClient.sharedInstance().lastName = lastName
//            
//            
//        }
//        task.resume()
//    }
    
    func saveStudentsInfo(_ results: AnyObject) {
        guard let studentList = results[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
            return
        }
        
        SIClient.sharedInstance().studentArray = StudentInformation.studentsInfoFromResults(studentList)
    }

}
