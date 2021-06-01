import Foundation


public protocol BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformation
    func build(information: BlockInformation) -> BlockInformation
}

class BlockInformationBuilder: BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformation {
        BlockInformation(id: id, content: content)
    }
    func build(information: BlockInformation) -> BlockInformation {
        BlockInformation.init(information: information)
    }
}
