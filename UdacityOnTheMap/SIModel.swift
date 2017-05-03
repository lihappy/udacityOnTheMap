//
//  SIModel.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 5/2/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

class SIModel: NSObject {
    
    var studentArray = [StudentInformation]()
    
    // Shared use id
    var userId: String? {
        didSet {
            // Get user info from Udacity
            SIClient.sharedInstance().getAndSaveUserName(userId!)
            
            // Get user objectId in Parse if have
            SIClient.sharedInstance().getAndSaveUserLocationId(userId!)
        }
    }
    var firstName: String?
    var lastName: String?
    
    var objectId: String?
    
    class func sharedInstance() -> SIModel {
        struct Singleton {
            static var sharedInstance = SIModel()
        }
        return Singleton.sharedInstance
    }

}
