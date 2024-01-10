//
//  DownloadManager.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/10.
//

import Foundation
import SwiftUI

final class DownloadManager: NetworkManager, ObservableObject  {
    @Published var isDownloading = false
    @Published var isDownloaded = false
    private var loadingTask: Task<Void, Error>?
    
    override init(endPoint: NetworkManager.NetworkEndpoint = .random, withSession session: Networking = urlSession()) {
        super.init(withSession: session)
    }
    
    deinit {
        loadingTask?.cancel()
    }
    
    func downloadFile(at url: URL) {
        isDownloading = true
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = url.pathExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension)")
        
        if let destinationUrl = destinationUrl {
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("File already exists")
                isDownloading = false
            }
       } else {
           
           guard let destinationUrl = destinationUrl else {
               return
           }
           
           let urlRequest = URLRequest(url: url)
           
           guard loadingTask == nil else {
               return
           }
           
           loadingTask = Task {
               
               do {
                   let result = try await self.data(for: urlRequest)
                   
                   switch result {
                   case .success(let imageData):
                       
                       try imageData.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                       DispatchQueue.main.async {
                           self.isDownloading = false
                       }
                       
                   case .failure(let error):
                       print("Error decoding: ", error)
                       self.isDownloading = false
                   }
                   
               } catch {
                   print("Error decoding: ", error)
                   isDownloading = false
               }
               
           }
               
           loadingTask = nil
       }
    }
    
    func deleteFile(at url: URL) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = url.pathExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension)")
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                isDownloaded = false
                print("File deleted successfully")
            } catch let error {
                print("Error while deleting video file: ", error)
            }
        }
    }
    
    func checkFileExists(at url: URL) -> Bool {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = url.pathExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension)")
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                isDownloaded = true
                return isDownloaded
            } else {
                isDownloaded = false
                return isDownloaded
            }
        } else {
            isDownloaded = false
            return isDownloaded
        }
    }
    
    func getImage(at url: URL) -> UIImage  {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = url.pathExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension)")
        
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                
                let imageData = try? Data(contentsOf: destinationUrl)
                
                if let imageData = imageData {
                    return UIImage(data: imageData)!
                } else {
                    return UIImage(systemName: "photo")!
                }
                
            } else {
                return UIImage(systemName: "photo")!
            }
        } else {
            return UIImage(systemName: "photo")!
        }
    }
}
