import SwiftUI

public protocol TitleProvider {
    var title: String { get }
}

public struct AnytypeInlinePicker<T> : View where T: (Identifiable & Equatable & TitleProvider & Hashable) {
    @Binding private var initialValue: T
    private var allValues: [T]
    
    public init(initialValue: Binding<T>, allValues: [T]) {
        self._initialValue = initialValue
        self.allValues = allValues
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(allValues, id: \.self) { value in
                Button {
                    initialValue = value
                } label: {
                    buildItem(value: value)
                }
                .newDivider(leadingPadding: 40, color: UIColor.separator.suColor)
            }
        }
        .cornerRadius(8)
    }
    
    @ViewBuilder
    func buildItem(value: T) -> some View {
        HStack {
            Spacer.fixedWidth(16)
            Image(asset: .system(name: "checkmark"))
                .opacity(value == initialValue ? 1 : 0)
            Spacer.fixedWidth(8)
            AnytypeText(value.title, style: .bodyRegular, color: .Text.primary)
            Spacer()
        }
        .frame(height: 48)
        .background(UIColor.secondarySystemGroupedBackground.suColor)
    }
}
