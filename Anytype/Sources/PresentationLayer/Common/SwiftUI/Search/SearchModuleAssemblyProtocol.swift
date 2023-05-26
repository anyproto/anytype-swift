import Foundation

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        title: String?,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
}
