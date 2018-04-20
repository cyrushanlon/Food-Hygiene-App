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
    
    //holds all of the data returned from the api
    var allTheData = [HygieneData]()
    //used for swapping out so there are no threading issues
    var allTheDataNew = [HygieneData]()
    
    //handles locaiton services
    let locationManager = CLLocationManager()
    //handles the search bar
    let searchController = UISearchController(searchResultsController: nil)
    //holds most recent position
    var longitude = 0.0
    var latitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //config table view
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //config the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //set up location manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //called when text is changed in the search box
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    //returns whether the search bar is empty or not
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //handles what happens when there is a change in the search bar
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText == "" { //if there is no text we do a positional search
            doRequestFromPosition(latitude: latitude, longitude: longitude, resetList: true, dontErase: false)
        } else {
            if searchText.count < 3 { //3 characters is the minimum search length
                return
            }
            //first clear the current data
            allTheDataNew = [HygieneData]()
            //do a request for both name and postcode as there could be some overlap, combine the results
            doRequestFromName(name: searchText, resetList: false, dontErase: false)
            doRequestFromPostcode(postcode: searchText, resetList: true, dontErase: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "myCell") as! HygieneDataTableViewCell
        //set the name and image of the current business
        cell.nameLabel.text = allTheData[indexPath.row].BusinessName
        cell.ratingImageView.image = UIImage(named: "rating-" + allTheData[indexPath.row].RatingValue)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTheData.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? MapViewController {
            //set the data into the new view so we know how to set up the map
            mapViewController.allTheData = self.allTheData
            mapViewController.latitude = self.latitude
            mapViewController.longitude = self.longitude
        } else if let detailsViewController = segue.destination as? DetailsViewController {
            //set the data into the new view so we know how to set up the details and map
            detailsViewController.targetData = allTheData[(myTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    func doRequestFromName(name:String, resetList:Bool, dontErase:Bool) {
        //URL encode the string first
        let name = name.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_name&name=" + name!, resetList: resetList, dontErase: dontErase)
    }
    
    func doRequestFromPostcode(postcode:String, resetList:Bool, dontErase:Bool) {
        //URL encode the string first
        let postcode = postcode.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_postcode&postcode=" + postcode!, resetList: resetList, dontErase: dontErase)
    }
    
    func doRequestFromPosition(latitude: Double, longitude: Double, resetList:Bool, dontErase:Bool) {
        doRequest(url: "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_loc&lat=" + "\(latitude)" + "&long=" + "\(longitude)", resetList: resetList, dontErase: dontErase)
    }
    
    func doRequest(url:String, resetList:Bool, dontErase:Bool) {
        let url = URL(string: url)
        //check that the url exists
        if url == nil {return}
        //do the request
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else {
                print("error with data"); return
            }
            do {
                //if we want to keep whatever is already in the data
                if dontErase {
                    //decode the JSON into the HygieneData object and append to the array
                    self.allTheDataNew += try JSONDecoder().decode([HygieneData].self, from: data);
                } else {
                    self.allTheDataNew = try JSONDecoder().decode([HygieneData].self, from: data);
                }
                
            } catch let err {
                print("error:", err)
            }
            //if we want to reset the list
            if resetList {
                DispatchQueue.main.async {
                    self.allTheData = self.allTheDataNew
                    self.myTableView.reloadData()
                }
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
        
        //set current lat and long
        self.latitude = coord.latitude
        self.longitude = coord.longitude
        
        //only if the search bar is empty do we want to update the results
        if searchBarIsEmpty() {
            self.doRequestFromPosition(latitude: self.latitude, longitude: self.longitude, resetList: true, dontErase: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

