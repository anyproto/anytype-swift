import Services


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
            paymentType: .email,
            color: .green
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
            paymentType: .mockExternal,
            color: .blue
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
            paymentType: .mockExternal,
            color: .red
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
            paymentType: .mockExternal,
            color: .purple
        )
    }
    
    static var mockBuilderTest: MembershipTier {
        MembershipTier(
            type: .custom(id: 1337),
            name: "Builder TEST",
            anyName: .none,
            features: [
                Loc.Membership.Feature.storageGB(128),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers("Unlimited")
            ],
            paymentType: .mockExternal,
            color: .blue
        )
    }
}
