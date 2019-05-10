//
//  RouteFinder.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class RouteFinder {
    
    let processingQueue = DispatchQueue(label: "routeProcessor")
    var routes:[Route] = []
    
    public static let sharedInstance = RouteFinder()
    
    // this routine is used for the UNIT test only
    public func getRoutes()->[Route]{
        // get our routes for the first time if we don't have them parsed...
        if self.routes.count == 0{
            let fileReader = CSVFileReader()
            
            guard let rawRoutes = fileReader.parseFileData(fileName: "routes", fileType: "csv") else {
                return []
            }
            
            self.routes = self.parseRoutes(routes: rawRoutes)
        }
        return self.routes
    }
    
    // our top level function that calls the file reader, parses the routes, then passes our routes
    // to find connection
    // note routes are only fetched from the file the first time
    public func findRoute(origin:String, destination:String, completion: @escaping (([[Route]])->Void)){
        processingQueue.async { [weak self] in
            guard let this = self else{
                completion([])
                return
            }
            // get our routes for the first time if we don't have them parsed...
            if this.routes.count == 0{
                let fileReader = CSVFileReader()
                
                guard let rawRoutes = fileReader.parseFileData(fileName: "routes", fileType: "csv") else {
                    completion([])
                    return
                }
                
                this.routes = this.parseRoutes(routes: rawRoutes)
            }
            
            if this.routes.count > 0{
                _ = this.findConnection(origin: origin, destination: destination, routes: this.routes, completion: { (flightOptions) in
                    completion(flightOptions)
                })
            }else{
                // no routes... todo: improve error handling
                completion([])
            }

        }
    }
    
    // parse our route model out of the raw string data
    private func parseRoutes(routes:[[String]])->[Route]{
        var routeModels:[Route] = []
        for (index,rawRoute) in routes.enumerated(){
            guard rawRoute.count > 2 && index > 0 else{
                continue
            }
            routeModels.append(Route(rawRoute: rawRoute))
        }
        return routeModels
    }
    
    // look through each dimension of routes until we either find our destination, or reach the end...
    private func findConnection(origin:String, destination:String, routes:[Route], completion: @escaping (([[Route]])->Void)){
        var flightPathOptions:[[Route]] = []
        var allRoutes = routes
        let flights = allRoutes.filter({$0.origin == origin})
        let destinations = allRoutes.filter({$0.destination == destination})
        
        guard flights.count > 0 && destinations.count > 0 else {
            // we can't find anything if there are no flights
            completion(flightPathOptions)
            return
        }
        
        // remove the routes we've used from the original array...
        allRoutes = Array(Set(allRoutes).subtracting(flights))
        
        var foundRoute = false
        var dimensionIndex = 0
        var dimensions:[[Route]] = []
        dimensions.append(flights)
        while allRoutes.count > 0 && foundRoute == false {
            guard dimensionIndex < dimensions.count else{
                completion(flightPathOptions)
                return
            }
            for route in dimensions[dimensionIndex]{
                if route.destination == destination{
                    // we found our destination
                    foundRoute = true // we don't want to go past this dimension, because any other dimension will be longer...
                    // we will keep going through, because there could be better options at this same level... no airline switch, etc...
                    
                    var flightPath:[Route] = []
                    flightPath.append(route)
                    
                    for i in stride(from: dimensionIndex, to: -1, by: -1){
                        if i < dimensionIndex{
                            let filtered = dimensions[i].filter({$0.destination == route.origin})
                            if let first = filtered.first{
                                flightPath.insert(first, at: 0)
                            }
                        }
                    }
                    flightPathOptions.append(flightPath)
                }else{
                    let nextDimensionFlights = allRoutes.filter({$0.origin == route.destination})
                    allRoutes = Array(Set(allRoutes).subtracting(nextDimensionFlights))
                    if dimensions.count - 1 < dimensionIndex+1{
                        dimensions.append([])
                    }
                    dimensions[dimensionIndex+1].append(contentsOf: nextDimensionFlights)
                }
            }
            dimensionIndex += 1
        }
        
        completion(flightPathOptions)
    }
}
