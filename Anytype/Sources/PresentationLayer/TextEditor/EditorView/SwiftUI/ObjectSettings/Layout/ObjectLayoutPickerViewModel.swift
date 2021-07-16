//
//  ObjectLayoutPickerViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 15.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import Combine

final class ObjectLayoutPickerViewModel: ObservableObject {
    
    @Published private(set) var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Private variables
    
    private let detailsService: ObjectDetailsService
    
    // MARK: - Initializer
    
    init(detailsService: ObjectDetailsService) {
        self.detailsService = detailsService
    }
 
    func update(with details: DetailsData) {
        selectedLayout = details.layout ?? .basic
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        detailsService.update(
            details: [
                .layout: DetailsEntry(value: layout)
            ]
        )
    }
    
}
