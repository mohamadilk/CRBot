//
//  FilterObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class FilterObject: BaseApiModel {
    
    var filterType: SymbolFilters?
    var minPrice: String?
    var maxPrice: String?
    var tickSize: String?
    var multiplierUp: String?
    var multiplierDown: String?
    var avgPriceMins: Int?
    var minQty: String?
    var maxQty: String?
    var stepSize: String?
    var minNotional: String?
    var applyToMarket: Bool?
    var limit: Int?
    var maxNumAlgoOrders: Int?
    var maxNumOrders: Int?

    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        filterType         <- map["filterType"]
        minPrice           <- map["minPrice"]
        maxPrice           <- map["maxPrice"]
        tickSize           <- map["tickSize"]
        multiplierUp       <- map["multiplierUp"]
        multiplierDown     <- map["multiplierDown"]
        avgPriceMins       <- map["avgPriceMins"]
        minQty             <- map["minQty"]
        maxQty             <- map["maxQty"]
        stepSize           <- map["stepSize"]
        minNotional        <- map["minNotional"]
        applyToMarket      <- map["applyToMarket"]
        limit              <- map["limit"]
        maxNumAlgoOrders   <- map["maxNumAlgoOrders"]
        maxNumOrders       <- map["maxNumOrders"]

    }
}

