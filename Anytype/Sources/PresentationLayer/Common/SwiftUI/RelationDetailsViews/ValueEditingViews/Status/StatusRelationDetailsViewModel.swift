import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {
    
    @Published private(set) var currentStatusModel: StatusSearchRowView.Model?
    
    let popupLayout = AnytypePopupLayoutType.constantHeight(height: 116, floatingPanelStyle: false)

    private let source: RelationSource
    private let allStatuses: [Relation.Status.Option]
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    private weak var popup: AnytypePopupProxy?
    
    init(
        source: RelationSource,
        currentStatus: Relation.Status.Option?,
        allStatuses: [Relation.Status.Option],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
        self.source = source
        
        self.currentStatusModel = currentStatus.flatMap { StatusSearchRowView.Model(
            text: $0.text, color: $0.color) }
        self.allStatuses = allStatuses
        
        self.relation = relation
        self.service = service
    }
    
}

extension StatusRelationDetailsViewModel {
    
    func didTapAddButton() {
        
    }
    
    func didTapClearButton() {

    }
    
}

extension StatusRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: StatusRelationDetailsView(viewModel: self))
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
