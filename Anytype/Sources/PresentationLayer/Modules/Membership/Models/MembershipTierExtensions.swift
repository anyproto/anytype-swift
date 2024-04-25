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
        switch color {
        case .green:
            return .Membership.tierExplorerMedium
        case .blue:
            return .Membership.tierBuilderMedium
        case .red:
            return .Membership.tierCocreatorMedium
        case .purple:
            anytypeAssertionFailure("Unsupported asset mediumIcon for custom tier")
            return .ghost
        }
    }
    
    var smallIcon: ImageAsset {
        switch color {
        case .green:
            .Membership.tierExplorerSmall
        case .blue:
            .Membership.tierBuilderSmall
        case .red:
            .Membership.tierCocreatorSmall
        case .purple:
            .Membership.tierCustomSmall
        }
    }
    
    var gradient: MembershipTierGradient {
        switch color {
        case .green:
            .teal
        case .blue:
            .blue
        case .red:
            .red
        case .purple:
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
