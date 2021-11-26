import SwiftUI

struct SetMinimizedHeader: View {
    let headerPosition: CGPoint
    let coverPosition: CGPoint
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    private let minimizedHeaderHeight: CGFloat = 92
    
    var body: some View {
        Group {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    header
                    headerSettings
                }
                .background(Color.background)
                .opacity(headerOpacity)
                Spacer()
            }
        }
    }
    
    private var headerOpacity: CGFloat {
        // start to appear in 2x of header height distance
        let percent = ((minimizedHeaderHeight * 2) - coverPosition.y) / minimizedHeaderHeight

        return percent.clamped(0, 1)
    }
    
    private var headerSettings: some View {
        Group {
            if headerPosition.y < minimizedHeaderHeight {
                SetHeaderSettings()
            } else {
                EmptyView()
            }
        }
    }
    
    private var header: some View {
        VStack {
            Spacer.fixedHeight(44)
            HStack {
                if let icon = model.details.objectIconImage {
                    SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObjectNavigationBar)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(8)
                }
                AnytypeText(model.details.title, style: .body, color: .textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal)
        }
        .frame(height: minimizedHeaderHeight, alignment: .center)
        .frame(maxWidth: .infinity)
    }
}

struct SetMinimizedHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetMinimizedHeader(headerPosition: .zero, coverPosition: .zero)
    }
}
