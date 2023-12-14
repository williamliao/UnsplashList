//
//  Current_user_contributions.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

struct Current_user_contributions: Codable {
    let id: String
    let title: String
    let published_at: String
    let last_collected_at: String
    let updated_at: String
    let cover_photo: Cover_Photo
    let user: User
}
