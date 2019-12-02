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
    
    func formatted(price: String,for symbol: String) -> String? {
        guard let symbolObject = ExchangeHandler.shared.getSyncSymbol(symbol: symbol) else { return nil }
        guard let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER }) else { return nil }
        guard let tickSize = priceFilter.first?.tickSize else { return nil }

        var subPrice = price
        if price.count > tickSize.count {
            subPrice = String(price.prefix(tickSize.count))

        }
        
        if let limitIndex = tickSize.indexDistance(of: "1") {
            while subPrice.count > limitIndex + 1 {
                subPrice = String(subPrice.prefix(subPrice.count - 1))
            }
            
            while (subPrice.last == "0" || subPrice.last == ".") {
                subPrice = String(subPrice.prefix(subPrice.count - 1))
            }
        }
        return subPrice
    }
    
    func formatted(price: String,for symbol: String, completion: @escaping (_ price: String?, _ error: ApiError?) -> Swift.Void) {
        
        ExchangeHandler.shared.getSymbol(symbol: symbol, completion: { (symbolObject, error) in
            if error != nil {
                completion(price,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                completion(price,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER })
            
            guard let tickSize = priceFilter?.first?.tickSize else {
                completion(price, nil)
                return
            }

            var subPrice = price
            if price.count > tickSize.count {
                subPrice = String(price.prefix(tickSize.count))

            }
            
            if let limitIndex = tickSize.indexDistance(of: "1") {
                while subPrice.count > limitIndex + 1 {
                    subPrice = String(subPrice.prefix(subPrice.count - 1))
                }
                
                while (subPrice.last == "0" || subPrice.last == ".") {
                    subPrice = String(subPrice.prefix(subPrice.count - 1))
                }
            }
            
            completion(subPrice, nil)
        })
    }
    
    func formatted(quantity: String,for symbol: String) -> String? {
        guard let symbolObject = ExchangeHandler.shared.getSyncSymbol(symbol: symbol) else { return nil }
        guard let priceFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE }) else { return nil }
        guard let stepSize = priceFilter.first?.stepSize else { return nil }

        var subQuantity = quantity
        if subQuantity.count > stepSize.count {
            subQuantity = String(subQuantity.prefix(stepSize.count))

        }
        
        let multiplyer = floor(subQuantity.doubleValue /  stepSize.doubleValue)
        if var limitIndex = stepSize.indexDistance(of: "1") {
            if stepSize.doubleValue < 1 {
                limitIndex = limitIndex - 1
            }
            subQuantity = (Double(multiplyer) * stepSize.doubleValue).toString(decimal: limitIndex)
        }
        
        return subQuantity
    }
    
    func formatted(quantity: String,for symbol: String, completion: @escaping (_ price: String?, _ error: ApiError?) -> Swift.Void) {
        
        ExchangeHandler.shared.getSymbol(symbol: symbol, completion: { (symbolObject, error) in
            if error != nil {
                completion(quantity,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                completion(quantity,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE })
            
            guard let stepSize = priceFilter?.first?.stepSize else {
                completion(quantity, nil)
                return
            }

            var subQuantity = quantity
            if subQuantity.count > stepSize.count {
                subQuantity = String(subQuantity.prefix(stepSize.count))

            }
            
            let multiplyer = floor(subQuantity.doubleValue /  stepSize.doubleValue) - 3
            if var limitIndex = stepSize.indexDistance(of: "1") {
                if stepSize.doubleValue < 1 {
                    limitIndex = limitIndex - 1
                }
                subQuantity = (Double(multiplyer) * stepSize.doubleValue).toString(decimal: limitIndex)
            }
            
            completion(subQuantity, nil)
        })
    }
    
    func stepSize(for symbol: String) -> String? {
        guard let symbolObject = ExchangeHandler.shared.getSyncSymbol(symbol: symbol) else {
            return nil
        }
        
        let amountFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE })
        
        guard let stepSize = amountFilter?.first?.stepSize else {
            return nil
        }
        
        return stepSize
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

extension Collection where Element: Equatable {
    func indexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
extension StringProtocol {
    func indexDistance<S: StringProtocol>(of string: S) -> Int? {
        guard let index = range(of: string)?.lowerBound else { return nil }
        return distance(from: startIndex, to: index)
    }
}

