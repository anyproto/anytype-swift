import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol WidgetActionsViewCommonMenuProviderProtocol: AnyObject {
    func onDeleteWidgetTap(
        widgetObject: any BaseDocumentProtocol,
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    )

    func onChangeTypeTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    )

    /// Toggle the personal favorite state for `targetObjectId`. Backed by
    /// `PersonalFavoritesService` — adds or removes a widget block in the
    /// per-user `personalWidgetsId` document.
    func onFavoriteTap(
        targetObjectId: String,
        accountInfo: AccountInfo
    )

    /// Toggle channel pin for `targetObjectId` against `widgetObject` (the shared
    /// channel widgets document, `info.widgetsId`). Mirrors the pin/unpin flow
    /// in `ObjectSettingsViewModel.changePinState`.
    func onChannelPinTap(
        targetObjectId: String,
        widgetObject: any BaseDocumentProtocol
    )
}

@MainActor
final class WidgetActionsViewCommonMenuProvider: WidgetActionsViewCommonMenuProviderProtocol {

    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.personalFavoritesService)
    private var personalFavoritesService: any PersonalFavoritesServiceProtocol

    nonisolated init() {}

    func onDeleteWidgetTap(
        widgetObject: any BaseDocumentProtocol,
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    ) {
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }

        if info.source.isLibrary {
            let data = DeleteSystemWidgetConfirmationData(onConfirm: { [weak self] in
                self?.deleteWidget(widgetObject: widgetObject, info: info, homeState: homeState)
            })
            output?.showDeleteSystemWidgetAlert(data: data)
        } else {
            deleteWidget(widgetObject: widgetObject, info: info, homeState: homeState)
        }
    }

    func onChangeTypeTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    ) {
        output?.onChangeWidgetType(widgetId: widgetBlockId, context: homeState.analyticsWidgetContext)
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onFavoriteTap(
        targetObjectId: String,
        accountInfo: AccountInfo
    ) {
        let service = personalFavoritesService
        Task {
            try? await service.toggle(objectId: targetObjectId, accountInfo: accountInfo)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onChannelPinTap(
        targetObjectId: String,
        widgetObject: any BaseDocumentProtocol
    ) {
        // Mirrors `ObjectSettingsViewModel.changePinState`: add or remove a widget
        // block against the channel widgets document. The call site supplies whichever
        // document is the "channel" in that context (for LinkWidget long-press, that's
        // `WidgetSubmoduleData.widgetObject`; for My Favorites rows, the caller hands
        // in the channel widgets doc explicitly).
        let service = blockWidgetService
        Task {
            if let widgetBlockId = widgetObject.widgetBlockIdFor(targetObjectId: targetObjectId) {
                try? await service.removeWidgetBlock(
                    contextId: widgetObject.objectId,
                    widgetBlockId: widgetBlockId
                )
            } else {
                let first = widgetObject.children.first
                try? await service.createWidgetBlock(
                    contextId: widgetObject.objectId,
                    sourceId: targetObjectId,
                    layout: .link,
                    limit: 0,
                    position: first.map { .above(widgetId: $0.id) } ?? .end
                )
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func deleteWidget(
        widgetObject: any BaseDocumentProtocol,
        info: BlockWidgetInfo,
        homeState: HomeWidgetsState
    ) {
        AnytypeAnalytics.instance().logDeleteWidget(
            source: info.source.analyticsSource,
            context: homeState.analyticsWidgetContext,
            createType: info.widgetCreateType
        )

        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: info.id
            )
        }

        UISelectionFeedbackGenerator().selectionChanged()
    }
}
