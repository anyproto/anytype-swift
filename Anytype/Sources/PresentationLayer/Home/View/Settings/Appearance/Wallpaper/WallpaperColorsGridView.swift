import SwiftUI

struct WallpaperColorsGridView: View {
    
    let onCoverSelect: (BackgroundType) -> ()
    
    private let columns: [GridItem] = {
        if UIDevice.isPad {
            return [GridItem(.adaptive(minimum: 100), spacing: 16)]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible()),
            ]
        }
    }()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: columns,
                spacing: 0,
                pinnedViews: []
            ) {
                gradientsSection
                colorsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Solid colors".localized)) {
            ForEach(CoverConstants.colors.indices, id: \.self) { index in
                colorView(at: index)
            }
        }
    }
    
    private var gradientsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Gradients".localized)) {
            ForEach(CoverConstants.gradients.indices, id: \.self) { index in
                gradientView(at: index)
            }
        }
    }
    
    private func colorView(at index: Int) -> some View {
        CoverConstants.colors[safe: index].flatMap { color in
            Color(hex: color.hex)
                .applyCoverGridItemAppearance(needTopPadding: index > columns.count - 1)
                .onTapGesture {
                    onCoverSelect(.color(color))
                }
        }
    }
    
    private func gradientView(at index: Int) -> some View {
        CoverConstants.gradients[safe: index].flatMap { gradient in
            gradient.asLinearGradient()
                .applyCoverGridItemAppearance(needTopPadding: index > columns.count - 1)
                .onTapGesture {
                    onCoverSelect(.gradient(gradient))
                }
        }
    }
}

private extension View {
    
    func applyCoverGridItemAppearance(needTopPadding: Bool) -> some View {
        self
            .cornerRadius(4)
            .frame(height: 208)
            .if(needTopPadding) {
                $0.padding(.top, 16)
            }
    }
    
}

struct WallpaperColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperColorsGridView(onCoverSelect: { _ in })
    }
}
