import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 請求通知權限
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知權限已獲得")
            } else if let error = error {
                print("通知權限請求失敗：\(error.localizedDescription)")
            }
        }
    }
    
    // 設置訂閱的通知
    func scheduleSubscriptionNotifications(for subscription: Subscription) {
        // 先移除該訂閱的舊通知
        removeNotifications(for: subscription)
        
        let calendar = Calendar.current
        var startDate = subscription.billingDate
        let endDate = subscription.endDate ?? calendar.date(byAdding: .year, value: 1, to: startDate)!
        
        // 設置通知時間為早上7點
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        dateComponents.hour = 12
        dateComponents.minute = 43

        // 根據頻率設置通知
        while startDate <= endDate {
            // 創建通知
            let content = UNMutableNotificationContent()
            content.title = "訂閱提醒"
            content.body = "\(subscription.name) 今天需要支付 $\(Int(subscription.amount))"
            content.sound = .default
            
            // 設置觸發時間
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // 創建通知請求
            let identifier = "\(subscription.id)_\(dateComponents.year!)_\(dateComponents.month!)_\(dateComponents.day!)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // 添加通知
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("設置通知失敗：\(error.localizedDescription)")
                } else {
                    print("通知已設置：\(dateComponents)")
                }
            }
            
            // 根據頻率計算下一個通知日期
            switch subscription.frequency {
            case "Daily":
                startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            case "Weekly":
                startDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
            case "Monthly":
                startDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
            case "Yearly":
                startDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
            default:
                break
            }
            
            dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
            dateComponents.hour = 7
            dateComponents.minute = 0
        }
    }
    
    // 移除訂閱的通知
    func removeNotifications(for subscription: Subscription) {
        let identifier = "\(subscription.id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // 移除所有通知
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 
