//
//  DocumentDetailsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 13.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine

final class DocumentDetailsViewModel {
    
    // MARK: Publishers
    
    @Published var componentViewModels: [DocumentDetailsChildViewModel] = []
    
    @Published var pageDetailsViewModels: [BlockViewBuilderProtocol] = []
    
}
