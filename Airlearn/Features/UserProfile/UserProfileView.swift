//
//  UserProfileView.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import SwiftUI
import ComposableArchitecture

struct UserProfileView: View {
    @Bindable var store: StoreOf<UserProfileFeature>
    
    var body: some View {
        NavigationStack { 
            ScrollView {
                VStack(spacing: 20){
                    ProfileHeader(user: store.deatileduser ?? store.user)
                    
                    
                    if store.isLoadingUser {
                        ProgressView()
                    } else if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    ProfileStats(user: store.deatileduser ?? store.user)
                    
                    Button(action: { store.send(.repositoriesButtonTapped) }) { 
                        HStack {
                            Image(systemName: "folder")
                            Text("View Repositories")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.destination?.repositories, action: \.destination.repositories)){ store in
            RepositoriesView(store: store)
        }
    }
}


// MARK: - ProfileHeader

struct ProfileHeader: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16){
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay { 
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            
            VStack(spacing: 8){
                Text(user.login)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let name = user.name {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
            }
            
        }
        .padding()
    }
}

//MARK: - ProfileStats

struct ProfileStats: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 30){
            StatItem(label: "Followers", value: "\(user.followers ?? 0)")
            StatItem(label: "Following", value: "\(user.following ?? 0)")
            StatItem(label: "Repositories", value: "\(user.publicRepos ?? 0)")
        }
        .padding()
    }
}

//MARK: - StatItem

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4){
            Text(label)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
        
        }
    }
}
