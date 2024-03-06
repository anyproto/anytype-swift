import SwiftUI

struct AnytypeCheckbox: View {
    @Binding var checked: Bool
    
    var body: some View {
        Group {
            if checked {
                Image(asset: .System.checkboxChecked)
            } else {
                Image(asset: .System.checkboxUnchecked)
            }
        }.onTapGesture {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                checked.toggle()
            }
        }
    }
}
