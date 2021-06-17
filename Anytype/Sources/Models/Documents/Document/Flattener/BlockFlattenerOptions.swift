
struct BlockFlattenerOptions {
    var shouldCheckIsRootToggleOpened = true
    var normalizers: [BlockChildrenNormalizer]
    var shouldIncludeRootNode = false
    static var `default`: Self = .init(normalizers: [NumberedBlockNormalizer()])
}
