import Foundation
import SwiftUI
import AnytypeCore
import DesignKit

struct ChannelCreateView: View {

    @State private var model: SpaceCreateViewModel
    @State private var isCreating = false
    @Environment(\.dismiss) private var dismiss

    init(data: SpaceCreateData, output: (any SpaceCreateModuleOutput)?) {
        _model = State(initialValue: SpaceCreateViewModel(data: data, output: output))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if !model.isConnected, model.data.selectedContacts.isNotEmpty {
                    OfflineMembersBannerView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
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

                membersSection
            }
        }
        .navigationTitle(Loc.Channel.Create.newChannel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarNavigationBarOpaqueBackgroundLegacy()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard !isCreating else { return }
                    isCreating = true
                    Task {
                        do {
                            try await model.onTapCreate()
                        } catch {
                            isCreating = false
                        }
                    }
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(Loc.create)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(Color.Control.accent100)
                .foregroundStyle(.white)
                .disabled(isCreating || model.spaceName.isEmpty || model.spaceName.count > ThresholdCounterUsecase.spaceName.threshold)
            }
        }
        .task {
            await model.startNetworkObservation()
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

    @ViewBuilder
    private var membersSection: some View {
        let contacts = model.data.selectedContacts
        if contacts.isNotEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Spacer.fixedHeight(20)
                AnytypeText(
                    Loc.membersPlural(contacts.count),
                    style: .caption1Regular
                )
                .foregroundStyle(Color.Text.secondary)
                .padding(.horizontal, 20)
                Spacer.fixedHeight(8)
                ForEach(contacts) { contact in
                    MemberRow(icon: contact.icon, name: contact.name, globalName: contact.globalName) {
                        EmptyView()
                    }
                }
            }
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
