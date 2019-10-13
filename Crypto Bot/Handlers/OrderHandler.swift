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
    
    let accountServices = AccountServices.shared
    
    func placeNewOrderWith(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: String? = nil, stopPrice: String? = nil, stopLimitPrice: String? = nil, percentage: String? = "100", response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        let symbol = "\(asset)\(currency)"
        
        var baseAsset: String = ""
        var quoteAsset: String = ""
        
        if side == .BUY {
            baseAsset = asset
            quoteAsset = currency
        } else {
            baseAsset = currency
            quoteAsset = asset
        }
        
        self.quantityFor(asset: asset, currency: currency, baseAssset: baseAsset, quoteAsset: quoteAsset, side: side, percent: percentage!, price: price ?? "") { (quantity, error) in
            
            if quantity == nil || quantity == 0 {
                response(nil, "Quantity does not meet minimum amount")
                return
            }
            switch type {
            case .LIMIT:
                self.accountServices.postNew_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: quantity!, price: price ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            case .LIMIT_MAKER:
                self.accountServices.postNew_LIMIT_MAKER_Order(symbol: symbol, side: side, quantity: quantity!, price: price ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            case .MARKET:
                self.accountServices.postNew_MARKET_Order(symbol: symbol, side: side, quantity: quantity!, timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            case .OCO:
                self.accountServices.postNewOCOOrder(symbol: symbol, side: side, quantity: quantity!, price: price ?? "", stopPrice: stopPrice ?? "", stopLimitPrice: stopLimitPrice ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                
                break
            case .STOP_LOSS:
                self.accountServices.postNew_STOP_LOSS_Order(symbol: symbol, side: side, quantity: quantity!, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                
                break
            case .STOP_LOSS_LIMIT:
                self.accountServices.postNew_STOP_LOSS_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: quantity!, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            case .TAKE_PROFIT:
                self.accountServices.postNew_TAKE_PROFIT_Order(symbol: symbol, side: side, quantity: quantity!, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            case .TAKE_PROFIT_LIMIT:
                self.accountServices.postNew_TAKE_PROFIT_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: quantity!, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                    guard error == nil else {
                        response(nil, error?.description)
                        return
                    }
                }
                break
            }
        }
        
    }
    
    private func currentUserCredit(currency: String, response: @escaping(_ balance: BalanceObject?, _ error: ApiError?) -> Swift.Void) {
        return AccountManager.shared.getCurrentUserCredit() { ( info, error) in
            guard error == nil else {
                response(nil, error)
                return
            }
            
            if let balances = info?.balances?.filter({ $0.asset == currency }), balances.count > 0 {
                response(balances.first, nil)
                return
            }
            response(nil, nil)
        }
    }
    
    func quantityFor(asset: String, currency: String, baseAssset: String, quoteAsset: String, side: OrderSide, percent: String, price: String, response: @escaping(_ quantity: Double?, _ error: String?) -> Swift.Void) {
        self.currentUserCredit(currency: quoteAsset) { (balance, error) in
            guard error == nil, balance != nil else {
                response(0, error?.localizedDescription)
                return
            }
                        
            ExchangeManager.shared.getSymbol(asset: asset, currency: currency) { (symbol, error) in
                guard error == nil, symbol != nil else {
                    response(0, error?.localizedDescription)
                    return
                }
                
                if let lotSizeArray = symbol!.filters?.filter({ $0.filterType == .LOT_SIZE }), lotSizeArray.count > 0 {
                    let lotSizeFilter = lotSizeArray[0]
                    
                    var quantity = 0.0
                    
                    if side == .SELL {
                        quantity = round((balance!.free!.doubleValue * 0.99 * percent.doubleValue) / 100 * 10000000) / 10000000
                    } else {
                        quantity = round((balance!.free!.doubleValue * 0.99 * percent.doubleValue) / price.doubleValue / 100 * 100) / 100
                    }
                    
                    if quantity < lotSizeFilter.minQty!.doubleValue {
                        response(nil, "Order quantity is less than minimum size")
                        return
                    }
                    
                    if quantity > lotSizeFilter.maxQty!.doubleValue {
                        response(nil, "Order quantity is more than maximum size")
                        return
                    }
                    
                    let multiplyer = Int(quantity / lotSizeFilter.stepSize!.doubleValue)
                    quantity = lotSizeFilter.minQty!.doubleValue * Double(multiplyer)
                    
                    let roundedQuantity = round(quantity * 1000) / 1000
                    response(roundedQuantity, nil)
                    
                }
            }
        }
    }
}
