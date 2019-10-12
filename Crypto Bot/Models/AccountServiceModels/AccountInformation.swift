//
//  AccountInformation.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/9/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class AccountInformation: BaseApiModel {
    
    var makerCommission: Int?
    var takerCommission: Int?
    var buyerCommission: Int?
    var sellerCommission: Int?
    var canTrade: Bool?
    var canWithdraw: Bool?
    var canDeposit: Bool?
    var updateTime: TimeInterval?
    var accountType: String?
    var balances: [BalanceObject]?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        makerCommission       <- map["makerCommission"]
        takerCommission       <- map["takerCommission"]
        buyerCommission       <- map["buyerCommission"]
        sellerCommission      <- map["sellerCommission"]
        canTrade              <- map["canTrade"]
        canWithdraw           <- map["canWithdraw"]
        canDeposit            <- map["canDeposit"]
        updateTime            <- map["updateTime"]
        accountType           <- map["accountType"]
        balances              <- map["balances"]
    }
      
}
