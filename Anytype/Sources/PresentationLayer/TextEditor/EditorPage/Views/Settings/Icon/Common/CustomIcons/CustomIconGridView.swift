import SwiftUI
import Services


struct CustomIconGridView: View {
    
    let onIconSelect: (CustomIcon, CustomIconColor) -> ()
    
    @State private var searchText = ""
    @State private var iconToPickColor: CustomIcon?
    
    private let defaultColor = CustomIconColor.gray
    
    var filteredIcons: [CustomIcon] {
        guard searchText.isNotEmpty else {
            return CustomIcon.allCases
        }
        
        return CustomIcon.allCases.filter { $0.rawValue.contains(searchText) }
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
        LazyVGrid(
            columns: columns,
            spacing: 0
        ) {
            ForEach(icons, id: \.rawValue) { icon in
                CustomIconView(icon: icon, color: iconToPickColor == icon ? Color.Control.transparentInactive : defaultColor.color)
                    .frame(width: 40, height: 40)
                    .padding(.top, 12)
                    .onTapGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onIconSelect(icon, defaultColor)
                    }
                    .onLongPressGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        iconToPickColor = icon
                    }
                    .if(iconToPickColor == icon) {
                        $0.overlay(alignment: .bottom) {
                            CustomIconColorOverlay(icon: icon) { color in
                                iconToPickColor = nil
                                onIconSelect(icon, color)
                            }
                                .offset(y: -56) // TBD: dynamic positioning
                        }
                    }
            }
        }
    }
}

struct CustomIconGridView_Previews: PreviewProvider {
    static var previews: some View {
        CustomIconGridView(onIconSelect: { _,_ in })
    }
}
