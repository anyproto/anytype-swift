import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class HomeWidgetsDocumentsLoaderViewModel {
    struct Documents {
        let channelWidgets: any BaseDocumentProtocol
        let personalWidgets: any BaseDocumentProtocol
    }

    @ObservationIgnored
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol

    @ObservationIgnored
    private let info: AccountInfo

    var documents: Documents?

    init(info: AccountInfo) {
        self.info = info
    }

    func openDocuments() async {
        let channel = documentsProvider.document(
            objectId: info.widgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )
        let personal = documentsProvider.document(
            objectId: info.personalWidgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )

        await withTaskGroup(of: Void.self) { group in
            group.addTask { try? await channel.open() }
            group.addTask { try? await personal.open() }
        }

        documents = Documents(channelWidgets: channel, personalWidgets: personal)
    }
}
