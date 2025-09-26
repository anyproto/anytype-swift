import Foundation
import SwiftUI
import AnytypeCore
import Services

struct HomeBottomNavigationPanelView: View {
    
    let homePath: HomePath
    let info: AccountInfo
    weak var output: (any HomeBottomNavigationPanelModuleOutput)?
    
    var body: some View {
        HomeBottomNavigationPanelViewInternal(homePath: homePath, info: info, output: output)
            .id(info.accountSpaceId)
    }
}

private struct HomeBottomNavigationPanelViewInternal: View {
    
    let homePath: HomePath
    @StateObject private var model: HomeBottomNavigationPanelViewModel
    
    init(homePath: HomePath, info: AccountInfo, output: (any HomeBottomNavigationPanelModuleOutput)?) {
        self.homePath = homePath
        self._model = StateObject(wrappedValue: HomeBottomNavigationPanelViewModel(info: info, output: output))
    }
    
    var body: some View {
        buttons
    }

    @ViewBuilder
    var buttons: some View {
        HStack(alignment: .center, spacing: 40) {
            navigation
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(progressView)
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
        .overlay {
            if !FeatureFlags.updatedHomePlusMenu {
                if #available(iOS 17.0, *) {
                    HomeTipView()
                }
            }
        }
        .padding(.vertical, 10)
        .if(FeatureFlags.homeTestSwipeGeature) { view in
            view.gesture(
                DragGesture(minimumDistance: 100)
                    .onEnded { value in
                        if value.translation.width > 150 {
                            model.onTapBackward()
                        } else if value.translation.width < -150 {
                            model.onTapForward()
                        }
                    }
            )
        }
        .task {
            await model.startSubscriptions()
        }
        .onAppear {
            if let last = homePath.lastPathElement {
                model.updateVisibleScreen(data: last)
            }
        }
        .onChange(of: homePath) { homePath in
            if let last = homePath.lastPathElement {
                model.updateVisibleScreen(data: last)
            }
        }
    }
    
    @ViewBuilder
    private var navigation: some View {
        
        leftButton
        
        if FeatureFlags.updatedHomePlusMenu {
            Menu {
                if let type = model.pageObjectType {
                    Button {
                        model.onTapCreateObject(type: type)
                    } label: {
                        Label(Loc.page, systemImage: "text.document")
                    }
                }

                if let type = model.noteObjectType {
                    Button {
                        model.onTapCreateObject(type: type)
                    } label: {
                        Label(Loc.note, systemImage: "doc.plaintext")
                    }
                }

                if let type = model.taskObjectType {
                    Button {
                        model.onTapCreateObject(type: type)
                    } label: {
                        Label(Loc.task, systemImage: "checkmark.square")
                    }
                }

                Divider()

                Menu(Loc.more) {
                    Button { model.onAddMediaSelected() } label: {
                        Label(Loc.photos, systemImage: "photo")
                    }

                    if FeatureFlags.loadAttachmentsOnHomePlusMenu {
                        Button { model.onCameraSelected() } label: {
                            Label(Loc.camera, systemImage: "camera")
                        }
                        Button { model.onAddFilesSelected() } label: {
                            Label(Loc.files, systemImage: "document")
                        }
                    }

                    Divider()

                    ForEach(model.otherObjectTypes) { type in
                        Button {
                            model.onTapCreateObject(type: type)
                        } label: {
                            Text(type.displayName)
                        }
                    }
                }
            } label: {
                Image(asset: .X32.Island.addObject)
                    .navPanelDynamicForegroundStyle()
            }
            .menuOrder(.fixed)
            .disabled(!model.canCreateObject)
        } else {
            Image(asset: .X32.Island.addObject)
                .onTapGesture {
                    model.onTapNewObject()
                }
                .navPanelDynamicForegroundStyle()
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in
                            model.onPlusButtonLongtap()
                        }
                )
                .disabled(!model.canCreateObject)
        }
        
        Button {
            model.onTapSearch()
        } label: {
            Image(asset: .X32.Island.search)
                .navPanelDynamicForegroundStyle()
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        if let progress = model.progress {
            GeometryReader { reader in
                Color.VeryLight.orange
                    .cornerRadius(2)
                    .frame(width: max(reader.size.width * progress, 30), alignment: .leading)
                    .animation(.linear, value: progress)
            }
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var leftButton: some View {
        switch model.leftButtonMode {
        case .member:
            Button {
                model.onTapMembers()
            } label: {
                Image(asset: .X32.Island.members)
                    .navPanelDynamicForegroundStyle()
            }
        case .owner(let enable):
            Button {
                model.onTapShare()
            } label: {
                Image(asset: .X32.Island.addMember)
                    .navPanelDynamicForegroundStyle()
            }
            .disabled(!enable)
        case .chat(let enable):
            Button {
                model.onTapAddToSpaceLevelChat()
            } label: {
                Image(asset: .X32.Island.discuss)
                    .navPanelDynamicForegroundStyle()
            }
            .disabled(!enable)
        case .home:
            Button {
                model.onTapHome()
            } label: {
                Image(asset: .X32.Island.vault)
                    .navPanelDynamicForegroundStyle()
            }
        case .none:
            EmptyView()
        }
    }
}
