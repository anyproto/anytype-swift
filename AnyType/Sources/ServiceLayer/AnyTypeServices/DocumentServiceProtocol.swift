//
//  DocumentServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

/// Service for managing documents in workspace
protocol DocumentServiceProtocol {
    
    /// Obtain documents list in workspace
    /// - Parameter completion: called on completion
    func obtainDocuments(completion: (_ resutl: Result<Documents, Error>) -> Void)
    
    /// Obtain document and its blocks
    /// - Parameter id: Document id
    func obtainDocument(id: String, completion: (_ resutl: Result<Document, Error>) -> Void)
}
