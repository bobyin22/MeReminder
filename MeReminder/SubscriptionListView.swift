import SwiftUI

struct SubscriptionService: Identifiable {
    let id = UUID()
    let name: String
    let icon: Image
}

struct SubscriptionListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedService: SubscriptionService?
    @State private var showingDetail = false
    @Binding var selectedTab: Int
    
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
        ZStack {
            VStack(spacing: 20) {
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
                .padding(.horizontal)
                
                // Subscription List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredServices) { service in
                            NavigationLink(destination: SubscriptionDetailView(service: service, selectedTab: $selectedTab)) {
                                HStack {
                                    service.icon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    
                                    Text(service.name)
                                        .font(.title3)
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Subscription")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: selectedTab) { newValue in
            if newValue == 0 {
                dismiss()
            }
        }
    }
} 
