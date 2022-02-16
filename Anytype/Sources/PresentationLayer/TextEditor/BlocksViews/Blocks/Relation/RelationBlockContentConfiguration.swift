struct RelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockView

    let relation: Relation
    @EquatableNoop private(set) var actionOnValue: ((_ relation: Relation) -> Void)?
}
