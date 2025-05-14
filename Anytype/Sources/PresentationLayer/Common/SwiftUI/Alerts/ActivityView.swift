import Foundation
import SwiftUI

struct ActivityView: View {
    let activityItems: [Any]
    
    var body: some View {
        ActivityViewRepresentable(activityItems: activityItems)
            .mediumPresentationDetents()
    }
}

private struct ActivityViewRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
