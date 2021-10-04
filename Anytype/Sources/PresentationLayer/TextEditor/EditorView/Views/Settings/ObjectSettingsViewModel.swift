import Foundation
import Combine
import BlocksModels

final class ObjectSettingsViewModel: ObservableObject {
    
    @Published private(set) var details: DetailsDataProtocol = DetailsData.empty
    var settings: [ObjectSetting] {
        if details.typeUrl == ObjectTypeProvider.myProfileURL {
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

    let objectActionsViewModel: ObjectActionsViewModel

    let iconPickerViewModel: ObjectIconPickerViewModel
    let coverPickerViewModel: ObjectCoverPickerViewModel
    let layoutPickerViewModel: ObjectLayoutPickerViewModel
    
    private let objectDetailsService: ObjectDetailsService
    
    init(objectId: String, objectDetailsService: ObjectDetailsService) {
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

        self.objectActionsViewModel = ObjectActionsViewModel(objectId: objectId)
    }
    
    func update(with details: DetailsDataProtocol) {
        objectActionsViewModel.details = details
        self.details = details
        iconPickerViewModel.details = details
        layoutPickerViewModel.details = details
    }
}
