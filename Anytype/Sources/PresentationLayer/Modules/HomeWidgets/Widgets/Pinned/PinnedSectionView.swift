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

    let info: AccountInfo
    let personalWidgetsObject: any BaseDocumentProtocol
    weak var output: (any HomeWidgetsModuleOutput)?

    init(
        info: AccountInfo,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.personalWidgetsObject = personalWidgetsObject
        self.output = output
        self._model = State(
            wrappedValue: PinnedSectionViewModel(
                spaceId: info.accountSpaceId,
                channelWidgetsObject: channelWidgetsObject
            )
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            if model.widgetBlocks.isNotEmpty {
                WidgetSwipeTipView()
                ForEach(model.widgetBlocks) { widgetInfo in
                    HomeWidgetSubmoduleView(
                        widgetInfo: widgetInfo,
                        channelWidgetsObject: model.channelWidgetsObject,
                        personalWidgetsObject: personalWidgetsObject,
                        workspaceInfo: info,
                        homeState: $model.homeState,
                        output: output
                    )
                }
            }
        }
        .anytypeVerticalDrop(data: model.widgetBlocks, state: $dndState) { from, to in
            model.widgetsDropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.widgetsDropFinish(from: from, to: to)
        }
        .animation(.default, value: model.widgetBlocks.count)
        .task {
            await model.startSubscriptions()
        }
    }
}
