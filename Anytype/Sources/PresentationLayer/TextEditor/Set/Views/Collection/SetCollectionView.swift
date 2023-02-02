import SwiftUI

struct SetCollectionView: View {
    @ObservedObject private(set) var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    
    var headerMinimizedSize: CGSize
    let viewType: SetContentViewType.CollectionType

    var body: some View {
        OffsetAwareScrollView(
            axes: [.vertical],
            showsIndicators: false,
            offsetChanged: { offset.y = $0.y }
        ) {
            Spacer.fixedHeight(tableHeaderSize.height)
            contentTypeView
            pagination
        }
    }
    
    private var contentTypeView: some View {
        Group {
            switch viewType {
            case .list:
                list
            case .gallery:
                gallery
            }
        }
    }
    
    // MARK: Gallery view
    
    private var gallery: some View {
        LazyVGrid(
            columns: columns(),
            alignment: .center,
            spacing: SetCollectionView.interCellSpacing,
            pinnedViews: [.sectionHeaders])
        {
            galleryContent
        }
        .padding(.top, -headerMinimizedSize.height)
        .padding(.horizontal, 10)
    }
    
    private var galleryContent: some View {
        Group {
            if model.isEmptyViews {
                EmptyView()
            } else if model.isEmptyQuery {
                emptyCompoundHeader
            } else {
                Section(header: compoundHeader) {
                    ForEach(model.configurationsDict.keys, id: \.self) { groupId in
                        if let configurations = model.configurationsDict[groupId] {
                            ForEach(configurations) { configuration in
                                SetGalleryViewCell(configuration: configuration)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: List view
    
    private var list: some View {
        LazyVStack(
            alignment: .center,
            spacing: 0,
            pinnedViews: [.sectionHeaders]
        ) {
            listContent
        }
        .padding(.top, -headerMinimizedSize.height)
        .padding(.horizontal, 20)
    }
    
    private var listContent: some View {
        Group {
            if model.isEmptyViews {
                EmptyView()
            } else if model.isEmptyQuery {
                emptyCompoundHeader
            } else {
                Section(header: compoundHeader) {
                    ForEach(model.configurationsDict.keys, id: \.self) { groupId in
                        if let configurations = model.configurationsDict[groupId] {
                            ForEach(configurations) { configuration in
                                if configurations.first == configuration {
                                    Divider()
                                }
                                SetListViewCell(configuration: configuration)
                                    .divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var pagination: some View {
        EditorSetPaginationView(
            paginationData: model.pagitationData(by: SubscriptionId.set.value),
            groupId: SubscriptionId.set.value
        )
        .frame(width: tableHeaderSize.width)
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                headerSettingsView
                Spacer.fixedHeight(
                    viewType == .list ? 16 : 6
                )
            }
        }
        .background(Color.Background.primary)
    }
    
    private var emptyCompoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            headerSettingsView
            Spacer.fixedHeight(14)
            AnytypeDivider()
            Spacer.fixedHeight(48)
            EditorSetEmptyView(
                model: EditorSetEmptyViewModel(
                    mode: .set,
                    onTap: model.showSetOfTypeSelection
                )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerSettingsView: some View {
        HStack {
            SetHeaderSettingsView(
                model: SetHeaderSettingsViewModel(
                    setDocument: model.setDocument,
                    isActive: !model.isEmptyQuery,
                    onViewTap: model.showViewPicker,
                    onSettingsTap: model.showSetSettings,
                    onCreateTap: model.createObject
                )
            )
            .frame(width: tableHeaderSize.width)
            .offset(x: model.isEmptyQuery && viewType == .gallery ? -10 : 4, y: 8)
            Spacer()
        }
    }
    
    private func columns() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: SetCollectionView.interCellSpacing, alignment: .topLeading),
            count: model.isSmallItemSize ? 2 : 1
        )
    }
}

extension SetCollectionView {
    static let interCellSpacing: CGFloat = 11
}

struct SetCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        SetCollectionView(
            model: EditorSetViewModel.emptyPreview,
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero,
            viewType: .gallery
        )
    }
}

