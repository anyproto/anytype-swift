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
    weak var output: (any CommonWidgetModuleOutput)?

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?,
        onCreateObjectType: @escaping () -> Void
    ) {
        self.output = output
        self._model = State(
            wrappedValue: ObjectTypesSectionViewModel(
                spaceId: spaceId,
                output: output,
                onCreateObjectType: onCreateObjectType
            )
        )
    }

    var body: some View {
        // Outer always-rendered VStack so .task attaches across the data-loading transition.
        VStack(spacing: 0) {
            if model.objectTypesDataLoaded {
                HomeWidgetsGroupView(title: Loc.types) {
                    model.onTapHeader()
                }
                if model.isExpanded {
                    ObjectTypesUnifiedWidgetView(
                        typeInfos: model.objectTypeWidgets,
                        canCreateType: model.canCreateObjectType,
                        onCreateType: { model.onCreateObjectType() },
                        output: output
                    )
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
