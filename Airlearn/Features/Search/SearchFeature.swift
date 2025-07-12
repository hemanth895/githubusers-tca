//
//  SearchFeature.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import Foundation
import ComposableArchitecture

 enum CancelID: Hashable, Sendable {
    case search 
    case refresh
    case loadMore 
}


@Reducer
struct SearchFeature {
    
    @ObservableState
    struct State: Equatable {
        var searchText = ""
        var users: [User] = []
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var isLoadingMore: Bool = false
        var currentPage: Int = 1
        var totalCount: Int = 0
        var hasMorePages: Bool = true
        var errorMessage: String?
        @Presents var destination: Destination.State?
        
        var canLoadMore: Bool {
            !isLoading && !isLoadingMore && hasMorePages && !users.isEmpty
        }
        
        var showingResults: Bool {
            !users.isEmpty || isLoading || isRefreshing
        }

        
    }
    
    @CasePathable
    enum Action {
        case searchTextChanged(String)
        case searchButtonTapped
        case refreshUsers
        case loadMoreUsers
        case userTapped(User)
        case searchResponse(Result<UserSearchResult, Error>)
        case refreshResponse(Result<UserSearchResult, Error>)
        case loadMoreResponse(Result<UserSearchResult, Error>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case userProfile(UserProfileFeature)
    }
    
    @Dependency(\.gitHubAPI) var gitHubAPI
    
    var body: some Reducer<State, Action>{
        Reduce { state, action in
            switch action {
                case .searchTextChanged(let text):
                    state.searchText = text
                    state.currentPage = 1
                    state.hasMorePages = true
                    state.totalCount = 0
                    if text.isEmpty {
                        state.users = []
                        return .cancel(id: "search")
                    }
                    return .none
                    
                case .searchButtonTapped:
                    guard !state.searchText.isEmpty else { return .none }
                    state.isLoading = true
                    state.errorMessage = nil
                    state.currentPage = 1
                    state.hasMorePages = true
                    return .run { [searchText = state.searchText] send in
                        await send(.searchResponse(
                            Result { try await gitHubAPI.searchUsers(searchText,1 , 30)}
                        ))
                    }
                    .cancellable(id: "search")
                    
                case .refreshUsers:
                    guard !state.searchText.isEmpty else { return .none }
                    state.isRefreshing = true
                    state.errorMessage = nil
                    state.currentPage = 1
                    return .run { [searchText = state.searchText] send in
                        await send(.refreshResponse(
                            Result { try await gitHubAPI.searchUsers(searchText, 1, 30)}
                        ))
                    }
                    .cancellable(id: "refresh")
                    
                case .loadMoreUsers:
                    guard state.canLoadMore else { return .none }
                    state.isLoadingMore = true
                    state.errorMessage = nil
                    let nextPage = state.currentPage + 1
                    return .run { [searchText = state.searchText] send in
                        await send(.loadMoreResponse(
                            Result { try await gitHubAPI.searchUsers(searchText, nextPage, 30)}
                        ))
                    }
                    .cancellable(id: "loadMore")

                case let .searchResponse(.success(result)):
                    state.isLoading = false
                    state.users = result.items
                    return .none
                    
                case let .searchResponse(.failure(error)):
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
                    
                case let .userTapped(user):
                    guard user.id > 0 else { return .none }
                    let userProfileState = UserProfileFeature.State(user: user)
                    state.destination = .userProfile(userProfileState)
                    return .none
                    
                case let .refreshResponse(.success(result)):
                    state.isRefreshing = false
                    state.users = result.items
                    state.totalCount = result.totalCount
                    state.currentPage = 1
                    state.hasMorePages = result.items.count == 30 && state.users.count < result.totalCount
                    return .none
                    
                case let .refreshResponse(.failure(error)):
                    state.isRefreshing = false
                    state.errorMessage = error.localizedDescription
                    return .none
                    
                case let .loadMoreResponse(.success(result)):
                    state.isLoadingMore = false
                    state.users.append(contentsOf: result.items)
                    state.currentPage += 1
                    state.hasMorePages = result.items.count == 30 && state.users.count < state.totalCount
                    return .none
                    
                case let .loadMoreResponse(.failure(error)):
                    state.isLoadingMore = false
                    state.errorMessage = error.localizedDescription
                    return .none

                case .destination:
                    return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
