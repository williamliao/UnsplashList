//
//  Profile_image.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Profile_image: Codable {
    let small: String
    let medium: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

extension Profile_image: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(small)
    }
    
    public static func == (lhs: Profile_image, rhs: Profile_image) -> Bool {
        return lhs.small == rhs.small
    }
}
