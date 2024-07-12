//
//  ImageCache.swift
//  Jikan
//
//  Created by William Liao on 2021/2/7.
//  Copyright © 2021 William Liao. All rights reserved.
//

import SwiftUI

// Declares in-memory image cache
protocol ImageCacheType: AnyObject {
    // Returns the image associated with a given url
    func image(for url: URL) -> ImageRepresentable?
    // Inserts the image of the specified url in the cache
    func insertImage(_ image: ImageRepresentable?, for url: URL)
    // Removes the image of the specified url in the cache
    func removeImage(for url: URL)
    // Removes all images from the cache
    func removeAllImages()
    // Accesses the value associated with the given key for reading and writing
    subscript(_ url: URL) -> ImageRepresentable? { get set }
}

final class ImageCache {

    // 1st level cache, that contains encoded images
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        return cache
    }()
    // 2nd level cache, that contains decoded images
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    private let lock = NSLock()
    private let config: Config

    struct Config {
        let countLimit: Int
        let memoryLimit: Int

        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }

    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
}

extension ImageCache: ImageCacheType {
   
    func insertImage(_ image: ImageRepresentable?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        let decodedImage = image.decodedImage()

        lock.lock(); defer { lock.unlock() }
        imageCache.setObject(decodedImage, forKey: url as AnyObject)
        decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
    }

    func removeImage(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeObject(forKey: url as AnyObject)
        decodedImageCache.removeObject(forKey: url as AnyObject)
    }
    
    public func removeAllImages() {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeAllObjects()
        decodedImageCache.removeAllObjects()
    }

    public subscript(_ key: URL) -> ImageRepresentable? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}

extension ImageCache {

    func image(for url: URL) -> ImageRepresentable? {
        lock.lock(); defer { lock.unlock() }
        // the best case scenario -> there is a decoded image
        if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? ImageRepresentable {
            return decodedImage
        }
        // search for image data
        if let image = imageCache.object(forKey: url as AnyObject) as? ImageRepresentable {
            let decodedImage = image.decodedImage()
            decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
            return decodedImage
        }
        return nil
    }
    
    func hasCacheImage(for url: URL) -> Bool {
        if let image = imageCache.object(forKey: url as AnyObject) as? ImageRepresentable {
            return true
        } else {
            return false
        }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCacheType = ImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] as! ImageCache }
        set { self[ImageCacheKey.self] = newValue }
    }
}


fileprivate extension ImageRepresentable {

    #if canImport(UIKit)
    func decodedImage() -> ImageRepresentable {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return ImageRepresentable(cgImage: decodedImage)
    }
    // Rough estimation of how much memory image uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    #elseif canImport(Cocoa)
    func decodedImage() -> ImageRepresentable {
        var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let cgImage = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else { return self }
        
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        
        return ImageRepresentable(cgImage: decodedImage, size: size)
    }
    
    var diskSize: Int {
        var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let cgImage = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    #endif
}

