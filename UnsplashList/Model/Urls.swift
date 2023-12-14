//
//  Urls.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Urls: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

extension Urls: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(raw)
        hasher.combine(full)
        hasher.combine(regular)
        hasher.combine(small)
        hasher.combine(thumb)
    }
}

extension Urls: Equatable {
    static func == (lhs: Urls, rhs: Urls) -> Bool {
        return lhs.raw == rhs.raw && lhs.full == rhs.full && lhs.regular == rhs.regular && lhs.small == rhs.small && lhs.thumb == rhs.thumb
    }
}
