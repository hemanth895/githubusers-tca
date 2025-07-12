//
//  SearchView.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import SwiftUI
import ComposableArchitecture



struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        NavigationStack { 
            VStack {
                SearchBar(
                    searchText: $store.searchText.sending(\.searchTextChanged),
                    onSearchButtonClicked: { store.send(.searchButtonTapped) }
                )
                
                if store.isLoading && store.users.isEmpty {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = store.errorMessage, store.users.isEmpty {
                    ErrorView(message: errorMessage) {
                        store.send(.searchButtonTapped)
                    }
                } else if store.users.isEmpty && !store.searchText.isEmpty && !store.isLoading {
                    EmptyStateView()
                } else if store.showingResults {
                    UsersList(
                        users: store.users,
                        isRefreshing: store.isRefreshing,
                        isLoadingMore: store.isLoadingMore,
                        canLoadMore: store.canLoadMore,
                        onUserTapped: { user in
                            store.send(.userTapped(user))
                        },
                        onRefresh: {
                            store.send(.refreshUsers)
                        },
                        onLoadMore: {
                            store.send(.loadMoreUsers)
                        }
                    )
                } else {
                    Spacer()
                }
                
                // Show error message as toast if users are present
                if let errorMessage = store.errorMessage, !store.users.isEmpty {
                    ErrorToast(message: errorMessage)
                }
            }
            .navigationTitle("Github Users")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $store.scope(state: \.destination?.userProfile, action: \.destination.userProfile)) { store in
                UserProfileView(store: store)
            }

        }
//        .fullScreenCover(item: $store.scope(state: \.destination?.userProfile, action: \.destination.userProfile)) { store in
//            UserProfileView(store: store)
//        }
    }
}

//MARK: - Search BAR
struct SearchBar: View {
    @Binding var searchText: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search Github Users...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button(action: onSearchButtonClicked) { 
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
            }
            .buttonStyle(.borderedProminent)
            .disabled(searchText.isEmpty)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

//MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 16){
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let onRetry = onRetry {
                Button("Retry") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//MARK: - Error Toast
struct ErrorToast: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

//MARK: - EmptyStateView
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16){
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Users Found")
                .font(.headline)
            
            Text("Try searching for different usernames")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - UsersList
struct UsersList: View {
    let users: [User]
    let isRefreshing: Bool
    let isLoadingMore: Bool
    let canLoadMore: Bool
    let onUserTapped: (User) -> Void
    let onRefresh: () -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        List {
            ForEach(users) { user in
                UserRow(user: user)
                    .onTapGesture { 
                        onUserTapped(user)
                    }
                    .onAppear {
                        // Trigger load more when approaching the end
                        if user.id == users.last?.id && canLoadMore {
                            onLoadMore()
                        }
                    }
            }
            
            // Load more indicator
            if isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            onRefresh()
        }
    }
}

//MARK: - UserRow
struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay { 
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) { 
                Text(user.login)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let name = user.name {
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("\(user.followers)", systemImage: "person.2")
                    Label("\(user.publicRepos)", systemImage: "folder")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
