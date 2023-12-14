//
//  Source.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Source: Codable {
    let ancestry: Ancestry
    let title: String
    let subtitle: String
    let description: String?
    let meta_title: String
    let meta_description: String
    let cover_photo: Cover_photo
}

extension Source: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public static func == (lhs: Source, rhs: Source) -> Bool {
        return lhs.title == rhs.title
    }
}
