//
//  ContentView.swift
//  MeReminder
//
//  Created by 邱慧珊 on 7/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Overview")
                }
                .tag(0)

            Text("Reports")
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Reports")
                }
                .tag(1)

            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(.purple)
    }
}

struct OverviewView: View {
    @Query private var subscriptions: [Subscription]
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    @State private var subscriptionToDelete: Subscription?
    @State private var showingDetail = false
    @State private var selectedSubscription: Subscription?
    @State private var timeSegment = 0 // 0: 月, 1: 年

    var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    // 計算兩個日期之間的天數（包含起始日和結束日）
    private func getDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        // 確保我們使用日期的開始時間進行比較
        let startOfStart = calendar.startOfDay(for: start)
        let startOfEnd = calendar.startOfDay(for: end)
        
        // 使用 range(of: .day, from: startOfStart, to: startOfEnd) 計算天數
        let range = calendar.dateComponents([.day], from: startOfStart, to: startOfEnd)
        let days = range.day ?? 0
        
        // 加1是因為要包含起始日和結束日
        let totalDays = days + 1
        
        // 調試輸出
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("計算天數：")
        print("開始日期：\(formatter.string(from: start))")
        print("結束日期：\(formatter.string(from: end))")
        print("計算得到天數：\(totalDays)")
        
        return totalDays
    }
    
    // 根據頻率計算每月金額
    private func getMonthlyAmount(for subscription: Subscription) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        
        // 取得當月的第一天和最後一天
        let monthStart = calendar.date(from: DateComponents(year: currentComponents.year, month: currentComponents.month, day: 1))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        
        // 計算實際的開始和結束日期
        let startDate = max(subscription.billingDate, monthStart)
        let endDate = subscription.endDate.map { min($0, monthEnd) } ?? monthEnd
        
        // 如果開始日期在結束日期之後，表示這個月沒有費用
        if startDate > endDate {
            return 0
        }
        
        // 計算這個月內實際的天數
        let daysInPeriod = getDaysBetween(start: startDate, end: endDate)
        
        // 調試輸出
        print("訂閱詳情：")
        print("頻率：\(subscription.frequency)")
        print("金額：\(subscription.amount)")
        print("計算天數：\(daysInPeriod)")
        
        switch subscription.frequency {
        case "Daily":
            // 每天收費，直接乘以天數
            let amount = subscription.amount * Double(daysInPeriod)
            print("Daily 計算：\(subscription.amount) × \(daysInPeriod) = \(amount)")
            return amount
            
        case "Weekly":
            // 計算完整的週數（向上取整）
            let weeks = ceil(Double(daysInPeriod) / 7.0)
            let amount = subscription.amount * weeks
            print("Weekly 計算：\(subscription.amount) × \(weeks) = \(amount)")
            return amount
            
        case "Monthly":
            // 如果是在計費日，收取整月費用
            if calendar.isDate(subscription.billingDate, equalTo: startDate, toGranularity: .month) {
                print("Monthly 計算：整月費用 = \(subscription.amount)")
                return subscription.amount
            }
            print("Monthly 計算：非計費月 = 0")
            return 0
            
        case "Yearly":
            // 如果是在計費日，收取年費的月分攤
            if calendar.isDate(subscription.billingDate, equalTo: startDate, toGranularity: .month) {
                let amount = subscription.amount / 12
                print("Yearly 計算：年費分攤 = \(amount)")
                return amount
            }
            print("Yearly 計算：非計費月 = 0")
            return 0
            
        default:
            return 0
        }
    }

    // 根據頻率計算年度金額
    private func getYearlyAmount(for subscription: Subscription, monthCount: Int) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year], from: now)
        
        // 取得當年的第一天和最後一天
        let yearStart = calendar.date(from: DateComponents(year: currentComponents.year, month: 1, day: 1))!
        let yearEnd = calendar.date(from: DateComponents(year: currentComponents.year, month: 12, day: 31))!
        
        // 計算實際的開始和結束日期
        let startDate = max(subscription.billingDate, yearStart)
        let endDate = subscription.endDate.map { min($0, yearEnd) } ?? yearEnd
        
        // 如果開始日期在結束日期之後，表示這一年沒有費用
        if startDate > endDate {
            return 0
        }
        
        // 計算實際的天數
        let daysInPeriod = getDaysBetween(start: startDate, end: endDate)
        
        switch subscription.frequency {
        case "Daily":
            // 每天收費，直接乘以天數
            return subscription.amount * Double(daysInPeriod)
            
        case "Weekly":
            // 計算完整的週數（向上取整）
            let weeks = ceil(Double(daysInPeriod) / 7.0)
            return subscription.amount * weeks
            
        case "Monthly":
            // 計算完整的月數（向上取整）
            let months = ceil(Double(daysInPeriod) / 30.0)
            return subscription.amount * months
            
        case "Yearly":
            // 如果是在計費年，收取整年費用
            if calendar.isDate(subscription.billingDate, equalTo: startDate, toGranularity: .year) {
                return subscription.amount
            }
            return 0
            
        default:
            return 0
        }
    }

    var totalAmount: Double {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        
        return subscriptions.reduce(0) { total, subscription in
            let components = calendar.dateComponents([.year, .month], from: subscription.billingDate)
            
            if timeSegment == 0 {
                // 月度總額：只計算當月的訂閱
                if components.year == currentComponents.year && 
                   components.month == currentComponents.month {
                    return total + getMonthlyAmount(for: subscription)
                }
            } else {
                // 年度總額：計算該年度內每個訂閱的總金額
                if components.year == currentComponents.year {
                    // 計算月份差
                    let startDate = subscription.billingDate
                    let endDate = subscription.endDate ?? calendar.date(byAdding: .year, value: 1, to: startDate)!
                    
                    // 如果結束日期在今年之後，只計算到今年年底
                    let yearEndDate = calendar.date(from: DateComponents(year: currentComponents.year, month: 12, day: 31))!
                    let effectiveEndDate = min(endDate, yearEndDate)
                    
                    // 計算月份差（包含起始月和結束月）
                    let monthDiff = calendar.dateComponents([.month], from: startDate, to: effectiveEndDate).month ?? 0
                    let monthCount = monthDiff + 1
                    
                    return total + getYearlyAmount(for: subscription, monthCount: monthCount)
                }
            }
            return total
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Overview Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Picker("Time Period", selection: $timeSegment) {
                            Text(currentMonth)
                                .tag(0)
                            Text("\(currentYear)")
                                .tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .cornerRadius(20)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Text("\(Int(totalAmount))")
                            .font(.system(size: 50, weight: .bold))
                        + Text(" USD")
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)

                // Upcoming Subscriptions
                VStack(alignment: .leading) {
                    Text("UPCOMING")
                        .foregroundColor(.gray)
                        .padding(.leading)
                        .padding(.bottom, 5)

                    List {
                        ForEach(subscriptions) { subscription in
                            Button {
                                withAnimation {
                                    selectedSubscription = subscription
                                    showingDetail = true
                                }
                            } label: {
                                SubscriptionRow(subscription: subscription)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    subscriptionToDelete = subscription
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.purple)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SubscriptionListView(selectedTab: $selectedTab)) {
                        Image(systemName: "plus")
                            .foregroundColor(.purple)
                    }
                }
            }
            .alert("確認刪除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {
                    subscriptionToDelete = nil
                }
                Button("刪除", role: .destructive) {
                    if let subscription = subscriptionToDelete {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            modelContext.delete(subscription)
                            try? modelContext.save()
                        }
                        subscriptionToDelete = nil
                    }
                }
            } message: {
                if let subscription = subscriptionToDelete {
                    Text("確定要刪除 \(subscription.name) 的訂閱嗎？此操作無法復原。")
                } else {
                    Text("確定要刪除這個訂閱嗎？此操作無法復原。")
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let subscription = selectedSubscription {
                    let service = SubscriptionService(
                        name: subscription.name,
                        systemName: subscription.icon
                    )
                    NavigationStack {
                        SubscriptionDetailView(
                            service: service,
                            selectedTab: $selectedTab,
                            existingSubscription: subscription
                        )
                    }
                }
            }
            .onChange(of: showingDetail) { oldValue, newValue in
                if !newValue {
                    // 當 sheet 關閉時，清除選中的訂閱
                    selectedSubscription = nil
                }
            }
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            Image(systemName: subscription.icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.3))
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(subscription.name)
                    .font(.headline)

                Text(getBillingText(date: subscription.billingDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(Int(subscription.amount)) $")
                .font(.headline)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.vertical, 4)
    }

    private func getBillingText(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "DUE TODAY"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "DUE TOMORROW"
        } else {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            return "DUE IN \(days) DAYS"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
