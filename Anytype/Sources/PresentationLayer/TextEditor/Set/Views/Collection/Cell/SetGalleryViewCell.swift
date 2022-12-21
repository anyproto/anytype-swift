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
        VStack(alignment: .leading, spacing: 11) {
            if configuration.hasCover {
                coverContent
            }
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
            }
            .padding(.top, configuration.hasCover ? 0 : Constants.contentPadding)
            .padding([.leading, .trailing, .bottom], Constants.contentPadding)
        }
        .background(Color.BackgroundNew.primary)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius).stroke(Color.strokePrimary, lineWidth: 0.5)
        )
        .readSize { width = $0.width }
    }
    
    private var coverContent: some View {
        ZStack {
            coverPlaceholder
            if let coverType = configuration.coverType {
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
            }
        }
        .frame(
            height: configuration.smallItemSize ?
            Constants.smallItemHeight :
                Constants.largeItemHeight
        )
        .frame(maxWidth: .infinity)
        .background(Color.strokeTransperent)
    }
    
    private var coverPlaceholder: some View {
        Image(asset: .setImagePlaceholder)
            .frame(width: 48, height: 48, alignment: .center)
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
    
    private func row(_ relation: Relation) -> some View {
        RelationValueView(
            relation: RelationItemModel(relation: relation),
            style: .setCollection, action: {}
        )
    }
}

extension SetGalleryViewCell {
    enum Constants {
        static let contentPadding: CGFloat = 12
        static let cornerRadius: CGFloat = 16
        static let smallItemHeight: CGFloat = 112
        static let largeItemHeight: CGFloat = 188
    }
}
