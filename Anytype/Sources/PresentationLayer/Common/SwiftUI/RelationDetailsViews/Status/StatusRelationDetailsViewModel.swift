import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {
    
    @Published private(set) var currentStatusModel: StatusSearchRowView.Model?
    @Published var isSearchPresented: Bool = false
    
    let popupLayout = AnytypePopupLayoutType.constantHeight(height: 116, floatingPanelStyle: false)

    private let source: RelationSource
    private var selectedStatus: RelationValue.Status.Option? {
        didSet {
            updateSelectedStatusViewModel()
        }
    }
    var isEditable: Bool {
        return relationValue.isEditable
    }
    private let relationValue: RelationValue
    private let service: RelationsServiceProtocol
    private let searchService = ServiceLocator.shared.searchService()
    private weak var popup: AnytypePopupProxy?
    
    init(
        source: RelationSource,
        selectedStatus: RelationValue.Status.Option?,
        relationValue: RelationValue,
        service: RelationsServiceProtocol
    ) {
        self.source = source
        
        self.selectedStatus = selectedStatus
        
        self.relationValue = relationValue
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
        service.updateRelation(relationKey: relationValue.key, value: nil)
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        NewSearchModuleAssembly.statusSearchModule(
            relationKey: relationValue.key,
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
        
        service.updateRelation(relationKey: relationValue.key, value: newStatusId.protobufValue)
        
        let newStatus = searchService.searchRelationOptions(optionIds: [newStatusId])?.first
            .map { RelationValue.Status.Option(option: $0) }
        
        guard let newStatus = newStatus else {
            popup?.close()
            return
        }
        
        selectedStatus = newStatus
    }
    
    func handleCreateOption(title: String) {
        let optionId = service.addRelationOption(source: source, relationKey: relationValue.key, optionText: title)
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
