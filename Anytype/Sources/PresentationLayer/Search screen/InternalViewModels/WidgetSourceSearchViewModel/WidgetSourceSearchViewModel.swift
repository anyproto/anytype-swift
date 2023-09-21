import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

final class WidgetSourceSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let anytypeId = "AnytypeId"
        static let searchId = "SearchId"
    }
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    var viewStatePublisher: AnyPublisher<NewSearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    private let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    private var objects: [ObjectDetails] = []
    private var libraryObjects: [WidgetAnytypeLibrarySource] = []
    private let interactor: WidgetSourceSearchInteractorProtocol
    private let internalModel: WidgetSourceSearchInternalViewModelProtocol
    
    init(
        interactor: WidgetSourceSearchInteractorProtocol,
        internalModel: WidgetSourceSearchInternalViewModelProtocol
    ) {
        self.interactor = interactor
        self.internalModel = internalModel
    }

    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) async throws {
        let objects = try await interactor.objectSearch(text: text)
        let libraryObjects = interactor.anytypeLibrarySearch(text: text)
        
        if objects.isEmpty && libraryObjects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects: objects, libraryObjects: libraryObjects)
        }
        
        self.objects = objects
        self.libraryObjects = libraryObjects
    }
    
    func handleRowsSelection(ids: [String]) {}
    
    func handleConfirmSelection(ids: [String]) {
        
        guard let id = ids.first else { return }

        if let libraryObject = libraryObjects.first(where: { $0.type.rawValue == id}) {
            internalModel.onSelect(source: .library(libraryObject.type))
            return
        }

        if let object = objects.first(where: { $0.id == id}) {
            internalModel.onSelect(source: .object(object))
            return
        }

        anytypeAssertionFailure("Object not found")
    }
    
    // MARK: - Private
    
    private func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    private func handleSearchResults(objects: [ObjectDetails], libraryObjects: [WidgetAnytypeLibrarySource]) {
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if libraryObjects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.anytypeId,
                            title: Loc.anytypeLibrary,
                            rows:  libraryObjects.asRowConfigurations()
                        )
                    }
                    if objects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.searchId,
                            title: Loc.objects,
                            rows:  objects.asRowConfigurations()
                        )
                    }
                })
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
}

private extension Array where Element == WidgetAnytypeLibrarySource {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { source in
            ListRowConfiguration(
                id: source.type.rawValue,
                contentHash: source.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(source: source),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
}

private extension SearchObjectRowView.Model {
    
    init(source: WidgetAnytypeLibrarySource) {
        self.icon = source.icon
        self.title = source.name
        self.subtitle = source.description
        self.style = .default
        self.isChecked = false
    }
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.title
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = details.description
        self.style = .default
        self.isChecked = false
    }
    
}
