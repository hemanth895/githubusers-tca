//
//  RepositoriesFeature.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RepositoriesFeature {
    
    @ObservableState
    struct State: Equatable {
        let userName: String
        var repositories: [Repository] = []
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    enum Action {
        case onAppear
        case repositoriesResponse(Result<[Repository], Error>)
    }
    
    @Dependency(\.gitHubAPI) var gitHubAPI
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    state.isLoading = true
                    state.errorMessage = nil
                    return .run { [username = state.userName] send in
                        await send(
                            .repositoriesResponse(
                                Result { try await gitHubAPI.fetchRepositories(username) }
                                )
                        )
                    }
                    
                case let .repositoriesResponse(.success(repositories)):
                    state.isLoading = false
                    state.repositories = repositories
                    return .none
                
                case let .repositoriesResponse(.failure(error)):    
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
            }
        }
    }
}
