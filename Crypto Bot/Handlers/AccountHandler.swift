//
//  AccountManager.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/10/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class AccountHandler {
    
    static let shared = AccountHandler()
    
    func getCurrentUserCredit(completion: @escaping(_ accountInfo: AccountInformation?, _ error: ApiError?) -> Swift.Void){
        AccountServices.shared.fetchAccountInformation(timestamp: NSDate().timeIntervalSince1970 * 1000) { (info, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(info, nil)
        }
    }
    
    func getUserActiveOrders(completion: @escaping(_ orders: [OrderDetailObject]?, _ error: ApiError?) -> Swift.Void) {
        AccountServices.shared.fetchOpenOrders(timestamp: NSDate().timeIntervalSince1970 * 1000) { (ordersArray, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(ordersArray, nil)
        }
    }
    
    func cancelOrder(model: OrderDetailObject, completion: @escaping(_ order: OrderDetailObject?, _ error: ApiError?) -> Swift.Void) {
        AccountServices.shared.cancelOrder(symbol: "\(model.symbol ?? "")", orderId: model.orderId, origClientOrderId: model.origClientOrderId, timestamp: NSDate().timeIntervalSince1970 * 1000) { (order, error) in
                completion(order, error)
        }
    }
    
    func cancelOCOOrder(model: OrderDetailObject, completion: @escaping(_ result: OrderResponseObject?, _ error: ApiError?) -> Swift.Void) {
        AccountServices.shared.cancelOCOOrder(symbol: "\(model.symbol ?? "")", orderListId: model.orderListId, listClientOrderId: model.clientOrderId, timestamp: NSDate().timeIntervalSince1970 * 1000) { (result, error) in
            completion(result, error)
        }
    }
}

