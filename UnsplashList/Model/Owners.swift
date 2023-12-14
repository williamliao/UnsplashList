//
//  Owners.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

struct Owners: Codable {
    let id: String
    let updated_at: String
    let username: String
    let name: String
    let first_name: String?
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: String
    let bio: String?
    let location: String
    let links: Links
    let profile_image: Profile_image
    let instagram_username: String?
    let total_collections: Int
    let total_likes : Int
    let total_photos: Int
    let accepted_tos: Bool
    let for_hire: Bool
}

extension Owners: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Owners: Equatable {
    static func == (lhs: Owners, rhs: Owners) -> Bool {
        return lhs.id == rhs.id
    }
}
