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
        var newRelations = setModel.activeView.relations
        let newRelation = relation.relation.updated(isVisible: isVisible)
        
        guard let relationIndex = newRelations
                .firstIndex(where: { $0.key == relation.relation.key }) else { return }
        newRelations[relationIndex] = newRelation
        
        let newView = setModel.activeView.updated(relations: newRelations)
        service.updateView(newView)
    }
    
    func showAddNewRelationView() {
        setModel.showAddNewRelationView { [weak self] relation in
            self?.service.addRelation(relation)
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
