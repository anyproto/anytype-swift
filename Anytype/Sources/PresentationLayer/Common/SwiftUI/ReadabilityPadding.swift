import SwiftUI

struct ReadabilityPadding: ViewModifier {
    
    let padding: CGFloat
    
    @ScaledMetric private var unit: CGFloat = 20
    @State private var padPadding: CGFloat? = nil
    
    func body(content: Content) -> some View {
        if UIDevice.isPad {
            content
                .padding(.vertical, padding)
                .padding(.horizontal, padPadding)
                .readSize { size in
                    padPadding = padding(for: size.width)
                }
        } else {
            content.padding(padding)
        }
    }

    private func padding(for width: CGFloat) -> CGFloat {
        // The internet seems to think the optimal readable width is 50-75
        // characters wide; I chose 70 here. The `unit` variable is the
        // approximate size of the system font and is wrapped in
        // @ScaledMetric to better support dynamic type. I assume that
        // the average character width is half of the size of the font.
        let idealWidth = 70 * unit / 2

        // If the width is already readable then don't apply any padding.
        guard width >= idealWidth else {
            return self.padding
        }

        // If the width is too large then calculate the padding required
        // on either side until the view's width is readable.
        let padding = round((width - idealWidth) / 2)
        return padding
    }
    
}
