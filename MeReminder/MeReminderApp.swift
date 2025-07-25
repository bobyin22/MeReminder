//
//  MeReminderApp.swift
//  MeReminder
//
//  Created by 邱慧珊 on 7/19/25.
//

import SwiftUI
import SwiftData

@main
struct MeReminderApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([Subscription.self])
            let config = ModelConfiguration("MeReminder", schema: schema)
            container = try ModelContainer(for: schema, configurations: [config])
            
            // 印出資料庫位置
            if let url = container.configurations.first?.url {
                print("📁 Database URL: \(url.path)")
                print("📁 Database Directory: \(url.deletingLastPathComponent().path)")
                
                // 印出更多有用的資訊
                let fileManager = FileManager.default
                if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    print("📁 App Support Directory: \(appSupport.path)")
                }
                if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    print("📁 Documents Directory: \(documents.path)")
                }
            }
            
            // Add sample data if needed
            if try container.mainContext.fetch(FetchDescriptor<Subscription>()).isEmpty {
//                addSampleData()
            }
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
//    private func addSampleData() {
//        let duolingo = Subscription(
//            name: "Duolingo",
//            amount: 15,
//            dueDate: Date(),
//            icon: "graduationcap.fill"
//        )
//        
//        let netflix = Subscription(
//            name: "Netflix",
//            amount: 250,
//            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
//            icon: "play.fill"
//        )
//        
//        let amazon = Subscription(
//            name: "Amazon",
//            amount: 2500,
//            dueDate: Calendar.current.date(byAdding: .day, value: 886, to: Date())!,
//            icon: "cart.fill"
//        )
//        
//        [duolingo, netflix, amazon].forEach { subscription in
//            container.mainContext.insert(subscription)
//        }
//    }
}
