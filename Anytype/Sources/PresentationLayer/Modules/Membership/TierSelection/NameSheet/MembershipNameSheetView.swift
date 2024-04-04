import SwiftUI
import Services


struct MembershipNameSheetView: View {    
    @StateObject private var model: MembershipNameSheetViewModel
    @State private var name = ""
    
    init(tier: MembershipTier, anyName: String) {
        _model = StateObject(
            wrappedValue: MembershipNameSheetViewModel(tier: tier, anyName: anyName)
        )
    }
    
    var body: some View {
        content
            .background(Color.Background.primary)
            .onChange(of: name) { name in
                model.validateName(name: name)
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            info
            nameInput
            .newDivider()
            status
            AnytypeText("$99 ", style: .title, color: .Text.primary) +
            AnytypeText(Loc.perYear(1), style: .relation1Regular, color: .Text.primary)
            Spacer.fixedHeight(15)
            StandardButton(
                Loc.payByCard,
                style: .primaryLarge
            ) {
                // TODO: Pay
            }
            .disabled(!model.state.isValidated)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
    }
    
    var info: some View {
        Group {
            if model.anyName.isEmpty {
                AnytypeText(Loc.Membership.NameForm.title, style: .bodySemibold, color: .Text.primary)
                Spacer.fixedHeight(6)
                AnytypeText(Loc.Membership.NameForm.subtitle, style: .calloutRegular, color: .Text.primary)
                Spacer.fixedHeight(10)
            }
        }
    }
    
    var nameInput: some View {
        HStack {
            if model.anyName.isEmpty {
                TextField(Loc.myself, text: $name)
                    .textContentType(.username)
                AnytypeText(".any", style: .bodyRegular, color: .Text.primary)
            } else {
                AnytypeText(model.anyName, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(".any", style: .bodyRegular, color: .Text.primary)
            }
        }
        .padding(.vertical, 12)
    }
    
    var status: some View {
        Group {
            if model.anyName.isEmpty {
                nameStatus
            }
        }
    }
    
    var nameStatus: some View {
        HStack {
            Spacer()
            Group {
                switch model.state {
                case .default:
                    AnytypeText(Loc.minXCharacters(model.minimumNumberOfCharacters), style: .relation2Regular, color: .Text.secondary)
                case .validating:
                    AnytypeText(Loc.Membership.NameForm.validating, style: .relation2Regular, color: .Text.secondary)
                case .error(text: let text):
                    AnytypeText(text, style: .relation2Regular, color: .Dark.red)
                case .validated:
                    AnytypeText(Loc.Membership.NameForm.validated, style: .relation2Regular, color: .Dark.green)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
            
            Spacer()
        }
        .lineLimit(1)
    }
}

#Preview {
    TabView {
        MembershipNameSheetView(tier: .mockBuilder, anyName: "")
        MembershipNameSheetView(tier: .mockCoCreator, anyName: "SonyaBlade")
    }.tabViewStyle(.page)
}
