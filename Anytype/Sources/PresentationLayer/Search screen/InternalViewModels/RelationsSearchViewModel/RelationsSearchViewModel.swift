import Foundation
import Combine
import Services
import AnytypeCore

final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let installedSectionId = "InstalledId"
        static let librarySectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    var viewStatePublisher: AnyPublisher<NewSearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    private let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    private var objects: [RelationDetails] = []
    private var marketplaceObjects: [RelationDetails] = []
    
    private let document: BaseDocumentProtocol
    private let excludedRelationsIds: [String]
    private let target: RelationsModuleTarget
    private let interactor: RelationsSearchInteractor
    private let onSelect: (_ relation: RelationDetails) -> Void
    
    init(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        interactor: RelationsSearchInteractor,
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) {
        self.document = document
        self.excludedRelationsIds = excludedRelationsIds
        self.target = target
        self.interactor = interactor
        self.onSelect = onSelect
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text, excludedIds: excludedRelationsIds, spaceId: document.spaceId)
        let marketplaceObjects = try await interactor.searchInLibrary(text: text, spaceId: document.spaceId)
        
        handleSearchResults(objects: objects, marketplaceObjects: marketplaceObjects)
        
        self.objects = objects
        self.marketplaceObjects = marketplaceObjects
    }
    
    func handleRowsSelection(ids: [String]) {
        
    }
    
    func createButtonModel(searchText: String) -> NewSearchViewModel.CreateButtonModel {
        return searchText.isEmpty ? .disabled : .enabled(title: Loc.createRelation(searchText))
    }
    
    func handleConfirmSelection(ids: [String]) {
        guard let id = ids.first else { return }
        
        if let marketplaceRelation = marketplaceObjects.first(where: { $0.id == id}) {
            Task { @MainActor in
                guard let installedRelation = try await interactor.installRelation(spaceId: document.spaceId, objectId: marketplaceRelation.id) else {
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
        case .object:
            Task { @MainActor in
                try await interactor.addRelationToObject(relation: relation)
                onSelect(relation)
            }
        case .dataview(let activeViewId):
            Task { @MainActor in
                try await interactor.addRelationToDataview(objectId: document.objectId, relation: relation, activeViewId: activeViewId)
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
