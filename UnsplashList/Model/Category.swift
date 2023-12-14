//
//  Category.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Category: Codable {
    let slug: String
    let pretty_slug: String
}

extension Category: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
    
    public static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.slug == rhs.slug
    }
}
