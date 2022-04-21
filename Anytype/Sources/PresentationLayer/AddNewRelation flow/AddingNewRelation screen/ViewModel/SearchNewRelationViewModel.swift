import BlocksModels
import CoreGraphics
import Combine
import AnytypeCore
import UIKit

final class SearchNewRelationViewModel: ObservableObject {
    
    @Published private(set) var searchData: [SearchNewRelationSectionType] = {
        if FeatureFlags.createNewRelation {
            return [.createNewRelation]
        } else {
            return []
        }
    }()

    // MARK: - Private variables
    
    // Used for exclude relations that already has in object
    private let usedObjectRelationsIds: Set<String>
    private let relationService: RelationsServiceProtocol
    private weak var output: SearchNewRelationModuleOutput?
    
    // MARK: - Initializers
    
    init(
        objectRelations: ParsedRelations,
        relationService: RelationsServiceProtocol,
        output: SearchNewRelationModuleOutput?
    ) {
        self.relationService = relationService
        self.output = output

        usedObjectRelationsIds = Set(objectRelations.all.map { $0.id })
    }
    
}

// MARK: - View model methods

extension SearchNewRelationViewModel {
    
    func search(text: String) {
        AnytypeAnalytics.instance().logSearchQuery(.menuSearch, length: text.count)
        
        let newSearchData = obtainAvailbaleRelationList()

        guard !text.isEmpty else {
            searchData = newSearchData
            return
        }

        newSearchData.forEach { section in
            guard case let .addFromLibriry(relationsMetadata) = section else { return }
            searchData.removeAll()

            let filteredRelationsMetadata = relationsMetadata.filter { relationMetadata in
                relationMetadata.name.contains(text)
            }
            
            if FeatureFlags.createNewRelation {
                searchData.append(.createNewRelation)
            }

            if filteredRelationsMetadata.isNotEmpty {
                searchData.append(.addFromLibriry(filteredRelationsMetadata))
            }
        }
    }

    func obtainAvailbaleRelationList() -> [SearchNewRelationSectionType] {
        let relatonsMetadata = relationService.availableRelations()?.filter {
            !$0.isHidden && !usedObjectRelationsIds.contains($0.id)
        } ?? []
        
        if FeatureFlags.createNewRelation {
            return [.createNewRelation, .addFromLibriry(relatonsMetadata)]
        } else {
            return [.addFromLibriry(relatonsMetadata)]
        }
    }

    func addRelation(_ relation: RelationMetadata) {
        if let createdRelation = relationService.addRelation(relation: relation) {
            UISelectionFeedbackGenerator().selectionChanged()
            output?.didAddRelation(createdRelation)
        }
    }

    
    func showAddRelation(searchText: String) {
        output?.didAskToShowCreateNewRelation(searchText: searchText)
    }
    
}
