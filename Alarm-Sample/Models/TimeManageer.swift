//
//  TimeManager.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import Foundation

struct TimeManager {
    func toString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: date)
    }
}
