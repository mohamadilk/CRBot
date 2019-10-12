//
//  OrderDetailObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderDetailObject: BaseApiModel {
    
    var symbol: String?
    var orderId: UInt?
    var origClientOrderId: String?
    var orderListId: Int?     //Unless part of an OCO, the value will always be -1.
    var clientOrderId: String?
    var price: String?
    var origQty: String?
    var executedQty: String?
    var cummulativeQuoteQty: String?
    var status: OrderStatus?
    var timeInForce: TimeInForce?
    var type: OrderTypes?
    var side: OrderSide?
    var stopPrice: String?
    var icebergQty: String?
    var time: TimeInterval?
    var updateTime: TimeInterval?
    var isWorking: Bool?
    var transactTime: TimeInterval?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol                 <- map["symbol"]
        orderId                <- map["orderId"]
        origClientOrderId      <- map["origClientOrderId"]
        orderListId            <- map["orderListId"]
        clientOrderId          <- map["clientOrderId"]
        price                  <- map["price"]
        origQty                <- map["origQty"]
        executedQty            <- map["executedQty"]
        cummulativeQuoteQty    <- map["cummulativeQuoteQty"]
        status                 <- map["status"]
        timeInForce            <- map["timeInForce"]
        type                   <- map["type"]
        side                   <- map["side"]
        stopPrice              <- map["stopPrice"]
        icebergQty             <- map["icebergQty"]
        time                   <- map["time"]
        updateTime             <- map["updateTime"]
        isWorking              <- map["isWorking"]
        transactTime           <- map["transactTime"]

    }
}
