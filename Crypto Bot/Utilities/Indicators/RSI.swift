//
//  RSI.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 10.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

import Foundation

public class RSI {
    private var period: Int
    private var alpha: Double
    private var change = [Double?]();
    
    var sampleList = [Double?]()

    init(period: Int) {
        self.period = period
        self.alpha = Double(Double(1) / Double(self.period))
    }
    
    private func avrGain(list: Array<Double?>, index: Int) -> Double? {
        
        if list.count == 0 { return nil }
        
        if index == 0 {
            return list[0]
        }
        
        let first = (alpha * (list[index] ?? 0))
        let second = ((1 - alpha) * (avrGain(list: list, index: index - 1) ?? 0))
        
        return first + second
    }

    public func CalculateNormalRSI() -> RSISerie  {
        let rsiSerie  = RSISerie();
        
        for i in 1..<sampleList.count {
            let newChange = (sampleList[i] ?? 0) - (sampleList[i - 1] ?? 0)
            change.append(newChange)
        }
        
        for i in 0..<change.count {
            
            if (i >= self.period) {
                let averageGain = change[(i - self.period)..<i].filter({ ($0 ?? 0.0) > 0.0 }).reduce(0.0,{ x, y in x + (y ?? 0) }) / Double(self.period)
                let averageLoss = change[(i - self.period)..<i].filter({ ($0 ?? 0.0) < 0.0 }).reduce(0.0,{ x, y in x + (y ?? 0) }) * Double(-1) / Double(self.period)
                rsiSerie.RS.append(averageGain / averageLoss)
            }
        }
        
        for rs in rsiSerie.RS {
            if rs == nil {
                rsiSerie.RSI.append(nil)
            } else {
                rsiSerie.RSI.append(100 - (100 / (1 + rs!)))
            }
        }
        
        return rsiSerie
    }
    
    public func CalculateWildersRSI() -> RSISerie  {
            let rsiSerie  = RSISerie();
            
            for i in 1..<sampleList.count {
                let newChange = (sampleList[i] ?? 0) - (sampleList[i - 1] ?? 0)
                change.append(newChange)
            }
            
            for i in 0..<change.count {
                
                if (i >= self.period) {
                    let gainArray = change[(i - self.period)..<i].filter({ ($0 ?? 0.0) > 0.0 })
                    let lossArray = change[(i - self.period)..<i].filter({ ($0 ?? 0.0) < 0.0 })
    
                    let gain = avrGain(list: gainArray, index: gainArray.count - 1)
                    let loss = abs((avrGain(list: lossArray, index: lossArray.count - 1) ?? -1))
    
                    rsiSerie.RS.append((gain ?? 1) / (loss ))
                }
                else {
                    rsiSerie.RS.append(nil)
                }
            }
            
            for rs in rsiSerie.RS {
                if rs == nil {
                    rsiSerie.RSI.append(nil)
                } else {
                    rsiSerie.RSI.append(100 - (100 / (1 + rs!)))
                }
            }
            
            return rsiSerie
        }
}

public class RSISerie {

    public var RS: Array<Double?>
    public var RSI: Array<Double?>

    init() {
        RSI = [Double?]()
        RS = [Double?]()
    }
}

public class StochasticRSI {
    
    private var period: Int

    init(period: Int) {
        self.period = period
    }
    
    public func calculateStochasticRSI(list: [Double?]) -> [Double?] {
        guard list.count > 0 else { return [] }
        var stoRSIs = [Double?]()
        
        for i in 1...list.count {
            var stRSI: Double? = nil

            if i >= self.period {
                let latestRSIs = list[(i - self.period)..<i]
                
                guard let currentRSI = latestRSIs.last else {
                    stoRSIs.append(0)
                    continue
                }
                
                var sortedLatestRSIs = [Double?]()
                
                sortedLatestRSIs.append(contentsOf: latestRSIs)
                sortedLatestRSIs = sortedLatestRSIs.sorted(by: { ($0 ?? 0) < ($1 ?? 0) })
                
                guard let lowestRSI = sortedLatestRSIs.first else {
                    stoRSIs.append(0)
                    continue
                }
                guard let highestRSI = sortedLatestRSIs.last else {
                    stoRSIs.append(0)
                    continue
                }
                
                guard (highestRSI ?? 0) > (lowestRSI ?? 0) else {
                    stoRSIs.append(0)
                    continue
                }
                
                stRSI = (currentRSI! - lowestRSI!) / (highestRSI! - lowestRSI!) * 100.0
                stoRSIs.append(stRSI)
            }
        }
        
        return stoRSIs
    }
}
