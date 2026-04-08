import SwiftUI

struct DiscussionEmbedBlockView: View {

    @State private var model: EmbedContentViewModel

    var body: some View {
        EmbedContentView(model: model)
    }

    init(data: EmbedContentData) {
        self._model = State(initialValue: EmbedContentViewModel(data: data))
    }
}
