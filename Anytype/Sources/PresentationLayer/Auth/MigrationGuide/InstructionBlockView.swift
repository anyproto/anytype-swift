import SwiftUI

struct InstructionBlockView<Content: View>: View {
    
    let title: String
    @Binding var expanded: Bool
    var content: () -> Content
    
    internal init(title: String, expanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._expanded = expanded
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AnytypeText(title, style: .subheading, color: .Text.primary)
                Spacer()
                Image(asset: .Widget.collapse)
                    .renderingMode(.template)
                    .foregroundColor(.Text.primary)
                    .rotationEffect(expanded ? .degrees(90) : .degrees(270))
            }
            .fixTappableArea()
            .onTapGesture {
                expanded.toggle()
            }
            
            .padding(.leading, 20)
            .padding(.trailing, 12)
            if (expanded) {
                Spacer.fixedHeight(12)
                content()
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(Color.Stroke.transperent)
        .cornerRadius(16, style: .continuous)
    }
}
