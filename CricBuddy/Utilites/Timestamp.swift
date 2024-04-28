//
//  Timestamp.swift
//  CricBuddy
//
//  Created by Vivek Shah on 26/03/24.
//

import Foundation

extension String {
    static func timestamp() -> String {
        let dateFMT = DateFormatter()
        dateFMT.locale = Locale(identifier: "en_US_POSIX")
        dateFMT.dateFormat = "yyyy-MM-dd 'T' HH:mm:ss.SSSS"
        let now = Date()

        return String(format: "%@", dateFMT.string(from: now))
    }

    func tad2Date() -> Date? {
        let dateFMT = DateFormatter()
        dateFMT.locale = Locale(identifier: "en_US_POSIX")
        dateFMT.dateFormat = "yyyyMMdd'T'HHmmss.SSSS"

        return dateFMT.date(from: self)
    }
}
