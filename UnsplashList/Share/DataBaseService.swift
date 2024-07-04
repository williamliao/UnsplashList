//
//  DataBaseService.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/7/3.
//

import Foundation

import Foundation
import Supabase
#if canImport(UIKit)
import UIKit
#else
import Cocoa
import SwiftUI
#endif

@Observable
class DataBaseService {
    
    @MainActor static let shared = DataBaseService()
    
    private var keysPlist: Dictionary<String, Any> {
        
        let path = NSString(string: "~/api.plist").expandingTildeInPath
        
        if let fileData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            if let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainers, format: nil) as? Dictionary<String, Any> {
                let dictionary = plist.compactMapValues { $0 }
                return dictionary
            }
        }
        fatalError("You must have a Keys.plist file in your application codebase.")
    }
    
    private var apiKey: String {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: keysPlist, options: .prettyPrinted)
        let decoder = JSONDecoder()

        guard let jsonData = jsonData else {
            fatalError("Your Keys.plist data is nil")
        }
        
        let result = try? decoder.decode(APIData.self, from: jsonData)
        
        guard let apiKey = result?.dataBaseKey else {
            fatalError("Your Keys.plist data is nil")
        }
        
        return apiKey
    }

    var supabaseUrl: URL {
        let jsonData = try? JSONSerialization.data(withJSONObject: keysPlist, options: .prettyPrinted)
        let decoder = JSONDecoder()

        guard let jsonData = jsonData else {
            fatalError("Your Keys.plist data is nil")
        }
        
        let result = try? decoder.decode(APIData.self, from: jsonData)
        
        guard let url = result?.dataBaseUrl else {
            fatalError("Your Keys.plist data is nil")
        }
        
        return URL(string: url)!
    }
    
    var supabaseClient: SupabaseClient!
    var items = [ImageModel]()

    init() {
        supabaseClient = SupabaseClient(supabaseURL: self.supabaseUrl, supabaseKey: self.apiKey)
    }
    
    func storageClient(bucketName: String = "photos") async -> StorageFileApi? {
        guard let jwt = try? await supabaseClient.auth.session.accessToken else { return nil}
        return SupabaseStorageClient(
            configuration: .init(url: URL(string: "\(supabaseUrl)/storage/v1")!,
            headers: [
                "Authorization": "Bearer \(jwt)",
                "apikey": apiKey,
            ], encoder: JSONEncoder(), decoder: JSONDecoder(), session: .init(session: URLSession.shared), logger: nil)
        ).from(bucketName)
    }
  
    func updateImage(item: UnsplashModel) async {
        guard let url = URL(string: item.raw!) else {
            return
        }
        
        let filename = url.lastPathComponent
        
        let storageClient = await DataBaseService.shared.storageClient()
        guard let uploadResponseData = try? await storageClient?.upload(
            path: "\(item.id)/\(filename)",
                file: Data()
            ) else { return }
    }
    
    func downloadImage(item: UnsplashModel) async {
        
        guard let url = item.raw else {
            return
        }

        if let data = try? await DataBaseService.shared.storageClient()?.download(
            path: url
        ) {
            let image = ImageRepresentable(data: data)
        }
        
    }

    func saveModel(item: ImageModel) async {
        do {

          try await supabaseClient
            .from("saveimages")
            .insert(item)
            .execute()

        } catch {
            debugPrint("saveModel \(error)")
        }
    }
    
    func fetchModel() async -> [ImageModel] {
        do {
            
            items = try await supabaseClient
                   .from("saveimages")
                   .select()
                   .execute()
                   .value

            return items
          
        } catch {
            debugPrint("fetchModel \(error)")
            
            return items
        }
    }
    
    func removeModel(item: ImageModel) async {
        do {
            try await supabaseClient
                .from("saveimages")
                .delete()
                .eq("id", value: item.id)
                .execute()
        } catch  {
            debugPrint("removeModel \(error)")
        }
    }
}

