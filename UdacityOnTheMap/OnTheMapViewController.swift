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

        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        
        // Load data
        SIClient.sharedInstance().requestStudentsInfo(self)
    }
    
    @IBAction func refresh(_ sender: Any) {
        SIClient.sharedInstance().requestStudentsInfo(self)
    }

    @IBAction func logout(_ sender: Any) {
        SIClient.sharedInstance().logout(self)
    }
    
    @IBAction func postInfo(_ sender: Any) {
        let postInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "postInfoViewController") as! PostInfoViewController
        self.present(postInfoViewController, animated: true, completion: nil);
    }
    
    func updateData() {
        let rootViewControllers = self.navigationController?.viewControllers
        var rootVC: OnTheMapViewController
        if (rootViewControllers != nil && (rootViewControllers?.count)! > 0) {
            rootVC = rootViewControllers?.first as! OnTheMapViewController
        } else {
            return
        }
        
        let tabViewControllers: [UIViewController] = (rootVC.viewControllers)!
        if (tabViewControllers.count >= 2) {
            DispatchQueue.main.async {
                let listVC = tabViewControllers[1] as! ListTableViewController
                listVC.tableView.reloadData()
                
                let mapVC = tabViewControllers[0] as! MapViewController
                mapVC.updateAnnotations()
            }
        }
    }
    
    func saveStudentsInfo(_ results: AnyObject) {
        guard let studentList = results[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
            return
        }
        
        SIModel.sharedInstance().studentArray = StudentInformation.studentsInfoFromResults(studentList)
    }

}
