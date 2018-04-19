//
//  DetailsViewController.swift
//  MobileApp
//
//  Created by Cyrus on 18/04/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var targetData: HygieneData?
    var allTheData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sort out the data for use in the table
        allTheData.append((targetData?.BusinessName)!)
        allTheData.append((targetData?.RatingValue)!)
        allTheData.append((targetData?.RatingDate)!)
        allTheData.append((targetData?.AddressLine1)!)
        if targetData?.AddressLine2 != nil {
            allTheData.append((targetData?.AddressLine2)!)
        }
        if targetData?.AddressLine3 != nil {
            allTheData.append((targetData?.AddressLine3)!)
        }
        
        //setup the table
        tableView.alwaysBounceVertical = false
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myRatingCell") as! HygieneDataTableViewCell
            cell.ratingImageView.image = UIImage(named: "rating-" + allTheData[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! UITableViewCell
        cell.textLabel?.text = allTheData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheData.count
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
