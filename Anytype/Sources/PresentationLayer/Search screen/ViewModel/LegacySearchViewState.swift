//
//  LegacySearchViewState.swift
//  Anytype
//
//  Created by Konstantin Mordan on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

enum LegacySearchViewState: Sendable {
    case resultsList(LegacySearchView.ListModel)
    case error(LegacySearchError)
}
