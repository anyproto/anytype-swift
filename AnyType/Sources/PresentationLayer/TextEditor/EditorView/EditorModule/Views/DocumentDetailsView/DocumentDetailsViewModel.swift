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
    
    let iconViewModel: DocumentIconViewModel

    // MARK: - Initializer
    
    init(documentIcon: DocumentIcon?,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.iconViewModel = DocumentIconViewModel(
            documentIcon: documentIcon,
            detailsActiveModel: detailsActiveModel,
            userActionSubject: userActionSubject
        )
    }
    
}
