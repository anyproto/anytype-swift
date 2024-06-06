import Services


enum MembershipUpgradeReason {
    case storageSpace
    case numberOfSpaceMembers
    case numberOfSharedSpaces
}

extension MembershipTier {
    func isPossibleToUpgrade(reason: MembershipUpgradeReason) -> Bool {
        switch reason {
        case .storageSpace:
            isPossibleToUpgradeStorageSpace
        case .numberOfSpaceMembers:
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
