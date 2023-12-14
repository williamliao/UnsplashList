//
//  UserProfileInfo.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import Foundation

struct UserProfileInfo:Codable {
    let id: UUID
    let name:String
    let userName:String
    let profile_image: Profile_image
}

extension UserProfileInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserProfileInfo: Equatable {
    static func == (lhs: UserProfileInfo, rhs: UserProfileInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
