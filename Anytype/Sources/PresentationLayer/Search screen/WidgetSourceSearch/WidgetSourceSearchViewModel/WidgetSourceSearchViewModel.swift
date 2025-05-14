import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

@MainActor
final class WidgetSourceSearchViewModel: NewInternalSearchViewModelProtocol {
    
    private enum Constants {
        static let objectTypesId = "ObjectTypesId"
        static let anytypeId = "AnytypeId"
        static let searchId = "SearchId"
    }
    
    let selectionMode: LegacySearchViewModel.SelectionMode = .singleItem
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never>()
    private var objectTypes: [ObjectDetails] = []
    private var objects: [ObjectDetails] = []
    private var libraryObjects: [WidgetAnytypeLibrarySource] = []
    private let interactor: any WidgetSourceSearchInteractorProtocol
    private let internalModel: any WidgetSourceSearchInternalViewModelProtocol
    
    private var searchText: String = ""
    
    init(
        interactor: some WidgetSourceSearchInteractorProtocol,
        internalModel: some WidgetSourceSearchInternalViewModelProtocol
    ) {
        self.interactor = interactor
        self.internalModel = internalModel
    }

    // MARK: - NewInternalSearchViewModelProtocol
    
    func search(text: String) async throws {
        self.searchText = text
        
        let objectTypes = try await interactor.objectsTypesSearch(text: text)
        let objects = try await interactor.objectsSearch(text: text)
        let libraryObjects = try await interactor.anytypeLibrarySearch(text: text)
        
        handleSearchResults(objectTypes: objectTypes, objects: objects, libraryObjects: libraryObjects)
        
        self.objectTypes = objectTypes
        self.objects = objects
        self.libraryObjects = libraryObjects
    }
    
    func handleRowsSelection(ids: [String]) {}
    
    func handleConfirmSelection(ids: [String]) {
        
        guard let id = ids.first else { return }
        
        if let object = objectTypes.first(where: { $0.id == id}) {
            internalModel.onSelect(source: .object(object), openObject: nil)
            return
        }
        
        if let libraryObject = libraryObjects.first(where: { $0.type.rawValue == id}) {
            internalModel.onSelect(source: .library(libraryObject.type), openObject: nil)
            return
        }

        if let object = objects.first(where: { $0.id == id}) {
            internalModel.onSelect(source: .object(object), openObject: nil)
            return
        }

        anytypeAssertionFailure("Object not found")
    }
    
    // MARK: - Private
    
    private func handleSearchResults(objectTypes: [ObjectDetails], objects: [ObjectDetails], libraryObjects: [WidgetAnytypeLibrarySource]) {
        viewStateSubject.send(
            .resultsList(
                .sectioned(sectinos: .builder {
                    if libraryObjects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.anytypeId,
                            title: Loc.Widgets.Source.library,
                            rows:  libraryObjects.asRowConfigurations()
                        )
                    }
                    if objectTypes.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.objectTypesId,
                            title: Loc.Widgets.Source.suggested,
                            rows:  objectTypes.asRowConfigurations()
                        )
                    }
                    if objects.isNotEmpty {
                        ListSectionConfiguration.smallHeader(
                            id: Constants.searchId,
                            title: Loc.Widgets.Source.objects,
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
        self.id = source.type.rawValue
        self.icon = source.icon
        self.title = source.name
        self.subtitle = source.description
        self.style = .default
        self.isChecked = false
    }
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.pluralTitle
        self.id = details.id
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = details.description
        self.style = .default
        self.isChecked = false
    }
    
}
