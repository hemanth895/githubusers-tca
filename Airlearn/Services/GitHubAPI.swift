//
//  GitHubAPI.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import Foundation
import ComposableArchitecture

import Foundation

// Custom error types for better error handling
enum GitHubAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case networkError(Error)
    case serverError(statusCode: Int)
    case rateLimitExceeded
    case userNotFound
    case repositoriesNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .userNotFound:
            return "User not found"
        case .repositoriesNotFound:
            return "Repositories not found for this user"
        }
    }
}

// MARK: - Debug Helper Extension
extension GitHubAPIError {
    static func debugDecodingError(_ data: Data, _ error: Error) -> GitHubAPIError {
        print("=== DECODING ERROR DEBUG ===")
        print("Error: \(error)")
        
        // Print raw JSON for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response (first 1000 characters):")
            print(String(jsonString.prefix(1000)))
        }
        
        // Try to decode as generic JSON to see structure
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("JSON parsed successfully - structure looks valid")
            
            // If it's a dictionary, print the keys
            if let dict = json as? [String: Any] {
                print("Top-level keys: \(dict.keys)")
            }
        } catch {
            print("Failed to parse as JSON: \(error)")
        }
        
        return .decodingFailed(error)
    }
}


struct GitHubAPI {
    var searchUsers: @Sendable (String, Int, Int) async throws -> UserSearchResult
    var fetchUser: @Sendable (String) async throws -> User
    var fetchRepositories: @Sendable (String) async throws -> [Repository]
}

extension GitHubAPI: DependencyKey {
    static let liveValue = GitHubAPI(
        searchUsers: { username, page, perpage in
            guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://api.github.com/search/users?q=\(encodedUsername)&page=\(page)&per_page=\(perpage)") else {
                throw GitHubAPIError.invalidURL
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        break // Success
                    case 403:
                        throw GitHubAPIError.rateLimitExceeded
                    case 404:
                        throw GitHubAPIError.userNotFound
                    default:
                        throw GitHubAPIError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                guard !data.isEmpty else {
                    throw GitHubAPIError.noData
                }
                
                do {
                    
                    return try JSONDecoder().decode(UserSearchResult.self, from: data)
                } catch {
                    throw GitHubAPIError.debugDecodingError(data, error)
                }
            } catch let error as GitHubAPIError {
                throw error
            } catch {
                throw GitHubAPIError.networkError(error)
            }
        },
        fetchUser: { username in
            guard let url = URL(string: "https://api.github.com/users/\(username)") else {
                throw GitHubAPIError.invalidURL
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        break // Success
                    case 403:
                        throw GitHubAPIError.rateLimitExceeded
                    case 404:
                        throw GitHubAPIError.userNotFound
                    default:
                        throw GitHubAPIError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                guard !data.isEmpty else {
                    throw GitHubAPIError.noData
                }
                
                do {
                    return try JSONDecoder().decode(User.self, from: data)
                } catch {
                    throw GitHubAPIError.decodingFailed(error)
                }
            } catch let error as GitHubAPIError {
                throw error
            } catch {
                throw GitHubAPIError.networkError(error)
            }
        },
        fetchRepositories: { username in
            guard let url = URL(string: "https://api.github.com/users/\(username)/repos?sort=stars&per_page=30") else {
                throw GitHubAPIError.invalidURL
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        break // Success
                    case 403:
                        throw GitHubAPIError.rateLimitExceeded
                    case 404:
                        throw GitHubAPIError.repositoriesNotFound
                    default:
                        throw GitHubAPIError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                guard !data.isEmpty else {
                    throw GitHubAPIError.noData
                }
                
                do {
                    return try JSONDecoder().decode([Repository].self, from: data)
                } catch {
                    throw GitHubAPIError.decodingFailed(error)
                }
            } catch let error as GitHubAPIError {
                throw error
            } catch {
                throw GitHubAPIError.networkError(error)
            }
        }
    )
}

extension DependencyValues {
    var gitHubAPI: GitHubAPI {
        get { self[GitHubAPI.self] }
        set { self[GitHubAPI.self] = newValue }
    }
}
