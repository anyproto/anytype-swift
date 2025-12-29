import SwiftUI

public struct AnytypeCheckbox: View {
    @Binding var checked: Bool
    
    public init(checked: Binding<Bool>) {
        self._checked = checked
    }
    
    public var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                checked.toggle()
            }
        } label: {
            Group {
                if checked {
                    Image(asset: .System.checkboxChecked)
                } else {
                    Image(asset: .System.checkboxUnchecked)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
