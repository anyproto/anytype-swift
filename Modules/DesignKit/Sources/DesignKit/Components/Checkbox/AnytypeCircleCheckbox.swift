import SwiftUI

struct AnytypeCircleCheckbox: View {
    @Binding var checked: Bool
    
    var backgroundCheckedColor = Color.Control.primary
    var foregroundCheckedColor = Color.Control.white
    var foregroundUncheckedColor = Color.Control.tertiary
    
    var body: some View {
        ZStack {
            if checked {
                Circle()
                    .foregroundStyle(backgroundCheckedColor)
                Image(asset: .X18.tick)
                    .foregroundStyle(foregroundCheckedColor)

            } else {
                Circle()
                    .stroke(foregroundUncheckedColor, lineWidth: 1)
            }
        }.onTapGesture {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                checked.toggle()
            }
        }
        .frame(width: 24, height: 24)
    }
}

extension AnytypeCircleCheckbox {
    init(checked: Bool) {
        self.init(checked: .constant(checked))
    }
}

extension AnytypeCircleCheckbox {
    func blueStyle() -> some View {
        var view = self
        view.backgroundCheckedColor = .Control.accent100
        return view
    }
}

#Preview {
    AnytypeCircleCheckbox(checked: .constant(true))
    AnytypeCircleCheckbox(checked: .constant(false))
    AnytypeCircleCheckbox(checked: .constant(true))
        .blueStyle()
}
