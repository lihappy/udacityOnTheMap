//
//  PostInfoViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit
import MapKit

class PostInfoViewController: LHBViewController {
    
    var pointAnnotation = MKPointAnnotation()
    var mediaUrl: String?
    var longtitute: Double?
    var latitude: Double?
    var mapString: String?
    
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
        self.setDefaultUI()
    }
    
    func setDefaultUI() {
        self.topTextView.delegate = self
        self.bottomTextView.delegate = self
        
        self.initTopTextView()
        
        self.view.backgroundColor = SIClient.Colors.GrayColor
        
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
    
    func initTopTextView() {
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
    }
    
    @IBAction func findOnTheMap(_ sender: Any) {
        // Check mapString
        if (self.bottomTextView.text == nil || self.bottomTextView.text == ""){
            showSimpleErrorAlert(_message: "Please enter address!", _sender: self)
            return
        }
        
        self.mapString = self.bottomTextView.text
        
        // find on the map
        self.activityIndicator.startAnimating();
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.mapString
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            // Failed
            if (error != nil) {
                showSimpleErrorAlert(_message: (error?.localizedDescription)!, _sender: self)
                return
            }
            
            if localSearchResponse == nil{
                showSimpleErrorAlert(_message: "Place not found", _sender: self)
                return
            }
            
            DispatchQueue.main.async {
                // Add annotation
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = self.mapString
                
                self.longtitute = localSearchResponse!.boundingRegion.center.longitude
                self.latitude = localSearchResponse?.boundingRegion.center.latitude
                
                let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longtitute!)
                self.pointAnnotation.coordinate = coordinate
                
                self.mapView .addAnnotation(self.pointAnnotation)
                
                // Zoom map
                self.mapView.centerCoordinate = coordinate
                let span = MKCoordinateSpan.init(latitudeDelta: 5.0, longitudeDelta: 5.0)
                let region = MKCoordinateRegion.init(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                // Change UI
                self.topTextView.text = "Enter your link here"
                self.topTextView.backgroundColor = SIClient.Colors.BlueColor
                self.topTextView.textColor = UIColor.white
                
                self.topTextView.isUserInteractionEnabled = true
                self.bottomTextView.isHidden = true
                self.findOnTheMapButton.isHidden = true
                self.submitButton.isHidden = false
                self.mapView.isHidden = false
                
            }   
        }
        
    }
    
    @IBAction func submit(_ sender: Any) {
        
        // Check mapString
        if (self.topTextView.text == nil || self.topTextView.text == ""){
            showSimpleErrorAlert(_message: "Please enter your link", _sender: self)
            return
        }
        self.mediaUrl = self.topTextView.text
        
        //Check if it's a valid url
        if (!self.isURLValid(string: self.mediaUrl)) {
            showSimpleErrorAlert(_message: "Invalid URL link", _sender: self)
            return
        }
        
        SIClient.sharedInstance().postLocation(self)
        
    }
    
    func isURLValid(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url: URL = URL(string: urlString) else {return false}
        if (!UIApplication.shared.canOpenURL(url)) {return false}
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
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
