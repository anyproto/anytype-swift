import BlocksModels

extension BlockModelProtocol {
    func children(container: BlockContainerModelProtocol) -> [BlockModelProtocol] {
        BlockModelChildrenProvider(container: container).children(model: self)
    }
}
