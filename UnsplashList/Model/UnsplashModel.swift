//
//  UnsplashModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import Foundation

class UnsplashModel: Identifiable, Codable {
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
    
    init(sponsorship: String?, id: String, created_at: String?, updated_at: String?, width: Int, height: Int, color: String, description: String?, alt_description: String?, urls: Urls, links: Links, categories: [Categories]?, likes: Int?, liked_by_user: Bool, current_user_collections: [Current_user_collections]?, user: User?, exif: Exif?, location: Location?, views: Int, downloads: Int, promoted_at: String?, blur_hash: String?, viewsCount: Int?, title: String?, published_at: String?, last_collected_at: String?, curated: Bool?, featured: Bool?, total_photos: Int?, privateKey: Bool?, share_key: String?, tags: Tags?, cover_photo: Cover_Photo?, preview_photos: Preview_Photos?) {
        self.sponsorship = sponsorship
        self.id = id
        self.created_at = created_at
        self.updated_at = updated_at
        self.width = width
        self.height = height
        self.color = color
        self.description = description
        self.alt_description = alt_description
        self.urls = urls
        self.links = links
        self.categories = categories
        self.likes = likes
        self.liked_by_user = liked_by_user
        self.current_user_collections = current_user_collections
        self.user = user
        self.exif = exif
        self.location = location
        self.views = views
        self.downloads = downloads
        self.promoted_at = promoted_at
        self.blur_hash = blur_hash
        self.viewsCount = viewsCount
        self.title = title
        self.published_at = published_at
        self.last_collected_at = last_collected_at
        self.curated = curated
        self.featured = featured
        self.total_photos = total_photos
        self.privateKey = privateKey
        self.share_key = share_key
        self.tags = tags
        self.cover_photo = cover_photo
        self.preview_photos = preview_photos
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
