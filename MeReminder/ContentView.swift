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
    @State private var currentDate = Date()
    @State private var showingDeleteAlert = false
    @State private var subscriptionToDelete: Subscription?
    @State private var showingDetail = false
    @State private var selectedSubscription: Subscription?
    
    var totalAmount: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Overview Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("July")
                            .font(.title2)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.3))
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        Text("2025")
                            .font(.title2)
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
                        icon: Image(systemName: subscription.icon)
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
                
                Text(getDueText(date: subscription.dueDate))
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
    
    private func getDueText(date: Date) -> String {
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
