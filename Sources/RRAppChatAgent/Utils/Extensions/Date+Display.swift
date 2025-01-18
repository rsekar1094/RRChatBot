//
//  Date+Display.swift
//  RRAppChatAgent
//
//  Created by Raj S on 12/01/25.
//

import Foundation
extension Date {
    
    var info: String {
        let currentTime = Date()
        guard Calendar.current.isDateInToday(self) else {
            let dayDifference = Calendar.current.dateComponents([.day], from: self, to: currentTime).day ?? 0
            return "\(dayDifference)d"
        }
    
        let secondsDifference = Calendar.current.dateComponents([.second], from: self, to: currentTime).second ?? 0
        if secondsDifference > 60 {
            let minutesDifference = Calendar.current.dateComponents([.minute], from: self, to: currentTime).minute ?? 0
            if minutesDifference < 60 {
                return "\(minutesDifference)m"
            } else {
                let hoursDifference = Calendar.current.dateComponents([.hour], from: self, to: currentTime).hour ?? 0
                return "\(hoursDifference)h"
            }
        } else {
            if secondsDifference == 0 {
                return "Now"
            } else {
                return "\(secondsDifference)s"
            }
        }
    }
}
