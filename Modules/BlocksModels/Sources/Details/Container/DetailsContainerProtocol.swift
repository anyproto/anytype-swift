public protocol DetailsContainerProtocol {
    func get(by id: ParentId) -> LegacyDetailsModel?
    func add(model: LegacyDetailsModel, by id: ParentId)
}
