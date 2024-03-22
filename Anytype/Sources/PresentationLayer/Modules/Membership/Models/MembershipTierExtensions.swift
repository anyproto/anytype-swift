import SwiftUI
import Services
import AnytypeCore


extension Optional where Wrapped == MembershipTier {
    var availableTiers: [MembershipTier] {
        switch self {
        case .none:
            [.explorer, .builder, .coCreator ]
        case .some(let tier):
            switch tier {
            case .custom(let id):
                [.custom(id: id), .builder, .coCreator ]
            case .explorer:
                [.explorer, .builder, .coCreator ]
            case .builder:
                [.builder, .coCreator ]
            case .coCreator:
                [.coCreator ]
            }
        }
    }
}

extension MembershipTier {
    var title: String {
        switch self {
        case .explorer:
            return Loc.Membership.Explorer.title
        case .builder:
            return Loc.Membership.Builder.title
        case .coCreator:
            return Loc.Membership.CoCreator.title
        case .custom:
            return Loc.Membership.Custom.title
        }
    }
    
    var subtitle: String {
        switch self {
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
    
    var benefits: [String] {
        switch self {
        case .explorer:
            [
                Loc.Membership.Explorer.benefit1,
                Loc.Membership.Explorer.benefit2,
                Loc.Membership.Explorer.benefit3
            ]
        case .builder:
            [
                Loc.Membership.Builder.benefit1,
                Loc.Membership.Builder.benefit2,
                Loc.Membership.Builder.benefit3,
                Loc.Membership.Builder.benefit4
            ]
        case .coCreator:
            [
                Loc.Membership.CoCreator.benefit1,
                Loc.Membership.CoCreator.benefit2,
                Loc.Membership.CoCreator.benefit3,
                Loc.Membership.CoCreator.benefit4,
                Loc.Membership.CoCreator.benefit5
            ]
        case .custom:
            [
                // TBD in future updates
            ]
        }
    }
    
    var mediumIcon: ImageAsset {
        switch self {
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
        switch self {
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
        switch self {
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
}
