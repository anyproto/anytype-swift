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

    @Namespace private var glassNamespace

    let homePath: HomePath
    @State private var model: HomeBottomNavigationPanelViewModel

    init(homePath: HomePath, info: AccountInfo, output: (any HomeBottomNavigationPanelModuleOutput)?) {
        self.homePath = homePath
        _model = State(initialValue: HomeBottomNavigationPanelViewModel(info: info, output: output))
    }
    
    var body: some View {
        buttons
    }

    @ViewBuilder
    var buttons: some View {
        VStack(spacing: 0) {
            GlassEffectContainerIOS26(spacing: 20) {
                HStack {
                    if model.showDiscussButton {
                        discussIsland
                            .glassEffectIDIOS26("discussIsland", in: glassNamespace)
                    } else {
                        searchButton
                            .glassEffectIDIOS26("search", in: glassNamespace)
                    }
                    Spacer()
                    if model.canCreateObject {
                        createButton
                            .glassEffectIDIOS26("create", in: glassNamespace)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background {
            HomeBlurEffectView(direction: .bottomToTop)
                .ignoresSafeArea()
        }
        .overlay {
            if !model.newObjectPlusMenu {
                HomeTipView()
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .onAppear {
            if let last = homePath.lastPathElement {
                model.updateVisibleScreen(data: last)
            }
        }
        .onChange(of: homePath) { _, homePath in
            if let last = homePath.lastPathElement {
                model.updateVisibleScreen(data: last)
            }
        }
    }

    private var searchButton: some View {
        Button {
            model.onTapSearch()
        } label: {
            Image(asset: .X32.Island.search)
                .renderingMode(.template)
                .foregroundStyle(Color.Control.primary)
        }
        .frame(width: 48, height: 48)
        .buttonStyleCircleGlassIOS26()
    }

    private var discussIsland: some View {
        Button {
            model.onTapDiscuss()
        } label: {
            Image(systemName: "message")
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.Control.primary)
        }
        .frame(width: 48, height: 48)
        .buttonStyleCircleGlassIOS26()
    }

    @ViewBuilder
    private var createButton: some View {
        if model.newObjectPlusMenu {
            Menu {
                if let type = model.pageObjectType {
                    Button {
                        model.onTapCreateObject(type: type)
                    } label: {
                        Label(Loc.page, systemImage: "doc.text")
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

                    Button { model.onCameraSelected() } label: {
                        Label(Loc.camera, systemImage: "camera")
                    }
                    Button { model.onAddFilesSelected() } label: {
                        Label(Loc.files, systemImage: "doc")
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
                Image(asset: .X32.Island.create)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.primary)
            }
            .frame(width: 48, height: 48)
            .glassEffectInteractiveIOS26(in: Circle())
            .menuOrder(.fixed)
        } else {
            Button {
                model.onTapNewObject()
            } label: {
                Image(asset: .X32.Island.create)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.primary)
            }
            .frame(width: 48, height: 48)
            .glassEffectInteractiveIOS26(in: Circle())
        }
    }
}
