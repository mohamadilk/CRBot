//
//  OCOOrderResponse.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OCOOrderResponse: BaseApiModel {
    
    var orderListId: Int?
    var contingencyType: String?
    var listStatusType: String?
    var listOrderStatus: String?
    var listClientOrderId: String?
    var transactionTime: TimeInterval?
    var symbol: String?
    var orders: [OrderSummaryObject]?
    var orderReports: [OrderDetailObject]?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        orderListId        <- map["orderListId"]
        contingencyType    <- map["contingencyType"]
        listStatusType     <- map["listStatusType"]
        listOrderStatus    <- map["listOrderStatus"]
        listClientOrderId  <- map["listClientOrderId"]
        transactionTime    <- map["transactionTime"]
        symbol             <- map["symbol"]
        orders             <- map["orders"]
        orderReports       <- map["orderReports"]
    }
}
