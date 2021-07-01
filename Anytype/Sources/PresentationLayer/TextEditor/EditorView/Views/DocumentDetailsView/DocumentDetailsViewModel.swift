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
    let cover: DocumentCover?

    // MARK: - Initializer
    
    init(iconViewModel: DocumentIconViewModel?,
         cover: DocumentCover?) {
        self.iconViewModel = iconViewModel
        self.cover = cover
    }
    
}
