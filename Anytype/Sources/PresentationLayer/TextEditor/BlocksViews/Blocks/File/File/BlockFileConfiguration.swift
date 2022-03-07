import BlocksModels

struct BlockFileConfiguration: BlockConfiguration {
    typealias View = BlockFileView

    let data: BlockFileMediaData
}
