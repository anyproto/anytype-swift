import Foundation
import Combine
import BlocksModels
import UIKit
import FloatingPanel
import SwiftUI

final class ObjectSettingsViewModel: ObservableObject, Dismissible {
    var onDismiss: () -> Void = {} {
        didSet {
            objectActionsViewModel.dismissSheet = onDismiss
        }
    }
    
    @Published private(set) var details: ObjectDetails = ObjectDetails(id: "", values: [:])
    
    let objectActionsViewModel: ObjectActionsViewModel

    let iconPickerViewModel: ObjectIconPickerViewModel
    let coverPickerViewModel: ObjectCoverPickerViewModel
    let layoutPickerViewModel: ObjectLayoutPickerViewModel
    let relationsViewModel: RelationsListViewModel
    
    private(set) var popupLayout: FloatingPanelLayout = ConstantHeightPopupLayout(height: 0)
    
    private weak var сontentDelegate: AnytypePopupContentDelegate?
    private let objectId: String
    private let objectDetailsService: DetailsService
    
    private let onLayoutSettingsTap: (ObjectLayoutPickerViewModel) -> ()
    
    init(
        objectId: String,
        objectDetailsService: DetailsService,
        popScreenAction: @escaping () -> (),
        onLayoutSettingsTap: @escaping (ObjectLayoutPickerViewModel) -> (),
        onRelationValueEditingTap: @escaping (String) -> ()
    ) {
        self.objectId = objectId
        self.objectDetailsService = objectDetailsService

        self.onLayoutSettingsTap = onLayoutSettingsTap
        
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
        
        self.relationsViewModel = RelationsListViewModel(
            relationsService: RelationsService(objectId: objectId),
            onValueEditingTap: onRelationValueEditingTap
        )

        self.objectActionsViewModel = ObjectActionsViewModel(objectId: objectId, popScreenAction: popScreenAction)
    }
    
    func update(objectRestrictions: ObjectRestrictions, parsedRelations: ParsedRelations) {
        if let details = ObjectDetailsStorage.shared.get(id: objectId) {
            objectActionsViewModel.details = details
            self.details = details
            iconPickerViewModel.details = details
            layoutPickerViewModel.details = details

            relationsViewModel.update(with: parsedRelations)
        }
        objectActionsViewModel.objectRestrictions = objectRestrictions
    }
    
    func showLayoutSettings() {
        onLayoutSettingsTap(layoutPickerViewModel)
    }
    
    func viewDidUpdateHeight(_ height: CGFloat) {
        popupLayout = ConstantHeightPopupLayout(height: height)
        сontentDelegate?.didAskInvalidateLayout(false)
    }
    
}

extension ObjectSettingsViewModel {
    
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
            return [.layout, .relations]
        case .set:
            return ObjectSetting.allCases
        }
    }
    
}

extension ObjectSettingsViewModel: AnytypePopupViewModelProtocol {
    
    func setContentDelegate(_ сontentDelegate: AnytypePopupContentDelegate) {
        self.сontentDelegate = сontentDelegate
    }
    
    func makeContentView() -> UIViewController {
        AnytypeUIHostingViewController(rootView: ObjectSettingsView(viewModel: self))
    }
    
}
