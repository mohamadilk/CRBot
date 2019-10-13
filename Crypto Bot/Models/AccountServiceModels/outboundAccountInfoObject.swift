//
//  outboundAccountInfoObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OutboundAccountInfo: BaseApiModel {
    
    var eventType: String?
    var eventTime: TimeInterval?
    var MakerCommissionRate: Double?
    var takerCommissionRate: Double?
    var buyerCommissionRate: Double?
    var sellerCommissionRate: Double?
    var canTrade: Bool?
    var canWithdraw: Bool?
    var canDeposit: Bool?
    var timeOfLastAccountUpdate: TimeInterval?
    var balancesArray: [SocketBalanceObject]?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        eventType                 <- map["e"]
        eventTime                 <- map["E"]
        MakerCommissionRate       <- map["m"]
        takerCommissionRate       <- map["t"]
        buyerCommissionRate       <- map["b"]
        sellerCommissionRate      <- map["s"]
        canTrade                  <- map["T"]
        canWithdraw               <- map["W"]
        canDeposit                <- map["D"]
        timeOfLastAccountUpdate   <- map["u"]
        balancesArray             <- map["B"]

    }
}

class SocketBalanceObject: BaseApiModel {
    
    var asset: String?
    var free: String?
    var locked: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        asset             <- map["a"]
        locked            <- map["l"]
        free              <- map["f"]
    }
}
