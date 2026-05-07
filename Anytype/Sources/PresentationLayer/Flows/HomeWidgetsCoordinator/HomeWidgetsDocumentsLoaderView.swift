import SwiftUI
import Services

struct HomeWidgetsDocumentsLoaderView<Content: View>: View {

    private let info: AccountInfo
    private let content: (_ channelWidgets: any BaseDocumentProtocol,
                          _ personalWidgets: any BaseDocumentProtocol) -> Content

    @State private var model: HomeWidgetsDocumentsLoaderViewModel

    init(
        info: AccountInfo,
        @ViewBuilder content: @escaping (any BaseDocumentProtocol, any BaseDocumentProtocol) -> Content
    ) {
        self.info = info
        self.content = content
        self._model = State(wrappedValue: HomeWidgetsDocumentsLoaderViewModel(info: info))
    }

    var body: some View {
        ZStack {
            if let documents = model.documents {
                content(documents.channelWidgets, documents.personalWidgets)
            } else {
                // Bridge frame between SpaceLoadingContainerView's loading state and content.
                // Same wallpaper background, no icon — pulse already played in SpaceLoadingContainerView.
                HomeWallpaperView(spaceId: info.accountSpaceId)
            }
        }
        .task {
            await model.openDocuments()
        }
    }
}
