import Testing
import Foundation
import Combine
@testable import Anytype

@Suite(.serialized)
final class HomeSectionsStorageTests {

    private let sut: HomeSectionsStorage

    init() {
        UserDefaults.standard.removeObject(forKey: HomeSectionsStorage.userDefaultsKey)
        self.sut = HomeSectionsStorage()
    }

    deinit {
        UserDefaults.standard.removeObject(forKey: HomeSectionsStorage.userDefaultsKey)
    }

    @Test func returnsDefaultWhenNoRecordExists() {
        #expect(sut.configuration(spaceId: "space-1") == .default)
    }

    @Test func setAndGetRoundTrip() {
        let custom = HomeSectionsConfiguration(visibleSections: [.unread, .objects])
        sut.setConfiguration(custom, spaceId: "space-1")

        #expect(sut.configuration(spaceId: "space-1") == custom)
    }

    @Test func isolationBetweenSpaces() {
        let custom = HomeSectionsConfiguration(visibleSections: [.bin])
        sut.setConfiguration(custom, spaceId: "space-A")

        #expect(sut.configuration(spaceId: "space-A") == custom)
        #expect(sut.configuration(spaceId: "space-B") == .default)
    }

    @Test func publisherEmitsCurrentValueOnSubscribe() {
        var received: [HomeSectionsConfiguration] = []
        let cancellable = sut.configurationPublisher(spaceId: "space-1")
            .sink { received.append($0) }
        defer { cancellable.cancel() }

        #expect(received == [.default])
    }

    @Test func publisherEmitsOnUpdate() {
        var received: [HomeSectionsConfiguration] = []
        let cancellable = sut.configurationPublisher(spaceId: "space-1")
            .sink { received.append($0) }
        defer { cancellable.cancel() }

        let custom = HomeSectionsConfiguration(visibleSections: [.bin])
        sut.setConfiguration(custom, spaceId: "space-1")

        #expect(received == [.default, custom])
    }

    @Test func publisherIgnoresUnrelatedSpaceUpdates() {
        var received: [HomeSectionsConfiguration] = []
        let cancellable = sut.configurationPublisher(spaceId: "space-1")
            .sink { received.append($0) }
        defer { cancellable.cancel() }

        let other = HomeSectionsConfiguration(visibleSections: [.bin])
        sut.setConfiguration(other, spaceId: "space-2")

        #expect(received == [.default])
    }
}
