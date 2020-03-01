//
//  AccountsTradeHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class AccountsTradeHandler: NSObject {
    
    var lowRsi: RSISerie?
    var highRsi: RSISerie?
    
    var lowTrix: (binanceTRIX: [Double?], tradingViewTRIX: [Double?])?
    var highTrix: (binanceTRIX: [Double?], tradingViewTRIX: [Double?])?
    
    var candles = [CandleObject]()
    
    var closeSamples = [Double?]()
    var highSamples = [Double?]()
    var lowSamples = [Double?]()
    
    func initialCandles(candles: [CandleObject]) {
        self.candles = candles
        
        for candle in candles {
            self.closeSamples.append(candle.close?.doubleValue ?? 0)
            self.highSamples.append(candle.high?.doubleValue ?? 0)
            self.lowSamples.append(candle.low?.doubleValue ?? 0)
        }
        
        self.updatedSamples()
    }
    
    func updatedSamples() {
        // Did update samples
    }
    
    func calculateCandlesTopsAndDowns(samples: [CandleObject], window: Int) -> (tops: [Int:Double], bottoms: [Int:Double]) {
        
        var tops = [Int:Double]()
        var bottoms = [Int:Double]()
        
        guard samples.count >= window * 2 + 1 else { return (tops, bottoms) }
        
        for i in window..<samples.count {
            let high = samples[i].close!
            let low = samples[i].close!
            
            var isHigh = true
            var isLow = true
            
            for w in 1...window {
                if high <= samples[i - w].close! {
                    isHigh = false
                    break
                }
            }
            
            if isHigh {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if high <= samples[w].close! {
                                isHigh = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isHigh {
                tops[i] = high.doubleValue
            }
            
            
            
            for w in 1...window {
                if low >= samples[i - w].close! {
                    isLow = false
                    break
                }
            }
            
            if isLow {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if low >= samples[w].close! {
                                isLow = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isLow {
                bottoms[i] = low.doubleValue
            }
        }
        
        return (tops, bottoms)
    }
    
    func calculateTopsAndDowns(samples: [Double], window: Int) -> (tops: [Int:Double], bottoms: [Int:Double]) {
        
        var tops = [Int:Double]()
        var bottoms = [Int:Double]()
        
        guard samples.count >= window * 2 + 1 else { return (tops, bottoms) }
        
        for i in window..<samples.count {
            let high = samples[i]
            let low = samples[i]
            
            var isHigh = true
            var isLow = true
            
            for w in 1...window {
                if high <= samples[i - w] {
                    isHigh = false
                    break
                }
            }
            
            if isHigh {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if high <= samples[w] {
                                isHigh = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isHigh {
                tops[i] = high
            }
            
            for w in 1...window {
                if low >= samples[i - w] {
                    isLow = false
                    break
                }
            }
            
            if isLow {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if low >= samples[w] {
                                isLow = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isLow {
                bottoms[i] = low
            }
        }
        return (tops, bottoms)
    
    }
    
    
    func checkForDivergence(candleTops: [Int:Double],
                            candleBottoms: [Int:Double],
                            rsiTops: [Int:Double],
                            rsiBottoms: [Int:Double],
                            lastPossibleIndex: Int) -> (hasDivergence: Bool, startIndex: Int ,endindex: Int) {
        
        let sortedRSITops =  Array(rsiTops.keys).sorted(by: <)
        let sortedCandlesTops =  Array(candleTops.keys).sorted(by: <)
        
        let sortedRSIDowns =  Array(rsiBottoms.keys).sorted(by: <)
        let sortedCandlesDowns =  Array(candleBottoms.keys).sorted(by: <)
        
        let lastTopCandleIndex = sortedCandlesTops.last!
        let lastTopRSIIndex = sortedRSITops.last!
        
        let lastBottomCandleIndex = sortedCandlesDowns.last!
        let lastBottomRSIIndex = sortedRSIDowns.last!
        
        if min(candleTops.count,rsiTops.count) > 1 {
            let shortDivergenceCheckPeriod = 12
            
            let count = (min(candleTops.count,rsiTops.count) > shortDivergenceCheckPeriod) ? shortDivergenceCheckPeriod : min(candleTops.count,rsiTops.count) - 1
            
            for i in 1...count {
                if (lastPossibleIndex - 1 > sortedCandlesTops.last ?? 0) { break }
                if ((lastPossibleIndex - 1) - sortedRSITops[sortedRSITops.count - i - 1] <= shortDivergenceCheckPeriod) {
                    if ((candleTops[lastTopCandleIndex]! > candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]!) && (rsiTops[lastTopRSIIndex]! < rsiTops[sortedRSITops[sortedRSITops.count - i - 1]]!)) ||
                        ((candleTops[lastTopCandleIndex]! < candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]!) && (rsiTops[lastTopRSIIndex]! > rsiTops[sortedRSITops[sortedRSITops.count - i - 1]]!)) {
                        
                        if abs(sortedRSITops[sortedRSITops.count - i - 1] - sortedCandlesTops[sortedCandlesTops.count - i - 1]) > 5 {
                            print("too much difference!")
                            break
                        }
                        
                        let priceSlope = abs(candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]! - candleTops[lastTopCandleIndex]!) / Double(sortedCandlesTops[sortedCandlesTops.count - 1] - sortedCandlesTops[sortedCandlesTops.count - i - 1])
                        
                        let indicatorSlope = abs(rsiTops[sortedRSITops[sortedRSITops.count - i - 1]]! - rsiTops[lastTopRSIIndex]!) / Double(sortedRSITops[sortedRSITops.count - 1] - sortedRSITops[sortedRSITops.count - i - 1])
                        
                        let Tangent_of_Angle = (indicatorSlope - priceSlope) / (1+priceSlope*indicatorSlope)
                        
                        if atan(Tangent_of_Angle) * 180 / Double.pi > 15 {
                            return (true, sortedCandlesTops[sortedCandlesTops.count - i - 1], lastTopCandleIndex)
                        }
                    }
                }
            }
        }
        
        if min(candleBottoms.count,rsiBottoms.count) > 1 {
            let shortDivergenceCheckPeriod = 12
            
            let count = (min(candleBottoms.count,rsiBottoms.count) > shortDivergenceCheckPeriod) ? shortDivergenceCheckPeriod : min(candleBottoms.count,rsiBottoms.count) - 1
            
            for i in 1...count {
                if (lastPossibleIndex - 1 > sortedCandlesDowns.last ?? 0) { break }
                if ((lastPossibleIndex - 1) - sortedRSIDowns[sortedRSIDowns.count - i - 1] <= shortDivergenceCheckPeriod) {
                    if ((candleBottoms[lastBottomCandleIndex]! > candleBottoms[sortedCandlesDowns[sortedCandlesDowns.count - i - 1]]!) && (rsiBottoms[lastBottomRSIIndex]! < rsiBottoms[sortedRSIDowns[sortedRSIDowns.count - i - 1]]!)) ||
                        ((candleBottoms[lastBottomCandleIndex]! < candleBottoms[sortedCandlesDowns[sortedCandlesDowns.count - i - 1]]!) && (rsiBottoms[lastBottomRSIIndex]! > rsiBottoms[sortedRSIDowns[sortedRSIDowns.count - i - 1]]!)) {
                        
                        if abs(sortedRSIDowns[sortedRSIDowns.count - i - 1] - sortedCandlesDowns[sortedCandlesDowns.count - i - 1]) > 5 {
                            print("too much difference!")
                            break
                        }
                        
                        let priceSlope = abs(candleBottoms[sortedCandlesDowns[sortedCandlesDowns.count - i - 1]]! - candleBottoms[lastBottomCandleIndex]!) / Double(sortedCandlesDowns[sortedCandlesDowns.count - 1] - sortedCandlesDowns[sortedCandlesDowns.count - i - 1])
                        
                        let indicatorSlope = abs(rsiBottoms[sortedRSIDowns[sortedRSIDowns.count - i - 1]]! - rsiBottoms[lastBottomRSIIndex]!) / Double(sortedRSIDowns[sortedRSIDowns.count - 1] - sortedRSIDowns[sortedRSIDowns.count - i - 1])
                        
                        let Tangent_of_Angle = (indicatorSlope - priceSlope) / (1+priceSlope*indicatorSlope)
                        
                        if atan(Tangent_of_Angle) * 180 / Double.pi > 15 {
                            return (true, sortedCandlesDowns[sortedCandlesDowns.count - i - 1], lastBottomCandleIndex)
                        }
                    }
                }
            }
        }
        
        return (false, 0, 0)
    }
}
