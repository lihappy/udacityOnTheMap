//
//  LHBViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/27/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class LHBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LHBViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }

}
