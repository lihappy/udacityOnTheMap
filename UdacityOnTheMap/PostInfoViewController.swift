//
//  PostInfoViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit
import MapKit

class PostInfoViewController: UIViewController {
    
    var pointAnnotation = MKPointAnnotation()
    var mediaUrl: String?
    var longtitute: Double?
    var latitude: Double?
    var mapString: String?
    
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    

    @IBOutlet weak var topTextView: UITextView!
    @IBOutlet weak var bottomTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultUI()

    }
    
    func defaultUI() {
        
        self.activityIndicator.hidesWhenStopped = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        
        
        self.topTextView.delegate = self
        self.bottomTextView.delegate = self
        
        self.view.backgroundColor = SIClient.Colors.GrayColor
        
        self.topTextView.isUserInteractionEnabled = false
        
        self.topTextView.backgroundColor = SIClient.Colors.GrayColor
        
        let questionString: NSString = "Where are you\nstudying\ntoday"
        let attributeString: NSMutableAttributedString = NSMutableAttributedString.init(string: questionString as String)
        
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 32.0), range: questionString.range(of: questionString as String))
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 36.0), range: questionString.range(of: "studying"))
        attributeString.addAttribute(NSForegroundColorAttributeName, value: SIClient.Colors.BlueColor, range: questionString.range(of: questionString as String))
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: questionString.range(of: questionString as String))
        
        self.topTextView.attributedText = attributeString
    

        
        self.findOnTheMapButton.tintColor = SIClient.Colors.BlueColor
        self.findOnTheMapButton.backgroundColor = UIColor.white
        self.findOnTheMapButton.layer.cornerRadius = 8.0

        self.bottomTextView.backgroundColor = SIClient.Colors.BlueColor
        self.bottomTextView.tintColor = UIColor.white

        self.submitButton.tintColor = SIClient.Colors.BlueColor
        self.submitButton.backgroundColor = SIClient.Colors.GrayColor
        self.submitButton.layer.cornerRadius = 8.0
        
        self.mapView.isHidden = true
        self.submitButton.isHidden = true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @IBAction func findOnTheMap(_ sender: Any) {
        // Check mapString
        if (self.bottomTextView.text == nil || self.bottomTextView.text == ""){
            showSimpleErrorAlert(_message: "Please enter address!", _sender: self)
            return
        }
        
        // find on the map
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.startAnimating();
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.bottomTextView.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            // Failed
            if localSearchResponse == nil{
                showSimpleErrorAlert(_message: "Place not found", _sender: self)
                return
            }
            
            // Succeeded
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.bottomTextView.text
            
            self.longtitute = localSearchResponse!.boundingRegion.center.longitude
            self.latitude = localSearchResponse?.boundingRegion.center.latitude
            self.mapString = self.bottomTextView.text
            
            let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longtitute!)
            
            self.pointAnnotation.coordinate = coordinate
            
            self.mapView .addAnnotation(self.pointAnnotation)
            
            self.mapView.centerCoordinate = coordinate
            
            let span = MKCoordinateSpan.init(latitudeDelta: 5.0, longitudeDelta: 5.0)
            let region = MKCoordinateRegion.init(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            // UI
            self.topTextView.text = "http://aaa.com"//Enter your link here
            self.topTextView.backgroundColor = SIClient.Colors.BlueColor
            self.topTextView.textColor = UIColor.white
            
            self.topTextView.isUserInteractionEnabled = true
            self.bottomTextView.isHidden = true
            self.findOnTheMapButton.isHidden = true
            self.submitButton.isHidden = false
            self.mapView.isHidden = false
            
        }
        
        
        
        
    }
    
    @IBAction func submit(_ sender: Any) {
        // Check mapString
        if (self.topTextView.text == nil || self.topTextView.text == ""){
            showSimpleErrorAlert(_message: "Please enter your link", _sender: self)
            return
        }
        self.mediaUrl = self.topTextView.text
        
        //Check if it's url
        if (!self.isURLValid(string: self.mediaUrl)) {
            showSimpleErrorAlert(_message: "Invalid URL link", _sender: self)
            return
        }
        
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters.setObject(SIClient.Constants.ParseApplicationID, forKey: SIClient.ParametersKey.ParseAppIdKey as NSCopying)
        parameters.setObject(SIClient.Constants.ParseApplicationKey, forKey: SIClient.ParametersKey.ParseApiKey as NSCopying)
        parameters.setObject(SIClient.Constants.ApplicationJson, forKey: SIClient.Constants.ContentType as NSCopying)
        
        var firstName = ""
        if (SIClient.sharedInstance().firstName != nil) {
            firstName = SIClient.sharedInstance().firstName!
        }
        var lastName = ""
        if (SIClient.sharedInstance().lastName != nil) {
            lastName = SIClient.sharedInstance().lastName!
        }
        
        let body = "{\"uniqueKey\": \"\(SIClient.sharedInstance().userId! as String)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(self.mapString! as String)\", \"mediaURL\": \"\(self.mediaUrl! as String)\",\"latitude\": \(self.latitude! as Double), \"longitude\": \(self.longtitute! as Double)}"
        
        var urlString: String = "https://parse.udacity.com/parse/classes/StudentLocation"
        var method: String = "POST"
        
        var objectId: String = ""
        if (SIClient.sharedInstance().objectId != nil) {
            objectId = SIClient.sharedInstance().objectId!
        }
        var isPost: Bool = false
        isPost = objectId.isEmpty
        
        if (!isPost) {
            urlString = urlString + "/\(objectId)"
            method = "PUT"
        }
        
//        SIClient.sharedInstance().taskForHttpRequest(url, method: "GET", parameters: parameters, jsonBody: body, needConvertData: true) { (result, error) in
////            self.saveStudentsInfo(result!)
//            if (result == nil) {
//                showSimpleErrorAlert(_message: "Failed", _sender: self)
//            }
//        }
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if (error != nil || data == nil) { // Handle error…
                showSimpleErrorAlert(_message: "Post Info failed", _sender: self)
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                NSLog("Could not parse the data as JSON: '\(data)'")
                showSimpleErrorAlert(_message: "Post Info failed", _sender: self)
                return
            }
            
            var objectId: String
            var updatedAt: String
            var isSucceeded: Bool = false
            if (isPost) {
                objectId = (parsedResult["objectId"] as? String)!
                if (!objectId.isEmpty) {
                    isSucceeded = true
                    SIClient.sharedInstance().objectId = objectId
                }
            } else {
                updatedAt = (parsedResult["updatedAt"] as? String)!
                if (!updatedAt.isEmpty) {
                    isSucceeded = true
                }
            }
            
            if (isSucceeded) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                showSimpleErrorAlert(_message: "Post failed", _sender: self)
            }
        }
        task.resume()
        
        
    }
    
    func isURLValid(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url: URL = URL(string: urlString) else {return false}
        if (!UIApplication.shared.canOpenURL(url)) {return false}
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func showActivityIndicatory(uiView: UIView) {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
//        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.frame = uiView.frame
//        actInd.frame(forAlignmentRect: <#T##CGRect#>)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    

}

extension PostInfoViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
}
