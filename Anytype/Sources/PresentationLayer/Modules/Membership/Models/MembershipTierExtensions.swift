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
    
    var featureDescriptions: [String] {
        var featureDescriptions = [anyName.description]
        featureDescriptions.append(contentsOf: features.map(\.description))
        return featureDescriptions
    }
}

extension MembershipAnyName {
    var description: String {
        switch self {
        case .none:
            Loc.Membership.Feature.localName
        case .some(let minLenght):
            Loc.Membership.Feature.uniqueName(minLenght)
        }
    }
}

extension MembershipFeature {
    var description: String {
        switch self {
        case .storageGbs(let value):
            Loc.Membership.Feature.storageGB(value)
        case .invites(let value):
            Loc.Membership.Feature.invites(value)
        case .spaceWriters(let value):
            Loc.Membership.Feature.spaceWriters(value)
        case .spaceReaders(let value):
            switch value {
            case .int(let intValue):
                if intValue == 1024 { // Middleware understanding of Unlimited
                    Loc.Membership.Feature.unlimitedViewers
                } else {
                    Loc.Membership.Feature.viewers(intValue)
                }
            case .string(let stringValue):
                Loc.Membership.Feature.viewers(stringValue)
            }
        case .sharedSpaces(let value):
            Loc.Membership.Feature.sharedSpaces(value)
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
                .storageGbs(.int(1)),
                .sharedSpaces(.int(3)),
                .spaceWriters(.int(3)),
                .spaceReaders(.int(3))
            ]
        )
    }
    
    static var mockBuilder: MembershipTier {
        MembershipTier(
            type: .builder,
            name: "Builder",
            anyName: .some(minLenght: 7),
            features: [
                .storageGbs(.int(128)),
                .sharedSpaces(.int(3)),
                .spaceWriters(.int(10)),
                .spaceReaders(.int(1024))
            ]
        )
    }
    
    static var mockCoCreator: MembershipTier {
        MembershipTier(
            type: .coCreator,
            name: "CockCreator",
            anyName: .some(minLenght: 5),
            features: [
                .storageGbs(.int(256)),
                .sharedSpaces(.int(3)),
                .spaceWriters(.int(10)),
                .spaceReaders(.int(1024))
            ]
        )
    }
    
    static var mockCustom: MembershipTier {
        MembershipTier(
            type: .custom(id: 228),
            name: "Na-Baron",
            anyName: .some(minLenght: 3),
            features: [
                .storageGbs(.int(2560)),
                .sharedSpaces(.int(333)),
                .spaceWriters(.int(100)),
                .spaceReaders(.int(1024)),
            ]
        )
    }
}
