import Testing
@testable import Anytype

struct UnifiedSearchChipModelTests {

    @Test
    func refinementPackagePutsSelectorsBeforeIndividualSuggestions() {
        let people = [
            UnifiedSearchChipModel(token: .creator(identity: "person-1"), title: "One")
        ]
        let channels = [
            UnifiedSearchChipModel(token: .space(spaceId: "space-1"), title: "Channel")
        ]

        let package = UnifiedSearchChipModel.refinementPackage(
            people: people,
            channels: channels,
            individualLimit: 5
        )

        #expect(package.map(\.action) == [
            .openChannelsPicker,
            .openPeoplePicker,
            people[0].action,
            channels[0].action
        ])
    }

    @Test
    func refinementPackageLimitsEachIndividualGroup() {
        let people = (0..<7).map {
            UnifiedSearchChipModel(token: .creator(identity: "person-\($0)"), title: "Person \($0)")
        }
        let channels = (0..<8).map {
            UnifiedSearchChipModel(token: .space(spaceId: "space-\($0)"), title: "Channel \($0)")
        }

        let package = UnifiedSearchChipModel.refinementPackage(
            people: people,
            channels: channels,
            individualLimit: 5
        )

        #expect(package.count == 12)
        #expect(package[2..<7].map(\.action) == people.prefix(5).map(\.action))
        #expect(package[7..<12].map(\.action) == channels.prefix(5).map(\.action))
    }

    @Test
    func refinementPackageKeepsCurrentChannelWithinLimit() {
        let channels = (0..<6).map {
            UnifiedSearchChipModel(token: .space(spaceId: "space-\($0)"), title: "Channel \($0)")
        }

        let package = UnifiedSearchChipModel.refinementPackage(
            people: [],
            channels: channels,
            prioritizedChannelSpaceId: "space-5",
            individualLimit: 5
        )

        #expect(package.map(\.action) == [
            .openChannelsPicker,
            channels[5].action,
            channels[0].action,
            channels[1].action,
            channels[2].action,
            channels[3].action
        ])
    }

    @Test
    func refinementPackageOmitsSelectorForEmptyGroup() {
        let channel = UnifiedSearchChipModel(token: .space(spaceId: "space-1"), title: "Channel")

        let package = UnifiedSearchChipModel.refinementPackage(
            people: [],
            channels: [channel],
            individualLimit: 5
        )

        #expect(package.map(\.action) == [.openChannelsPicker, channel.action])
    }
}
