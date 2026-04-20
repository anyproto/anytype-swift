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

    /// Toggle channel pin for `targetObjectId` against `channelWidgetsObject`
    /// (`info.widgetsId`). Mirrors the pin/unpin flow in
    /// `ObjectSettingsViewModel.changePinState`.
    func onChannelPinTap(
        targetObjectId: String,
        channelWidgetsObject: any BaseDocumentProtocol
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
        // TODO: IOS-5864 No dedicated favorite/unfavorite analytics event exists today.
        // Mirror with `ObjectSettingsViewModel.changeFavoriteState` when product confirms
        // the event shape.
        let service = personalFavoritesService
        Task {
            try? await service.toggle(objectId: targetObjectId, accountInfo: accountInfo)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onChannelPinTap(
        targetObjectId: String,
        channelWidgetsObject: any BaseDocumentProtocol
    ) {
        // TODO: IOS-5864 No dedicated pin/unpin analytics event exists today.
        // Mirror with `ObjectSettingsViewModel.changePinState` when product confirms
        // the event shape.
        let service = blockWidgetService
        let contextId = channelWidgetsObject.objectId
        let existingWidgetBlockId = channelWidgetsObject.widgetBlockIdFor(targetObjectId: targetObjectId)
        let firstChildBlockId = channelWidgetsObject.children.first?.id
        Task {
            try? await service.toggleWidgetBlock(
                contextId: contextId,
                targetObjectId: targetObjectId,
                existingWidgetBlockId: existingWidgetBlockId,
                firstChildBlockId: firstChildBlockId,
                layout: .link,
                limit: 0
            )
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
