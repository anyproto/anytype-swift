import Foundation
import UIKit
import BlocksModels

final class DocumentSettingsViewModel {
    
    // MARK: - Private variables
    
    private let iconPickerViewModel: DocumentIconPickerViewModel
    private let coverPickerViewModel: DocumentCoverPickerViewModel
    private let layoutPickerViewModel: DocumentLayoutPickerViewModel
    
    // MARK: - Initializer
    
    init(activeModel: DetailsActiveModel) {
        self.iconPickerViewModel = DocumentIconPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsActiveModel: activeModel
        )
        
        self.coverPickerViewModel = DocumentCoverPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsActiveModel: activeModel
        )
        
        self.layoutPickerViewModel = DocumentLayoutPickerViewModel(
            detailsActiveModel: activeModel
        )
    }
    
    // MARK: - Internal function
    
    func configure(with details: DetailsData) {
        iconPickerViewModel.configure(with: details)
        layoutPickerViewModel.configure(with: details)
    }
    
    func makeSettingsViewController() -> UIViewController {
        BottomFloaterBuilder().builBottomFloater {
            DocumentSettingsView()
                .padding(8)
                .environmentObject(iconPickerViewModel)
                .environmentObject(coverPickerViewModel)
                .environmentObject(layoutPickerViewModel)
        }
    }

}
