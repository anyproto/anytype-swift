import Foundation
import SwiftUI

struct GallerySpaceSelectionView: View {
    
    @StateObject private var model: GallerySpaceSelectionViewModel
    
    init(output: GallerySpaceSelectionModuleOutput?) {
        _model = StateObject(wrappedValue: GallerySpaceSelectionViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack(spacing: 0) {
                    plus
                    spaces
                }
                .padding(.horizontal, 20)
            }
        }
        .presentationCornerRadiusLegacy(16)
        .presentationDetents([.height(250), .large])
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    private var plus: some View {
        if model.canCreateNewSpace {
            Button {
                model.onTapNewSpace()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Color.Background.highlightedOfSelected
                            .spaceIconCornerRadius()
                            .border(4, color: Color.Shape.secondary)
                        IconView(icon: .asset(.X24.plus))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 48, height: 48)
                    AnytypeText(Loc.Gallery.installToNew, style: .uxTitle2Regular)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 64)
            }
        }
    }
    
    private var spaces: some View {
        ForEach(model.spaces) { space in
            Button {
                model.onTapSpace(spaceView: space)
            } label: {
                HStack(spacing: 12) {
                    IconView(icon: space.objectIconImage)
                        .frame(width: 48, height: 48)
                    AnytypeText(space.title, style: .uxTitle2Regular)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 64)
            }
        }
    }
}
