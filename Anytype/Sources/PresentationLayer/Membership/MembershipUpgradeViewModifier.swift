import SwiftUI


@MainActor
final class MembershipUpgradeViewModifierModel: ObservableObject {
    @Published var openUrl: URL?
    @Published var showMembershipScreen = false
    @Published var showMembershipEmailAlert = false
    
    @Injected(\.mailUrlBuilder) private var mailUrlBuilder
    @Injected(\.membershipStatusStorage) private var statusStorage
    
    private let reason: MembershipUpgradeReason
    
    nonisolated init(reason: MembershipUpgradeReason) {
        self.reason = reason
    }
    
    func onPresented() {
        guard let currentTier = statusStorage.currentStatus.tier else { return }
        
        if currentTier.isPossibleToUpgrade(reason: reason) {
            showMembershipScreen = true
        } else {
            showMembershipEmailAlert = true
        }
    }
    
    func onTapContactAnytype() {
        openUrl = mailUrlBuilder.membershipUpgrateUrl()
        showMembershipEmailAlert = false
    }
}

struct MembershipUpgradeViewModifier: ViewModifier {
    
    @StateObject private var model: MembershipUpgradeViewModifierModel
    @Binding private var isPresented: Bool
    
    init(isPresented: Binding<Bool>, reason: MembershipUpgradeReason) {
        _isPresented = isPresented
        _model = StateObject(wrappedValue: MembershipUpgradeViewModifierModel(reason: reason))
    }


     func body(content: Content) -> some View {
         content
             .openUrl(url: $model.openUrl)
             .sheet(isPresented: $model.showMembershipScreen, onDismiss: {
                 isPresented = false
             }, content: {
                 MembershipCoordinator()
             })
             .anytypeSheet(isPresented: $model.showMembershipEmailAlert, onDismiss: {
                 isPresented = false
             } ,content: {
                 MembershipUpgradeEmailBottomAlert {
                     model.onTapContactAnytype()
                     isPresented = false
                 }
             })
         
             .onAppear {
                 if isPresented { model.onPresented() }
             }
             .onChange(of: isPresented) { isPresented in
                 if isPresented { model.onPresented() }
             }
     }
}


extension View {
    func membershipUpgrade(isPresented: Binding<Bool>, reason: MembershipUpgradeReason) -> some View {
        modifier(MembershipUpgradeViewModifier(isPresented: isPresented, reason: reason))
     }
}
