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
    
    init(name: String, amount: Double, dueDate: Date, icon: String) {
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.icon = icon
    }
}
