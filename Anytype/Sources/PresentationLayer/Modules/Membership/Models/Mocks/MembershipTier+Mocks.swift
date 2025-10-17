import Services


extension MembershipTier {
    static var mockStarter: MembershipTier {
        MembershipTier(
            type: .starter,
            name: "Starter",
            description: "Starter description",
            anyName: .none,
            features: [
                Loc.Membership.Feature.storageGB(1),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(3),
                Loc.Membership.Feature.viewers(3)
            ],
            paymentType: nil,
            color: .green,
            isTest: false,
            iosProductID: ""
        )
    }

    static var mockBuilder: MembershipTier {
        MembershipTier(
            type: .builder,
            name: "Builder",
            description: "Builder description",
            anyName: .some(minLenght: 7),
            features: [
                Loc.Membership.Feature.storageGB(128),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers(999)
            ],
            paymentType: .mockExternal,
            color: .blue,
            isTest: false,
            iosProductID: "io.anytype.membership.builder"
        )
    }

    static var mockCoCreator: MembershipTier {
        MembershipTier(
            type: .coCreator,
            name: "CockCreator",
            description: "CockCreator description",
            anyName: .some(minLenght: 5),
            features: [
                Loc.Membership.Feature.storageGB(256),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers(999)
            ],
            paymentType: .mockExternal,
            color: .red,
            isTest: false,
            iosProductID: "io.anytype.membership.cocreator"
        )
    }

    static var mockCustom: MembershipTier {
        MembershipTier(
            type: .custom(id: 228),
            name: "Na-Baron",
            description: "Noble title given to a Baron's heir-apparent",
            anyName: .some(minLenght: 3),
            features: [
                Loc.Membership.Feature.storageGB(2560),
                Loc.Membership.Feature.sharedSpaces(333),
                Loc.Membership.Feature.spaceWriters(100),
                Loc.Membership.Feature.viewers(999)
            ],
            paymentType: .mockExternal,
            color: .purple,
            isTest: false,
            iosProductID: "io.anytype.membership.custom"
        )
    }

    static var mockBuilderTest: MembershipTier {
        MembershipTier(
            type: .custom(id: 1337),
            name: "Builder TEST",
            description: "Builder TEST description",
            anyName: .none,
            features: [
                Loc.Membership.Feature.storageGB(128),
                Loc.Membership.Feature.sharedSpaces(3),
                Loc.Membership.Feature.spaceWriters(10),
                Loc.Membership.Feature.viewers(999)
            ],
            paymentType: .mockExternal,
            color: .blue,
            isTest: true,
            iosProductID: "io.anytype.membership.builder.test"
        )
    }
}
