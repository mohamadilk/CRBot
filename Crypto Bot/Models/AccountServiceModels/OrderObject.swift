//
//  OrderObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderSummaryObject: BaseApiModel {
    
    var symbol: String?
    var orderId: Int?
    var clientOrderId: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol             <- map["symbol"]
        orderId            <- map["orderId"]
        clientOrderId      <- map["clientOrderId"]
    }
}

class AccountOrderDetailObject: BaseApiModel {
    
    var symbol: String?
    var id: Int64?
    var orderId: Int64?
    var orderListId: Int?
    var price: String?
    var qty: String?
    var quoteQty: String?
    var commission: String?
    var commissionAsset: String?
    var time: TimeInterval?
    var isBuyer: Bool?
    var isMaker: Bool?
    var isBestMatch: Bool?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol           <- map["symbol"]
        orderId          <- map["orderId"]
        id               <- map["id"]
        orderListId      <- map["orderListId"]
        price            <- map["price"]
        qty              <- map["qty"]
        quoteQty         <- map["quoteQty"]
        commission       <- map["commission"]
        commissionAsset  <- map["commissionAsset"]
        time             <- map["time"]
        isBuyer          <- map["isBuyer"]
        isMaker          <- map["isMaker"]
        isBestMatch      <- map["isBestMatch"]
    }
}
