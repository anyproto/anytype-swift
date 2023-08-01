import Foundation

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        spaceId: String,
        title: String?,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
}
