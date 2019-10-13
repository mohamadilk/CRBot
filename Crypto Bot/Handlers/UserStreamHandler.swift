//
//  UserStreamHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 7/20/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

protocol UserStreamHandlerDelegate {
    
    func executionReportReceived(report: ExecutionReport)
    func outboundAccountinfoReceived(Info: OutboundAccountInfo)
}

class UserStreamHandler {
    
    public static let shared = UserStreamHandler()
    private var listenKey: String?
    var delegate: UserStreamHandlerDelegate?
    let streamService = UserDataStreamServices.shared
    
    var pingTimer: Timer?
    var resetStreamTimer: Timer?
    
    public func startUserStream() {
        
        streamService.delegate = self
        streamService.startUserDataStream { (key, error) in
            guard error == nil, key != nil else {
                self.startUserStream()
                return
            }
            
            self.listenKey = key
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 60 * 2, repeats: true, block: { _ in
                self.streamService.keepAliveUserDataStream(listenKey: self.listenKey!)
            })
            
            self.resetStreamTimer = Timer.scheduledTimer(withTimeInterval: 60 * 60 * 23, repeats: true, block: { _ in
                self.resetDataStream()
            })
            
        }
    }
    
    func resetDataStream() {
        
        self.pingTimer?.invalidate()
        self.resetStreamTimer?.invalidate()
        
        streamService.closeAliveUserDataStream(listenKey: self.listenKey!) { success in
            print("Deleted user data stream status: \(success)")
            if success {
                self.startUserStream()
            }
        }
    }
}

extension UserStreamHandler: UserDataStreamServicesDelegate {
    func didReceiveExecutionReport(object: ExecutionReport) {
        delegate?.executionReportReceived(report: object)
    }
    
    func didReceiveOutboundAccount(Info: OutboundAccountInfo) {
        delegate?.outboundAccountinfoReceived(Info: Info)
    }
}
