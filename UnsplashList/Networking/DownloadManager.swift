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
    
    func downloadFile(for item: UnsplashModel) {
        isDownloading = true
        
        guard let url = URL(string: item.raw!) else {
            isDownloading = false
            return
        }
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = item.fileExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension ?? "jpg")")
        
        if let destinationUrl = destinationUrl {
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("File already exists")
                isDownloading = false
            } else {
                startDownload(at: url, destinationUrl: destinationUrl)
            }
       } else {
           
           startDownload(at: url, destinationUrl: destinationUrl)
       }
    }
    
    func startDownload(at url: URL, destinationUrl: URL?) {
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
    
    func deleteFile(for item: UnsplashModel) {
        
        guard let url = URL(string: item.raw!) else {
            return
        }
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = item.fileExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension ?? "jpg")")
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
    
    func checkFileExists(for item: UnsplashModel) -> Bool {
        guard let url = URL(string: item.raw!) else {
            isDownloaded = false
            return isDownloaded
        }
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = item.fileExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension ?? "jpg")")
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
    
    func getImage(for item: UnsplashModel) -> UIImage {
        guard let url = URL(string: item.raw!) else {
            return UIImage(systemName: "photo")!
        }
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = item.fileExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension ?? "jpg")")
        
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
