//
//  NewSearchError.swift
//  Anytype
//
//  Created by Konstantin Mordan on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct NewSearchError: Error {
    
    let title: String
    let subtitle: String?
    
}

extension NewSearchError {
    
    static func noObjectError(searchText: String) -> NewSearchError {
        NewSearchError(
            title: "\(Loc.thereIsNoObjectNamed) \"\(searchText)\"",
            subtitle: Loc.tryToCreateANewOneOrSearchForSomethingElse
        )
    }
    
    static func noObjectErrorWithoutSubtitle(searchText: String) -> NewSearchError {
        NewSearchError(
            title: "\(Loc.thereIsNoObjectNamed) \"\(searchText)\"",
            subtitle: nil
        )
    }
    
    static func alreadySelected(searchText: String) -> NewSearchError {
        NewSearchError(
            title: "\"\(searchText)\" \(Loc.isAlreadySelected)",
            subtitle: nil
        )
    }
    
}
