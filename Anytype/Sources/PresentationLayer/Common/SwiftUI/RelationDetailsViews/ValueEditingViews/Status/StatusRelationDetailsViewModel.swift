import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {
    
    let source: RelationSource
        
    private weak var popup: AnytypePopupProxy?
    
    let popupLayout = AnytypePopupLayoutType.fullScreen

    @Published var selectedStatus: Relation.Status.Option?
    
    private let allStatuses: [Relation.Status.Option]
    
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        source: RelationSource,
        selectedStatus: Relation.Status.Option?,
        allStatuses: [Relation.Status.Option],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
        self.source = source
        
        self.selectedStatus = selectedStatus
        self.allStatuses = allStatuses
        
        self.relation = relation
        self.service = service
        
    }
    
}

extension StatusRelationDetailsViewModel {
    
    
    
}

extension StatusRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: StatusRelationDetailsView(viewModel: self))
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
