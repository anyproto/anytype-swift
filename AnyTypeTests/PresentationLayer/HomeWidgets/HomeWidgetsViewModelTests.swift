import Testing
import Foundation
@testable import Anytype
import Services
import Factory

@Suite(.serialized)
@MainActor
struct HomeWidgetsViewModelTests {

    private let widgetsStorage: TestWidgetsObjectsStorage

    init() {
        let widgetsStorage = TestWidgetsObjectsStorage()
        Container.shared.widgetsObjectsStorage.register { widgetsStorage }
        // VM still injects documentsProvider for set/homepage docs; provide a no-op stub
        // so test resolution doesn't pick up a stale registration from another suite.
        Container.shared.documentsProvider.register { TestDocumentsProvider() }
        self.widgetsStorage = widgetsStorage
    }

    // MARK: - openWidgetObjects

    @Test func openWidgetObjects_storageHasBothDocs_setsBothObjects() async {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        let channel = MockBaseDocument(objectId: info.widgetsId)
        let personal = MockBaseDocument(objectId: info.personalWidgetsId)
        widgetsStorage.preload(spaceId: info.accountSpaceId, channel: channel, personal: personal)
        let model = HomeWidgetsViewModel(info: info, output: nil)

        await model.openWidgetObjects()

        #expect(model.channelWidgetsObject?.objectId == info.widgetsId)
        #expect(model.personalWidgetsObject?.objectId == info.personalWidgetsId)
    }

    @Test func openWidgetObjects_storageReturnsNil_leavesObjectsNil() async {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        let model = HomeWidgetsViewModel(info: info, output: nil)

        await model.openWidgetObjects()

        #expect(model.channelWidgetsObject == nil)
        #expect(model.personalWidgetsObject == nil)
    }

    @Test func widgetObjects_areNilBeforeOpenWidgetObjectsResolves() {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        let model = HomeWidgetsViewModel(info: info, output: nil)

        #expect(model.channelWidgetsObject == nil)
        #expect(model.personalWidgetsObject == nil)
    }

    // MARK: - Helpers

    private func makeAccountInfo(widgetsId: String, spaceId: String) -> AccountInfo {
        AccountInfo(
            homeObjectID: "",
            archiveObjectID: "",
            profileObjectID: "",
            gatewayURL: "",
            accountSpaceId: spaceId,
            spaceViewId: "",
            widgetsId: widgetsId,
            analyticsId: "",
            deviceId: "",
            networkId: "",
            techSpaceId: "",
            ethereumAddress: "",
            spaceChatId: "",
            metadataKey: ""
        )
    }
}

// MARK: - Inline test mocks

@MainActor
private final class TestWidgetsObjectsStorage: WidgetsObjectsStorageProtocol {
    private var spaceId: String?
    private var channel: (any BaseDocumentProtocol)?
    private var personal: (any BaseDocumentProtocol)?

    func preload(spaceId: String, channel: any BaseDocumentProtocol, personal: any BaseDocumentProtocol) {
        self.spaceId = spaceId
        self.channel = channel
        self.personal = personal
    }

    func prepare(info: AccountInfo) {}
    func waitForReady(spaceId: String) async {}

    func channelWidgetsObject(spaceId: String) -> (any BaseDocumentProtocol)? {
        guard self.spaceId == spaceId else { return nil }
        return channel
    }

    func personalWidgetsObject(spaceId: String) -> (any BaseDocumentProtocol)? {
        guard self.spaceId == spaceId else { return nil }
        return personal
    }
}

private final class TestDocumentsProvider: DocumentsProviderProtocol, @unchecked Sendable {
    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        MockBaseDocument(objectId: objectId)
    }

    func setDocument(
        objectId: String,
        spaceId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        fatalError("setDocument not used by HomeWidgetsViewModelTests")
    }
}
