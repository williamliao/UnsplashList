//
//  User.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct User: Codable, Identifiable {
   
    let id: String
    let updated_at: String
    let username: String
    let name: String
    let first_name: String
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: String?
    let bio: String?
    let location: String?
    let links: Links
    let profile_image: Profile_image
    let instagram_username: String?
    let total_collections: Int
    let total_likes: Int
    let total_photos: Int
    let accepted_tos: Bool
    let for_hire: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case updated_at
        case username
        case name
        case first_name
        case last_name
        case twitter_username
        case portfolio_url
        case bio
        case location
        case links
        case profile_image
        case instagram_username
        case total_collections
        case total_photos
        case total_likes
        case accepted_tos
        case for_hire
    }
}

extension User: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
