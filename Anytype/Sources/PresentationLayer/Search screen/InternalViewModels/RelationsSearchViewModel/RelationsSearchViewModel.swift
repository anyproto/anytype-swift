import Foundation
import Combine
import BlocksModels

final class RelationsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let installedSectionId = "InstalledId"
        static let marketplaceSectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [RelationDetails] = []
    private var marketplaceObjects: [RelationDetails] = []
    
    private let selectedRelations: ParsedRelations
    private let interactor: RelationsSearchInteractor
    private let onSelect: (_ ids: [RelationDetails]) -> Void
    
    init(
        selectedRelations: ParsedRelations,
        interactor: RelationsSearchInteractor,
        onSelect: @escaping (_ ids: [RelationDetails]) -> Void
    ) {
        self.selectedRelations = selectedRelations
        self.interactor = interactor
        self.onSelect = onSelect
    }
    
    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) {
        let objects = interactor.search(text: text, excludedIds: selectedRelations.all.map(\.id))
        let sources = objects.map { $0.sourceObject }
        let marketplaceObjects = interactor.searchInMarketplace(text: text, excludedIds: sources)
        
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
        let idsToInstall = marketplaceObjects.filter { ids.contains($0.id) }.map { $0.id }
        let installedObjects = objects.filter { ids.contains($0.id) }
        let newInstalledObjects = interactor.installRelations(objectIds: idsToInstall)
        let result = installedObjects + newInstalledObjects
    
        interactor.addRelationToObject(relations: result)
        
        onSelect(result)
    }
    
    // MARK: - Private
    
    private func handleSearchResults(objects: [RelationDetails], marketplaceObjects: [RelationDetails]) {
    
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if objects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.installedSectionId,
                            title: Loc.Relation.myRelations,
                            rows:  objects.asRowConfigurations()
                        )
                    }
                    if marketplaceObjects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.marketplaceSectionId,
                            title: Loc.marketplace,
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
