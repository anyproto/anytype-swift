import SwiftUI

enum ExpandedTapAreaButtonConstants {
    static let defaultInsets = EdgeInsets(side: 15)
}

struct ExpandedTapAreaButton<Label: View>: View {

    let action: @MainActor () -> Void
    let insets: EdgeInsets
    @ViewBuilder
    let label: Label

    init(insets: EdgeInsets = ExpandedTapAreaButtonConstants.defaultInsets, action: @escaping @MainActor () -> Void, @ViewBuilder label: () -> Label) {
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
