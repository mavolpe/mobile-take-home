//
//  AirportManager.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class AirportManager: NSObject {
    let processingQueue = DispatchQueue(label: "airportProcessor")
    private var airports:[Airport] = []
    
    public static let sharedInstance = AirportManager()
    
    public func getAirports(completion: @escaping (([Airport])->Void)){
        // get our routes for the first time if we don't have them parsed...
        processingQueue.async { [weak self] in
            guard let this = self else{
                completion([])
                return
            }
            if this.airports.count == 0{
                let fileReader = CSVFileReader()
                
                guard let rawAirports = fileReader.parseFileData(fileName: "airports", fileType: "csv") else {
                    return
                }
                
                this.airports = this.parseAirports(airports: rawAirports)
            }
            completion(this.airports)
        }
    }
    
    private func parseAirports(airports:[[String]])->[Airport]{
        var airportModels:[Airport] = []
        for (index,rawAirport) in airports.enumerated(){
            guard rawAirport.count > 2 && index > 0 else{
                continue
            }
            let airport = Airport(rawAirport: rawAirport)
            if airport.IATA != "Null"{
                airportModels.append(airport)
            }
        }
        return airportModels
    }
}
