//
//  executionReportObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class ExecutionReport: BaseApiModel {
    
    var eventType: String?
    var eventTime: TimeInterval?
    var symbol: String?
    var ClientOrderID: String?
    var side: OrderSide?
    var orderType: OrderTypes?
    var timeInForce: TimeInForce?
    var orderQuantity: String?
    var orderPrice: String?
    var stopPrice: String?
    var icebergQuantity: String?
    var orderListId: Int?
    var originalClientOrderID: String? //This is the ID of the order being canceled
    var currentExecutionType: ExecutionTypes?
    var currentOrderStatus: OrderStatus?
    var orderRejectReason: String? //will be an error code
    var orderId: UInt?
    var lastExecutedQuantity: String?
    var cumulativefilledQuantity: String?
    var lastExecutedPrice: String?
    var commissionAmount: String?
    var commissionAsset: String?
    var transactionTime: TimeInterval?
    var tradeId: Int?
    var orderCreationTime: TimeInterval?
    var isTheOrderWorking: Bool?
    var isThisTradeTheMakerSide: Bool?
    var cumulativeQuoteAssetTransactedQuantity: String?
    var lastQuoteAssetTransactedQuantity: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        eventType                               <- map["e"]
        eventTime                               <- map["E"]
        symbol                                  <- map["s"]
        ClientOrderID                           <- map["c"]
        side                                    <- map["S"]
        orderType                               <- map["o"]
        timeInForce                             <- map["f"]
        orderQuantity                           <- map["q"]
        orderPrice                              <- map["p"]
        icebergQuantity                         <- map["u"]
        stopPrice                               <- map["P"]
        orderListId                             <- map["g"]
        originalClientOrderID                   <- map["C"]
        currentExecutionType                    <- map["x"]
        currentOrderStatus                      <- map["X"]
        orderRejectReason                       <- map["r"]
        orderId                                 <- map["i"]
        lastExecutedQuantity                    <- map["l"]
        cumulativefilledQuantity                <- map["z"]
        lastExecutedPrice                       <- map["L"]
        commissionAmount                        <- map["n"]
        commissionAsset                         <- map["N"]
        transactionTime                         <- map["T"]
        tradeId                                 <- map["t"]
        orderCreationTime                       <- map["O"]
        isTheOrderWorking                       <- map["w"]
        isThisTradeTheMakerSide                 <- map["m"]
        cumulativeQuoteAssetTransactedQuantity  <- map["Z"]
        lastQuoteAssetTransactedQuantity        <- map["Y"]


    }
}
