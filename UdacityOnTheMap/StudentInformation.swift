//
//  StudentInformation.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/21/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

struct StudentInformation {
    
    // MARK: Properties
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String?
    let mediaURL: String?
    let latitude: Double
    let longitude: Double
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(_ dictionary: [String:AnyObject]) {
        objectId = dictionary[SIClient.JSONResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[SIClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[SIClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[SIClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[SIClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[SIClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[SIClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[SIClient.JSONResponseKeys.Longitude] as! Double
    }
    
    static func studentsInfoFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            guard let _ = result[SIClient.JSONResponseKeys.ObjectId],
                let _ = result[SIClient.JSONResponseKeys.UniqueKey],
                let _ = result[SIClient.JSONResponseKeys.FirstName],
                let _ = result[SIClient.JSONResponseKeys.LastName],
                let _ = result[SIClient.JSONResponseKeys.Latitude],
                let _ = result[SIClient.JSONResponseKeys.Longitude]
                else {
                break
            }
            
            students.append(StudentInformation(result))
        }
        
        return students
    }
}

