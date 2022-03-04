import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    private let bigCover: CGFloat = 230
    private let smallCover: CGFloat = 150
    
    var body: some View {
        header
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            Spacer.fixedHeight(32)
            
            AnytypeText(model.details.title, style: .title, color: .textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            
            description
            
            Spacer.fixedHeight(8)
            
            featuredRelations
        }
        .readSize { width = $0.width }
    }
    
    private var description: some View {
        Group {
            if model.details.description.isNotEmpty {
                Spacer.fixedHeight(6)
                AnytypeText(model.details.description, style: .relation2Regular, color: .textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            } else {
                EmptyView()
            }
        }
    }
    
    private var featuredRelations: some View {
        FlowRelationsView(
            viewModel: FlowRelationsViewModel(
                relations: model.featuredRelations,
                onRelationTap: { relation in
                    model.router?.showRelationValueEditingView(key: relation.id, source: .object)
                }
            )
        )
            .padding(.horizontal, 20)
    }
    
    private let iconBackgroundPadding: CGFloat = 4
    private func iconView(icon: ObjectIconImage) -> some View {
        ZStack {
            if let guideline = ObjectIconImageUsecase.openedObject
                .objectIconImageGuidelineSet
                .imageGuideline(for: icon) {
                let paddingFromBothSides = iconBackgroundPadding * 2
                RoundedRectangle(cornerRadius: guideline.cornersGuideline.radius + iconBackgroundPadding).foregroundColor(.white)
                    .frame(width: guideline.size.width + paddingFromBothSides, height: guideline.size.height + paddingFromBothSides)
            }
            
            SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObject)
                .frame(width: 96, height: 96)
        }
        .padding(.leading, -8 + 20) // 8 is default padding
        .padding(.bottom, -8 - 16)
    }
    
    private var cover: some View {
        Group {
            switch model.details.documentCover {
            case .color(let color):
                color.suColor.frame(height: bigCover)
            case .gradient(let gradient):
                gradient.asLinearGradient().frame(height: bigCover)
            case .imageId(let imageId):
                    if let url = ImageID(id: imageId, width: .custom(width)).resolvedUrl {
                        KFImage(url)
                            .resizable()
                            .placeholder{ Color.strokePrimary }
                            .frame(width: width, height: bigCover)
                            .aspectRatio(contentMode: .fill)
                }
            case .none:
                Color.backgroundPrimary
                    .if(model.details.icon.isNotNil) {
                        $0.frame(height: bigCover)
                    } else: {
                        $0.frame(height: smallCover)
                    }
            }
        }
        .ifLet(model.details.objectIconImage) { view, icon in
            view.overlay(iconView(icon: icon), alignment: .bottomLeading)
        }
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}
