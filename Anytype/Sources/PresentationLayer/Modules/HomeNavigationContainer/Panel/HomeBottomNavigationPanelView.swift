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

    @Environment(\.widgetsAnimationNamespace) private var widgetsNamespace

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
            HStack {
                if model.isWidgetsScreen {
                    searchButton
                    Spacer()
                    createButton
                } else {
                    burgerButton
                    Spacer()
                    searchButton
                    Spacer()
                    createButton
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
    
    @ViewBuilder
    private var burgerButton: some View {
        if let widgetsNamespace, #available(iOS 26.0, *) {
            burgerButtonView.matchedTransitionSource(id: "widgetsOverlay", in: widgetsNamespace)
        } else {
            burgerButtonView
        }
    }

    @ViewBuilder
    private var burgerButtonView: some View {
        Button {
            model.onTapShowWidgets()
        } label: {
            Image(asset: .X24.burger)
                .renderingMode(.template)
                .navPanelDynamicForegroundStyle()
                .padding(4)
        }
        .frame(width: 40, height: 40)
        .background(Color.Shape.tertiary)
        .clipShape(Circle())
    }

    private var searchButton: some View {
        Button {
            model.onTapSearch()
        } label: {
            Image(asset: .X24.search)
                .renderingMode(.template)
                .navPanelDynamicForegroundStyle()
                .padding(4)
        }
        .frame(width: 40, height: 40)
        .background(Color.Shape.tertiary)
        .clipShape(Circle())
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
                Image(systemName: "square.and.pencil")
                    .renderingMode(.template)
                    .navPanelDynamicForegroundStyle()
                    .padding(4)
            }
            .frame(width: 40, height: 40)
            .background(Color.Shape.tertiary)
            .clipShape(Circle())
            .menuOrder(.fixed)
            .disabled(!model.canCreateObject)
        } else {
            Button {
                model.onTapNewObject()
            } label: {
                Image(asset: .X24.edit)
                    .renderingMode(.template)
                    .navPanelDynamicForegroundStyle()
                    .padding(4)
            }
            .frame(width: 40, height: 40)
            .background(Color.Shape.tertiary)
            .clipShape(Circle())
            .disabled(!model.canCreateObject)
        }
    }
}
