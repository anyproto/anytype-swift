import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

final class Legacy_ObjectTypeSearchViewModel {
    
    private enum Constants {
        static let installedSectionId = "MyTypeId"
        static let librarySectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    
    private let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    private var objects: [ObjectDetails] = []
    private var marketplaceObjects: [ObjectDetails] = []
    private let interactor: Legacy_ObjectTypeSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    private let selectedObjectId: BlockId?
    private let hideMarketplace: Bool
    private let showDescription: Bool
    private let onSelect: (_ type: ObjectType) -> Void
    
    init(
        interactor: Legacy_ObjectTypeSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        selectedObjectId: BlockId? = nil,
        hideMarketplace: Bool = false,
        showDescription: Bool = true,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.selectedObjectId = selectedObjectId
        self.hideMarketplace = hideMarketplace
        self.showDescription = showDescription
        self.onSelect = onSelect
    }
}

extension Legacy_ObjectTypeSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var viewStatePublisher: AnyPublisher<NewSearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text)
        let marketplaceObjects = (text.isEmpty && hideMarketplace) ? [] : try await interactor.searchInLibrary(text: text)
        
        if objects.isEmpty && marketplaceObjects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects: objects, marketplaceObjects: marketplaceObjects)
        }
        
        self.objects = objects
        self.marketplaceObjects = marketplaceObjects
    }
    
    func handleRowsSelection(ids: [String]) {}
    
    func handleConfirmSelection(ids: [String]) {
        
        guard let id = ids.first else { return }

        if let marketplaceType = marketplaceObjects.first(where: { $0.id == id}) {
            Task { @MainActor in
                let installedType = try await interactor.installType(objectId: marketplaceType.id)
                toastPresenter.show(message: Loc.ObjectType.addedToLibrary(installedType.name))
                onSelect(ObjectType(details: installedType))
            }
            return
        }
        
        if let installedType = objects.first(where: { $0.id == id}) {
            onSelect(ObjectType(details: installedType))
            return
        }
       
        anytypeAssertionFailure("Type not found")
    }
}

private extension Legacy_ObjectTypeSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noTypeError(searchText: text)))
    }
    
    func handleSearchResults(objects: [ObjectDetails], marketplaceObjects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if objects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.installedSectionId,
                            title: Loc.ObjectType.myTypes,
                            rows:  objects.asRowConfigurations(selectedId: selectedObjectId, showDescription: showDescription)
                        )
                    }
                    if marketplaceObjects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.librarySectionId,
                            title: Loc.anytypeLibrary,
                            rows:  marketplaceObjects.asRowConfigurations(selectedId: selectedObjectId, showDescription: showDescription)
                        )
                    }
                })
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(selectedId: BlockId?, showDescription: Bool) -> [ListRowConfiguration] {
        sorted { lhs, rhs in
            lhs.id == selectedId && rhs.id != selectedId
        }.map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details, isChecked: details.id == selectedId, showDescription: showDescription),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails, isChecked: Bool, showDescription: Bool) {
        let title = details.title
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = showDescription ? details.description : ""
        self.style = .default
        self.isChecked = isChecked
    }
    
}
