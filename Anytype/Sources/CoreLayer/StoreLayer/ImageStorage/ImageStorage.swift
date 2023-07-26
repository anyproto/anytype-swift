//
//  ImageStorage.swift
//  ImageStorage
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ImageStorage {
    
    static let shared = ImageStorage()
    
    private init() {}
    private let cache = NSCache<NSString, UIImage>()
    
}

extension ImageStorage: ImageStorageProtocol {
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
}
