import SwiftUI


enum MembershipTier: String, Identifiable, CaseIterable {
    case explorer
    case builder
    case coCreator
    
    var id: String { rawValue }
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
        }
    }
    
    var mediumIcon: ImageAsset {
        switch self {
        case .explorer:
            .Membership.tierExplorerMedium
        case .builder:
            .Membership.tierBuilderMedium
        case .coCreator:
            .Membership.tierCocreatorMedium
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
        }
    }
}
