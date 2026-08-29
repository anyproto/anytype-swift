import Foundation
import SwiftUI
import Services

struct QuickCaptureCoordinatorView: View {

    @State private var model: QuickCaptureCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var topInset: CGFloat = 0

    init(onCreated: @escaping (QuickCaptureCreatedBanner) -> Void) {
        _model = State(initialValue: QuickCaptureCoordinatorViewModel(onCreated: onCreated))
    }

    var body: some View {
        content
            .ignoresSafeArea(.keyboard)
            .onAppear {
                model.dismiss = dismiss
            }
            .task {
                await model.onAppear()
            }
            .task(id: model.editorData?.objectId) {
                await model.subscribeOnDraft()
            }
            .homeBottomPanelState(.constant(HomeBottomPanelState()))
            .pageNavigation(model.pageNavigation)
            .pageEditorAdditionalSafeAreaInsets(UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0))
            .safeAreaInset(edge: .top, spacing: 0) {
                headerContainer
                    .readSize {
                        topInset = $0.height
                    }
            }
            .anytypeSheet(item: $model.syncStatusSpaceId) {
                SyncStatusInfoView(spaceId: $0.value)
            }
            .anytypeSheet(item: $model.undoRedoObjectId) {
                UndoRedoView(objectId: $0.value)
            }
            .sheet(isPresented: $model.showSpacePicker) {
                QuickCaptureSpacePickerView(
                    spaces: model.sortedEditableSpaces,
                    selectedSpaceId: model.spaceView?.targetSpaceId,
                    onSelect: { model.onSelectSpace($0) }
                )
            }
            .snackbar(toastBarData: $model.toastBarData)
    }

    @ViewBuilder
    private var content: some View {
        if let editorData = model.editorData {
            EditorPageCoordinatorView(data: editorData, showHeader: false)
                .id(editorData.objectId)
        } else {
            VStack {
                Spacer()
                CircleLoadingView()
                    .frame(width: 24, height: 24)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.Background.primary)
        }
    }

    private var headerContainer: some View {
        VStack(spacing: 0) {
            DragIndicator()
            header
        }
    }

    private var header: some View {
        GlassEffectContainerIOS26(spacing: 12) {
            HStack(spacing: 12) {
                spaceChip

                Spacer(minLength: 8)

                syncStatusButton
                if let editorData = model.editorData {
                    settingsMenu(editorData)
                }
                if model.isNotEmpty {
                    trashButton
                }
                sendButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .confirmationDialog(
            Loc.QuickCapture.clearDraftTitle,
            isPresented: $model.showClearDraftConfirmation,
            titleVisibility: .visible
        ) {
            Button(Loc.QuickCapture.clearDraft, role: .destructive) {
                model.onConfirmClearDraft()
            }
        }
        .confirmationDialog(
            Loc.QuickCapture.replaceDraftTitle(model.pendingSpaceSwitch?.title ?? ""),
            isPresented: replaceDraftConfirmation,
            titleVisibility: .visible
        ) {
            Button(Loc.QuickCapture.replaceDraft, role: .destructive) {
                model.onConfirmReplaceDraft()
            }
            Button(Loc.cancel, role: .cancel) {
                model.onCancelReplaceDraft()
            }
        } message: {
            Text(Loc.QuickCapture.replaceDraftMessage)
        }
    }

    private var replaceDraftConfirmation: Binding<Bool> {
        Binding(
            get: { model.pendingSpaceSwitch != nil },
            set: { if !$0 { model.onCancelReplaceDraft() } }
        )
    }

    private var spaceChip: some View {
        Button {
            model.onTapSpaceChip()
        } label: {
            HStack(spacing: 6) {
                IconView(icon: model.spaceView?.objectIconImage)
                    .frame(width: 20, height: 20)
                AnytypeText(model.spaceView?.title ?? "", style: .uxCalloutMedium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Image(asset: .X18.Disclosure.down)
                    .foregroundStyle(Color.Control.secondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
        }
        .disabled(model.isProcessing)
        .glassEffectInteractiveIOS26(in: Capsule())
    }

    private var syncStatusButton: some View {
        Button {
            model.onTapSyncStatus()
        } label: {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
                onTap: {}
            )
            .frame(width: 28, height: 28)
            .allowsHitTesting(false)
        }
        .frame(width: 44, height: 44)
        .glassEffectInteractiveIOS26(in: Circle())
    }

    private func settingsMenu(_ editorData: EditorPageObject) -> some View {
        ObjectSettingsMenuContainer(
            objectId: editorData.objectId,
            spaceId: editorData.spaceId,
            output: model,
            quickCapture: true
        ) {
            Image(asset: .X24.more)
                .renderingMode(.template)
                .foregroundStyle(Color.Control.primary)
                .frame(width: 44, height: 44)
        }
        .glassEffectInteractiveIOS26(in: Circle())
    }

    private var trashButton: some View {
        Button {
            model.onTapClearDraft()
        } label: {
            Image(asset: .X32.delete)
                .renderingMode(.template)
                .foregroundStyle(Color.Control.primary)
        }
        .frame(width: 44, height: 44)
        .disabled(model.isProcessing)
        .glassEffectInteractiveIOS26(in: Circle())
    }

    private var sendButton: some View {
        Button {
            model.onTapSend()
        } label: {
            Group {
                if model.isProcessing {
                    CircleLoadingView()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.Text.white)
                }
            }
            .frame(width: 44, height: 44)
            .background(Color.Control.accent100)
            .clipShape(Circle())
            .opacity(model.isNotEmpty ? 1 : 0.4)
        }
        .disabled(!model.isNotEmpty || model.isProcessing)
    }

}
