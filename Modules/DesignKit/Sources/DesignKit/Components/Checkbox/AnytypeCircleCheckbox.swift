import SwiftUI
import Assets

public struct AnytypeCircleCheckbox: View {
    @Binding private var checked: Bool
    
    private(set) var backgroundCheckedColor: Color
    private(set) var foregroundCheckedColor: Color
    private(set) var foregroundUncheckedColor: Color
    private var interactive: Bool
    
    public init(
        checked: Binding<Bool>,
        backgroundCheckedColor: Color = .Control.accent100,
        foregroundCheckedColor: Color = .Control.white,
        foregroundUncheckedColor: Color = .Control.tertiary,
        interactive: Bool = true
    ) {
        self._checked = checked
        self.backgroundCheckedColor = backgroundCheckedColor
        self.foregroundCheckedColor = foregroundCheckedColor
        self.foregroundUncheckedColor = foregroundUncheckedColor
        self.interactive = interactive
    }
    
    public var body: some View {
        ZStack {
            if checked {
                Circle()
                    .foregroundStyle(backgroundCheckedColor)
                Image(asset: .X18.tick)
                    .resizable()
                    .padding(3)
                    .foregroundStyle(foregroundCheckedColor)

            } else {
                Circle()
                    .stroke(foregroundUncheckedColor, lineWidth: 1)
            }
        }
        .onTapGesture {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                checked.toggle()
            }
        }
        .allowsHitTesting(interactive)
        .frame(width: 24, height: 24)
    }
}

public extension AnytypeCircleCheckbox {
    init(checked: Bool) {
        self.init(checked: .constant(checked), interactive: false)
    }
}

public extension AnytypeCircleCheckbox {
    func lightBlueStyle() -> some View {
        var view = self
        view.backgroundCheckedColor = .Pure.sky
        return view
    }
}

#Preview {
    AnytypeCircleCheckbox(checked: .constant(true))
    
    AnytypeCircleCheckbox(checked: .constant(false))
    
    AnytypeCircleCheckbox(checked: .constant(true))
        .lightBlueStyle()
}
