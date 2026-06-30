import SwiftUI
import Services


struct MembershipCodeActivationView: View {
    @State private var model: MembershipCodeActivationViewModel

    init(data: MembershipCodeActivationData, onRedeemed: @escaping (MembershipTierType?) async -> Void) {
        _model = State(initialValue: MembershipCodeActivationViewModel(data: data, onRedeemed: onRedeemed))
    }

    var body: some View {
        BottomAlertView(
            title: Loc.Membership.Code.title,
            message: Loc.Membership.Code.subtitle,
            headerView: {
                Image(asset: .Dialog.pinCode)
            },
            bodyView: {
                VStack(alignment: .leading, spacing: 6) {
                    FramedTextField(
                        placeholder: Loc.Membership.Code.placeholder,
                        text: $model.code
                    )
                    .disabled(model.isActivating)
                    if let errorText = model.errorText {
                        AnytypeText(errorText, style: .relation2Regular)
                            .foregroundStyle(Color.Dark.red)
                            .padding(.horizontal, 16)
                    }
                }
            },
            buttons: {
                BottomAlertButton(
                    text: Loc.Membership.Code.activate,
                    style: .primary,
                    disable: model.code.isEmpty
                ) {
                    await model.activate()
                }
            }
        )
        .onChange(of: model.code) {
            model.onCodeChanged()
        }
        .onAppear {
            model.onAppear()
        }
    }
}
