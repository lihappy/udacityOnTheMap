//
//  SIConstants.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/21/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit

extension SIClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ParseApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApplicationKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ParseApiHost = "parse.udacity.com"
        static let StudentListApiPath = "/parse/classes/StudentLocation"
        
        static let ApplicationJson = "application/json"
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        
        static let UdacityURL = "https://www.udacity.com"
        static let AuthorizationURL = "\(UdacityURL)/api/session"
        static let UserInfoURL = "\(UdacityURL)/api/users"
        
        static let StudentsLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
        
        static let UdacityDataTrimLength = 5
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusCode = "status"
        static let Error = "error"
        
        // MARK: Authorization
        static let Account = "account"
        static let AccountKey = "key"
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: Student information from parse
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"        
        static let Results = "results"
        
    }
    
    struct ParametersKey {
        static let ParseAppIdKey: String = "X-Parse-Application-Id"
        static let ParseApiKey: String = "X-Parse-REST-API-Key"
        
    }
    
    struct Colors {
        static let BlueColor = UIColor.init(red: 81.0/255, green: 137.0/255, blue: 180.0/255, alpha: 1.0)
        static let GrayColor = UIColor.init(red: 224.0/255, green: 224.0/255, blue: 221.0/255, alpha: 1.0)
        static let LogoBlueColor = UIColor.init(red: 2.0/255, green: 179.0/255, blue: 228.0/255, alpha: 1.0)
        
    }
    

}
