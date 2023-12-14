//
//  Location.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Location: Codable {
    let title: String?
    let name: String?
    let city: String?
    let country: String?
    let position: Position
}

extension Location: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(name)
        hasher.combine(city)
        hasher.combine(country)
        hasher.combine(position)
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.title == rhs.title && lhs.name == rhs.name && lhs.city == rhs.city && lhs.country == rhs.country && lhs.position == rhs.position
    }
}
