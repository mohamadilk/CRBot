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
    private var accountManager :AccountHandler!
    
    init(viewController: PlaceNewOrderViewController) {
        super.init()
        self.viewController = viewController
        self.accountManager = AccountHandler.shared
    }
    
    func SetTargetsAndPlaceNewOrder(targets: [String], type: OrderTypes, asset: String, currency: String, side: OrderSide, percentage: String, price: String? = nil, buyStopPrice: String? = nil, buyStopLimitPrice: String? = nil, sellStopPrice: String? = nil, sellStopLimitPrice: String? = nil, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        OrderHandler.shared.addPricesForSymbol(symbol: "\(asset)\(currency)", targetsArray: targets, stopPrice: sellStopPrice, stopLimitPrice: sellStopLimitPrice)
        
        OrderHandler.shared.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, price: price, stopPrice: (side == .SELL) ? sellStopPrice : buyStopPrice, stopLimitPrice: (side == .SELL) ? sellStopLimitPrice : buyStopLimitPrice, percentage: percentage) { (result, error) in
            response(result, error)
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
    
    var decimalValue: String {
        return self.replacingOccurrences(of: ",", with: ".")
    }
}


