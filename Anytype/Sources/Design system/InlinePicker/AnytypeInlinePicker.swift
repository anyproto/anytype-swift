import SwiftUI

public protocol TitleProvider {
    var title: String { get }
}

public struct AnytypeInlinePicker<T> : View where T: (Identifiable & Equatable & TitleProvider & Hashable) {
    @State private var initialValue: T?
    private var allValues: [T]
    private let selectionHandler: (T) -> Void
    
    public init(allValues: [T], selectionHandler: @escaping (T) -> Void) {
        self.allValues = allValues
        self.selectionHandler = selectionHandler
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(allValues, id: \.self) { value in
                Button {
                    initialValue = value
                    selectionHandler(value)
                } label: {
                    buildItem(value: value)
                }
                .newDivider(leadingPadding: 40)
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
        .background(Color.Background.primary)
    }
}
