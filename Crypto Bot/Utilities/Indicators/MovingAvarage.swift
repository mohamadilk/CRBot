//
//  MovingAvarage.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 10.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class MovingAverage {
    
    private var period: Int

    init(period: Int) {
        self.period = period
    }
    
    public func calculateSimpleMovingAvarage(list: [Double?]) -> [Double?] {
        
        guard list.count > 0 else { return [0] }
        var MAsArray = [Double?]()
        var latestValues = [Double?]()
        
        for i in 1...list.count {
            
            if i >= self.period {
                latestValues = Array(list[(i - self.period)..<i])
            } else {
                latestValues = Array(list[0..<i])
            }
            var sum: Double = 0
            
            for value in latestValues {
                sum = sum + (value ?? 0)
            }
            
            let average = sum / Double(latestValues.count)
            MAsArray.append(average)
        }
        
        return MAsArray
    }
    
    var previewsEMA: Double? = nil
    
    public func calculateExponentialMovingAvarage(list: [Double?]) -> [Double?] {

        if list.count < self.period { return [] }

        var emaArray = [Double?]()

        for i in 0..<list.count {
            if i >= self.period - 1 {
                var subArray = [Double?]()
                subArray.append(contentsOf: list[(i - self.period + 1)...i])
                emaArray.append(ExponentialMA(list: subArray, price: list[i] ?? 0))
            }
        }
        
        return emaArray
    }
    
    private func ExponentialMA(list: Array<Double?>, price: Double) -> Double? {
        
        if list.count == 0 { return nil }
        
        let k = Double(2.0 / (Double(self.period) + 1.0))

        if previewsEMA == nil {
            previewsEMA = list.reduce(0.0,{ x, y in x + (y ?? 0) }) / Double(list.count)
        } else {
            previewsEMA = price * k + previewsEMA! * (1 - k);
        }
        return previewsEMA
    }
}
