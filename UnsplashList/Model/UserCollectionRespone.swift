//
//  UserCollectionRespone.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/29.
//

import Foundation

struct UserCollectionRespone:Codable {
    let id:String
    let title: String?
    let published_at: String?
    let last_collected_at: String?
    let updated_at: String?
    let total_photos: Int
    let privateKey: Bool?
    let share_key: String
    let cover_photo: Cover_Photo
    let description: String?
    let user: User
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case published_at
        case last_collected_at
        case total_photos
        case share_key
        case privateKey = "private"
        case cover_photo
        case description
        case user
        case links
        case updated_at
    }
}

extension UserCollectionRespone: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserCollectionRespone, rhs: UserCollectionRespone) -> Bool {
        return lhs.id == rhs.id
    }
}
