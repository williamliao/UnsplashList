//
//  Ancestry.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Ancestry: Codable {
    let type: Type
    let category: Category?
}

extension Ancestry: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
    
    public static func == (lhs: Ancestry, rhs: Ancestry) -> Bool {
        return lhs.type == rhs.type
    }
}
