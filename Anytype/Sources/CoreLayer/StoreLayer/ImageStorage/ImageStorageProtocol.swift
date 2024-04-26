//
//  ImageStorageProtocol.swift
//  ImageStorageProtocol
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

protocol ImageStorageProtocol {
    
    func image(forKey key: String) -> UIImage?
    func saveImage(_ image: UIImage, forKey key: String)
    
}
