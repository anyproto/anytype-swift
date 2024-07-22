//
//  LegacySearchError.swift
//  Anytype
//
//  Created by Konstantin Mordan on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct LegacySearchError: Error {
    
    let title: String
    let subtitle: String?
    
}

extension LegacySearchError {
    
    static func noObjectError(searchText: String) -> LegacySearchError {
        LegacySearchError(
            title: Loc.thereIsNoObjectNamed(searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
    
    static func noTypeError(searchText: String) -> LegacySearchError {
        LegacySearchError(
            title: Loc.thereIsNoTypeNamed(searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
    
    static func noObjectErrorWithoutSubtitle(searchText: String) -> LegacySearchError {
        LegacySearchError(
            title: Loc.thereIsNoObjectNamed(searchText),
            subtitle: nil
        )
    }
}
