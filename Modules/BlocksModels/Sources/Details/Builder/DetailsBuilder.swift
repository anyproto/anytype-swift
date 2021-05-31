import Foundation

public enum DetailsBuilder {
    
    public static let detailsProviderBuilder: DetailsProviderBuilderProtocol = DetailsProviderBuilder()

    public static func emptyDetailsContainer() -> DetailsContainerProtocol {
        DetailsContainer()
    }
    
    public static func build(information: DetailsProviderProtocol) -> DetailsModelProtocol {
        DetailsModel(detailsProvider: information)
    }
    
}
