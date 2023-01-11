import Foundation
import SwiftUI
import FloatingPanel
import AnytypeCore

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

    private let relationKey: String
    private let searchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol
    private let service: RelationsServiceProtocol
    
    init(
        selectedOptions: [ListRowConfiguration],
        emptyOptionsPlaceholder: String,
        relation: Relation,
        searchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol,
        service: RelationsServiceProtocol
    ) {
        self.selectedOptions = selectedOptions
        self.title = relation.name
        self.emptyPlaceholder = emptyOptionsPlaceholder
        self.relationKey = relation.key
        self.searchModuleBuilder = searchModuleBuilder
        self.service = service
        self.isEditable = relation.isEditable
        
        updateLayout()
    }
        
}

// MARK: - Internal functions

extension RelationOptionsListViewModel {
    
    func delete(_ indexSet: IndexSet) {
        selectedOptions.remove(atOffsets: indexSet)
        service.updateRelation(
            relationKey: relationKey,
            value: selectedOptions.map { $0.id }.protobufValue
        )
        
        updateLayout()
    }
    
    func move(source: IndexSet, destination: Int) {
        selectedOptions.move(fromOffsets: source, toOffset: destination)
        service.updateRelation(
            relationKey: relationKey,
            value: selectedOptions.map { $0.id }.protobufValue
        )
    }
    
    func didTapAddButton() {
        isSearchPresented = true
    }
    
    func makeSearchView() -> some View {
        searchModuleBuilder.buildModule(
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
        let newSelectedOptionsIds = selectedOptionIds + ids
        
        service.updateRelation(
            relationKey: relationKey,
            value: newSelectedOptionsIds.protobufValue
        )
        isSearchPresented = false
        popup?.close()
    }
    
    func handleCreateOption(title: String) {
        let optionId = service.addRelationOption(relationKey: relationKey, optionText: title)
        guard let optionId = optionId else { return}

        handleNewOptionIds([optionId])
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
