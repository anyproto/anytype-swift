import SwiftUI
import SafariServices

extension View {
    func safariFullScreen(url: Binding<URL?>) -> some View {
        self
            .modifier(NonHttpURLRouter(url: url))
            .fullScreenCover(item: safariOnlyBinding(url)) {
                SafariWebView(url: $0)
                    .ignoresSafeArea()
            }
    }

    func safariSheet(url: Binding<URL?>) -> some View {
        self
            .modifier(NonHttpURLRouter(url: url))
            .sheet(item: safariOnlyBinding(url)) {
                SafariWebView(url: $0)
                    .ignoresSafeArea()
            }
    }
}

private struct NonHttpURLRouter: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Binding var url: URL?

    func body(content: Content) -> some View {
        content.onChange(of: url) { _, newValue in
            guard let value = newValue, !value.containsHttpProtocol else { return }
            url = nil
            openURL(value)
        }
    }
}

private func safariOnlyBinding(_ url: Binding<URL?>) -> Binding<URL?> {
    Binding(
        get: { url.wrappedValue?.containsHttpProtocol == true ? url.wrappedValue : nil },
        set: { url.wrappedValue = $0 }
    )
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
