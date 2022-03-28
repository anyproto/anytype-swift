import FloatingPanel
import SwiftUI
import ProtobufMessages
import BlocksModels


final class EditorSetViewSettingsViewModel: ObservableObject, AnytypePopupViewModelProtocol {
    weak var popup: AnytypePopupProxy?
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    
    init(setModel: EditorSetViewModel, service: DataviewServiceProtocol) {
        self.setModel = setModel
        self.service = service
    }
    
    func onShowIconChange(_ show: Bool) {
        let newView = setModel.activeView.updated(hideIcon: !show)
        service.updateView(newView)
    }
    
    func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        let newOption = relation.option.updated(isVisible: isVisible)
        let newView = setModel.activeView.updated(option: newOption)
        service.updateView(newView)
    }
    
    func showAddNewRelationView() {
        setModel.showAddNewRelationView { [weak self] relation in
            guard let self = self else { return }
            
            if self.service.addRelation(relation) {
                let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
                let newView = self.setModel.activeView.updated(option: newOption)
                self.service.updateView(newView)
            }
        }
    }
    
    // MARK: - AnytypePopupViewModelProtocol
    var popupLayout: AnytypePopupLayoutType {
        .fullScreen
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: EditorSetViewSettingsView()
                .environmentObject(self)
                .environmentObject(setModel)
        )
    }
}
