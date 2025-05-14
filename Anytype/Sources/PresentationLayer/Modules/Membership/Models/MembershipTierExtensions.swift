import SwiftUI
import Services
import AnytypeCore


extension MembershipTier {
    var subtitle: String {
        switch self.type {
        case .starter:
            return Loc.Membership.Starter.subtitle
        case .builder:
            return Loc.Membership.Builder.subtitle
        case .coCreator:
            return Loc.Membership.CoCreator.subtitle
        case .custom:
            return Loc.Membership.Custom.subtitle
        case .anyTeam:
            return "This special tier with extended limits and more. Thank you for being an integral part of Team Any."
        }
    }
    
    var mediumIcon: ImageAsset {
        switch color {
        case .green:
            return .Membership.tierStarterMedium
        case .blue:
            return .Membership.tierBuilderMedium
        case .red:
            return .Membership.tierCocreatorMedium
        case .purple:
            return .Membership.tierCustomMedium
        }
    }
    
    var smallIcon: ImageAsset {
        switch color {
        case .green:
            .Membership.tierStarterSmall
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
        case .starter:
            Loc.Membership.Success.curiosity
        case .builder, .coCreator, .custom, .anyTeam:
            Loc.Membership.Success.support
        }
    }
}
