//
//  AlbumItem.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import Foundation

class AlbumItem: Codable, Hashable {
    var identifier = UUID()
    let albumURL: URL
    let ownerTitle: String
    let ownerURL: URL
    let albumTitle: String
    let imageItems: [AlbumDetailItem]
    let isLandscape: Bool

    init(albumTitle: String, albumURL: URL, ownerTitle: String, ownerURL: URL, isLandscape: Bool, imageItems: [AlbumDetailItem] = []) {
        self.albumURL = albumURL
        self.albumTitle = albumTitle
        self.imageItems = imageItems
        self.isLandscape = isLandscape
        self.ownerURL = ownerURL
        self.ownerTitle = ownerTitle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class AlbumDetailItem:Codable, Hashable {
    var identifier: String
    let title: String
    let photoURL: URL
    let thumbnailURL: URL
    let subitems: [AlbumDetailItem]
    let profile_image: Profile_image
    let urls: Urls

    init(identifier: String, title: String, photoURL: URL, thumbnailURL: URL, profile_image: Profile_image, urls: Urls, subitems: [AlbumDetailItem] = []) {
        self.photoURL = photoURL
        self.thumbnailURL = thumbnailURL
        self.subitems = subitems
        self.profile_image = profile_image
        self.urls = urls
        self.identifier = identifier
        self.title = title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: AlbumDetailItem, rhs: AlbumDetailItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
