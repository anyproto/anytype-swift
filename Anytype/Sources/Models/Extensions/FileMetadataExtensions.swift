//
//  FileMetadataExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 29.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

extension FileMetadata: DownloadableContentProtocol {
    
    var downloadingUrl: URL? {
        UrlResolver.resolvedUrl(.file(id: self.hash))
    }
    
}
