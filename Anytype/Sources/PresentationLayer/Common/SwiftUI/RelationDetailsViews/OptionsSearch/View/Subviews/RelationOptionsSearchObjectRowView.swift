import SwiftUI

struct RelationOptionsSearchObjectRowView: View {
    
    let model: Model
    let onTap: (String) -> ()
    
    var body: some View {
        Button {
            onTap(model.id)
        } label: {
            content
        }
    }
    
    private var content: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: model.icon,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            text
            Spacer()
            
            if model.isSelected {
                Image.optionChecked.foregroundColor(.textSecondary)
            }
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
        .divider(spacing: 0, leadingPadding: 80, trailingPadding: 20)
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(model.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            AnytypeText(model.subtitle, style: .relation2Regular, color: .textSecondary)
                .lineLimit(1)
        }
    }
}

extension RelationOptionsSearchObjectRowView {
    
    struct Model: Hashable, Identifiable {
        let id: String
        let icon: ObjectIconImage
        let title: String
        let subtitle: String
        
        let isSelected: Bool
    }
    
}

//struct RelationOptionsSearchObjectRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationOptionsSearchObjectRowView()
//    }
//}
