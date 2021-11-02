import Foundation
import Combine
import BlocksModels

final class ObjectSettingsViewModel: ObservableObject {
    var dismissHandler: () -> Void = {}
    
    @Published private(set) var details: ObjectDetails = ObjectDetails(id: "", values: [:])
    var settings: [ObjectSetting] {
        if details.type == ObjectTemplateType.BundledType.profile.rawValue {
            return ObjectSetting.allCases.filter { $0 != .layout }
        }
        
        switch details.layout {
        case .basic:
            return ObjectSetting.allCases
        case .profile:
            return ObjectSetting.allCases
        case .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        case .note:
            return [.layout]
        }
    }

    let objectActionsViewModel: ObjectActionsViewModel

    let iconPickerViewModel: ObjectIconPickerViewModel
    let coverPickerViewModel: ObjectCoverPickerViewModel
    let layoutPickerViewModel: ObjectLayoutPickerViewModel
    let relationsViewModel: ObjectRelationsViewModel
    
    private let objectDetailsService: ObjectDetailsService
    
    init(
        objectId: String,
        objectDetailsService: ObjectDetailsService,
        popScreenAction: @escaping () -> ()
    ) {
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
        
        self.relationsViewModel = ObjectRelationsViewModel()

        self.objectActionsViewModel = ObjectActionsViewModel(objectId: objectId, popScreenAction: popScreenAction)
    }
    
    func update(with details: ObjectDetails?, objectRestrictions: ObjectRestrictions) {
        if let details = details {
            objectActionsViewModel.details = details
            self.details = details
            iconPickerViewModel.details = details
            layoutPickerViewModel.details = details
        }
        objectActionsViewModel.objectRestrictions = objectRestrictions
    }
    
    func configure(dismissHandler: @escaping () -> Void) {
        self.dismissHandler = dismissHandler
        objectActionsViewModel.dismissSheet = dismissHandler
    }
}
