//
//  Topic.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

struct Topic: Codable, Identifiable {
    let id: String
    let slug: String
    let title: String
    let description: String
    let published_at: String
    let updated_at: String
    let starts_at: String
    let end_at: String?
    let featured: Bool
    let total_photos: Int
    let links: Links
    let status: String
    let owners: [Owners]?
    let current_user_contributions: [Current_user_contributions]?
    let total_current_user_submissions: Total_current_user_submissions?
    let cover_photo: Cover_photo
    let preview_photos: [Preview_Photos]
}

extension Topic: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Topic: Equatable {
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
    }
}
