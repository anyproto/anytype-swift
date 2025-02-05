import SwiftUI
import SafariServices

struct SafariBookmarkView: UIViewControllerRepresentable {
    let url: URL
    let onOpenObject: () -> Void
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        let safariController = SFSafariViewController(url: url)
        safariController.delegate = context.coordinator
        return safariController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        context.coordinator.onOpenObject = onOpenObject
    }
    
    func makeCoordinator() -> SafariBookmarkViewCoordinator {
        SafariBookmarkViewCoordinator()
    }
}

final class SafariBookmarkViewCoordinator: NSObject, SFSafariViewControllerDelegate {
    
    var onOpenObject: (() -> Void)?
    
    func safariViewController(
        _ controller: SFSafariViewController,
        activityItemsFor URL: URL,
        title: String?
    ) -> [UIActivity] {
        let activity = OpenObjectActivity { [weak self] in
            self?.onOpenObject?()
        }
        return [activity]
    }
}

