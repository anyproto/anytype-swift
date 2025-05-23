import SwiftUI
import Services
import AnytypeCore


extension MembershipTier {    
    var mediumIcon: ImageAsset {
        switch color {
        case .green:
            .Membership.tierStarterMedium
        case .blue:
            .Membership.tierBuilderMedium
        case .red:
            .Membership.tierCocreatorMedium
        case .purple:
            .Membership.tierCustomMedium
        case .ice:
            .Membership.tierExplorerMedium
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
        case .ice:
            .Membership.tierExplorerSmall
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
        case .ice:
            .ice
        }
    }
    
    var successMessage: String {
        switch self.type {
        case .starter, .legacyExplorer:
            Loc.Membership.Success.curiosity
        case .builder, .coCreator, .custom, .anyTeam, .explorer:
            Loc.Membership.Success.support
        }
    }
}
