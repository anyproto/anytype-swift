import Services

extension Participant {
    var publishingDomain: DomainType {
        if globalName.isNotEmpty {
            .paid("\(globalName).org")
        } else {
            .free("any.coop/\(identity)")
        }
    }
}
