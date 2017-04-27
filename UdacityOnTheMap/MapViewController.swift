//
//  MapViewController.swift
//  UdacityOnTheMap
//
//  Created by Li, Haibo on 4/20/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

//    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var students = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.students = SIClient.sharedInstance().studentArray
        self.annotations = self.generateAnnotationsFromStudents(self.students)
        
        self.mapView.addAnnotations(self.annotations)        
    }
    
    func updateAnnotations() {
        if self.annotations.count > 0 {
            self.mapView.removeAnnotations(self.annotations)
        }
        
        self.annotations = self.generateAnnotationsFromStudents(SIClient.sharedInstance().studentArray)
        self.mapView.addAnnotations(self.annotations)
    }

    func generateAnnotationsFromStudents(_ students: [StudentInformation]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for student in students {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }        
        return annotations
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            openUrlWithSafari((view.annotation?.subtitle!)!)
        }
    }
    
}
