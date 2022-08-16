import SwiftUI
import Kingfisher

struct SetCollectionViewCell: View {
    @State private var width: CGFloat = .zero
    let configuration: SetContentViewItemConfiguration
    
    var body: some View {
        content
            .background(Color.backgroundPrimary)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.strokePrimary, lineWidth: 0.5)
            )
            .onTapGesture {
                UISelectionFeedbackGenerator().selectionChanged()
                configuration.onItemTap()
            }
            .readSize { width = $0.width }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 11) {
            if configuration.hasCover {
                coverContent
            }
            VStack(alignment: .leading, spacing: 0) {
                icon
                title
                Spacer.fixedHeight(4)
                relations
            }
            .padding(.top, configuration.hasCover ? 0 : 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private var coverContent: some View {
        ZStack {
            coverPlaceholder
            if let coverType = configuration.coverType {
                SwiftUIObjectHeaderCoverView(
                    objectCover: coverType,
                    size: CGSize(
                        width: width,
                        height: configuration.smallItemSize ? 112 : 188
                    ),
                    fitImage: configuration.coverFit
                )
            }
        }
        .frame(height: configuration.smallItemSize ? 112 : 188)
        .frame(maxWidth: .infinity)
        .background(Color.strokeTransperent)
    }
    
    private var coverPlaceholder: some View {
        Image(asset: .setImagePlaceholder)
            .frame(width: 48, height: 48, alignment: .center)
    }
    
    private var icon: some View {
        Group {
            if let icon = configuration.icon, configuration.showIcon {
                Button {
                    configuration.onIconTap()
                } label: {
                    SwiftUIObjectIconImageView(
                        iconImage: icon,
                        usecase: .setRow)
                    .frame(width: 18, height: 18)
                }
            }
        }
    }
    
    private var title: some View {
        AnytypeText(configuration.title, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    private var relations: some View {
        LazyVStack(spacing: 4) {
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
    }
}
