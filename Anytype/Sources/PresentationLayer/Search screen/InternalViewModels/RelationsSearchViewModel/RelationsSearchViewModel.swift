import Foundation
import Combine
import Services
import AnytypeCore

@MainActor
final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let installedSectionId = "InstalledId"
        static let librarySectionId = "MarketplaceId"
    }
    
    let selectionMode: LegacySearchViewModel.SelectionMode = .singleItem
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never>()
    private var objects: [RelationDetails] = []
    private var marketplaceObjects: [RelationDetails] = []
    
    private let objectId: String
    private let spaceId: String
    private let excludedRelationsIds: [String]
    private let target: RelationsModuleTarget
    private let interactor: RelationsSearchInteractor
    private let onSelect: (_ relation: RelationDetails) -> Void
    
    init(
        objectId: String,
        spaceId: String,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        interactor: RelationsSearchInteractor,
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.excludedRelationsIds = excludedRelationsIds
        self.target = target
        self.interactor = interactor
        self.onSelect = onSelect
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text, excludedIds: excludedRelationsIds, spaceId: spaceId)
        let marketplaceObjects = try await interactor.searchInLibrary(text: text, spaceId: spaceId)
        
        handleSearchResults(objects: objects, marketplaceObjects: marketplaceObjects)
        
        self.objects = objects
        self.marketplaceObjects = marketplaceObjects
    }
    
    func handleRowsSelection(ids: [String]) {
        
    }
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel {
        return searchText.isEmpty ? .disabled : .enabled(title: Loc.createRelation(searchText))
    }
    
    func handleConfirmSelection(ids: [String]) {
        guard let id = ids.first else { return }
        
        if let marketplaceRelation = marketplaceObjects.first(where: { $0.id == id}) {
            Task { @MainActor in
                guard let installedRelation = try await interactor.installRelation(spaceId: spaceId, objectId: marketplaceRelation.id) else {
                    anytypeAssertionFailure("Relation not installed", info: ["id": marketplaceRelation.id, "key": marketplaceRelation.key])
                    return
                }
                addRelation(relation: installedRelation)
            }
            return
        }
        
        if let installedRelation = objects.first(where: { $0.id == id}) {
            addRelation(relation: installedRelation)
            return
        }
    
        anytypeAssertionFailure("Relation not found")
    }
    
    // MARK: - Private
    
    private func addRelation(relation: RelationDetails) {
        switch target {
        case .type(let data):
            Task { @MainActor in
                try await interactor.addRelationToType(relation: relation, isFeatured: data.isFeatured)
                onSelect(relation)
            }
        case .dataview(let activeViewId):
            Task { @MainActor in
                try await interactor.addRelationToDataview(objectId: objectId, relation: relation, activeViewId: activeViewId)
                onSelect(relation)
            }
        }
    }
    
    private func handleSearchResults(objects: [RelationDetails], marketplaceObjects: [RelationDetails]) {
    
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if objects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.installedSectionId,
                            title: Loc.Relation.myRelations,
                            rows:  objects.asRowConfigurations()
                        )
                    }
                    if marketplaceObjects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.librarySectionId,
                            title: Loc.anytypeLibrary,
                            rows:  marketplaceObjects.asRowConfigurations()
                        )
                    }
                })
            )
        )
    }
}

private extension Array where Element == RelationDetails {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(relationDetails: details),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}
