//
//  RelationValueStatusSectionBuilder.swift
//  Anytype
//
//  Created by Konstantin Mordan on 02.12.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

final class RelationValueStatusSectionBuilder {
    
    static func sections(from options: [RelationMetadata.Option], filterText: String?) -> [RelationValueStatusSection] {
        let filter: (Bool, String) -> Bool = { scopeFilter, optionText in
            if let text = filterText, text.isNotEmpty {
                return scopeFilter && optionText.lowercased().contains(text.lowercased())
            }
            
            return scopeFilter
        }
        
        let localOptions = options.filter { filter($0.scope == .local, $0.text) }
        let otherOptions = options.filter { filter($0.scope != .local, $0.text) }
        
        var sections: [RelationValueStatusSection] = []
        if localOptions.isNotEmpty {
            sections.append(
                RelationValueStatusSection(
                    id: Constants.localStatusSectionID,
                    title: "In this object".localized,
                    statuses: localOptions.map { RelationValue.Status(option: $0) }
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationValueStatusSection(
                    id: Constants.otherStatusSectionID,
                    title: "Everywhere".localized,
                    statuses: otherOptions.map { RelationValue.Status(option: $0) }
                )
            )
        }
        
        return sections
    }
    
}

private extension RelationValueStatusSectionBuilder {
    
    enum Constants {
        static let localStatusSectionID = "localStatusSectionID"
        static let otherStatusSectionID = "otherStatusSectionID"
    }
    
}
