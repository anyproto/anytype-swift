import Services

enum MembershipParticipantUpgradeReason {
    case numberOfSpaceReaders
    case numberOfSpaceEditors
    
    var warningText: String {
        switch self {
        case .numberOfSpaceReaders:
            return Loc.Membership.Upgrade.noMoreMembers
        case .numberOfSpaceEditors:
            return Loc.Membership.Upgrade.noMoreEditors
        }
    }
}


enum MembershipUpgradeReason {
    case storageSpace
    case numberOfSpaceReaders
    case numberOfSpaceEditors
    case numberOfSharedSpaces
    
    init(participantReason: MembershipParticipantUpgradeReason) {
        switch participantReason {
        case .numberOfSpaceReaders:
            self = .numberOfSpaceReaders
        case .numberOfSpaceEditors:
            self = .numberOfSpaceEditors
        }
    }
}

extension MembershipTier {
    func isPossibleToUpgrade(reason: MembershipUpgradeReason) -> Bool {
        switch reason {
        case .storageSpace:
            isPossibleToUpgradeStorageSpace
        case .numberOfSpaceReaders:
            isPossibleToUpgradeNumberOfSpaceMembers
        case .numberOfSpaceEditors:
            isPossibleToUpgradeNumberOfSpaceMembers
        case .numberOfSharedSpaces:
            false
        }
    }
    
    private var isPossibleToUpgradeStorageSpace: Bool {
        switch self.type {
        case .builder, .explorer, .custom:
            true
        case .anyTeam, .coCreator:
            false
        }
    }
    
    private var isPossibleToUpgradeNumberOfSpaceMembers: Bool {
        switch self.type {
        case .explorer,  .custom:
            true
        case .anyTeam, .builder, .coCreator:
            false
        }
    }
}
