//
//  Danbooru.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import Foundation

struct Danbooru:Identifiable, Codable {
    let id: Int
    let created_at: Date
    let uploader_id: Int
    let score: Int?
    let source: String
    let md5: String?
    let last_comment_bumped_at: Date?
    let rating: String
    let image_width: Int
    let image_height: Int
    let tag_string: String
    let fav_count: Int?
    let file_ext: String
    let last_noted_at: String?
    let parent_id: Int?
    let has_children: Bool
    let approver_id: Int?
    let tag_count_general: Int?
    let tag_count_artist: Int?
    let tag_count_character: Int?
    let tag_count_copyright: Int?
    let file_size: Int
    let up_score: Int?
    let down_score: Int?
    let is_pending: Bool
    let is_flagged: Bool
    let is_deleted: Bool
    let tag_count: Int?
    let updated_at: Date?
    let is_banned: Bool
    let pixiv_id: Int?
    let last_commented_at: Date?
    let has_active_children: Bool
    let bit_flags: Int?
    let tag_count_meta: Int?
    let has_large: Bool
    let has_visible_children: Bool
    let media_asset: Media_asset?
    let tag_string_general: String
    let tag_string_character: String
    let tag_string_copyright: String
    let tag_string_artist: String
    let tag_string_meta: String
    let file_url: String
    let large_file_url: String
    let preview_file_url: String
}

struct Media_asset: Codable {
    let id: Int
    let created_at: Date
    let updated_at: Date?
    let md5: String?
    let file_ext: String
    let file_size: Int
    let image_width: Int
    let image_height: Int
    let duration: Int?
    let status: String
    let file_key: String?
    let is_public: Bool
    let pixel_hash: String
    let variants: [Variants]?
}

struct Variants: Codable {
    let type: String
    let url: String
    let width: Int
    let height: Int
    let file_ext: String
}
