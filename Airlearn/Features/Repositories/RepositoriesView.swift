//
//  RepositoriesView.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import SwiftUI
import ComposableArchitecture

struct RepositoriesView: View {
    
    @Bindable var store: StoreOf<RepositoriesFeature>
    
    var body: some View {
        NavigationStack { 
            Group {
                if store.isLoading {
                    ProgressView("Loading Repositories...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = store.errorMessage {
                    ErrorView(message: errorMessage)
                } else if store.repositories.isEmpty {
                    EmptyRepositoriesView()
                } else {
                    RepositoriesList(repositories: store.repositories)
                }
            }
            .navigationTitle("Repositories")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            store.send(.onAppear)
        }
    }
}

//MARK: - RepositoriesList

struct RepositoriesList: View {
    let repositories: [Repository]

    var body: some View {
        List(repositories){ repo in
            RepositoryRow(repository: repo)
        }
        .listStyle(PlainListStyle())
    }
}

//MARK: - RepositoryRow

struct RepositoryRow: View {
    let repository: Repository
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(repository.name)
                        .font(.headline)

                    Spacer()
                    
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                            .padding(.horizontal, 16)
                    }
                    
                }
                
                if let description = repository.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                
                HStack {
                    Label("\(repository.stargazersCount)", systemImage: "star")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(repository.forksCount)", systemImage: "tuningfork")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    
                    Spacer()
                    Spacer()



                }
                .padding(.vertical, 4)
                
            }
        }
    }
}

//MARK: - EmptyRepositoriesView

struct EmptyRepositoriesView: View {
    var body: some View {
        VStack {
            Image(systemName: "folder")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No repositories found.")
                .font(.headline)
            
            Text("This user doesn't have any public repositories")
                .font(.subheadline)
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}


//#Preview{
//    RepositoriesView(store: StoreOf<RepositoriesFeature>())
//}
