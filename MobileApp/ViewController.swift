//
//  ViewController.swift
//  MobileApp
//
//  Created by Cyrus on 28/02/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var allTheData = [HygieneData]()
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    var longitude = 0.0
    var latitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //set up
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        if searchText == "" {
        doRequestFromPosition(latitude: latitude, longitude: longitude)
        } else {
            var postcode = false
         
            //check if we are searching a postcode or just a string
            
            if postcode {
                doRequestFromPostcode(postcode: searchText)
            } else {
                doRequestFromName(name: searchText)
            }
            
        }
        
        myTableView.reloadData()
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
    
    func doRequestFromName(name:String) {
        //URL encode the string first
        let name = name.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_name&name=" + name!)
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

