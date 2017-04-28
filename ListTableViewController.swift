//
//  ListTableViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var students = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        students = SIClient.sharedInstance().studentArray
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let student = students[indexPath.row]
        cell.imageView?.image = UIImage.init(named: "icon_pin")
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        openUrlWithSafari(student.mediaURL!)
    }
    
}
