import Foundation
import BlocksModels
import Combine
import SwiftUI

final class ObjectTypesSearchViewModel {
    
    private enum Constants {
        static let installedSectionId = "MyTypeId"
        static let marketplaceSectionId = "MarketplaceId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [ObjectDetails] = []
    private var marketplaceObjects: [ObjectDetails] = []
    private let interactor: ObjectTypesSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    private let selectedObjectId: BlockId?
    private let onSelect: (_ id: String, _ message: String?) -> Void
    
    init(
        interactor: ObjectTypesSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        selectedObjectId: BlockId? = nil,
        onSelect: @escaping (_ id: String, _ message: String?) -> Void
    ) {
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.selectedObjectId = selectedObjectId
        self.onSelect = onSelect
    }
}

extension ObjectTypesSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let objects = interactor.search(text: text)
        let marketplaceObjects = interactor.searchInMarketplace(text: text)
        
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

        guard let marketplaceType = marketplaceObjects.first(where: { $0.id == id}) else {
            onSelect(id, nil)
            return
        }
        
        guard let installedType = interactor.installType(objectId: marketplaceType.id) else { return }
        
        toastPresenter.show(message: Loc.ObjectType.addedToLibrary(installedType.name))
        
        onSelect(installedType.id, nil)
    }
}

private extension ObjectTypesSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    func handleSearchResults(objects: [ObjectDetails], marketplaceObjects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if objects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.installedSectionId,
                            title: Loc.ObjectType.myTypes,
                            rows:  objects.asRowConfigurations(selectedId: selectedObjectId)
                        )
                    }
                    if marketplaceObjects.isNotEmpty {
                        ListSectionConfiguration(
                            id: Constants.marketplaceSectionId,
                            title: Loc.marketplace,
                            rows:  marketplaceObjects.asRowConfigurations(selectedId: selectedObjectId)
                        )
                    }
                })
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(selectedId: BlockId?) -> [ListRowConfiguration] {
        sorted { lhs, rhs in
            lhs.id == selectedId && rhs.id != selectedId
        }.map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details, isChecked: details.id == selectedId),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails, isChecked: Bool) {
        let title = details.title
        self.icon = {
            if details.layoutValue == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.description
        self.style = .default
        self.isChecked = isChecked
    }
    
}
