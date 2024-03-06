import SwiftUI
import Kingfisher

struct SetGalleryViewCell: View {
    @State private var width: CGFloat = .zero
    let configuration: SetContentViewItemConfiguration
    
    var body: some View {
        Button {
            configuration.onItemTap()
        } label: {
            content
        }
        .buttonStyle(LightDimmingButtonStyle())
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: Constants.bottomCoverSpacing) {
            coverContent
            VStack(alignment: .leading, spacing: 0) {
                TitleWithIconView(
                    icon: configuration.icon,
                    showIcon: configuration.showIcon,
                    title: configuration.title,
                    style: .gallery,
                    onIconTap: configuration.onIconTap
                )
                
                Spacer.fixedHeight(4)
                
                relations
                
                Spacer(minLength: 0)
            }
            .padding(.top, configuration.hasCover && configuration.coverType.isNotNil ? 0 : Constants.contentPadding )
            .padding([.leading, .trailing, .bottom], Constants.contentPadding)
        }
        .background(Color.Background.primary)
        .frame(maxWidth: .infinity, minHeight: configuration.minHeight, alignment: .topLeading)
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius).stroke(Color.Shape.primary, lineWidth: 0.5)
        )
        .readSize { width = $0.width }
    }
    
    @ViewBuilder
    private var coverContent: some View {
        if configuration.hasCover, let coverType = configuration.coverType {
            SwiftUIObjectHeaderCoverView(
                objectCover: coverType,
                size: CGSize(
                    width: width,
                    height: configuration.smallItemSize ?
                    Constants.smallItemHeight :
                        Constants.largeItemHeight
                ),
                fitImage: configuration.coverFit
            )
            .frame(
                height: configuration.smallItemSize ?
                Constants.smallItemHeight :
                    Constants.largeItemHeight
            )
            .frame(maxWidth: .infinity)
            .background(Color.Shape.transperent)
        }
    }
    
    private var relations: some View {
        LazyVStack(spacing: Constants.relationSpacing) {
            ForEach(configuration.relations) { relation in
                if relation.hasValue {
                    row(relation)
                }
            }
        }
    }
    
    private func row(_ relation: Relation) -> some View {
        RelationValueView(
            model: RelationValueViewModel(
                relation:  RelationItemModel(relation: relation),
                style: .setCollection,
                mode: .button(action: nil)
            )
        )
    }
}

extension SetGalleryViewCell {
    enum Constants {
        static let contentPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let smallItemHeight: CGFloat = 112
        static let largeItemHeight: CGFloat = 188
        static let relationHeight: CGFloat = 16
        static let relationSpacing: CGFloat = 4
        static let bottomCoverSpacing: CGFloat = 12
        static let maxTitleHeight: CGFloat = 40
    }
}
