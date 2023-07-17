import Foundation
import Combine
import Services
import AnytypeCore

final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let installedSectionId = "InstalledId"
        static let marketplaceSectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [RelationDetails] = []
    private var marketplaceObjects: [RelationDetails] = []
    
    private let excludedRelationsIds: [String]
    private let target: RelationsSearchTarget
    private let interactor: RelationsSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    private let onSelect: (_ relation: RelationDetails) -> Void
    
    init(
        excludedRelationsIds: [String],
        target: RelationsSearchTarget,
        interactor: RelationsSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) {
        self.excludedRelationsIds = excludedRelationsIds
        self.target = target
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text, excludedIds: excludedRelationsIds)
        let marketplaceObjects = try await interactor.searchInMarketplace(text: text)
        
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
            guard let installedRelation = interactor.installRelation(objectId: marketplaceRelation.id) else {
                anytypeAssertionFailure("Relation not installed", info: ["id": marketplaceRelation.id, "key": marketplaceRelation.key])
                return
            }
            toastPresenter.show(message: Loc.Relation.addedToLibrary(installedRelation.name))
            addRelation(relation: installedRelation)
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
            if interactor.addRelationToObject(relation: relation) {
                onSelect(relation)
            } else {
                anytypeAssertionFailure("Relation not added to document", info: ["id": relation.id, "key": relation.key])
            }
        case .dataview(let activeViewId):
            Task { @MainActor [weak self] in
                try await self?.interactor.addRelationToDataview(relation: relation, activeViewId: activeViewId)
                self?.onSelect(relation)
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
                            id: Constants.marketplaceSectionId,
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
