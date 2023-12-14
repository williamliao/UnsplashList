//
//  SearchResults.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import Foundation

struct SearchResults: Codable,Hashable {
    let title:String
    let category: Category
    
    enum Category: Codable {
      case photos
      case collections
      case users
    }
    
    enum CodingKeys: CodingKey {
        case title, category
    }
    
    init(title: String, category: Category) {
        self.title = title
        self.category = category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(Category.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(category, forKey: .category)
    }
}

extension SearchResults: Equatable {
    static func == (lhs: SearchResults, rhs: SearchResults) -> Bool {
        return lhs.title == rhs.title
    }
}

extension SearchResults.Category: CaseIterable { }

extension SearchResults.Category: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
            case "Photos": self = .photos
            case "Collections": self = .collections
            case "Users": self = .users
            default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
            case .photos: return "Photos"
            case .collections: return "Collections"
            case .users: return "Users"
        }
    }
}
