import Services

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        title: String?,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
    
    func makeObjectSearch(
        title: String?,
        layouts: [DetailsLayout],
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule
}
