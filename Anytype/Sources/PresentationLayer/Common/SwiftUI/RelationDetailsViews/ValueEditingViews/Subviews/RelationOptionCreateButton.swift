import SwiftUI

struct RelationOptionCreateButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image.Relations.createOption.frame(width: 24, height: 24)
                AnytypeText("\("Create option".localized) \"\(text)\"", style: .uxBodyRegular, color: .textSecondary)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 52)
        .divider()
        .padding(.horizontal, 20)
    }
}

struct RelationValueOptionCreateButton_Previews: PreviewProvider {
    static var previews: some View {
        RelationOptionCreateButton(text: "tetet") {}
    }
}
