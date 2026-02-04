import Foundation
import Services
import AnytypeCore
import UIKit

@MainActor
@Observable
final class BookmarkCreateViewModel {

    let data: BookmarkCreateScreenData

    @ObservationIgnored
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol

    // MARK: - State

    var urlText = ""
    var isLoading = false
    var dismiss = false
    var toastBarData: ToastBarData?

    @ObservationIgnored
    var pageNavigation: PageNavigation?

    var isCreateDisabled: Bool {
        urlText.isEmpty || isLoading
    }

    init(data: BookmarkCreateScreenData) {
        self.data = data
    }

    func onTapCreate() {
        guard !isLoading else { return }
        guard urlText.isNotEmpty else { return }
        guard let url = AnytypeURL(string: urlText) else {
            toastBarData = ToastBarData(Loc.Set.Bookmark.Error.message, type: .failure)
            return
        }

        isLoading = true

        Task {
            defer { isLoading = false }

            let details: ObjectDetails
            do {
                let type = try? objectTypeProvider.objectType(uniqueKey: .bookmark, spaceId: data.spaceId)
                details = try await bookmarkService.createBookmarkObject(
                    spaceId: data.spaceId,
                    url: url,
                    templateId: type?.defaultTemplateId,
                    origin: .none
                )
            } catch {
                toastBarData = ToastBarData(error.localizedDescription, type: .failure)
                return
            }

            if let collectionId = data.collectionId {
                try? await objectActionsService.addObjectsToCollection(
                    contextId: collectionId,
                    objectIds: [details.id]
                )
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateObject(
                objectType: details.analyticsType,
                spaceId: details.spaceId,
                route: data.analyticsRoute
            )
            SharingTip.didCopyText = true

            dismiss = true
            pageNavigation?.open(details.screenData())
        }
    }
}
