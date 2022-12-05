import Foundation

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        title: String?,
        context: AnalyticsEventsSearchContext,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
}
