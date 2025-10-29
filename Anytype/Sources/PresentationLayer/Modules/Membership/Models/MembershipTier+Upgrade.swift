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

extension MembershipTier {
    func isPossibleToUpgrade(reason: MembershipUpgradeReason) -> Bool {
        switch reason {
        case .storageSpace:
            isPossibleToUpgradeStorageSpace
        case .numberOfSpaceEditors:
            isPossibleToUpgradeNumberOfSpaceMembers
        case .numberOfSharedSpaces:
            false
        }
    }
    
    private var isPossibleToUpgradeStorageSpace: Bool {
        switch self.type {
        case .builder, .starter, .explorer, .custom, .legacyExplorer, .seatBasedTier:
            true
        case .anyTeam, .coCreator:
            false
        }
    }
    
    private var isPossibleToUpgradeNumberOfSpaceMembers: Bool {
        switch self.type {
        case .starter, .explorer, .custom, .legacyExplorer, .seatBasedTier:
            true
        case .anyTeam, .builder, .coCreator:
            false
        }
    }
}
