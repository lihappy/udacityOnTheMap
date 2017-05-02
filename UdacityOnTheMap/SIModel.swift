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
            self.getUserName(userId!)
            
            // Get user objectId in Parse if have
            self.getUserLocationId(userId!)
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
    
    func getUserName(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let url = URL(string: "\(SIClient.Constants.UserInfoURL)/\(userId)")!
        let _ = SIClient.sharedInstance().startHttpTask(url, method: SIClient.Constants.GetMethod, parameters: NSMutableDictionary(), jsonBody: "", needTrimData: true) { (result, error) in
            if (error != nil || result == nil) {
                return
            }
            
            let user = result?[SIClient.JSONResponseKeys.User] as? [String:AnyObject]
            self.firstName = user?[SIClient.JSONResponseKeys.FirstNameKey] as? String
            self.lastName = user?[SIClient.JSONResponseKeys.LastNameKey] as? String
        }
    }
    
    func getUserLocationId(_ userId: String) {
        if (userId.isEmpty) {
            return
        }
        
        let urlString = "\(SIClient.Constants.StudentsLocationURL)?where={\"\(SIClient.JSONResponseKeys.UniqueKey)\":\"\(userId)\"}"
        let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: escapedUrlString!)!
        
        let parameters: NSMutableDictionary = getBaseParseParams()
        
        let _ = SIClient.sharedInstance().startHttpTask(url, method: SIClient.Constants.GetMethod, parameters: parameters, jsonBody: "", needTrimData: false) { (result, error) in
            if (error != nil || result == nil || (result?[SIClient.JSONResponseKeys.Error] as? String != nil)) {
                return
            }
            
            let results = result?[SIClient.JSONResponseKeys.Results] as? [[String:AnyObject]]
            if (results != nil && (results?.count)! > 0) {
                let firstResult = (results?[0])! as [String:AnyObject]
                self.objectId = firstResult[SIClient.JSONResponseKeys.ObjectId] as? String
            }
        }
        
    }

}
