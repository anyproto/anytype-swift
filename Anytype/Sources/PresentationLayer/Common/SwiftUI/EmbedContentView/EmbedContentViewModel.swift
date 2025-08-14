import SwiftUI

@MainActor
final class EmbedContentViewModel: ObservableObject {
    
    let data: EmbedContentData

    @Published var safariUrl: URL?
    
    init(data: EmbedContentData) {
        self.data = data
    }

    func onOpenTap() {
        safariUrl = data.url
    }
}
