//
//  SymbolObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class SymbolObject: BaseApiModel {
    
    var symbol: String?
    var status: SymbolStatus?
    var baseAsset: String?
    var baseAssetPrecision: Int?
    var quoteAsset: String?
    var quotePrecision: Int?
    var orderTypes: Array<OrderTypes>?
    var icebergAllowed: Bool?
    var ocoAllowed: Bool?
    var isSpotTradingAllowed: Bool?
    var isMarginTradingAllowed: Bool?
    var filters: Array<FilterObject>?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol                   <- map["symbol"]
        status                   <- map["status"]
        baseAsset                <- map["baseAsset"]
        baseAssetPrecision       <- map["baseAssetPrecision"]
        quoteAsset               <- map["quoteAsset"]
        quotePrecision           <- map["quotePrecision"]
        orderTypes               <- map["orderTypes"]
        icebergAllowed           <- map["icebergAllowed"]
        ocoAllowed               <- map["ocoAllowed"]
        isSpotTradingAllowed     <- map["isSpotTradingAllowed"]
        isMarginTradingAllowed   <- map["isMarginTradingAllowed"]
        filters                  <- map["filters"]
    }
}
