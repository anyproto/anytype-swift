import Foundation


public protocol BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformationModel
    func build(information: BlockInformationModel) -> BlockInformationModel
}

class BlockInformationBuilder: BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformationModel {
        BlockInformationModel(id: id, content: content)
    }
    func build(information: BlockInformationModel) -> BlockInformationModel {
        BlockInformationModel.init(information: information)
    }
}
