import Foundation
import SwiftUI
import FloatingPanel

final class RelationOptionsViewModel: ObservableObject {
    
    weak var delegate: RelationDetailsViewModelDelegate?
        
    @Published var selectedOptions: [RelationOptionProtocol] = []
    private(set) var floatingPanelLayout: FloatingPanelLayout = RelationOptionsPopupLayout() {
        didSet {
            delegate?.didAskInvalidateLayout(true)
        }
    }

    private let type: RelationOptionsType
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        type: RelationOptionsType,
        selectedOptions: [RelationOptionProtocol],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
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
            RelationOptionsSearchView(
                viewModel: RelationOptionsSearchViewModel(
                    type: .objects,
                    excludedIds: selectedOptions.map { $0.id }
                ) { [weak self] ids in
                    self?.handleNewOptionIds(ids)
                }
            )
        case .tags(let allTags):
            TagRelationOptionSearchView(viewModel: searchViewModel(allTags: allTags))
        case .files:
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
    
    private func searchViewModel(allTags: [Relation.Tag.Option]) -> TagRelationOptionSearchViewModel {
        let availableTags = allTags.filter { tag in
            !selectedOptions.contains { $0.id == tag.id }
        }
        
        return TagRelationOptionSearchViewModel(
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
        
        delegate?.didAskToClose()
    }
    
    private func updateLayout() {
        floatingPanelLayout = selectedOptions.isNotEmpty ? RelationOptionsPopupLayout() : FixedHeightPopupLayout(height: 166)
    }
    
}

extension RelationOptionsViewModel: RelationDetailsViewModelProtocol {
    
    func makeViewController() -> UIViewController {
        UIHostingController(rootView: RelationOptionsView(viewModel: self))
    }
    
}
