//
//  DocumentCoverViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels

final class DocumentCoverViewModel {
    
    // MARK: - Private variables
    
    private let cover: DocumentCover
    private let detailsActiveModel: DetailsActiveModel
    private let userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>
    
    // MARK: - Initializer
    
    init(cover: DocumentCover,
         detailsActiveModel: DetailsActiveModel,
         userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never>) {
        self.cover = cover
        self.detailsActiveModel = detailsActiveModel
        self.userActionSubject = userActionSubject
    }
    
}

// MARK: - Internal functions

extension DocumentCoverViewModel {
    
    func makeView() -> UIView {
        DocumentCoverView().configured(with: cover)
    }
    
}
