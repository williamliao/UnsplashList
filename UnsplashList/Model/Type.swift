//
//  Type.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Type: Codable {
    let slug: String
    let pretty_slug: String
}

extension Type: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
    
    public static func == (lhs: Type, rhs: Type) -> Bool {
        return lhs.slug == rhs.slug
    }
}
