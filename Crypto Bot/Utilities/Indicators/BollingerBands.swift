//
//  BollingerBands.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 1.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class BollingerBands {
    
    private var period: Int
    private var mult: Double

    init(period: Int, mult: Double) {
        self.period = period
        self.mult = mult
    }
    
    public func calculateBollingerBands(samples: [Double]) -> (middle: [Double?], upper: [Double?], lower: [Double?]) {
        
        let mid = MovingAverage(period: period).calculateSimpleMovingAvarage(list: samples)
        
        var upperBand = [Double?]()
        var lowerBand = [Double?]()
        
        if samples.count >= period {
            for i in 0..<samples.count {
                if i >= (period - 1) {
                    let subArray = Array(samples[i - (period - 1)...i])
                    upperBand.append(mid[i]! + standardDeviation(arr: subArray) * mult)
                    lowerBand.append(mid[i]! - standardDeviation(arr: subArray) * mult)
                } else {
                    upperBand.append(mid[i]!)
                    lowerBand.append(mid[i]!)
                }
            }
        }
        
        return (mid, upperBand, lowerBand)
    }
    
     private func standardDeviation(arr : [Double]) -> Double {
        
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }

}
