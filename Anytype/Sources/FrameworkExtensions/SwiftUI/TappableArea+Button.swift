import SwiftUI

struct IncreaseTapButton<Label: View>: View {
    
    let action: @MainActor () -> Void
    let insets: EdgeInsets
    @ViewBuilder
    let label: Label
    
    init(action: @escaping @MainActor () -> Void, insets: EdgeInsets = EdgeInsets(side: 15), @ViewBuilder label: () -> Label) {
        self.action = action
        self.insets = insets
        self.label = label()
    }
    
    var body: some View {
        Button(action: action) {
            label
                .padding(insets)
                .fixTappableArea()
        }
        .padding(insets.inverted)
    }
}
