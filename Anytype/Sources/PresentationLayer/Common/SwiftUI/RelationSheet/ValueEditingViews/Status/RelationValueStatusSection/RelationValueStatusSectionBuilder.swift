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
    
    static func sections(from options: [RelationMetadata.Option]) -> [RelationValueStatusSection] {
        let localOptions = options.filter { $0.scope == .local }
        let otherOptions = options.filter { $0.scope != .local }
        
        var sections: [RelationValueStatusSection] = [
            RelationValueStatusSection(
                id: Constants.localStatusSectionID,
                title: "In this object".localized,
                statuses: localOptions.map { RelationValue.Status(option: $0) }
            )
        ]
        
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
