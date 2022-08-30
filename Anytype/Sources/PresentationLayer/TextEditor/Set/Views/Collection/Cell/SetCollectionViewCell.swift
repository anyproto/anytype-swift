import SwiftUI
import Kingfisher

struct SetCollectionViewCell: View {
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
                titleWithIcon
                Spacer.fixedHeight(4)
                relations
            }
            .padding(.top, configuration.hasCover ? 0 : Constants.contentPadding)
            .padding([.leading, .trailing, .bottom], Constants.contentPadding)
        }
        .background(Color.backgroundPrimary)
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
    
    private var titleWithIcon: some View {
        Group {
            if let icon = configuration.icon, configuration.showIcon {
                ZStack(alignment: .topLeading) {
                    title(with: configuration.leftIndentedTitle)
                    SwiftUIObjectIconImageView(
                        iconImage: icon,
                        usecase: .setRow)
                    .frame(width: 18, height: 18)
                    .padding(.top, 1)
                    .onTapGesture {
                        configuration.onIconTap()
                    }
                }
            } else {
                title(with: configuration.title)
            }
        }
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
    
    private func title(with text: String) -> some View {
        AnytypeText(text, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    private func row(_ relationData: Relation) -> some View {
        RelationValueView(
            relation: RelationItemModel(
                relation: relationData),
            style: .setGallery, action: {}
        )
    }
}

extension SetCollectionViewCell {
    enum Constants {
        static let contentPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let smallItemHeight: CGFloat = 112
        static let largeItemHeight: CGFloat = 188
    }
}
