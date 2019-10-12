//
//  RateLimitObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class RateLimitObject: BaseApiModel {
    
    var rateLimitType: RateLimitType?
    var interval: IntervalType?
    var intervalNum: Int?
    var limit: Int?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        rateLimitType     <- map["rateLimitType"]
        interval          <- map["interval"]
        intervalNum       <- map["intervalNum"]
        limit             <- map["limit"]
    }
}
