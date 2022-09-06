import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {
    
    @Published private(set) var currentStatusModel: StatusSearchRowView.Model?
    @Published var isSearchPresented: Bool = false
    
    let popupLayout = AnytypePopupLayoutType.constantHeight(height: 116, floatingPanelStyle: false)

    private let source: RelationSource
    private var selectedStatus: Relation.Status.Option? {
        didSet {
            updateSelectedStatusViewModel()
        }
    }
    var isEditable: Bool {
        return relation.isEditable
    }
    private let allStatuses: [Relation.Status.Option]
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    private weak var popup: AnytypePopupProxy?
    
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
        
        updateSelectedStatusViewModel()
    }
    
}

extension StatusRelationDetailsViewModel {
    
    func didTapAddButton() {
        isSearchPresented = true
    }
    
    func didTapClearButton() {
        selectedStatus = nil
        service.updateRelation(relationKey: relation.key, value: nil)
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        NewSearchModuleAssembly.statusSearchModule(
            allStatuses: allStatuses,
            selectedStatusesIds: selectedStatus.flatMap { [$0.id] } ?? []
        ) { [weak self] ids in
            self?.handleSelectedOptionIds(ids)
        } onCreate: { [weak self] title in
            self?.handleCreateOption(title: title)
        }
    }
    
}

private extension StatusRelationDetailsViewModel {
    
    func updateSelectedStatusViewModel() {
        currentStatusModel = selectedStatus.flatMap {
            StatusSearchRowView.Model(text: $0.text, color: $0.color)
        }
    }
    
    func handleSelectedOptionIds(_ ids: [String]) {
        defer {
            isSearchPresented = false
        }
        
        guard
            let newStatusId = ids.first,
            let newStatus = allStatuses.first(where: { $0.id ==  newStatusId })
        else {
            ids.first.flatMap {
                service.updateRelation(
                    relationKey: relation.key,
                    value: $0.protobufValue
                )
            }
            popup?.close()
            return
        }
        
        selectedStatus = newStatus
        service.updateRelation(relationKey: relation.key, value: newStatusId.protobufValue)
    }
    
    func handleCreateOption(title: String) {
        let optionId = service.addRelationOption(source: source, relationKey: relation.key, optionText: title)
        guard let optionId = optionId else {
            return
        }

        handleSelectedOptionIds([optionId])
    }
    
}

extension StatusRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView:
                StatusRelationDetailsView(viewModel: self)
                .highPriorityGesture(
                    DragGesture()
                )
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
