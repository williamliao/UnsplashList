//
//  DownloadManager.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/10.
//

import Foundation
import SwiftUI
import Kingfisher

final class DownloadManager: NetworkManager, ObservableObject, @unchecked Sendable  {
    @Published var isDownloading = false
    @Published var isDownloaded = false
    private var loadingTask: Task<Void, Error>?
    private var dataBaseService = DataBaseService()
    
    override init(endPoint: NetworkManager.NetworkEndpoint = .random, withSession session: Networking = URLSession.shared) {
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
    
    func downloadFileWithKingfisher(for url: URL?) {
        
        guard let downloadUrl = url else {
            isDownloading = false
            return
        }
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = downloadUrl.pathExtension
        let fileName = downloadUrl.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension)")
        
        if let destinationUrl = destinationUrl {
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("File already exists")
                isDownloading = false
            } else {
                startDownloadWithKingfisher(at: downloadUrl, destinationUrl: destinationUrl)
            }
       } else {
           
           startDownloadWithKingfisher(at: downloadUrl, destinationUrl: destinationUrl)
       }
        
    }
    
    func startDownloadWithKingfisher(at url: URL, destinationUrl: URL?) {
        let resource = KF.ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            
            switch result {
                case .success(let value):
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                
                if let data = value.data() {
                    do {
                        try data.write(to: destinationUrl!, options: Data.WritingOptions.atomic)
                        DispatchQueue.main.async {
                           // self.isDownloading = false
                        }
                    } catch  {
                        print("failed save Image: \(value.image). Got from: \(value.cacheType)")
                    }
                }
                
                case .failure(let error):
                    print("Error: \(error)")
                    self.isDownloading = false
            }
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
                        
                        let apiData = self.readApiData()
                        
                       // if let login = apiData?.login {
                            
                            let id = UUID().uuidString
                            let lastPath = url.lastPathComponent
                            
                            let saveURL = self.showSavePanel(fileName: lastPath)
                            let saveImageItem = ImageItem(id: id, imageData: imageData)
                            let saveImageData = saveImageItem.imageData
                            
                            if let saveImageData  = saveImageData, let saveURL = saveURL {
                                do {
                                   // try saveImageData.write(to: fileURLwithName)
                                    try saveImageData.write(to: saveURL)
                                } catch  {
                                    print("** saveImageData error: \(error.localizedDescription)")
                                }
                            }
                       // }
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
        
        Task {
            await dataBaseService.saveModel(item:item)
        }

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
    
    func getImage(for item: UnsplashModel) -> ImageRepresentable {
        guard let url = URL(string: item.raw!) else {
            return getPlaceHolderImage()
        }
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileExtension = item.fileExtension
        let fileName = url.lastPathComponent

        let destinationUrl = docsUrl?.appendingPathComponent("\(fileName).\(fileExtension ?? "jpg")")
        
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                
                let imageData = try? Data(contentsOf: destinationUrl)
                
                if let imageData = imageData {
                    return ImageRepresentable(data: imageData)!
                } else {
                    return getPlaceHolderImage()
                }
                
            } else {
                return getPlaceHolderImage()
            }
        } else {
            return getPlaceHolderImage()
        }
    }
    
    func getPlaceHolderImage() -> ImageRepresentable {
        #if canImport(UIKit)
            return Image(systemName: "photo")
        #elseif canImport(Cocoa)
            return NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!
        #endif
    }
    
    func readApiData() -> APIData? {
        
        do {
            let location = NSString(string: "~/api.plist").expandingTildeInPath
            let data: Data? = try Data(contentsOf: URL(fileURLWithPath: location))
            
            if let fileData = data {
                guard let plist = try PropertyListSerialization.propertyList(from: fileData, options: .mutableContainers, format: nil) as? Dictionary<String, Any> else {return nil}
              
                let dict = plist.compactMapValues { $0 }
                
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIData.self, from: jsonData)
                
                return result
                
            } else {
                return nil
            }
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func showSavePanel(fileName: String) -> URL? {
        /// 1. Form the plugin's bundle URL
        let bundleFileName = "MacPlugin.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?
                                    .appendingPathComponent(bundleFileName) else { return nil }

        /// 2. Create a bundle instance with the plugin URL
        guard let bundle = Bundle(url: bundleURL) else { return nil }

        /// 3. Load the bundle and our plugin class
        let className = "MacPlugin.MacPlugin"
        guard let pluginClass = bundle.classNamed(className) as? Plugin.Type else { return nil }

        /// 4. Create an instance of the plugin class
        let plugin = pluginClass.init()
  
        return plugin.savePanel(for: .png, fileName: fileName)
    }
}
