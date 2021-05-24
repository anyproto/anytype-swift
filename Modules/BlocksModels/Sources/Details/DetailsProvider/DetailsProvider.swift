//
//  DetailsProvider.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct DetailsProvider: DetailsProviderProtocol {
    
    // MARK: - Properties
    
    let details: [DetailsId: DetailsEntry]
    var parentId: String?
    
    // MARK: - Initialization
    
    init(_ details: [DetailsId: DetailsEntry]) {
        self.details = details
    }
    
}

// MARK: - DetailsInformationProvider

extension DetailsProvider: DetailsEntryValueProvider {
    
    subscript(kind: DetailsKind) -> String? {
        guard let entry = details[kind.rawValue] else {
            return nil
        }
        
        return entry.value
    }

}

// MARK: Hashable
extension DetailsProvider: Hashable {}
