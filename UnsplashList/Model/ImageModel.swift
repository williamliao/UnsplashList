//
//  ImageModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/7/3.
//

import Foundation

struct ImageModel: Identifiable, Codable, Sendable {
    let id: String
    let create_at: String?
    let updated_at: String?
    let name: String?
    let bio: String?
    let location: String?
    let likes: Int?
    var isFavorite: Bool
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
    let tags: String?
    let fileExtension: String?
    let service: String?
}
