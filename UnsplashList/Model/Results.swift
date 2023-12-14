//
//  Results.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Results: Codable, Identifiable {
    let id: String
    let created_at: String?
    let published_at: String?
    let last_collected_at: String?
    let updated_at: String
    let share_key: String?
    let featured: Bool?
    let width: Int?
    let height: Int?
    let color: String?
    let description: String?
    let alt_description: String?
    let total_photos: NSInteger?
    let privateKey: Bool?
    let urls: Urls?
    let links: Links?
    let categories: [Categories]?
    let likes: Int?
    let liked_by_user: Bool?
    let current_user_collections: [Current_user_collections]?
    let user: User?
    let tags: [Tags]?
    let blur_hash: String?
    let promoted_at: String?
    let sponsorship: Sponsorship?
    let cover_photo: Cover_photo?
    let preview_photos: [Preview_Photos]?
    let username: String?
    let name: String?
    let first_name: String?
    let last_name: String?
    let twitter_username: String?
    let instagram_username: String?
    let portfolio_url: String?
    let bio: String?
    let location: String?
    let profile_image: Profile_image?
    let total_collections: NSInteger?
    let total_likes: Int?
    let accepted_tos: Bool?
    let for_hire: Bool?
    let followed_by_user: Bool?
    let photos: [Photos]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case created_at
        case published_at
        case last_collected_at
        case updated_at
        case featured
        case width
        case height
        case color
        case description
        case alt_description
        case total_photos
        case privateKey = "private"
        case urls
        case links
        case categories
        case likes
        case liked_by_user
        case current_user_collections
        case user
        case tags
        case blur_hash
        case promoted_at
        case sponsorship
        case share_key
        case cover_photo
        case username
        case name
        case first_name
        case last_name
        case twitter_username
        case instagram_username
        case portfolio_url
        case bio
        case location
        case profile_image
        case total_collections
        case total_likes
        case accepted_tos
        case for_hire
        case followed_by_user
        case photos
        case preview_photos
    }
}

struct Sponsorship: Codable {
    let tagline_url: String?
    let sponsor: Sponsor?
    let impression_urls: [URL]?
    let tagline: String?
}

struct Sponsor: Codable {
    let id: String
    let total_photos: NSInteger
    let for_hire: Bool
    let twitter_username: String?
    let instagram_username: String?
    let portfolio_url: String?
    let bio: String?
    let accepted_tos: Bool
    let location: String?
    let first_name: String?
    let updated_at: String
    let username: String
    let link: Links?
    let profile_image: Profile_image
    let last_name: String?
    let name: String?
    let total_likes: NSInteger
    let total_collections: NSInteger
}

extension Sponsor: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Sponsor, rhs: Sponsor) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Results: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Results, rhs: Results) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Cover_Photo:Codable {
    let id: String
    let created_at: String
    let width: Int
    let height: Int
    let color: String
    let blur_hash: String?
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let user: User
    let url: Urls
    let links: Links
}

struct Photos: Codable {
    let id: String
    let created_at: String
    let updated_at: String
    let blur_hash: String
    let urls: Urls
}
