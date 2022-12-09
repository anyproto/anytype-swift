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
    private let relation: Relation
    private let service: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private weak var popup: AnytypePopupProxy?
    
    init(
        source: RelationSource,
        selectedStatus: Relation.Status.Option?,
        relation: Relation,
        service: RelationsServiceProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.source = source
        
        self.selectedStatus = selectedStatus
        
        self.relation = relation
        self.service = service
        self.searchService = searchService
        self.newSearchModuleAssembly = newSearchModuleAssembly
        
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
        newSearchModuleAssembly.statusSearchModule(
            relationKey: relation.key,
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
        
        guard let newStatusId = ids.first else { return }
        
        service.updateRelation(relationKey: relation.key, value: newStatusId.protobufValue)
        
        let newStatus = searchService.searchRelationOptions(optionIds: [newStatusId])?.first
            .map { Relation.Status.Option(option: $0) }
        
        guard let newStatus = newStatus else {
            popup?.close()
            return
        }
        
        selectedStatus = newStatus
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
