import Foundation


public protocol BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformation.InformationModel
    func build(information: BlockInformation.InformationModel) -> BlockInformation.InformationModel
}

class BlockInformationBuilder: BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformation.InformationModel {
        BlockInformation.InformationModel(id: id, content: content)
    }
    func build(information: BlockInformation.InformationModel) -> BlockInformation.InformationModel {
        BlockInformation.InformationModel.init(information: information)
    }
}
