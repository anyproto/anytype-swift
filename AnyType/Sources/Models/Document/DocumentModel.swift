//
//  DocumentModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

struct DocumentHeader {
    var id: Data? = nil
    var name: String
    var version: String? = nil
    var icon: String? = nil
}

struct Documents {
    let currentDocumentId: String
    
    var documents = [DocumentHeader]()
}

/// Model for document in workspace
struct Document {
    let header: DocumentHeader
    
    var blocks = [Block]()
}
