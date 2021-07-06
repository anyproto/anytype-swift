import Foundation
import UIKit

final class DocumentSettingsViewModel {
    
    // MARK: - Private variables

    private let iconPickerViewModel: DocumentIconPickerViewModel
    private let coverPickerViewModel: DocumentCoverPickerViewModel
    
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
    }
    
    // MARK: - Internal function
    
    func makeSettingsViewController() -> UIViewController {
        BottomFloaterBuilder().builBottomFloater {
            DocumentSettingsView()
                .padding(8)
                .environmentObject(iconPickerViewModel)
                .environmentObject(coverPickerViewModel)
        }
    }

}
