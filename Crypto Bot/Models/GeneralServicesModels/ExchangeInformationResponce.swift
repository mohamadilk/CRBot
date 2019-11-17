//
//  ExchangeInformationResponse.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class ExchangeInformationResponse: BaseApiModel {
    
    var timezone: String?
    var serverTime: TimeInterval?
    var rateLimits: Array<RateLimitObject>?
    var exchangeFilters: Array<FilterObject>?
    var symbols: Array<SymbolObject>?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        timezone              <- map["timezone"]
        serverTime            <- map["serverTime"]
        rateLimits            <- map["rateLimits"]
        exchangeFilters       <- map["exchangeFilters"]
        symbols               <- map["symbols"]
    }
}
