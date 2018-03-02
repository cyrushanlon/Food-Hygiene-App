//
//  ViewController.swift
//  MobileApp
//
//  Created by Cyrus on 28/02/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var allTheData = [HygieneData]()
    let locationManager = CLLocationManager()
    var longitude = 0.0
    var latitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //set up
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "myCell") as! HygieneDataTableViewCell
        cell.nameLabel.text = allTheData[indexPath.row].BusinessName
        cell.ratingImageView.image = UIImage(named: "rating-" + allTheData[indexPath.row].RatingValue)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheData.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? MapViewController {
            //set the data into the new view so we know how to setup the map
            mapViewController.allTheData = self.allTheData
            mapViewController.latitude = self.latitude
            mapViewController.longitude = self.longitude
        }
    }
    
    func doRequestFromPostcode(postcode:String) {
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_postcode&postcode=" + postcode)
    }
    
    func doRequestFromPosition(latitude: Double, longitude: Double) {
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_loc&lat=" + "\(latitude)" + "&long=" + "\(longitude)")
    }
    
    func doRequest(url:String) {
        let url = URL(string: url)
        
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { print("error with data"); return }
            do {
                self.allTheData = try JSONDecoder().decode([HygieneData].self, from: data);
                DispatchQueue.main.async {
                    self.myTableView.reloadData();
                }
            } catch let err {
                print("error:", err)
            }
            }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        //SetMapPosition(location: CLLocationCoordinate2DMake(coord.latitude, coord.longitude), span: MKCoordinateSpanMake(0.1, 0.1))
        self.latitude = coord.latitude
        self.longitude = coord.longitude
        self.doRequestFromPosition(latitude: self.latitude, longitude: self.longitude)
    }
}

