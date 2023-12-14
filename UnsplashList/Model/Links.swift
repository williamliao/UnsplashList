//
//  Links.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Links: Codable {
    let selfLink: String?
    let html: String?
    let photos: String?
    let download : String?
    let likes: String?
    let portfolio: String?
    let following: String?
    let followers: String?
    let download_location: String?
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html
        case photos
        case likes
        case portfolio
        case following
        case followers
        case download
        case download_location
    }
}

extension Links: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(selfLink)
        hasher.combine(html)
        hasher.combine(photos)
        hasher.combine(download)
        hasher.combine(likes)
        hasher.combine(portfolio)
        hasher.combine(following)
        hasher.combine(followers)
        hasher.combine(download_location)
    }
}

extension Links: Equatable {
    static func == (lhs: Links, rhs: Links) -> Bool {
        return lhs.selfLink == rhs.selfLink && lhs.html == rhs.html && lhs.photos == rhs.photos && lhs.download == rhs.download && lhs.likes == rhs.likes && lhs.portfolio == rhs.portfolio && lhs.following == rhs.following && lhs.followers == rhs.followers && lhs.download_location == rhs.download_location
    }
}
