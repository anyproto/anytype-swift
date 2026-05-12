import Foundation
import SwiftUI
import Services

struct ObjectTypesSectionView: View {

    let spaceId: String
    weak var output: (any CommonWidgetModuleOutput)?
    let onCreateObjectType: () -> Void

    var body: some View {
        ObjectTypesSectionViewInternal(
            spaceId: spaceId,
            output: output,
            onCreateObjectType: onCreateObjectType
        )
    }
}

private struct ObjectTypesSectionViewInternal: View {

    @State private var model: ObjectTypesSectionViewModel
    let onCreateObjectType: () -> Void

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?,
        onCreateObjectType: @escaping () -> Void
    ) {
        self.onCreateObjectType = onCreateObjectType
        self._model = State(wrappedValue: ObjectTypesSectionViewModel(spaceId: spaceId, output: output))
    }

    var body: some View {
        // Outer always-rendered VStack so .task attaches across the data-loading transition.
        VStack(spacing: 0) {
            if model.objectTypesDataLoaded {
                HomeWidgetsGroupView(title: Loc.types) {
                    model.onTapObjectTypeHeader()
                }
                if model.objectTypeSectionIsExpanded {
                    ObjectTypesUnifiedWidgetView(
                        typeInfos: model.objectTypeWidgets,
                        canCreateType: model.canCreateObjectType,
                        onCreateType: onCreateObjectType,
                        onTap: { model.onTypeTap(info: $0) },
                        onCreate: { try await model.onCreateObject(info: $0) }
                    )
                    .transition(.sectionBody)
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
