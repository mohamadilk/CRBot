//
//  systemBRAIN.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
class systemBRAIN {
    
    public static let shared = systemBRAIN()
    
    let streamHandler = UserStreamHandler.shared
    
    init() {
        self.streamHandler.delegate = self
    }
    
}

extension systemBRAIN: UserStreamHandlerDelegate {
    func executionReportReceived(report: ExecutionReport) {
        switch report.currentOrderStatus {
        case .NEW:
            switch report.side! {
            case .BUY:
                print("NEW BUY ORDER PLACED")
                break
            case .SELL:
                print("NEW CELL ORDER PLACED")
                break
            }
            break
            
        case .FILLED, .PARTIALLY_FILLED:
            
            break
            
        case .CANCELED:
            
            break
            
        case .EXPIRED:
            
            break
            
        case .REJECTED:
            
            break
        default:
            break
        }
    }
    
    func outboundAccountinfoReceived(Info: OutboundAccountInfo) {

    }
    
    
}


