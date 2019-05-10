//
//  SearchTableViewCell.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-10.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var resultText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public var airport:Airport!{
        didSet{
            resultText.text = String("\(airport.IATA) - \(airport.city) - \(airport.name)")
        }
    }
    
}
