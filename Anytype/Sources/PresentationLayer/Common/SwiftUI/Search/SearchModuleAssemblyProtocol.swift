import Foundation

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        title: String?,
        context: AnalyticsEventsSearchContext,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
}

// Module Specific

extension SearchModuleAssemblyProtocol {
    func makeLinkToObjectSearch(onSelect: @escaping (ObjectSearchData) -> ()) -> SwiftUIModule {
        return makeObjectSearch(title: Loc.linkTo, context: .menuSearch, onSelect: onSelect)
    }
}
