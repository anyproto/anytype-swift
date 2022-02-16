import BlocksModels

struct DividerBlockContentConfiguration: BlockConfiguration {
    typealias View = DividerBlockContentView

    let content: BlockDivider
}
