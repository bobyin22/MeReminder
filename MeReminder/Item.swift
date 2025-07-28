//
//  Item.swift
//  MeReminder
//
//  Created by 邱慧珊 on 7/19/25.
//

import Foundation
import SwiftData

@Model
class Subscription {
    var name: String
    var amount: Double
    var billingDate: Date
    var icon: String
    var endDate: Date?  // 可選類型，因為可能沒有結束日期
    var frequency: String = "Monthly"  // 預設為每月
    
    init(name: String, amount: Double, billingDate: Date, icon: String, endDate: Date? = nil, frequency: String = "Monthly") {
        self.name = name
        self.amount = amount
        self.billingDate = billingDate
        self.icon = icon
        self.endDate = endDate
        self.frequency = frequency
    }
}
