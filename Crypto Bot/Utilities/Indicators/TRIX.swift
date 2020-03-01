//
//  TRIX.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class TRIX {
    
    
    private var period: Int
    
    init(period: Int) {
        self.period = period
    }
    
    func calculateTrixValues(samples: [Double?]) -> (binanceTRIX: [Double?], tradingViewTRIX: [Double?]) {
    
        let EMA1 = MovingAverage(period: period).calculateExponentialMovingAvarage(list: samples)
        let EMA2 = MovingAverage(period: period).calculateExponentialMovingAvarage(list: EMA1)
        let EMA3 = MovingAverage(period: period).calculateExponentialMovingAvarage(list: EMA2)
        
        var tradingTRIX = [0.0]
        
        for i in 1..<EMA3.count {
            tradingTRIX.append(((EMA3[i]! - EMA3[i - 1]!) / EMA3[i - 1]!) * 10000)
        }
        return (EMA3, tradingTRIX)
    }
}
