import Testing
import Foundation
@testable import Anytype
import Services
import Factory

@Suite(.serialized)
@MainActor
struct WidgetsObjectsStorageTests {

    private let documentsProvider: TestDocumentsProvider
    private let sut: WidgetsObjectsStorage

    init() {
        let documentsProvider = TestDocumentsProvider()
        Container.shared.documentsProvider.register { documentsProvider }
        self.documentsProvider = documentsProvider
        self.sut = WidgetsObjectsStorage()
    }

    @Test func prepare_opensBothDocsForSpace() async {
        let info = makeInfo(spaceId: "A")
        let channel = MockBaseDocument(objectId: info.widgetsId)
        let personal = MockBaseDocument(objectId: info.personalWidgetsId)
        documentsProvider.register(objectId: info.widgetsId, doc: channel)
        documentsProvider.register(objectId: info.personalWidgetsId, doc: personal)
        var channelOpened = false
        var personalOpened = false
        channel.openHandler = { channelOpened = true }
        personal.openHandler = { personalOpened = true }

        sut.prepare(info: info)
        await sut.waitForReady(spaceId: info.accountSpaceId)

        #expect(channelOpened)
        #expect(personalOpened)
        let docs = sut.widgetsObjects(spaceId: info.accountSpaceId)
        #expect(docs?.channel.objectId == info.widgetsId)
        #expect(docs?.personal.objectId == info.personalWidgetsId)
    }

    @Test func prepare_sameSpaceTwice_doesNotReopen() async {
        let info = makeInfo(spaceId: "A")
        let channel = MockBaseDocument(objectId: info.widgetsId)
        let personal = MockBaseDocument(objectId: info.personalWidgetsId)
        documentsProvider.register(objectId: info.widgetsId, doc: channel)
        documentsProvider.register(objectId: info.personalWidgetsId, doc: personal)

        sut.prepare(info: info)
        await sut.waitForReady(spaceId: info.accountSpaceId)
        let firstCallCount = documentsProvider.callCount(objectId: info.widgetsId)

        sut.prepare(info: info)
        await sut.waitForReady(spaceId: info.accountSpaceId)

        #expect(documentsProvider.callCount(objectId: info.widgetsId) == firstCallCount)
    }

    @Test func prepare_differentSpace_dropsPreviousAndOpensNew() async {
        let infoA = makeInfo(spaceId: "A")
        let infoB = makeInfo(spaceId: "B")
        documentsProvider.register(objectId: infoA.widgetsId, doc: MockBaseDocument(objectId: infoA.widgetsId))
        documentsProvider.register(objectId: infoA.personalWidgetsId, doc: MockBaseDocument(objectId: infoA.personalWidgetsId))
        documentsProvider.register(objectId: infoB.widgetsId, doc: MockBaseDocument(objectId: infoB.widgetsId))
        documentsProvider.register(objectId: infoB.personalWidgetsId, doc: MockBaseDocument(objectId: infoB.personalWidgetsId))

        sut.prepare(info: infoA)
        await sut.waitForReady(spaceId: infoA.accountSpaceId)
        sut.prepare(info: infoB)
        await sut.waitForReady(spaceId: infoB.accountSpaceId)

        #expect(sut.widgetsObjects(spaceId: infoA.accountSpaceId) == nil)
        let docsB = sut.widgetsObjects(spaceId: infoB.accountSpaceId)
        #expect(docsB?.channel.objectId == infoB.widgetsId)
        #expect(docsB?.personal.objectId == infoB.personalWidgetsId)
    }

    @Test func waitForReady_unknownSpace_returnsImmediately() async {
        await sut.waitForReady(spaceId: "never-prepared")
        #expect(sut.widgetsObjects(spaceId: "never-prepared") == nil)
    }

    @Test func prepare_openThrows_stillExposesDocs() async {
        let info = makeInfo(spaceId: "A")
        let channel = MockBaseDocument(objectId: info.widgetsId)
        channel.openHandler = { throw TestError.openFailed }
        let personal = MockBaseDocument(objectId: info.personalWidgetsId)
        documentsProvider.register(objectId: info.widgetsId, doc: channel)
        documentsProvider.register(objectId: info.personalWidgetsId, doc: personal)

        sut.prepare(info: info)
        await sut.waitForReady(spaceId: info.accountSpaceId)

        #expect(sut.widgetsObjects(spaceId: info.accountSpaceId) != nil)
    }

    // MARK: - Helpers

    private func makeInfo(spaceId: String) -> AccountInfo {
        AccountInfo(
            homeObjectID: "",
            archiveObjectID: "",
            profileObjectID: "",
            gatewayURL: "",
            accountSpaceId: spaceId,
            spaceViewId: "",
            widgetsId: "\(spaceId)-channel",
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

private enum TestError: Error {
    case openFailed
}

private final class TestDocumentsProvider: DocumentsProviderProtocol, @unchecked Sendable {
    private var documentsByObjectId: [String: any BaseDocumentProtocol] = [:]
    private var callCounts: [String: Int] = [:]

    func register(objectId: String, doc: any BaseDocumentProtocol) {
        documentsByObjectId[objectId] = doc
    }

    func callCount(objectId: String) -> Int {
        callCounts[objectId] ?? 0
    }

    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        callCounts[objectId, default: 0] += 1
        if let doc = documentsByObjectId[objectId] {
            return doc
        }
        let fallback = MockBaseDocument(objectId: objectId)
        documentsByObjectId[objectId] = fallback
        return fallback
    }

    func setDocument(
        objectId: String,
        spaceId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        fatalError("setDocument not used by WidgetsObjectsStorageTests")
    }
}
