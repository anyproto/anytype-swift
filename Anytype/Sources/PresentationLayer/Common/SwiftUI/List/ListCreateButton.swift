import SwiftUI

struct ListCreateButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(asset: .relationNew).foregroundStyle(Color.Control.secondary).frame(width: 24, height: 24)
                AnytypeText(text, style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 52)
        .divider()
        .padding(.horizontal, 20)
    }
}

struct ListCreateButton_Previews: PreviewProvider {
    static var previews: some View {
        ListCreateButton(text: "Create object") {}
    }
}
