//
//  Exif.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Exif: Codable {
    let make: String?
    let model: String?
    let exposure_time: String?
    let aperture: String?
    let focal_length: String?
    let iso: Int?
    
    enum CodingKeys: String, CodingKey {
        case make
        case model
        case exposure_time
        case aperture
        case focal_length
        case iso
    }
}

extension Exif: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(make)
        hasher.combine(model)
        hasher.combine(exposure_time)
        hasher.combine(aperture)
        hasher.combine(focal_length)
        hasher.combine(iso)
    }
}
extension Exif: Equatable {
    static func == (lhs: Exif, rhs: Exif) -> Bool {
        return lhs.make == rhs.make && lhs.model == rhs.model && lhs.exposure_time == rhs.exposure_time && lhs.aperture == rhs.aperture && lhs.focal_length == rhs.focal_length && lhs.iso == rhs.iso
    }
}
