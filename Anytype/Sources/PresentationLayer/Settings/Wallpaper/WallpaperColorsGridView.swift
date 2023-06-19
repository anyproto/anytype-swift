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
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: []) {
                gradientsSection
                colorsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        Section(header: PickerSectionHeaderView(title: Loc.solidColors)) {
            ForEach(CoverColor.allCases) { color in
                colorView(color)
            }
        }
    }
    
    private var gradientsSection: some View {
        Section(header: PickerSectionHeaderView(title: Loc.gradients)) {
            ForEach(CoverGradient.allCases) { gradient in
                gradientView(gradient)
            }
        }
    }
    
    private func colorView(_ color: CoverColor) -> some View {
        Color(hex: color.data.hex)
            .сoverGridAppearance()
            .onTapGesture {
                onCoverSelect(.color(color))
            }
    }
    
    private func gradientView(_ gradient: CoverGradient) -> some View {
        gradient.data.asLinearGradient()
            .сoverGridAppearance()
            .onTapGesture {
                onCoverSelect(.gradient(gradient))
            }
    }
}

private extension View {
    func сoverGridAppearance() -> some View {
        self
            .cornerRadius(4)
            .frame(height: 208)
            .padding(.top, 16)
    }
    
}

struct WallpaperColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperColorsGridView(onCoverSelect: { _ in })
    }
}
