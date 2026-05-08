import Testing
import Foundation
@testable import Anytype
import Services
import Factory

@Suite(.serialized)
@MainActor
struct HomeWidgetsViewModelTests {

    private let documentsProvider: TestDocumentsProvider

    init() {
        let documentsProvider = TestDocumentsProvider()
        Container.shared.documentsProvider.register { documentsProvider }
        self.documentsProvider = documentsProvider
    }

    // MARK: - openDocuments

    @Test func openDocuments_bothSucceed_setsDocsAndDocumentsReadyTrue() async {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        documentsProvider.register(objectId: info.widgetsId, doc: MockBaseDocument(objectId: info.widgetsId))
        documentsProvider.register(objectId: info.personalWidgetsId, doc: MockBaseDocument(objectId: info.personalWidgetsId))
        let model = HomeWidgetsViewModel(info: info, output: nil)

        await model.openDocuments()

        #expect(model.channelWidgetsObject?.objectId == info.widgetsId)
        #expect(model.personalWidgetsObject?.objectId == info.personalWidgetsId)
        #expect(model.documentsReady)
        #expect(documentsProvider.requestedObjectIds.contains(info.widgetsId))
        #expect(documentsProvider.requestedObjectIds.contains(info.personalWidgetsId))
    }

    @Test func openDocuments_oneOpenThrows_stillSetsDocsAndFlipsGate() async {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        let channelDoc = MockBaseDocument(objectId: info.widgetsId)
        channelDoc.openHandler = { throw TestError.openFailed }
        let personalDoc = MockBaseDocument(objectId: info.personalWidgetsId)
        documentsProvider.register(objectId: info.widgetsId, doc: channelDoc)
        documentsProvider.register(objectId: info.personalWidgetsId, doc: personalDoc)
        let model = HomeWidgetsViewModel(info: info, output: nil)

        await model.openDocuments()

        #expect(model.channelWidgetsObject?.objectId == info.widgetsId)
        #expect(model.personalWidgetsObject?.objectId == info.personalWidgetsId)
        #expect(model.documentsReady)
    }

    @Test func documentsReady_isFalseBeforeOpenDocumentsResolves() {
        let info = makeAccountInfo(widgetsId: "channel-id", spaceId: "space-id")
        let model = HomeWidgetsViewModel(info: info, output: nil)

        #expect(model.channelWidgetsObject == nil)
        #expect(model.personalWidgetsObject == nil)
        #expect(!model.documentsReady)
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

private enum TestError: Error {
    case openFailed
}

private final class TestDocumentsProvider: DocumentsProviderProtocol, @unchecked Sendable {
    private var documentsByObjectId: [String: any BaseDocumentProtocol] = [:]
    private(set) var requestedObjectIds: [String] = []

    func register(objectId: String, doc: any BaseDocumentProtocol) {
        documentsByObjectId[objectId] = doc
    }

    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        requestedObjectIds.append(objectId)
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
        fatalError("setDocument not used by HomeWidgetsViewModel")
    }
}
