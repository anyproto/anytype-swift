//
//  DocumentSettingViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class DocumentSettingViewModel {
    
    // MARK: - Private variables

    private let iconPickerViewModel: DocumentIconPickerViewModel
    private let coverPickerViewModel: DocumentCoverPickerViewModel
    
    // MARK: - Initializer
    
    init(detailsActiveModel: DetailsActiveModel) {
        self.iconPickerViewModel = DocumentIconPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsActiveModel: detailsActiveModel
        )
        
        self.coverPickerViewModel = DocumentCoverPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsActiveModel: detailsActiveModel
        )
    }
    
    // MARK: - Internal function
    
    func makeSettingsViewController() -> UIViewController {
        BottomFloaterBuilder().builBottomFloater {
            DocumentSettingsContentView()
                .padding(8)
                .environmentObject(iconPickerViewModel)
                .environmentObject(coverPickerViewModel)
        }
    }

}
