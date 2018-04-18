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
    var allTheDataNew = [HygieneData]()
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
            doRequestFromPosition(latitude: latitude, longitude: longitude, resetList: true, dontErase: false)
        } else {
            if searchText.count < 3 {
                return
            }
            allTheDataNew = [HygieneData]()
            
            doRequestFromName(name: searchText, resetList: false, dontErase: false)
            //print(allTheData.count)
            doRequestFromPostcode(postcode: searchText, resetList: true, dontErase: true)
            //print(allTheData)
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
        } else if let detailsViewController = segue.destination as? DetailsViewController {
            //set the data into the new view so we know how to setup the map
            detailsViewController.targetData = allTheData[(myTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    func doRequestFromName(name:String, resetList:Bool, dontErase:Bool) {
        //URL encode the string first
        let name = name.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_name&name=" + name!, resetList: resetList, dontErase: dontErase)
    }
    
    func doRequestFromPostcode(postcode:String, resetList:Bool, dontErase:Bool) {
        let postcode = postcode.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_postcode&postcode=" + postcode!, resetList: resetList, dontErase: dontErase)
    }
    
    func doRequestFromPosition(latitude: Double, longitude: Double, resetList:Bool, dontErase:Bool) {
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_loc&lat=" + "\(latitude)" + "&long=" + "\(longitude)", resetList: resetList, dontErase: dontErase)
    }
    
    func doRequest(url:String, resetList:Bool, dontErase:Bool) {
        let url = URL(string: url)
        if url == nil {return}
        print(url)
        print("start")
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else {
                print("error with data"); return
                
            }
            do {
                if dontErase {
                    self.allTheDataNew += try JSONDecoder().decode([HygieneData].self, from: data);
                } else {
                    self.allTheDataNew = try JSONDecoder().decode([HygieneData].self, from: data);
                }
                
            } catch let err {
                print("error:", err)
            }
            if resetList {
                DispatchQueue.main.async {
                    self.allTheData = self.allTheDataNew
                    self.myTableView.reloadData()
                }
            }
        }.resume()
        print("finish")
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
        if searchBarIsEmpty() {
            self.doRequestFromPosition(latitude: self.latitude, longitude: self.longitude, resetList: true, dontErase: false)
        }
    }
}

