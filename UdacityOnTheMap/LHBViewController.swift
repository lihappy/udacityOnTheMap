//
//  LHBViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/27/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class LHBViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LHBViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        self.view .bringSubview(toFront: self.activityIndicator)
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }

}
