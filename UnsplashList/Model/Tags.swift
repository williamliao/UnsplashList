//
//  Tags.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Tags: Codable {
    let type: String
    let title: String
    let source: Source?
}

extension Tags: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public static func == (lhs: Tags, rhs: Tags) -> Bool {
        return lhs.title == rhs.title
    }
}
