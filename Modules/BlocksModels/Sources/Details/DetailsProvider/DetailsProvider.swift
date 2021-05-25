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
    
    let details: [DetailsId: DetailsEntry<AnyHashable>]
    var parentId: String?
    
    // MARK: - Initialization
    
    init(_ details: [DetailsId: DetailsEntry<AnyHashable>]) {
        self.details = details
    }
    
}

// MARK: - DetailsInformationProvider

extension DetailsProvider: DetailsEntryValueProvider {
    
    var name: String? {
        return value(for: .name)
    }
    
    var iconEmoji: String? {
        return value(for: .iconEmoji)
    }
    
    var iconImage: String? {
        return value(for: .iconImage)
    }
    
    var coverId: String? {
        return value(for: .coverId)
    }
    
    var coverType: CoverType? {
        return value(for: .coverType)
    }
    
    private func value<V>(for kind: DetailsKind) -> V? {
        guard let entry = details[kind.rawValue] else {
            return nil
        }
        
        return entry.value as? V
    }

}

// MARK: Hashable
extension DetailsProvider: Hashable {}
