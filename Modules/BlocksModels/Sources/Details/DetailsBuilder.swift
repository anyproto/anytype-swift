import Foundation
import os

public protocol DetailsBuilderProtocol {
    func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol
    func emptyContainer() -> DetailsContainerModelProtocol
    func build(information: DetailsInformationModel) -> DetailsModelProtocol
    var informationBuilder: DetailsInformationBuilderProtocol {get}
}

class DetailsBuilder: DetailsBuilderProtocol {
    func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol {
        let container = Details.Container()
        list.forEach(container.add(_:))
        return container
    }
    
    func emptyContainer() -> DetailsContainerModelProtocol {
        build(list: [])
    }
    
    func build(information: DetailsInformationModel) -> DetailsModelProtocol {
        Details.DetailsModel(details: information)
    }
    
    let informationBuilder: DetailsInformationBuilderProtocol = DetailsInformationBuilder()
}
