//
//  DocumentDetailsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 13.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import BlocksModels

final class DocumentDetailsViewModel {
    
    let iconViewModel: DocumentIconViewModel?
    let coverViewState: DocumentCoverViewState

    // MARK: - Initializer
    
    init(iconViewModel: DocumentIconViewModel?,
         coverViewState: DocumentCoverViewState) {
        self.iconViewModel = iconViewModel
        self.coverViewState = coverViewState
    }
    
}
