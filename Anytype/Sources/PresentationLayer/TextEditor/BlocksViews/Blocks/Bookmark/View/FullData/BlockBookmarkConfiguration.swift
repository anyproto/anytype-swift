import BlocksModels

struct BlockBookmarkConfiguration: BlockConfiguration {
    typealias View = BlockBookmarkView

    let payload: BlockBookmarkPayload
}
