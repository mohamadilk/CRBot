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
    
    func automaticallyPlaceNewOrderWith(type: OrderTypes, asset: String, currency: String , side: OrderSide, price: String, stopPrice: String? = nil, stopLimitPrice: String? = nil, percentage: String,  response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {

        var baseAsset: String = ""
        var quoteAsset: String = ""

        if side == OrderSide.BUY {
            baseAsset = asset
            quoteAsset = currency
        } else {
            baseAsset = currency
            quoteAsset = asset
        }

        quantityFor(asset: asset, currency: currency, baseAssset: baseAsset, quoteAsset: quoteAsset, side: side, percent: percentage, price: price, buyStopLimitPrice: stopLimitPrice) { (quantity, error) in
            guard error == nil else { return }
            
            
            if let amount = quantity?.toString() {
                NumbersUtilities.shared.formatted(quantity: amount, for: "\(asset)\(currency)") { (newAmount, error) in
                    guard error == nil, newAmount != nil else {
                        response(nil, error?.localizedDescription)
                        return
                    }
                    
                    self.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, amount: amount, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice) { (result, error) in
                        response(result, error)
                    }
                }

            } else {
                response(nil, nil)
            }
        }
    }
    
    func placeNewOrderWith(type: OrderTypes, asset: String, currency: String , side: OrderSide, amount: String, price: String? = nil, stopPrice: String? = nil, stopLimitPrice: String? = nil, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        let symbol = "\(asset)\(currency)"
        
        switch type {
        case .LIMIT:
            self.accountServices.postNew_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: price ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        case .LIMIT_MAKER:
            self.accountServices.postNew_LIMIT_MAKER_Order(symbol: symbol, side: side, quantity: amount, price: price ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        case .MARKET:
            self.accountServices.postNew_MARKET_Order(symbol: symbol, side: side, quantity: amount, timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        case .OCO:
            self.accountServices.postNewOCOOrder(symbol: symbol, side: side, quantity: amount, price: price ?? "", stopPrice: stopPrice ?? "", stopLimitPrice: stopLimitPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                
                if side == .SELL {
                    if result != nil {
                        print("----------> order added to cashe handler")
                        OrdersCasheHandler.shared.newSellOrderPlaced(response: result!)
                    }
                }
                
                response(result, nil)
            }
            
            break
        case .STOP_LOSS:
            self.accountServices.postNew_STOP_LOSS_Order(symbol: symbol, side: side, quantity: amount, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            
            break
        case .STOP_LOSS_LIMIT:
            self.accountServices.postNew_STOP_LOSS_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: stopLimitPrice ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        case .TAKE_PROFIT:
            self.accountServices.postNew_TAKE_PROFIT_Order(symbol: symbol, side: side, quantity: amount, stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        case .TAKE_PROFIT_LIMIT:
            self.accountServices.postNew_TAKE_PROFIT_LIMIT_Order(symbol: symbol, side: side, timeInForce: .GTC, quantity: amount, price: price ?? "", stopPrice: stopPrice ?? "", timestamp: timeStamp) { (result, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                response(result, nil)
            }
            break
        }

        
//        self.quantityFor(asset: asset, currency: currency, baseAssset: baseAsset, quoteAsset: quoteAsset, side: side, percent: percentage!, price: price ?? "", buyStopLimitPrice: stopLimitPrice) { (quantity, error) in
//
//            if quantity == nil || quantity == 0 {
//                response(nil, "Quantity does not meet minimum amount")
//                return
//            }
//        }
        
    }
    
    func replaceOCOSellOrder(symbol: String, price: String, stopPrice: String, stopLimitPrice: String, quantity: String, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        print("..................................")
        self.accountServices.postNewOCOOrder(symbol: symbol, side: .SELL, quantity: quantity, price: price, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice, timestamp: NSDate().timeIntervalSince1970 * 1000) { (result, error) in
            guard error == nil else {
                response(nil, error?.description)
                return
            }
            
            print("----------> order added to cashe handler")
            OrdersCasheHandler.shared.newSellOrderPlaced(response: result!)
            
            response(result, nil)
        }
    }
    
    func cancelOCOOrder(symbol: String, listClientOrderId: String, response: @escaping(_ success: Bool?, _ error: String?) -> Swift.Void) {
        let timeStamp = NSDate().timeIntervalSince1970 * 1000
        self.accountServices.cancelOCOOrder(symbol: symbol, listClientOrderId: listClientOrderId, timestamp: timeStamp) { (success, error) in
            guard error == nil else {
                response(false, error?.localizedDescription)
                return
            }
            
            response(success, nil)
        }
    }
    
    func addPricesForSymbol(symbol: String, targetsArray: [String]?, stopPrice: String?, stopLimitPrice: String?) {
        systemBRAIN.shared.addPricesForSymbol(symbol: symbol, targetsArray: targetsArray, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice)
    }
    
    private func currentUserCredit(currency: String, response: @escaping(_ balance: BalanceObject?, _ error: ApiError?) -> Swift.Void) {
        return AccountHandler.shared.getCurrentUserCredit() { ( info, error) in
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
    
    func quantityFor(asset: String, currency: String, baseAssset: String, quoteAsset: String, side: OrderSide, percent: String, price: String, buyStopLimitPrice: String? = nil, response: @escaping(_ quantity: Double?, _ error: String?) -> Swift.Void) {
        self.currentUserCredit(currency: quoteAsset) { (balance, error) in
            guard error == nil, balance != nil else {
                response(0, error?.localizedDescription)
                return
            }
                        
            ExchangeHandler.shared.getSymbol(symbol: "\(asset)\(currency)") { (symbol, error) in
                guard error == nil, symbol != nil else {
                    response(0, error?.localizedDescription)
                    return
                }
                
                if let lotSizeArray = symbol!.filters?.filter({ $0.filterType == .LOT_SIZE }), lotSizeArray.count > 0 {
                    let lotSizeFilter = lotSizeArray[0]
                    
                    var quantity = 0.0
                    let checkPrice: String = (buyStopLimitPrice != nil) ? buyStopLimitPrice! : price
                    
                    if side == .SELL {
                        quantity = round((balance!.free!.doubleValue * 0.99 * percent.doubleValue) / 100 * 10000000) / 10000000
                    } else {
                        quantity = round((balance!.free!.doubleValue * 0.99 * (percent.doubleValue / 100)) / checkPrice.doubleValue * 100000) / 100000
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
                    
                    let roundedQuantity = round(quantity * 1000000) / 1000000
                    response(roundedQuantity, nil)
                    
                }
            }
        }
    }
}
