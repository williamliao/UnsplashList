//
//  Response.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation
#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

struct Response: Codable, Identifiable {
    let sponsorship: String?
    let id: String
    let created_at: String?
    let updated_at: String?
    let width: Int
    let height: Int
    let color: String
    let description: String?
    let alt_description: String?
    let urls: Urls
    let links: Links
    let categories: [Categories]?
    let likes: Int?
    let liked_by_user: Bool
    let current_user_collections: [Current_user_collections]?
    let user: User?
    let exif: Exif?
    let location: Location?
    let views: Int
    let downloads: Int
    let promoted_at: String?
    let blur_hash: String?
    let viewsCount: Int?
    let title: String?
    let published_at: String?
    let last_collected_at: String?
    let curated: Bool?
    let featured: Bool?
    let total_photos: Int?
    let privateKey: Bool?
    let share_key: String?
    let tags: Tags?
    let cover_photo: Cover_Photo?
    let preview_photos: Preview_Photos?
    
    enum CodingKeys: String, CodingKey {
        case sponsorship
        case id
        case created_at
        case updated_at
        case width
        case height
        case color
        case description
        case alt_description
        case urls
        case links
        case categories
        case likes
        case liked_by_user
        case current_user_collections
        case user
        case exif
        case location
        case views
        case downloads
        case promoted_at
        case blur_hash
        case viewsCount
        case title
        case published_at
        case last_collected_at
        case curated
        case featured
        case total_photos
        case privateKey = "private"
        case share_key
        case tags
        case cover_photo
        case preview_photos
    }

    var imageRatio: CGFloat {
        return CGFloat(height) / CGFloat(width)
    }
    
    var author: String? {
        return user?.name
    }
    
    var smallSizedImageUrl: String {
        return urls.small
    }
    
    var thumbnailSizedImageUrl: String {
        return urls.thumb
    }
}

extension Response: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Response: Equatable {
    static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.id == rhs.id
    }
}
