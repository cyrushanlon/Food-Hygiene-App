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
        
        let region :MKCoordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(Double((targetData?.Latitude)!)!, Double((targetData?.Longitude)!)!), MKCoordinateSpanMake(0.005, 0.005))
        mapView.setRegion(region, animated: true)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
