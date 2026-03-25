import Foundation
import SwiftUI
import AnytypeCore
import DesignKit

struct ChannelCreateView: View {

    @State private var model: SpaceCreateViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: SpaceCreateData, output: (any SpaceCreateModuleOutput)?) {
        _model = State(initialValue: SpaceCreateViewModel(data: data, output: output))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                iconSection

                FramedTextField(
                    title: Loc.name,
                    placeholder: Loc.untitled,
                    axis: .vertical,
                    text: $model.spaceName
                )
                .accessibilityLabel("SpaceNameTextField")

                ThresholdCounter(usecase: .spaceName, count: model.spaceName.count)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle(Loc.Channel.Create.newChannel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AsyncButton {
                    try await model.onTapCreate()
                } label: {
                    Text(Loc.create)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(model.spaceName.isEmpty || model.spaceName.count > ThresholdCounterUsecase.spaceName.threshold)
            }
        }
        .onAppear {
            model.onAppear()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
        .background(Color.Background.primary)
        .onChange(of: model.spaceName) {
            model.updateNameIconIfNeeded($1)
        }
    }

    private var iconSection: some View {
        Button {
            model.onIconTapped()
        } label: {
            VStack(spacing: 0) {
                Spacer.fixedHeight(8)
                IconView(icon: model.spaceIcon)
                    .frame(width: 96, height: 96)
                Spacer.fixedHeight(6)
                AnytypeText(Loc.changeIcon, style: .uxCalloutMedium)
                    .foregroundStyle(Color.Control.secondary)
                Spacer.fixedHeight(20)
            }
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
}
