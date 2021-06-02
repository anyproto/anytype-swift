import Foundation

public enum BlockInformationBuilder {
    public static func build(id: BlockId, content: BlockContent) -> BlockInformation {
        BlockInformation(id: id, content: content)
    }

    public static func build(information: BlockInformation) -> BlockInformation {
        BlockInformation.init(information: information)
    }
}
