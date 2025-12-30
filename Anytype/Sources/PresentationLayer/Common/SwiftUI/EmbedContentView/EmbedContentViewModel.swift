import SwiftUI

@MainActor
@Observable
final class EmbedContentViewModel {

    let data: EmbedContentData

    var safariUrl: URL?
    
    init(data: EmbedContentData) {
        self.data = data
    }

    func onOpenTap() {
        safariUrl = data.url
    }
}
