//
//  UnsplashModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import Foundation

class UnsplashModel: Identifiable, Codable {
    let id: String
    let urls: Urls?
    let user: User?
    let exif: Exif?
    let location: Location?
    var isFavorite: Bool
    
    init(id: String, urls: Urls?, user: User?, exif: Exif?, location: Location?, isFavorite: Bool = false) {
        self.id = id
        self.urls = urls
        self.user = user
        self.exif = exif
        self.location = location
        self.isFavorite = isFavorite
    }
}

extension UnsplashModel: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UnsplashModel, rhs: UnsplashModel) -> Bool {
        return lhs.id == rhs.id
    }
}
