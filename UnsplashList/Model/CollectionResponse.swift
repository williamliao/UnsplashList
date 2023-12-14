//
//  CollectionResponse.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import Foundation

struct CollectionResponse:Codable {
    let id:String
    let created_at: String?
    let updated_at: String?
    let width: Int
    let height: Int
    let color: String
    let blur_hash: String?
    let likes: Int?
    let liked_by_user: Bool
    let description: String?
    let user: User
    let current_user_collections: [Current_user_collections]?
    let urls: Urls
    let links: Links
}

extension CollectionResponse: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CollectionResponse, rhs: CollectionResponse) -> Bool {
        return lhs.id == rhs.id
    }
}
