import Foundation
import SwiftUI
import FloatingPanel
import AnytypeCore

final class RelationOptionsViewModel: ObservableObject {
            
    @Published var selectedOptions: [ListRowConfiguration] = []
    @Published var isSearchPresented: Bool = false
    
    private(set) var popupLayout: AnytypePopupLayoutType = .relationOptions {
        didSet {
            popup?.updateLayout(true)
        }
    }

    private weak var popup: AnytypePopupProxy?

    private let source: RelationSource
    private let type: RelationOptionsType
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        source: RelationSource,
        type: RelationOptionsType,
        selectedOptions: [ListRowConfiguration],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
        self.source = source
        self.type = type
        self.selectedOptions = selectedOptions
        self.relation = relation
        self.service = service
        
        updateLayout()
    }
    
    var title: String { relation.name }
    
    var emptyPlaceholder: String { type.placeholder }
    
}

// MARK: - Internal functions

extension RelationOptionsViewModel {
    
    func delete(_ indexSet: IndexSet) {
        selectedOptions.remove(atOffsets: indexSet)
        service.updateRelation(
            relationKey: relation.id,
            value: selectedOptions.map { $0.id }.protobufValue
        )
        
        updateLayout()
    }
    
    func move(source: IndexSet, destination: Int) {
        selectedOptions.move(fromOffsets: source, toOffset: destination)
        service.updateRelation(
            relationKey: relation.id,
            value: selectedOptions.map { $0.id }.protobufValue
        )
    }
    
    func didTapAddButton() {
        isSearchPresented = true
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        switch type {
        case .objects:
            NewSearchModuleAssembly.buildObjectsSearchModule(
                selectedObjectIds: selectedOptionIds
            ) { [weak self] ids in
                self?.handleNewOptionIds(ids)
            }
        case .tags(let allTags):
            NewSearchModuleAssembly.buildTagsSearchModule(
                allTags: allTags,
                selectedTagIds: selectedOptionIds
            ) { [weak self] ids in
                self?.handleNewOptionIds(ids)
            } onCreate: { [weak self] title in
                self?.handleCreateOption(title: title)
            }
        case .files:
            NewSearchModuleAssembly.buildFilesSearchModule(
                selectedObjectIds: selectedOptionIds
            ) { [weak self] ids in
                self?.handleNewOptionIds(ids)
            }
        }
    }
    
}

// MARK: - Private extension

private extension RelationOptionsViewModel {
    
    func handleNewOptionIds(_ ids: [String]) {
        let newSelectedOptionsIds = selectedOptionIds + ids
        
        service.updateRelation(
            relationKey: relation.id,
            value: newSelectedOptionsIds.protobufValue
        )
        isSearchPresented = false
        popup?.close()
    }
    
    func handleCreateOption(title: String) {
        let optionId = service.addRelationOption(source: source, relationKey: relation.id, optionText: title)
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

extension RelationOptionsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: RelationOptionsView(viewModel: self))
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
