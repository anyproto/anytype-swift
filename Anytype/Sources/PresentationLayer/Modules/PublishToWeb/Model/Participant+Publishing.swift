import Services

extension Participant {
    var publishingDomain: DomainType {
        if globalName.isNotEmpty {
            .paid("\(globalName).any.coop")
        } else {
            .free("any.coop/\(identity)")
        }
    }
}
