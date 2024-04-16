import SwiftUI
import SafariServices

extension View {
    func safariView(url: Binding<URL?>) -> some View {
        self.fullScreenCover(item: url) {
            SafariWebView(url: $0).ignoresSafeArea()
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariWebView(url: URL(string: "http://anytype.io")!)
}
