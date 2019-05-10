//
//  Airport.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class Airport: Hashable {
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        return lhs.name == rhs.name &&
            lhs.city == rhs.city &&
            lhs.country == rhs.country &&
            lhs.IATA == rhs.IATA &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.city)
        hasher.combine(self.IATA)
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
    
    var name:String = ""
    var city:String = ""
    var country:String = ""
    var IATA:String = ""
    var latitude:Double = 0
    var longitude:Double = 0
    
    init (rawAirport:[String]){
        guard rawAirport.count > 5 else{
            return
        }
        name = rawAirport[0]
        city = rawAirport[1]
        country = rawAirport[2]
        IATA = rawAirport[3]
        
        if let lat = Double(rawAirport[4]){
            latitude = lat
        }
        
        if let long = Double(rawAirport[5]){
            longitude = long
        }
    }
}
