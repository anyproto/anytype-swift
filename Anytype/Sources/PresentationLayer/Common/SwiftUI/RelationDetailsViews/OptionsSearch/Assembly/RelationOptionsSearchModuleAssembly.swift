import Foundation

final class RelationOptionsSearchModuleAssembly {
    
    static func buildModule(searchType: RelationOptionsSearchType) -> NewRelationOptionsSearchView {
        
        let interactor = NewRelationOptionsSearchInteractor(type: searchType, excludedOptionIds: [], searchService: SearchService())
        let presenter = NewRelationOptionsSearchPresenter(interactor: interactor)
        
        return NewRelationOptionsSearchView(presenter: presenter)
    }
    
}
