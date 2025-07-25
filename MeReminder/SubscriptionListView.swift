import SwiftUI

struct SubscriptionService: Identifiable {
    let id = UUID()
    let name: String
    let systemName: String
    
    var icon: Image {
        Image(systemName: systemName)
    }
}

struct SubscriptionListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @Binding var selectedTab: Int
    @State private var showingDetail = false
    @State private var selectedService: SubscriptionService?
    
    let subscriptionServices: [SubscriptionService] = [
        SubscriptionService(name: "1Password", systemName: "lock.fill"),
        SubscriptionService(name: "Adobe XD", systemName: "paintbrush.fill"),
        SubscriptionService(name: "Aha", systemName: "video.fill"),
        SubscriptionService(name: "Airtel", systemName: "antenna.radiowaves.left.and.right"),
        SubscriptionService(name: "Albert Heijn", systemName: "cart.fill"),
        SubscriptionService(name: "Amazon", systemName: "cart.fill"),
        SubscriptionService(name: "Amazon AWS", systemName: "cloud.fill"),
        SubscriptionService(name: "Amazon Prime", systemName: "play.fill"),
        SubscriptionService(name: "American Express", systemName: "creditcard.fill")
    ]
    
    var filteredServices: [SubscriptionService] {
        if searchText.isEmpty {
            return subscriptionServices
        }
        return subscriptionServices.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .padding()
            
            // Subscription List
            List {
                ForEach(filteredServices) { service in
                    Button {
                        withAnimation {
                            selectedService = service
                            showingDetail = true
                        }
                    } label: {
                        HStack {
                            service.icon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                            
                            Text(service.name)
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Add Subscription")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDetail) {
            if let service = selectedService {
                NavigationStack {
                    SubscriptionDetailView(
                        service: service,
                        selectedTab: $selectedTab
                    )
                }
            }
        }
        .onChange(of: showingDetail) { oldValue, newValue in
            if !newValue {
                selectedService = nil
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 0 {
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissToRoot"))) { _ in
            dismiss()
        }
    }
} 

