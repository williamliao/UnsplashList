//
//  Yande.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/8.
//

import Foundation

struct Approver_id: Codable {
}

struct Frames_pending: Codable {
}

struct Frames: Codable {
}

struct Parent_id: Codable {
}

struct Yande:Identifiable, Codable {
    let id: Int
    let tags: String
    let created_at: Int
    let updated_at: Int
    let creator_id: Int
    let approver_id: Approver_id
    let author: String
    let change: Int
    let source: String
    let score: Int
    let md5: String
    let file_size: Int
    let file_ext: String
    let file_url: String
    let is_shown_in_index: Bool
    let preview_url: String
    let preview_width: Int
    let preview_height: Int
    let actual_preview_width: Int
    let actual_preview_height: Int
    let sample_url: String
    let sample_width: Int
    let sample_height: Int
    let sample_file_size: Int
    let jpeg_url: String
    let jpeg_width: Int
    let jpeg_height: Int
    let jpeg_file_size: Int
    let rating: String
    let is_rating_locked: Bool
    let has_children: Bool
    let parent_id: Parent_id
    let status: String
    let is_pending: Bool
    let width: Int
    let height: Int
    let is_held: Bool
    let frames_pending_string: String
    let frames_pending: [String]
    let frames_string: String
    let frames: [String]
    let is_note_locked: Bool
    let last_noted_at: Int
    let last_commented_at: Int
}

struct YandePost: Codable {
    let posts: [Yande]
}
