import Foundation
import SwiftUI

private struct URLViewModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Binding var url: URL?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: url) { _, currentUrl in
                guard let currentUrl else { return }
                
                openURL(currentUrl)
                
                // If user tap again url should be changed for call onChange. Reset after open it.
                url = nil
            }
    }
}


extension View {
    func openUrl(url: Binding<URL?>) -> some View {
        modifier(URLViewModifier(url: url))
    }
}
