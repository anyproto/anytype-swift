import Foundation
import Combine
import BlocksModels

final class ObjectSettingsViewModel: ObservableObject {
    
    @Published private(set) var details = DetailsData.empty
    var settings: [ObjectSetting] {
        if details.typeUrl == Constants.myProfileType {
            return ObjectSetting.allCases.filter { $0 != .layout }
        }
        
        guard let layout = details.layout else {
            return ObjectSetting.allCases
        }
        
        switch layout {
        case .basic:
            return ObjectSetting.allCases
        case .profile:
            return ObjectSetting.allCases
        case .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        }
    }
    
    let iconPickerViewModel: ObjectIconPickerViewModel
    let coverPickerViewModel: ObjectCoverPickerViewModel
    let layoutPickerViewModel: ObjectLayoutPickerViewModel
    
    private let objectDetailsService: ObjectDetailsService
    
    init(objectDetailsService: ObjectDetailsService) {
        self.objectDetailsService = objectDetailsService
        self.iconPickerViewModel = ObjectIconPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsService: objectDetailsService
        )
        self.coverPickerViewModel = ObjectCoverPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsService: objectDetailsService
        )
        
        self.layoutPickerViewModel = ObjectLayoutPickerViewModel(
            detailsService: objectDetailsService
        )
    }
    
    func update(with details: DetailsData) {
        self.details = details
        iconPickerViewModel.details = details
        layoutPickerViewModel.details = details
    }
    
}

private extension ObjectSettingsViewModel {
    
    enum Constants {
        static let myProfileType = "_otprofile"
    }
    
}
