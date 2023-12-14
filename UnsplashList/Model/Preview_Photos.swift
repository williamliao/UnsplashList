//
//  Preview_Photos.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

struct Preview_Photos:Codable {
    let id: String
    let created_at: String
    let updated_at: String
    let blur_hash: String
    let urls: Urls
}

extension Preview_Photos: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Preview_Photos: Equatable {
    static func == (lhs: Preview_Photos, rhs: Preview_Photos) -> Bool {
        return lhs.id == rhs.id
    }
}
