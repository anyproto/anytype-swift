import SwiftUI

struct SetTableView: View {
    @ObservedObject private(set) var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    var headerMinimizedSize: CGSize
    
    @State private var dropData = SetCardDropData()

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
    
    @ViewBuilder
    private var content: some View {
        if model.isEmptyViews {
            EmptyView()
        } else {
            Section(header: compoundHeader) {
                ForEach(model.configurationsDict.keys, id: \.self) { groupId in
                    if let configurations = model.configurationsDict[groupId] {
                        ForEach(configurations) { configuration in
                            SetDragAndDropView(
                                dropData: $dropData,
                                configuration: configuration,
                                groupId: groupId,
                                dragAndDropDelegate: model,
                                content: {
                                    SetTableViewRow(model: model, configuration: configuration, xOffset: xOffset)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var pagination: some View {
        EditorSetPaginationView(
            model: model,
            paginationData: model.pagitationData()
        )
        .frame(width: tableHeaderSize.width)
        .offset(x: xOffset, y: 0)
    }

    private var xOffset: CGFloat {
        max(-offset.x, 0)
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            headerSettingsView
            SetTableViewHeader(model: model)
        }
        .background(Color.Background.primary)
    }
    
    private var headerSettingsView: some View {
        HStack {
            SetHeaderSettingsView(model: model.headerSettingsViewModel)
            .offset(x: xOffset, y: 0)
            .frame(width: tableHeaderSize.width)
            Spacer()
        }
    }
}

struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(
            model: EditorSetViewModel.emptyPreview,
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

