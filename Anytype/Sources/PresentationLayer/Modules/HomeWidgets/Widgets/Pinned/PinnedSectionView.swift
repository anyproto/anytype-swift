import Foundation
import SwiftUI
import Services

struct PinnedSectionView: View {

    let info: AccountInfo
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    weak var output: (any HomeWidgetsModuleOutput)?

    var body: some View {
        PinnedSectionViewInternal(
            info: info,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject,
            output: output
        )
    }
}

private struct PinnedSectionViewInternal: View {

    @State private var model: PinnedSectionViewModel
    @State private var dndState = DragState()

    init(
        info: AccountInfo,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self._model = State(
            wrappedValue: PinnedSectionViewModel(
                info: info,
                channelWidgetsObject: channelWidgetsObject,
                personalWidgetsObject: personalWidgetsObject,
                output: output
            )
        )
    }

    var body: some View {
        content
            .task {
                await model.startSubscriptions()
            }
    }

    @ViewBuilder
    private var content: some View {
        if model.widgetBlocks.isNotEmpty {
            VStack(spacing: 12) {
                WidgetSwipeTipView()
                ForEach(model.widgetBlocks) { widgetInfo in
                    HomeWidgetSubmoduleView(
                        widgetInfo: widgetInfo,
                        channelWidgetsObject: model.channelWidgetsObject,
                        personalWidgetsObject: model.personalWidgetsObject,
                        workspaceInfo: model.info,
                        homeState: $model.homeState,
                        output: model.output
                    )
                }
            }
            .anytypeVerticalDrop(data: model.widgetBlocks, state: $dndState) { from, to in
                model.widgetsDropUpdate(from: from, to: to)
            } dropFinish: { from, to in
                model.widgetsDropFinish(from: from, to: to)
            }
        }
    }
}
