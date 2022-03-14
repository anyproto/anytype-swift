import Foundation
import SwiftUI
import FloatingPanel
import AnytypeCore

final class RelationOptionsViewModel: ObservableObject {
            
    @Published var selectedOptions: [RelationOptionProtocol] = []
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
        selectedOptions: [RelationOptionProtocol],
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
    
    @ViewBuilder
    func makeSearchView() -> some View {
        switch type {
        case .objects:
            if FeatureFlags.newRelationOptionsSearch {
                RelationOptionsSearchModuleAssembly.buildModule(searchType: .objects)
            } else {
                RelationOptionsSearchView(
                    viewModel: RelationOptionsSearchViewModel(
                        type: .objects,
                        excludedIds: selectedOptions.map { $0.id }
                    ) { [weak self] ids in
                        self?.handleNewOptionIds(ids)
                    }
                )
            }
        case .tags(let allTags):
            if FeatureFlags.newRelationOptionsSearch {
                NewSearchModuleAssembly.buildTagsSearchModule(allTags: allTags, selectedTagIds: selectedOptions.map { $0.id })
                RelationOptionsSearchModuleAssembly.buildModule(searchType: .tags(allTags))
            } else {
                TagRelationOptionSearchView(viewModel: searchViewModel(allTags: allTags))
            }
        case .files:
            if FeatureFlags.newRelationOptionsSearch {
                RelationOptionsSearchModuleAssembly.buildModule(searchType: .files)
            } else {
                RelationOptionsSearchView(
                    viewModel: RelationOptionsSearchViewModel(
                        type: .files,
                        excludedIds: selectedOptions.map { $0.id }
                    ) { [weak self] ids in
                        self?.handleNewOptionIds(ids)
                    }
                )
            }   
        }
    }
    
    private func searchViewModel(allTags: [Relation.Tag.Option]) -> TagRelationOptionSearchViewModel {
        let availableTags = allTags.filter { tag in
            !selectedOptions.contains { $0.id == tag.id }
        }
        
        return TagRelationOptionSearchViewModel(
            source: source,
            availableTags: availableTags,
            relation: relation,
            service: service
        ) { [weak self] ids in
            self?.handleNewOptionIds(ids)
        }
    }
    
    private func handleNewOptionIds(_ ids: [String]) {
        let newSelectedOptionsIds = selectedOptions.map { $0.id } + ids
        
        service.updateRelation(
            relationKey: relation.id,
            value: newSelectedOptionsIds.protobufValue
        )
        
        popup?.close()
    }
    
    private func updateLayout() {
        popupLayout = selectedOptions.isNotEmpty ? .relationOptions : .constantHeight(height: 150, floatingPanelStyle: false)
    }
    
}

extension RelationOptionsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: RelationOptionsView(viewModel: self))
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
