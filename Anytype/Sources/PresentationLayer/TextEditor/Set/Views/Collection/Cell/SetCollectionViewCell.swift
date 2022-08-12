import SwiftUI
import Kingfisher

struct SetCollectionViewCell: View {
    let configuration: SetContentViewItemConfiguration
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.strokePrimary, lineWidth: 0.5)
            )
    }
    
    private var content: some View {
        Button {
            configuration.onItemTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                title
                Spacer.fixedHeight(4)
                relations
            }
            .padding(16)
        }
    }
    
    private var title: some View {
        AnytypeText(configuration.title, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    private var relations: some View {
        LazyVStack(spacing: 5) {
            ForEach(configuration.relations) { relation in
                if relation.hasValue {
                    row(relation)
                }
            }
        }
    }
    
    private func row(_ relationData: Relation) -> some View {
        RelationValueView(
            relation: RelationItemModel(
                relation: relationData),
            style: .setGallery, action: {}
        )
        .disabled(true)
    }
}
