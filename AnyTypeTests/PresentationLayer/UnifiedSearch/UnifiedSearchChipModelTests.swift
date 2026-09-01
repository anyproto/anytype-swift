import Testing
@testable import Anytype

struct UnifiedSearchChipModelTests {

    @Test
    func channelScopePackageAppendsPickerToIndividualChannels() {
        let individualChips = [
            UnifiedSearchChipModel(token: .space(spaceId: "space-1"), title: "One"),
            UnifiedSearchChipModel(token: .space(spaceId: "space-2"), title: "Two")
        ]

        let package = UnifiedSearchChipModel.channelScopePackage(individualChips: individualChips)

        #expect(package.dropLast() == individualChips[...])
        #expect(package.last?.action == .openChannelsPicker)
    }

    @Test
    func channelScopePackageIsEmptyWithoutIndividualChannels() {
        #expect(UnifiedSearchChipModel.channelScopePackage(individualChips: []).isEmpty)
    }
}
