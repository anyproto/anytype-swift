import SwiftUI
import Services
import AnytypeCore


extension MembershipTier {
    var subtitle: String {
        switch self.type {
        case .explorer:
            return Loc.Membership.Explorer.subtitle
        case .builder:
            return Loc.Membership.Builder.subtitle
        case .coCreator:
            return Loc.Membership.CoCreator.subtitle
        case .custom:
            return Loc.Membership.Custom.subtitle
        }
    }
    
    var mediumIcon: ImageAsset {
        switch self.type {
        case .explorer:
            return .Membership.tierExplorerMedium
        case .builder:
            return .Membership.tierBuilderMedium
        case .coCreator:
            return .Membership.tierCocreatorMedium
        case .custom:
            anytypeAssertionFailure("Unsupported asset mediumIcon for custom tier")
            return .ghost
        }
    }
    
    var smallIcon: ImageAsset {
        switch self.type {
        case .explorer:
            .Membership.tierExplorerSmall
        case .builder:
            .Membership.tierBuilderSmall
        case .coCreator:
            .Membership.tierCocreatorSmall
        case .custom:
            .Membership.tierCustomSmall
        }
    }
    
    var gradient: MembershipTeirGradient {
        switch self.type {
        case .explorer:
            .teal
        case .builder:
            .blue
        case .coCreator:
            .red
        case .custom:
            .purple
        }
    }
    
    var successMessage: String {
        switch self.type {
        case .explorer:
            Loc.Membership.Success.curiosity
        case .builder, .coCreator, .custom:
            Loc.Membership.Success.support
        }
    }
}

// MARK: - Mocks
extension MembershipTier {
    static var mockExplorer: MembershipTier {
        MembershipTier(
            type: .explorer,
            name: "Explorer",
            anyName: .none,
            features: [
                Loc.Membership.Feature.storageGB(1),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(3),
                Loc.Membership.Feature.viewers(3)
            ],
            paymentType: .email
        )
    }
    
    static var mockBuilder: MembershipTier {
        MembershipTier(
            type: .builder,
            name: "Builder",
            anyName: .some(minLenght: 7),
            features: [
                Loc.Membership.Feature.storageGB(128),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers("Unlimited")
            ],
            paymentType: .mockExternal
        )
    }
    
    static var mockCoCreator: MembershipTier {
        MembershipTier(
            type: .coCreator,
            name: "CockCreator",
            anyName: .some(minLenght: 5),
            features: [
                Loc.Membership.Feature.storageGB(256),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers("Unlimited")
            ],
            paymentType: .mockExternal
        )
    }
    
    static var mockCustom: MembershipTier {
        MembershipTier(
            type: .custom(id: 228),
            name: "Na-Baron",
            anyName: .some(minLenght: 3),
            features: [
                Loc.Membership.Feature.storageGB(2560),
                Loc.Membership.Feature.sharedSpaces(333),
                Loc.Membership.Feature.spaceWriters(100),
                Loc.Membership.Feature.viewers("Unlimited")
            ],
            paymentType: .mockExternal
        )
    }
}
