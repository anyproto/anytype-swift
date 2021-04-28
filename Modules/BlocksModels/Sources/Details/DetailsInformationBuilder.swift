import Foundation

public protocol DetailsInformationBuilderProtocol {
    typealias Content = DetailsContent
    func empty() -> DetailsInformationModel
    func build(list: [Content]) -> DetailsInformationModel
    func build(information: DetailsInformationModel) -> DetailsInformationModel
}

class DetailsInformationBuilder: DetailsInformationBuilderProtocol {
    func empty() -> DetailsInformationModel {
        self.build(list: [])
    }
    func build(list: [Content]) -> DetailsInformationModel {
        Details.Information.InformationModel.init(list)
    }
    func build(information: DetailsInformationModel) -> DetailsInformationModel {
        Details.Information.InformationModel.init(information.details)
    }
}
