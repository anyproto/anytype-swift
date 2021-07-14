//
//  DocumentLayoutPickerViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import Combine

final class DocumentLayoutPickerViewModel: ObservableObject {
    
    @Published private(set) var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Private variables
    
    private let detailsActiveModel: DetailsActiveModel
    
    private var updateDetailsSubscription: AnyCancellable?

    // MARK: - Initializer
    
    init(detailsActiveModel: DetailsActiveModel) {
        self.detailsActiveModel = detailsActiveModel
    }
 
    func configure(with details: DetailsData) {
        let newLayout = details.layout ?? .basic
        guard newLayout != selectedLayout else {
            return
        }
        
        selectedLayout = newLayout
    }
    
    func updateLayout(_ layout: DetailsLayout) {
        selectedLayout = layout
        
        DispatchQueue.main.async {
            self.updateDetailsSubscription = self.detailsActiveModel.update(
                details: [.layout: DetailsEntry(value: layout)]
            )?
            .sinkWithDefaultCompletion("Layout update details") { _ in }
        }
        
    }
    
}
