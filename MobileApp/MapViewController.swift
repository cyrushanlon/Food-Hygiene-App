//
//  MapViewController.swift
//  MobileApp
//
//  Created by Cyrus on 01/03/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var allTheData = [HygieneData]()
    
    let locationManager = CLLocationManager()
    var longitude = 0.0
    var latitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //bury : 53.5943778,-2.3110067
        SetMapPosition(location: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: MKCoordinateSpanMake(0.005, 0.005))
        
        //add the annotations
        for d in allTheData {
            let anno = CustomPin()
            anno.image = UIImage(named: "ratingPin-" + d.RatingValue)
            anno.coordinate = CLLocationCoordinate2DMake((d.Latitude as NSString).doubleValue, (d.Longitude as NSString).doubleValue)
            anno.title = d.BusinessName
            anno.subtitle = d.RatingValue
            mapView.addAnnotation(anno)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetMapPosition(location: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        let region :MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    /* //no reason to use this delegate as we dont want to update it from within the map screen
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        //SetMapPosition(location: CLLocationCoordinate2DMake(coord.latitude, coord.longitude), span: MKCoordinateSpanMake(0.1, 0.1))
        //self.latitude = coord.latitude
        //self.longitude = coord.longitude
    }
    */
    
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
}
