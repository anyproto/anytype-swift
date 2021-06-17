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
    let coverViewModel: DocumentCoverViewModel?

    // MARK: - Initializer
    
    init(iconViewModel: DocumentIconViewModel?,
         coverViewModel: DocumentCoverViewModel?) {
        self.iconViewModel = iconViewModel
        self.coverViewModel = coverViewModel
    }
    
}
