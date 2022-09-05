import SwiftUI

struct SetTableView: View {
    @ObservedObject private(set) var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    var headerMinimizedSize: CGSize

    var body: some View {
        if #available(iOS 15.0, *) {
            SingleAxisGeometryReader { fullWidth in
                scrollView(fullWidth: fullWidth)
            }
        } else {
            scrollView(fullWidth: UIApplication.shared.keyWindow!.frame.width)
        }
    }
    
    private func scrollView(fullWidth: CGFloat) -> some View {
        OffsetAwareScrollView(
            axes: [.horizontal],
            showsIndicators: false,
            offsetChanged: { offset.x = $0.x }
        ) {
            OffsetAwareScrollView(
                axes: [.vertical],
                showsIndicators: false,
                offsetChanged: {
                    offset.y = $0.y
                    UIApplication.shared.hideKeyboard()
                }
            ) {
                Spacer.fixedHeight(tableHeaderSize.height)
                LazyVStack(
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    content
                    pagination
                }
                .frame(minWidth: fullWidth)
                .padding(.top, -headerMinimizedSize.height)
            }
        }
    }
    
    private var content: some View {
        Group {
            if model.isEmpty {
                EmptyView()
            } else {
                Section(header: compoundHeader) {
                    ForEach(model.configurations) { configuration in
                        SetTableViewRow(configuration: configuration, xOffset: xOffset)
                    }
                }
            }
        }
    }
    
    private var pagination: some View {
        EditorSetPaginationView()
            .frame(width: tableHeaderSize.width)
            .offset(x: xOffset, y: 0)
    }

    private var xOffset: CGFloat {
        max(-offset.x, 0)
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                HStack {
                    SetHeaderSettings()
                        .offset(x: xOffset, y: 0)
                        .environmentObject(model)
                        .frame(width: tableHeaderSize.width)
                    Spacer()
                }
                SetTableViewHeader()
            }
        }
        .background(Color.backgroundPrimary)
    }
}


struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(
            model: EditorSetViewModel.empty,
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

