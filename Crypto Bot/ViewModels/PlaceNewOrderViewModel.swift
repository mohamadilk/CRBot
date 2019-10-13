//
//  PlaceNewOrderViewModel.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/10/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

public class PlaceNewOrderViewModel: NSObject {
    
    private var viewController :PlaceNewOrderViewController!
    private var accountManager :AccountManager!
    
    init(viewController: PlaceNewOrderViewController) {
        super.init()
        self.viewController = viewController
        self.accountManager = AccountManager.shared
    }
    
    func checkQuantityAndPlaceNewOrder(type: OrderTypes, asset: String, currency: String, side: OrderSide, percentage: String, price: String? = nil, stopPrice: String? = nil, stopLimitPrice: String? = nil, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        if price != nil {
            quantityFor(asset: asset, currency: currency, percent: percentage, price: price!) { (quantity, error) in
                guard error == nil else {
                    response(nil, error?.description)
                    return
                }
                
                OrderHandler.shared.placeNewOrderWith(type: type, Symbol: "\(asset)\(currency)", side: side, price: price, quantity: quantity ?? 0, stopPrice: stopPrice, stopLimitPrice: stopLimitPrice) { (result, error) in
                    response(result, error)
                }
            }
        } else {
            currentUserCredit(currency: currency) { (balance, error) in
                //TODO: Get market price and place order
            }
        }
        
    }
    
    private func currentUserCredit(currency: String, response: @escaping(_ balance: BalanceObject?, _ error: ApiError?) -> Swift.Void) {
        return accountManager.getCurrentUserCredit() { ( info, error) in
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
    
    func quantityFor(asset: String, currency: String, percent: String, price: String, response: @escaping(_ quantity: Double?, _ error: String?) -> Swift.Void) {
        self.currentUserCredit(currency: currency) { (balance, error) in
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
                    
                    var quantity = round((balance!.free!.doubleValue * 0.99 * percent.doubleValue) / price.doubleValue / 100 * 100) / 100
                                        
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
                    response(quantity, nil)
                    
                }
            }
        }
    }
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
