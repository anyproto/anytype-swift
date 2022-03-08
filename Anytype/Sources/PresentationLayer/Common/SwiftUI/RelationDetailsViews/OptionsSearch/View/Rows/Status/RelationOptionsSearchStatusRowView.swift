import SwiftUI

struct RelationOptionsSearchStatusRowView: View {
    
    let model: Model
    let onTap: (String) -> ()
    
    var body: some View {
        Button {
            onTap(model.id)
        } label: {
            label
        }
    }
    
    private var label: some View {
        HStack(spacing: 0) {
            AnytypeText(model.text, style: .relation1Regular, color: model.color.suColor)
            Spacer()
        }
        .frame(height: 48)
        .divider()
        .padding(.horizontal, 20)
    }
    
}
