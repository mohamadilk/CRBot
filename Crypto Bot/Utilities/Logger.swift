//
//  Logger.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 2.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

struct Log: TextOutputStream {

    func write(_ string: String) {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myLogger.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}

var logger = Log()


