//
//  Ichimoku.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 10.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class Ichimoku {
    
    let conversionPeriod = 9
    let basePeriod       = 26
    let spanPeriod       = 52
    let displacement     = 26
    
//    private func generator(price: Double) -> IchimokuReult? {
        
//        let result: IchimokuReult?
//        let tick: CandleObject
//
//        let period = max(conversionPeriod, basePeriod, spanPeriod, displacement)
//        var periodCounter = 0
//        var spanCounter = 0
//        var highs = [Double]()
//        var lows = [Double]()
//        var spanAs = [Double]()
//        var spanBs = [Double]()
//
//        var conversionPeriodLow = 0.0
//        var conversionPeriodHigh = 0.0
//        var basePeriodLow = 0.0
//        var basePeriodHigh = 0.0
//        var spanbPeriodLow = 0.0
//        var spanbPeriodHigh = 0.0
//
//        while (true) {
//            // Keep a list of lows/highs for the max period
//            highs.append(tick.high?.doubleValue ?? 0)
//            lows.append(tick.low?.doubleValue ?? 0)
//
//            if(periodCounter < period) {
//                periodCounter += 1
//            } else {
//                highs.removeFirst()
//                lows.removeFirst()
//
//                // Tenkan-sen (ConversionLine): (9-period high + 9-period low)/2))
//                conversionPeriodLow = Array(lows[(lows.count - conversionPeriod)..<lows.count]).min() ?? 0
//                conversionPeriodHigh = Array(highs[(highs.count - conversionPeriod)..<highs.count]).max() ?? 0
//
//                let conversionLine = (conversionPeriodHigh + conversionPeriodLow) / 2
//
//                // Kijun-sen (Base Line): (26-period high + 26-period low)/2))
//
//                basePeriodLow = Array(lows[(lows.count - basePeriod)..<lows.count]).min() ?? 0
//                basePeriodHigh = Array(highs[(highs.count - basePeriod)..<highs.count]).max() ?? 0
//
//                let baseLine = (basePeriodHigh + basePeriodLow) / 2
//
//                // Senkou Span A (Leading Span A): (Conversion Line + Base Line)/2))
//                var spanA = 0.0
//                spanAs.append((conversionLine + baseLine) / 2)
//
//                // Senkou Span B (Leading Span B): (52-period high + 52-period low)/2))
//                var spanB = 0.0
//                spanbPeriodLow = Array(lows[(lows.count - spanPeriod)..<lows.count]).min() ?? 0
//                spanbPeriodHigh = Array(highs[(highs.count - spanPeriod)..<highs.count]).max() ?? 0
//                spanBs.append((spanbPeriodHigh + spanbPeriodLow) / 2)
//
//                // Senkou Span A / Senkou Span B offset by 26 periods
//                if(spanCounter < displacement) {
//                    spanCounter += 1
//                } else {
//                    spanA = spanAs.removeFirst()
//                    spanB = spanBs.removeFirst()
//                }
//
//                result = IchimokuReult()
//                result!.conversion = conversionLine
//                result!.base = baseLine
//                result!.spanA = Double(spanA)
//                result!.spanB = Double(spanB)
//            }
//
//            return result
//        }
//    }

//    func insertNextValue(price: Double) -> IchimokuReult? {
//        return generator(price: price);
//    }

}

class IchimokuReult {
    
    var conversion :Double?
    var base :Double?
    var spanA :Double?
    var spanB :Double?
    
}

//extension Array {
//    func shiftRight(amount: Int = 1) -> [Element] {
//        var mutableAmount = amount
//        assert(-count...count ~= mutableAmount, "Shift amount out of bounds")
//        if mutableAmount < 0 { mutableAmount += count }  // this needs to be >= 0
//        return Array(self[mutableAmount ..< count] + self[0 ..< mutableAmount])
//    }
//
//    mutating func shiftRightInPlace(amount: Int = 1) {
//        self = shiftRight(amount: amount)
//    }
//}
