//
//  TripDistanceCalculator.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-10.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit
import CoreLocation

class TripDistanceCalculator {
    // MARK: helper functions to get the trip distance...
    static func getTripDistance(hops:[HopViewModel])->Double{
        var totalDistance:Double = 0.0
        for hop in hops{
            let origin = CLLocation(latitude: hop.originLatitude, longitude: hop.originLongitude)
            
            let dest = CLLocation(latitude: hop.destLatitude, longitude: hop.destLongitude)
            
            let distance = origin.distance(from: dest) / 1000
            
            totalDistance += distance
        }
        return totalDistance
    }
    
    static func getShortestTrip(trips:[[HopViewModel]])->[HopViewModel]{
        guard trips.count > 0 else{
            return []
        }
        var shortestTrip:Double = 0.0
        var shortestTripIndex = 0
        for (index, trip) in trips.enumerated(){
            let tripDistance = getTripDistance(hops: trip)
            NSLog("#### trip \(index) was \(tripDistance) km")
            if index == 0{
                shortestTrip = tripDistance
                shortestTripIndex = index
            }else if tripDistance < shortestTrip{
                shortestTrip = tripDistance
                shortestTripIndex = index
            }
        }
        return trips[shortestTripIndex]
    }
}
