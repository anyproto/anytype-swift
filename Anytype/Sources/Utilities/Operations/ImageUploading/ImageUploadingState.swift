//
//  ImageUploadingState.swift
//  Anytype
//
//  Created by Konstantin Mordan on 28.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

enum ImageUploadingState {
    case preparing
    case uploading(localPath: String)
    case finished(hash: Hash?)
    case cancelled
}
