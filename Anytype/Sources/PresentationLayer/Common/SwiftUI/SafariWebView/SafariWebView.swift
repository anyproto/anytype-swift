import SwiftUI
import SafariServices

extension View {
    func safariFullScreen(url: Binding<URL?>, preferredColorScheme: UIUserInterfaceStyle? = nil) -> some View {
        self.fullScreenCover(item: url) {
            SafariWebView(url: $0, preferredColorScheme: preferredColorScheme).ignoresSafeArea()
        }
    }
    
    func safariSheet(url: Binding<URL?>, preferredColorScheme: UIUserInterfaceStyle? = nil) -> some View {
        self.sheet(item: url) {
            SafariWebView(url: $0, preferredColorScheme: preferredColorScheme)
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    let preferredColorScheme: UIUserInterfaceStyle?
    
    init(url: URL, preferredColorScheme: UIUserInterfaceStyle? = nil) {
        self.url = url
        self.preferredColorScheme = preferredColorScheme
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        let safariController = SFSafariViewController(url: url)
        preferredColorScheme.flatMap { safariController.overrideUserInterfaceStyle = $0 }
        
        return safariController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariWebView(url: URL(string: "http://anytype.io")!)
}
