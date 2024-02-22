import Foundation
import SwiftUI
import FloatingPanel
import AnytypeCore
import Services

@MainActor
final class RelationOptionsListViewModel: ObservableObject {
            
    @Published var selectedOptions: [ListRowConfiguration] = []
    @Published var isSearchPresented: Bool = false
    
    let isEditable: Bool
    let title: String
    let emptyPlaceholder: String
    
    private(set) var popupLayout: AnytypePopupLayoutType = .relationOptions {
        didSet {
            popup?.updateLayout(true)
        }
    }

    private weak var popup: AnytypePopupProxy?

    private let details: ObjectDetails
    private let relationKey: String
    private let searchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol
    private let service: RelationsServiceProtocol
    private let analyticsType: AnalyticsEventsRelationType
    
    init(
        details: ObjectDetails,
        selectedOptions: [ListRowConfiguration],
        emptyOptionsPlaceholder: String,
        relation: Relation,
        searchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol,
        service: RelationsServiceProtocol,
        analyticsType: AnalyticsEventsRelationType
    ) {
        self.details = details
        self.selectedOptions = selectedOptions
        self.title = relation.name
        self.emptyPlaceholder = emptyOptionsPlaceholder
        self.relationKey = relation.key
        self.searchModuleBuilder = searchModuleBuilder
        self.service = service
        self.analyticsType = analyticsType
        self.isEditable = relation.isEditable
        
        updateLayout()
    }
        
}

// MARK: - Internal functions

extension RelationOptionsListViewModel {
    
    func delete(_ indexSet: IndexSet) {
        selectedOptions.remove(atOffsets: indexSet)
        Task {
            try await service.updateRelation(
                relationKey: relationKey,
                value: selectedOptions.map { $0.id }.protobufValue
            )
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOptions.isEmpty, type: analyticsType)
            updateLayout()
        }
    }
    
    func move(source: IndexSet, destination: Int) {
        selectedOptions.move(fromOffsets: source, toOffset: destination)
        
        Task {
            try await service.updateRelation(
                relationKey: relationKey,
                value: selectedOptions.map { $0.id }.protobufValue
            )
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOptions.isEmpty, type: analyticsType)
        }
    }
    
    func didTapAddButton() {
        isSearchPresented = true
    }
    
    func makeSearchView() -> some View {
        searchModuleBuilder.buildModule(
            spaceId: details.spaceId,
            excludedOptionIds: selectedOptionIds
        ) { [weak self] ids in
            self?.handleNewOptionIds(ids)
        } onCreate: { [weak self] title in
            self?.handleCreateOption(title: title)
        }
    }
    
}

// MARK: - Private extension

private extension RelationOptionsListViewModel {
    
    func handleNewOptionIds(_ ids: [String]) {
        Task {
            let newSelectedOptionsIds = selectedOptionIds + ids
            try await service.updateRelation(
                relationKey: relationKey,
                value: newSelectedOptionsIds.protobufValue
            )
            isSearchPresented = false
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: newSelectedOptionsIds.isEmpty, type: analyticsType)
            popup?.close()
        }
    }
    
    func handleCreateOption(title: String) {
        Task {
            let optionId = try await service.addRelationOption(spaceId: details.spaceId, relationKey: relationKey, optionText: title, color: nil)
            guard let optionId = optionId else { return}

            handleNewOptionIds([optionId])
        }
    }
    
    func updateLayout() {
        popupLayout = selectedOptions.isNotEmpty ? .relationOptions : .constantHeight(height: 150, floatingPanelStyle: false)
    }
    
    var selectedOptionIds: [String] {
        selectedOptions.map { $0.id }
    }
    
}


// MARK: - AnytypePopupViewModelProtocol

extension RelationOptionsListViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView:
                RelationOptionsListView(viewModel: self)
                .highPriorityGesture(
                    DragGesture()
                )
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
