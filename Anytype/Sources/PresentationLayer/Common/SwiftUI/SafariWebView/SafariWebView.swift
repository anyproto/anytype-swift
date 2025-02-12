import SwiftUI
import SafariServices

extension View {
    func safariFullScreen(url: Binding<URL?>) -> some View {
        self.fullScreenCover(item: url) {
            SafariWebView(url: $0)
                .ignoresSafeArea()
        }
    }
    
    func safariSheet(url: Binding<URL?>) -> some View {
        self.sheet(item: url) {
            SafariWebView(url: $0)
                .ignoresSafeArea()
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        let safariController = SFSafariViewController(url: url)        
        return safariController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SafariWebView(url: URL(string: "http://anytype.io")!)
}
