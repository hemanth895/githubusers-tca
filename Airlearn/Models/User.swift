//
//  User.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import Foundation

struct User: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let login: String
    let avatarURL: String
    let name: String?
    let bio: String?
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    let createdAt: String?
    let htmlURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, bio, followers, following
        case avatarURL = "avatar_url"
        case publicRepos = "public_repos"
        case createdAt = "created_at"
        case htmlURL = "html_url"
    }
}


struct UserSearchResult: Codable, Equatable, Sendable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
