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
    var dueDate: Date
    var icon: String
    var endDate: Date?  // 可選類型，因為可能沒有結束日期
    
    init(name: String, amount: Double, dueDate: Date, icon: String, endDate: Date? = nil) {
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.icon = icon
        self.endDate = endDate
    }
}
