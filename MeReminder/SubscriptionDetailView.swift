import SwiftUI

struct SubscriptionDetailView: View {
    let service: SubscriptionService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedTab: Int  // 新增這行


    @State private var amount: Double = 0
    @State private var billingDate = Date()
    @State private var endDate: Date?
    @State private var frequency: SubscriptionFrequency = .monthly
    @State private var currency: Currency = .usd
    @State private var category: SubscriptionCategory = .general
    @State private var notification: NotificationFrequency = .never
    
    var body: some View {
        ZStack {
            //Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("NEW SUBSCRIPTION")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    
                    // Service Header
                    HStack {
                        service.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        Text(service.name)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                    }
                    
                    // Amount Input
                    VStack(alignment: .leading) {
                        HStack {
                            Text("$")
                                .font(.system(size: 30, weight: .bold))
                            
                            TextField("0.00", value: $amount, format: .number)
                                .font(.system(size: 30, weight: .bold))
                                .keyboardType(.decimalPad)
                        }
                        .padding(.vertical, 8)
                        Divider().background(Color.gray)
                    }
                    
                    // Date Fields
                    VStack(spacing: 20) {
                        DateField(title: "Billing date", date: $billingDate)
                        DateField(title: "End date", date: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), showNone: true)
                    }
                    
                    // Frequency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequency")
                            .font(.title3)
                        
                        Picker("Frequency", selection: $frequency) {
                            ForEach(SubscriptionFrequency.allCases) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        
                        Divider().background(Color.gray)
                    }
                    
                    // Currency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.title3)
                        
                        Picker("Currency", selection: $currency) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        
                        Divider().background(Color.gray)
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.title3)
                        
                        Picker("Category", selection: $category) {
                            ForEach(SubscriptionCategory.allCases) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.purple)
                                    Text(category.rawValue)
                                }.tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        
                        Divider().background(Color.gray)
                    }
                    
                    // Notification
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Receive Notification")
                            .font(.title3)
                        
                        Picker("Notification", selection: $notification) {
                            ForEach(NotificationFrequency.allCases) { notification in
                                Text(notification.rawValue).tag(notification)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        
                        Divider().background(Color.gray)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Add Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveSubscription()
                }
                .foregroundColor(.purple)
            }
        }
    }
    
    private func saveSubscription() {
        let newSubscription = Subscription(
            name: service.name,
            amount: amount,
            dueDate: billingDate,
            icon: category.icon
        )
        modelContext.insert(newSubscription)
        try? modelContext.save()
        
        // 設置回到 Overview tab
        selectedTab = 0
        
        // 發送通知以關閉所有視圖
        NotificationCenter.default.post(name: Notification.Name("DismissToRoot"), object: nil)
        
        // 關閉當前視圖
        dismiss()
    }
}

// 支援的列舉類型
enum SubscriptionFrequency: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD ($)"
    case eur = "EUR (€)"
    case gbp = "GBP (£)"
    
    var id: String { rawValue }
}

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case general = "General"
    case entertainment = "Entertainment"
    case productivity = "Productivity"
    case utilities = "Utilities"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .general: return "tag.fill"
        case .entertainment: return "play.fill"
        case .productivity: return "briefcase.fill"
        case .utilities: return "bolt.fill"
        }
    }
}

enum NotificationFrequency: String, CaseIterable, Identifiable {
    case never = "Never"
    case onDueDate = "On due date"
    case dayBefore = "1 day before"
    case weekBefore = "1 week before"
    
    var id: String { rawValue }
}

// 自定義日期選擇器視圖
struct DateField: View {
    let title: String
    @Binding var date: Date
    var showNone: Bool = false
    @State private var isNone: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
            
            if showNone {
                Toggle("No end date", isOn: $isNone)
                    .tint(.purple)
            }
            
            if !isNone {
                DatePicker(
                    title,
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.purple)
            }
            
            Divider().background(Color.gray)
        }
    }
} 
