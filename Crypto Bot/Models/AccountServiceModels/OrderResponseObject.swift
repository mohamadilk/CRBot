//
//  OrderResponseObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderResponseObject: BaseApiModel {
    var symbol: String?
    var orderId: Int?
    var orderListId: Int? //Unless OCO, value will be -1
    var clientOrderId: String?
    var transactTime: TimeInterval?
    var price: String?
    var origQty: String?
    var executedQty: String?
    var cummulativeQuoteQty: String?
    var status: String?
    var timeInForce: String?
    var type: String?
    var side: String?
    var fills: [OrderFillObject]?

    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol                <- map["symbol"]
        orderId               <- map["orderId"]
        orderListId           <- map["orderListId"]
        clientOrderId         <- map["clientOrderId"]
        transactTime          <- map["transactTime"]
        price                 <- map["price"]
        origQty               <- map["origQty"]
        executedQty           <- map["executedQty"]
        cummulativeQuoteQty   <- map["cummulativeQuoteQty"]
        status                <- map["status"]
        timeInForce           <- map["timeInForce"]
        type                  <- map["type"]
        side                  <- map["side"]
        fills                 <- map["fills"]
    }
}
