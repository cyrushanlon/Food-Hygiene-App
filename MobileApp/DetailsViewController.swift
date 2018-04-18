//
//  DetailsViewController.swift
//  MobileApp
//
//  Created by Cyrus on 18/04/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var targetData: HygieneData?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set the details into the listview
        label.numberOfLines = 0
        
        label.text = (targetData?.BusinessName)! + "\n" +
            (targetData?.AddressLine1)! + "\n" +
            (targetData?.AddressLine2)! + "\n" +
            (targetData?.AddressLine3)! + "\n" +
            (targetData?.RatingValue)! + "\n" +
            (targetData?.RatingDate)! + "\n" +
            (targetData?.Latitude)! + " " + (targetData?.Longitude)!
        
        label.sizeToFit()
        
        //set the position of the map to around the target
        //set up location manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //config mapview
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        
        let location = CLLocationCoordinate2DMake(Double((targetData?.Latitude)!)!, Double((targetData?.Longitude)!)!)
        
        let region :MKCoordinateRegion = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.005, 0.005))
        mapView.setRegion(region, animated: true)
        
        let anno = CustomPin()
        anno.image = UIImage(named: "ratingPin-" + (targetData?.RatingValue)!)
        anno.coordinate = location
        anno.title = targetData?.BusinessName
        
        var distance = ""
        //check that the distance isnt nil
        if targetData?.DistanceKM != nil {
            let distanceDouble = (targetData?.DistanceKM! as! NSString).doubleValue
            //less than 100 m we convert to whole meters
            if (distanceDouble < 0.1) {
                distance = String(round(distanceDouble * 10000) / 10) + "m"
            } else { //otherwise we round to 2dp
                distance = String(Double(round(distanceDouble * 100) / 100)) + "km"
            }
            anno.subtitle = "Distance: " + distance
        }
        mapView.addAnnotation(anno)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapview: MKMapView, viewFor annotation: MKAnnotation) ->MKAnnotationView? {
        
        guard !annotation.isKind(of:MKUserLocation.self) else {return nil}
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPin
        annotationView!.image = customPointAnnotation.image
        return annotationView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
