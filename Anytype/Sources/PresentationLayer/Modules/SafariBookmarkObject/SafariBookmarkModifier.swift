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
            .sheet(item: $screenData) { data in
                SafariBookmarkView(url: data.url) {
                    screenData = nil
                    onOpenBookmarkAsObject(data)
                }
                .ignoresSafeArea()
            }
    }
}
