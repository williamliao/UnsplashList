//
//  UnsplashModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import Foundation

struct UnsplashModel: Identifiable, Codable, @unchecked Sendable {
    let id: String
    let user: User?
    let exif: Exif?
    let location: Location?
    var isFavorite: Bool
    var preview_url: String?
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
    let tags: String?
    let fileExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case exif
        case location
        case isFavorite
        case preview_url
        case raw
        case full
        case regular
        case small
        case thumb
        case tags
        case fileExtension
    }
    
    init(id: String, user: User?, exif: Exif?, location: Location?, isFavorite: Bool = false, preview_url: String? = nil, raw: String?, full: String?, regular: String?, small: String?, thumb: String?, tags: String?, fileExtension: String?) {
        self.id = id
        self.user = user
        self.exif = exif
        self.location = location
        self.isFavorite = isFavorite
        self.preview_url = preview_url
        self.raw = raw
        self.full = full
        self.regular = regular
        self.small = small
        self.thumb = thumb
        self.tags = tags
        self.fileExtension = fileExtension
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
