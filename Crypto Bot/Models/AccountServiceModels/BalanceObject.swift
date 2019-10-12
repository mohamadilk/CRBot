//
//  BalanceObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class BalanceObject: BaseApiModel {
    
    var asset: String?
    var free: String?
    var locked: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        asset             <- map["asset"]
        locked            <- map["locked"]
        free              <- map["free"]
    }
}
