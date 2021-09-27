//
//  ImageUploadingDemon.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class ImageUploadingDemon {
    
    static let shared = ImageUploadingDemon()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
}
