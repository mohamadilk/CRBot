//
//  NumbersUtilities.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/9/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class NumbersUtilities {
    
    public static let shared = NumbersUtilities()
    
    func formatted(price: String,for symbol: String, result:@escaping (_ price: String?, _ error: ApiError?) -> Swift.Void) {
        
        ExchangeHandler.shared.getSymbol(symbol: symbol, result: { (symbolObject, error) in
            if error != nil {
                result(price,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                result(price,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER })
            
            guard let tickSize = priceFilter?.first?.tickSize else {
                result(price, nil)
                return
            }

            var subPrice = price
            if price.count > tickSize.count {
                subPrice = String(price.prefix(tickSize.count))

            }
            
            while subPrice.last == "0" || subPrice.last == "." {
                subPrice = String(subPrice.prefix(subPrice.count - 1))
            }
            result(subPrice, nil)
        })
    }
    
    func formatted(quantity: String,for symbol: String, result:@escaping (_ price: String?, _ error: ApiError?) -> Swift.Void) {
        
        ExchangeHandler.shared.getSymbol(symbol: symbol, result: { (symbolObject, error) in
            if error != nil {
                result(quantity,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                result(quantity,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE })
            
            guard let stepSize = priceFilter?.first?.stepSize else {
                result(quantity, nil)
                return
            }

            var subQuantity = quantity
            if subQuantity.count > stepSize.count {
                subQuantity = String(subQuantity.prefix(stepSize.count))

            }
            
            while subQuantity.last == "0" || subQuantity.last == "."{
                subQuantity = String(subQuantity.prefix(subQuantity.count - 1))
            }
            result(subQuantity, nil)
        })
    }
}

extension String {

    subscript (r: CountableClosedRange<Int>) -> String? {
        get {
            guard r.lowerBound >= 0, let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound, limitedBy: self.endIndex),
                let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound, limitedBy: self.endIndex) else { return nil }
            return String(self[startIndex...endIndex])
        }
    }
}
