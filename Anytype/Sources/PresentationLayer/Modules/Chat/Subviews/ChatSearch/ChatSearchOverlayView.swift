import SwiftUI

struct ChatSearchOverlayView: View {

    @Bindable var model: ChatViewModel

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ChatSearchInputBar(text: $model.searchQuery) {
                    model.onTapCloseSearch()
                }
            }
            .background(Color.Background.primary.ignoresSafeArea())
            .task(id: model.searchQuery) {
                await model.searchMessages()
            }
    }

    private var content: some View {
        ZStack {
            if showEmptyState {
                EmptyStateView(title: Loc.nothingFound, style: .withImage)
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(model.searchResults) { data in
                                ChatSearchResultRow(data: data) {
                                    model.onSelectSearchResult(data)
                                }
                            }
                        }
                        // Keep short result lists pinned above the search bar instead of the screen top
                        .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .bottom)
                    }
                }
            }
            if model.searchInProgress {
                CircleLoadingView(.Control.primary)
                    .frame(width: 24, height: 24)
            }
        }
    }

    private var showEmptyState: Bool {
        model.searchQuery.isNotEmpty && !model.searchInProgress && model.searchResults.isEmpty
    }
}
