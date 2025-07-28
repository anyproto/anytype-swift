import SwiftUI
import Services


struct CustomIconGridView: View {
    
    let onIconSelect: (CustomIcon, CustomIconColor) -> ()
    
    @State private var searchText = ""
    @State private var iconToPickColor: CustomIcon?
    @State private var overlayFrame = CGRect.zero
    
    private let defaultColor = CustomIconColor.gray
    
    var filteredIcons: [CustomIcon] {
        guard searchText.isNotEmpty else {
            return CustomIcon.allCases
        }
        
        return CustomIcon.allCases.filter { $0.rawValue.lowercased().contains(searchText.lowercased()) }
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false)
            contentView
        }
        .animation(.spring(response: 0.3), value: iconToPickColor)
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        return Group {
            if filteredIcons.isEmpty {
                makeEmptySearchResultView(placeholder: searchText)
            } else {
                makeGrid(icons: filteredIcons)
            }
        }
    }
    
    private func makeEmptySearchResultView(placeholder: String) -> some View {
        VStack(spacing: 0) {
            AnytypeText(
                Loc.thereIsNoIconNamed + " \"\(placeholder)\"",
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
            
            AnytypeText(
                Loc.tryToFindANewOne,
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.secondary)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private func makeGrid(icons: [CustomIcon]) -> some View {
        ScrollView(showsIndicators: false) {
            makeGridView(icons: icons)
        }
        .scrollDismissesKeyboard(.interactively)
        .padding(.horizontal, 16)
    }
    
    private func makeGridView(icons: [CustomIcon]) -> some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(icons) { icon in
                Image(asset: icon.imageAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(iconToPickColor == icon ? Color.Control.transparentTertiary : defaultColor.color)
                    .frame(width: 40, height: 40)
                    .padding(.top, 12)
                    .onTapGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        if let icontToPickColor = iconToPickColor, icontToPickColor != icon {
                            iconToPickColor = nil
                        } else {
                            onIconSelect(icon, defaultColor)
                        }
                    }
                    .onLongPressGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        iconToPickColor = icon
                    }
                    .if(iconToPickColor == icon) { view in
                        view.overlay {
                            GeometryReader { geometry in
                                CustomIconColorOverlay(icon: icon) { color in
                                    iconToPickColor = nil
                                    onIconSelect(icon, color)
                                }
                                .readFrame{ frame in
                                    overlayFrame = frame
                                }

                                .position(
                                    x: calculateXPosition(in: geometry),
                                    y: calculateYPosition(in: geometry)
                                )
                            }
                        }.zIndex(1000)
                    }
            }
        }
    }
    
    private func calculateXPosition(in geometry: GeometryProxy) -> CGFloat {
        let centerX = geometry.frame(in: .local).width / 2
        
        // Calculate the absolute position of popup edges if centered
        let absoluteX = geometry.frame(in: .global).minX + centerX
        let leftEdge = absoluteX - overlayFrame.width/2
        let rightEdge = absoluteX + overlayFrame.width/2
        
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 24
        
        // Calculate minimal adjustments needed
        if rightEdge > screenWidth - padding {
            // Move left by the amount it overflows
            let overflow = rightEdge - (screenWidth - padding)
            return centerX - overflow
        } else if leftEdge < padding {
            // Move right by the amount it overflows
            let overflow = padding - leftEdge
            return centerX + overflow
        }
        
        return centerX
    }

    private func calculateYPosition(in geometry: GeometryProxy) -> CGFloat {
        let iconGlobalY = geometry.frame(in: .global).minY
        let screenCenter = UIScreen.main.bounds.height / 2
        
        if iconGlobalY < screenCenter {
            // Show below the icon
            return geometry.size.height + (overlayFrame.height/2) + 4
        } else {
            // Default to showing above
            return -(overlayFrame.height/2)
        }
    }
}

struct CustomIconGridView_Previews: PreviewProvider {
    static var previews: some View {
        CustomIconGridView(onIconSelect: { _,_ in })
    }
}
