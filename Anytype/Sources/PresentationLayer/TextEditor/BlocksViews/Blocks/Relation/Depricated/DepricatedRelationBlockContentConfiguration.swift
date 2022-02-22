
struct DepricatedRelationBlockContentConfiguration: BlockConfiguration {
    typealias View = RelationBlockViewDepricated

    @EquatableNoop private(set) var actionOnValue: ((_ relation: Relation) -> Void)?
    let relation: Relation
}
