//
//  HygeneData.swift
//  MobileApp
//
//  Created by Cyrus on 01/03/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import Foundation

class HygieneData: Codable {
    let id:String
    let BusinessName:String
    let AddressLine1:String
    let AddressLine2:String
    let AddressLine3:String
    let PostCode:String
    let RatingValue:String
    let RatingDate:String
    let Longitude:String
    let Latitude:String
    let DistanceKM:String?
}
