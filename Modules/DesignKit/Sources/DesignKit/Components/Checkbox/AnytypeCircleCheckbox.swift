import SwiftUI
import Assets

public struct AnytypeCircleCheckbox: View {
    @Binding private var checked: Bool

    private(set) var backgroundCheckedColor: Color
    private(set) var foregroundCheckedColor: Color
    private(set) var foregroundUncheckedColor: Color
    private var interactive: Bool
    private let size: CGFloat

    public init(
        checked: Binding<Bool>,
        backgroundCheckedColor: Color = .Control.accent100,
        foregroundCheckedColor: Color = .Control.white,
        foregroundUncheckedColor: Color = .Control.tertiary,
        interactive: Bool = true,
        size: CGFloat = 24
    ) {
        self._checked = checked
        self.backgroundCheckedColor = backgroundCheckedColor
        self.foregroundCheckedColor = foregroundCheckedColor
        self.foregroundUncheckedColor = foregroundUncheckedColor
        self.interactive = interactive
        self.size = size
    }

    public var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                checked.toggle()
            }
        } label: {
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
        }
        .buttonStyle(.plain)
        .allowsHitTesting(interactive)
        .frame(width: size, height: size)
    }
}

public extension AnytypeCircleCheckbox {
    init(checked: Bool, size: CGFloat = 24) {
        self.init(checked: .constant(checked), interactive: false, size: size)
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
