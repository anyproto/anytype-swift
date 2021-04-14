import Foundation
import os

public protocol DetailsBuilderProtocol {
    func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol
    func emptyContainer() -> DetailsContainerModelProtocol
    func build(information: DetailsInformationModel) -> DetailsModelProtocol
    var informationBuilder: DetailsInformationBuilderProtocol {get}
}

extension Details {
    class Builder: DetailsBuilderProtocol {
        
        typealias BlockId = DetailsId
        typealias Model = DetailsModel
        typealias CurrentContainer = Container
                
        func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol {
            let container: CurrentContainer = .init()
            list.forEach(container.add(_:))
            return container
        }
        
        func emptyContainer() -> DetailsContainerModelProtocol {
            build(list: [])
        }
        
        func build(information: DetailsInformationModel) -> DetailsModelProtocol {
            Model.init(details: information)
        }
        
        var informationBuilder: DetailsInformationBuilderProtocol = Information.Builder.init()
    }
}
