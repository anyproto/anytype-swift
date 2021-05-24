import Foundation

final class DetailsBuilder: DetailsBuilderProtocol {
    
    let detailsProviderBuilder: DetailsProviderBuilderProtocol = DetailsProviderBuilder()

    func emptyStorage() -> DetailsStorageProtocol {
        DetailsStorage()
    }
    
    func build(information: DetailsProviderProtocol) -> DetailsModelProtocol {
        DetailsModel(details: information)
    }
    
}
