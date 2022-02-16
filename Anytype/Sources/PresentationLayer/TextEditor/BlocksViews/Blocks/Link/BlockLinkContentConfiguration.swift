import BlocksModels

struct BlockLinkContentConfiguration: BlockConfiguration {
    typealias View = BlockLinkView

    let state: BlockLinkState
}
