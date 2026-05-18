import Services

enum MembershipParticipantUpgradeReason {
    case numberOfSpaceEditors

    var warningText: String {
        switch self {
        case .numberOfSpaceEditors:
            return Loc.Membership.Upgrade.noMoreEditors
        }
    }
}


enum MembershipUpgradeReason {
    case storageSpace
    case numberOfSpaceEditors
    case numberOfSharedSpaces
    
    init(participantReason: MembershipParticipantUpgradeReason) {
        switch participantReason {
        case .numberOfSpaceEditors:
            self = .numberOfSpaceEditors
        }
    }
    
    var analyticsType: ClickUpgradePlanTooltipType {
        switch self {
        case .storageSpace:
            return .storage
        case .numberOfSpaceEditors:
            return .editors
        case .numberOfSharedSpaces:
            return .sharedSpaces
        }
    }
}

