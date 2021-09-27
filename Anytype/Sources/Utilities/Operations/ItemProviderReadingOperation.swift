//
//  ItemProviderReadingOperation.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class ItemProviderReadingOperation: Operation {

    // MARK: - Private variables
    
    private let contentType: MediaPickerContentType
    private let itemProvider: NSItemProvider
    
    // MARK: - Initializers
    
    init(contentType: MediaPickerContentType, itemProvider: NSItemProvider) {
        self.contentType = contentType
        self.itemProvider = itemProvider
        super.init()
    }
    
    override func main() {
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            contentType.supportedTypeIdentifiers.contains($0)
        }
        
        guard let identifier = typeIdentifier else { return }
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier
        ) { [weak self] url, error in
            
        }
    }
}
