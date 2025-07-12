//
//  UserProfileFeature.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct UserProfileFeature {
    
    @ObservableState
    struct State: Equatable {
        var user: User
        var deatileduser: User?
        var isLoadingUser = false
        var errorMessage: String?
        @Presents var destination: Destination.State?
    }
    
    @CasePathable
    enum Action {
        case onAppear
        case repositoriesButtonTapped
        case userDetailedresponse(Result<User, Error>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case repositories(RepositoriesFeature)
    }
    
    
    @Dependency(\.gitHubAPI) var gitHubAPI
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    state.isLoadingUser = true
                    state.errorMessage = nil
                    return .run { [username = state.user.login] send in
                        await send(.userDetailedresponse(
                            Result {
                                try await gitHubAPI.fetchUser(username)
                            }
                        ))
                    }
                    
                case .repositoriesButtonTapped:
                    state.destination = .repositories(
                        RepositoriesFeature.State(userName: state.user.login)
                    )
                    return .none

                case let .userDetailedresponse(.success(result)):
                    state.isLoadingUser = false
                    state.deatileduser = result
                    return .none
                    
                case let .userDetailedresponse(.failure(error)):
                    state.isLoadingUser = false
                    state.errorMessage = error.localizedDescription
                    return .none
                    
                case .destination:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)  // Added destination handling        
    }
}
