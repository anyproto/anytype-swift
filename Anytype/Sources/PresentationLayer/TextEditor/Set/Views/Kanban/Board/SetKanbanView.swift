import SwiftUI
import BlocksModels

struct SetKanbanView: View {
    @ObservedObject var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    
    var headerMinimizedSize: CGSize

    var body: some View {
        OffsetAwareScrollView(
            axes: [.vertical],
            showsIndicators: false,
            offsetChanged: { offset.y = $0.y }
        ) {
            Spacer.fixedHeight(tableHeaderSize.height)
            content
            Spacer()
        }
    }

    // MARK: List view
    
    private var content: some View {
        LazyVStack(
            alignment: .center,
            spacing: 0,
            pinnedViews: [.sectionHeaders]
        ) {
            boardView
        }
        .padding(.top, -headerMinimizedSize.height)
    }
    
    private var boardView: some View {
        Group {
            if model.isEmpty {
                EmptyView()
            } else {
                Section(header: compoundHeader) {
                    boardContent
                }
            }
        }
    }
    
    private var boardContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(model.configurationsDict.keys, id: \.value) { key in
                    if let configurations = model.configurationsDict[key] {
                        SetKanbanColumn(
                            subId: key,
                            headerRelation: nil, // will be updated after branch `relatio-as-object` was merged
                            configurations: configurations,
                            dragAndDropDelegate: model
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                HStack {
                    SetHeaderSettings()
                        .environmentObject(model)
                        .frame(width: tableHeaderSize.width)
                        .offset(x: 4, y: 8)
                    Spacer()
                }
                Spacer.fixedHeight(16)
            }
        }
        .background(Color.backgroundPrimary)
    }
}
