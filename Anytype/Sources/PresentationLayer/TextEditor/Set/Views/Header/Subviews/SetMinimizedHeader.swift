import SwiftUI

struct SetMinimizedHeader: View {
    let headerPosition: CGPoint
    let coverPosition: CGPoint
    let xOffset: CGFloat
    
    @EnvironmentObject private var model: EditorSetViewModel
    @State private var initialOffset = CGFloat.zero
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
        }.onAppear {
            initialOffset = xOffset
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
                VStack(alignment: .leading, spacing: 0) {
                    SetHeaderSettings()
                    Divider()
                    ScrollView([], showsIndicators: false) {
                        SetTableViewHeader()
                            .offset(x: xOffset - initialOffset)
                        
                    }.frame(height: 40)
                    Divider()
                }
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
        SetMinimizedHeader(headerPosition: .zero, coverPosition: .zero, xOffset: 0)
    }
}
