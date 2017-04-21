//
//  OnTheMapViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class OnTheMapViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Redirect users to login page
//        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
//        self.navigationController?.present(loginViewController, animated: false, completion: nil);
        
        // Load data
        self.requestStudentsInfo()
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.requestStudentsInfo()
        
        let listTableVC = self.storyboard?.instantiateViewController(withIdentifier: "listTableViewController") as! ListTableViewController
        listTableVC.tableView.reloadData()
        
        //TODO
        
    }

    @IBAction func postInfo(_ sender: Any) {
        let postInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "postInfoViewController") as! PostInfoViewController
        self.present(postInfoViewController, animated: true, completion: nil);
    }
    
    func requestStudentsInfo() {
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(SIClient.Constants.ParseApplicationID, forKey: SIClient.ParametersKey.ParseAppIdKey as NSCopying)
        parameters.setObject(SIClient.Constants.ParseApplicationKey, forKey: SIClient.ParametersKey.ParseApiKey as NSCopying)
        parameters.setObject("100", forKey: "limit" as NSCopying)
        parameters.setObject("-updatedAt", forKey: "order" as NSCopying)
        
        let url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
        
        SIClient.sharedInstance().taskForHttpRequest(url, method: "GET", parameters: parameters, jsonBody: "") { (result, error) in
            self.saveStudentsInfo(result!)
        }
    }
    
    func saveStudentsInfo(_ results: AnyObject) {
        guard let studentList = results[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
            return
        }
        
        SIClient.sharedInstance().studentArray = StudentInformation.studentsInfoFromResults(studentList)
    }

}
