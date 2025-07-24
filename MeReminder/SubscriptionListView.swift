import SwiftUI

struct SubscriptionService: Identifiable {
    let id = UUID()
    let name: String
    let icon: Image
}

struct SubscriptionListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @Binding var selectedTab: Int
    @State private var showingDetail = false
    @State private var selectedService: SubscriptionService?
    
    let subscriptionServices: [SubscriptionService] = [
        SubscriptionService(name: "1Password", icon: Image(systemName: "lock.fill")),
        SubscriptionService(name: "Adobe XD", icon: Image(systemName: "paintbrush.fill")),
        SubscriptionService(name: "Aha", icon: Image(systemName: "video.fill")),
        SubscriptionService(name: "Airtel", icon: Image(systemName: "antenna.radiowaves.left.and.right")),
        SubscriptionService(name: "Albert Heijn", icon: Image(systemName: "cart.fill")),
        SubscriptionService(name: "Amazon", icon: Image(systemName: "cart.fill")),
        SubscriptionService(name: "Amazon AWS", icon: Image(systemName: "cloud.fill")),
        SubscriptionService(name: "Amazon Prime", icon: Image(systemName: "play.fill")),
        SubscriptionService(name: "American Express", icon: Image(systemName: "creditcard.fill"))
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredServices) { service in
                        Button {
                            selectedService = service
                            showingDetail = true
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
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Add Subscription")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDetail) {
            if let service = selectedService {
                NavigationStack {
                    SubscriptionDetailView(service: service, selectedTab: $selectedTab)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissToRoot"))) { _ in
            showingDetail = false
            dismiss()
        }
    }
} 
