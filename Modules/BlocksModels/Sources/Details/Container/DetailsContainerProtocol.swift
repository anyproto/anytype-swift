public protocol DetailsContainerProtocol {
    func get(by id: BlockId) -> LegacyDetailsModel?
    func add(model: LegacyDetailsModel, id: BlockId)
}
