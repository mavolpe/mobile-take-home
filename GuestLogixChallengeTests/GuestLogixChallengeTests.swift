//
//  GuestLogixChallengeTests.swift
//  GuestLogixChallengeTests
//
//  Created by Mark Volpe on 2019-05-08.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import XCTest
@testable import GuestLogixChallenge

class GuestLogixChallengeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadAirports(){
        AirportManager.sharedInstance.getAirports { (airports) in
            XCTAssert(airports.count > 0)
        }
    }
    
    func testRouteFinder(){
        let dispatchGroup = DispatchGroup()
        let routes = RouteFinder.sharedInstance.getRoutes()
        for route in routes{
            for secondRoute in routes{
                if secondRoute == route || secondRoute.origin == route.origin{
                    continue
                }
                dispatchGroup.enter()
                RouteFinder.sharedInstance.findRoute(origin: route.origin, destination: secondRoute.origin) { (routeOptions) in
                    for option in routeOptions{
                        if let last = option.last{
                            XCTAssertEqual(secondRoute.origin, last.destination)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.wait()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let dispatchGroup = DispatchGroup()

            dispatchGroup.enter()
            RouteFinder.sharedInstance.findRoute(origin: "DUB", destination: "LHR") { (routeOptions) in
                dispatchGroup.leave()
            }

            dispatchGroup.wait()
        }
    }

}
