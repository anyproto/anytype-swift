import Services

extension Participant {
    var publishingDomain: String {
        if globalName.isNotEmpty {
            "\(globalName).any.coop"
        } else {
            "any.coop/\(identity)"
        }
    }
}
