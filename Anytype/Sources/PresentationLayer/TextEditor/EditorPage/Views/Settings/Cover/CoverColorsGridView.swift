import SwiftUI

struct CoverColorsGridView: View {
    
    let onCoverSelect: (BackgroundType) -> ()
    
    private let columns: [GridItem] = {
        if UIDevice.isPad {
            return [GridItem(.adaptive(minimum: 200), spacing: 16)]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible())
            ]
        }
    }()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: columns,
                spacing: 16,
                pinnedViews: [.sectionHeaders]
            ) {
                colorsSection
                gradientsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Solid colors".localized)) {
            ForEach(CoverConstants.colors) { color in
                Color(hex: color.hex)
                    .cornerRadius(4)
                    .frame(height: 112)
                    .onTapGesture {
                        onCoverSelect(.color(color))
                    }
            }
        }
    }
    
    private var gradientsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Gradients".localized)) {
            ForEach(CoverConstants.gradients) { gradient in
                gradient.asLinearGradient()
                .cornerRadius(4)
                .frame(height: 112)
                .onTapGesture {
                    onCoverSelect(.gradient(gradient))
                }
            }
        }
    }
}

struct CoverColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        CoverColorsGridView(onCoverSelect: { _ in })
    }
}
