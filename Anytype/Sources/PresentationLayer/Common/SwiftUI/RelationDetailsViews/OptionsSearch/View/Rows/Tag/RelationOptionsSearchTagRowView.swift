import SwiftUI

struct RelationOptionsSearchTagRowView: View {

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
            TagView(tag: model.tag, guidlines: model.guidlines)
            Spacer()
            
            if model.isSelected {
                Image.optionChecked.foregroundColor(.textSecondary)
            }
        }
        .frame(height: 48)
        .divider()
        .padding(.horizontal, 20)
    }
    
}
