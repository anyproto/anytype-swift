import Foundation
import SwiftUI
import AnytypeCore

struct SpaceCreateView: View {
    
    @StateObject private var model: SpaceCreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceCreateData, output: (any SpaceCreateModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceCreateViewModel(data: data, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: FeatureFlags.spaceUxTypes ? model.data.title : Loc.SpaceCreate.Space.title)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    iconSection
                    
                    RoundedTextFieldWithTitle(
                        title: FeatureFlags.spaceUxTypes ? Loc.name : Loc.Settings.spaceName,
                        placeholder: Loc.untitled,
                        text: $model.spaceName
                    )
                    .focused(.constant(true))
                    
                    if !FeatureFlags.spaceUxTypes {
                        SectionHeaderView(title: Loc.typeLabel)
                        SpaceTypeView(name: model.spaceAccessType.name)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                StandardButton(model: StandardButtonModel(text: Loc.create, inProgress: model.createLoadingState, style: .primaryLarge, action: {
                    model.onTapCreate()
                }))
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            model.onAppear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .ignoreSafeAreaKeyboardLegacy()
        .background(Color.Background.primary)
        .onChange(of: model.spaceName) {
            model.updateNameIconIfNeeded($0)
        }
    }
    
    private var iconSection: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            IconView(icon: model.spaceIcon)
                .frame(width: 96, height: 96)
            Spacer.fixedHeight(6)
            AnytypeText(Loc.changeIcon, style: .uxCalloutMedium)
                .foregroundColor(.Control.secondary)
            Spacer.fixedHeight(20)
        }
        .fixTappableArea()
        .onTapGesture {
            model.onIconTapped()
        }
    }
}

private extension View {
    // Fix glitch when user dismiss screen with opened keyboard
    @available(iOS, deprecated: 16.4)
    func ignoreSafeAreaKeyboardLegacy() -> some View {
        if #available(iOS 16.4, *) {
            return self
        } else {
            return self.ignoresSafeArea(.keyboard)
        }
    }
}
