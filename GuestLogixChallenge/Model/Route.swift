//
//  Route.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-09.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class Route : Hashable{
    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.airline == rhs.airline && lhs.destination == rhs.destination && lhs.origin == rhs.origin
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.airline)
        hasher.combine(self.destination)
        hasher.combine(self.origin)
    }
    
    var airline:String = ""
    var origin:String = ""
    var destination:String = ""
    init (rawRoute:[String]){
        guard rawRoute.count > 2 else{
            return
        }
        airline = rawRoute[0]
        origin = rawRoute[1]
        destination = rawRoute[2]
    }
}
