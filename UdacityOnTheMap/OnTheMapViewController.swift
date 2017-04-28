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
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        parameters.setObject("100", forKey: SIClient.JSONResponseKeys.Limit as NSCopying)
        parameters.setObject("-updatedAt", forKey: SIClient.JSONResponseKeys.Order as NSCopying)
        
        let url = URL(string: SIClient.Constants.StudentsLocationURL)!
        
        let _ = SIClient.sharedInstance().taskForHttpRequest(url, method: SIClient.Constants.GetMethod, parameters: parameters, jsonBody: "", needTrimData: false) { (result, error) in
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
