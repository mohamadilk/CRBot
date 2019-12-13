//
//  CandidateSymbolObject.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9/5/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class CandidateSymbolObject: NSObject {
        
    var symbolOrderBook: SymbolOrderBookObject?
    
    var rawScore: Double?
    var weightedScore: Double?
    var latestPrice: String?
    
    func getTargetPercent() -> Double {
        return rawScore ?? 0
    }

    func getStopLossPercent() -> Double? {
        var stopLossPercent: Double = getTargetPercent()/2
        if(stopLossPercent > 2) { stopLossPercent = 2.0 }
        return stopLossPercent
    }
}
