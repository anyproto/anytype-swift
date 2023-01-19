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
            title: Loc.thereIsNoObjectNamed(searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
    
    static func noTypeError(searchText: String) -> NewSearchError {
        NewSearchError(
            title: Loc.thereIsNoTypeNamed(searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
    
    static func noObjectErrorWithoutSubtitle(searchText: String) -> NewSearchError {
        NewSearchError(
            title: Loc.thereIsNoObjectNamed(searchText),
            subtitle: nil
        )
    }
}
