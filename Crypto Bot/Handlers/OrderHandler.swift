//
//  OrderHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
class OrderHandler {
    
    public static let shared = OrderHandler()
    
    func placeNewOrderWith(type: OrderTypes, Symbol: String, side: OrderSide, price: String? = nil, quantity: Double, stopPrice: String? = nil, stopLimitPrice: String? = nil, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        
        switch type {
        case .LIMIT:
            AccountServices.shared.postNew_LIMIT_Order(symbol: Symbol, side: side, timeInForce: .GTC, quantity: quantity, price: price ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        case .LIMIT_MAKER:
            AccountServices.shared.postNew_LIMIT_MAKER_Order(symbol: Symbol, side: side, quantity: quantity, price: price ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        case .MARKET:
            AccountServices.shared.postNew_MARKET_Order(symbol: Symbol, side: side, quantity: quantity, timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        case .OCO:
            AccountServices.shared.postNewOCOOrder(symbol: Symbol, side: .BUY, quantity: quantity, price: price ?? "", stopPrice: stopPrice ?? "", stopLimitPrice: stopLimitPrice ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            
            break
        case .STOP_LOSS:
            AccountServices.shared.postNew_STOP_LOSS_Order(symbol: Symbol, side: side, quantity: quantity, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            
            break
        case .STOP_LOSS_LIMIT:
            AccountServices.shared.postNew_STOP_LOSS_LIMIT_Order(symbol: Symbol, side: side, timeInForce: .GTC, quantity: quantity, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        case .TAKE_PROFIT:
            AccountServices.shared.postNew_TAKE_PROFIT_Order(symbol: Symbol, side: side, quantity: quantity, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        case .TAKE_PROFIT_LIMIT:
            AccountServices.shared.postNew_TAKE_PROFIT_LIMIT_Order(symbol: Symbol, side: side, timeInForce: .GTC, quantity: quantity, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (responce, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
            }
            break
        }
    }
}
