import Foundation
import SwiftUI

extension View {
    func safariBookmarkObject(
        _ data: Binding<BookmarkScreenData?>,
        onOpenBookmarkAsObject: @escaping (_ data: BookmarkScreenData) -> Void
    ) -> some View {
        modifier(SafariBookmarkModifier(screenData: data, onOpenBookmarkAsObject: onOpenBookmarkAsObject))
    }
}

struct SafariBookmarkModifier: ViewModifier {

    @Binding var screenData: BookmarkScreenData?
    var onOpenBookmarkAsObject: (_ data: BookmarkScreenData) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: screenData) { _, newValue in
                guard let url = newValue?.url, !url.containsHttpProtocol else { return }
                screenData = nil
                UIApplication.shared.open(url)
            }
            .sheet(item: safariBinding) { data in
                SafariBookmarkView(url: data.url) {
                    screenData = nil
                    onOpenBookmarkAsObject(data)
                }
                .ignoresSafeArea()
            }
    }

    private var safariBinding: Binding<BookmarkScreenData?> {
        Binding(
            get: { screenData?.url.containsHttpProtocol == true ? screenData : nil },
            set: { screenData = $0 }
        )
    }
}
