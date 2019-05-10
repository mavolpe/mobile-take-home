//
//  HopViewModel.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class HopViewModel {
    var originAirPortName:String = ""
    var destinationAirPortName:String = ""
    var originLongitude:Double = 0
    var originLatitude:Double = 0
    var destLongitude:Double = 0
    var destLatitude:Double = 0
    init(route:Route, airports:[Airport], flightIndex:Int) {
        NSLog("#### index = \(flightIndex)")
        let originAirport = airports.filter({$0.IATA == route.origin})
        let destAirport = airports.filter({$0.IATA == route.destination})
        if let firstAirport = originAirport.first{
            originAirPortName = String("\(firstAirport.name) - (\(firstAirport.city))")
            originLatitude = firstAirport.latitude
            originLongitude = firstAirport.longitude
        }
        if let secondAirport = destAirport.first{
            destinationAirPortName = String("\(secondAirport.name) - (\(secondAirport.city))")
            destLatitude = secondAirport.latitude
            destLongitude = secondAirport.longitude
        }
    }
}
