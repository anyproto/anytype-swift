import SwiftUI
import Services

struct SimpleSetView: View {
    
    @StateObject private var model: SimpleSetViewModel
    
    init(objectId: String, spaceId: String, output: (any SimpleSetModuleOutput)?) {
        self._model = StateObject(wrappedValue: SimpleSetViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PageNavigationHeader(title: model.title) {}
            content
        }
        .task {
            await model.startSubscriptions()
        }
        .task(item: model.state) { _ in
            await model.subscribeOnObjects()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.sections.isEmpty {
            emptyState
        } else {
            layoutView
        }
    }
    
    @ViewBuilder
    private var layoutView: some View {
        if let layout = model.state?.layout {
            switch layout {
            case .list:
                list
            case .gallery:
                gallery
            }
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 20)
                }
                ForEach(section.rows, id: \.id) { row in
                    WidgetObjectListRowView(model: row)
                        .onAppear {
                            model.onAppearLastRow(row.id)
                        }
                        .if(row.canArchive) {
                            $0.swipeActions {
                                Button(Loc.toBin, role: .destructive) {
                                    model.onDelete(objectId: row.objectId)
                                }
                            }
                        }
                }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var gallery: some View {
        let imageIds: [String] = model.sections.flatMap { $0.rows.map(\.objectId) }
        return ImagesGalleryView(
            imageIds: imageIds,
            onImageSelected: { imageId in
                model.onObjectSelected(imageId)
            },
            onImageIdAppear: { imageId in
                model.onAppearLastRow(imageId)
            }
        ).padding(.horizontal, 20)
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: Loc.GlobalSearch.EmptyState.subtitle,
            style: .plain
        )
    }
}

#Preview {
    SimpleSetView(objectId: "", spaceId: "", output: nil)
}
