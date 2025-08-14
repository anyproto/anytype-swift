import Foundation
import SwiftUI

struct InitialCoordinatorView: View {
    
    @StateObject private var model = InitialCoordinatorViewModel()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if model.showSaveBackupAlert {
                crashView
            }
        }
        .onAppear {
            model.onAppear()
        }
        .alert(Loc.Initial.UnstableMiddle.title, isPresented: $model.showWarningAlert) {
            if model.userId.isNotEmpty {
                Button(Loc.Initial.UnstableMiddle.logout) {
                    model.contunueWithLogout()
                }
                
                Button(Loc.Initial.UnstableMiddle.continue, role: .cancel) {
                    model.contunueWithoutLogout()
                }
            } else {
                Button(Loc.Initial.UnstableMiddle.wontUseProd) {
                    model.contunueWithTrust()
                }
            }
        } message: {
            Text(verbatim: Loc.Initial.UnstableMiddle.message)
        }
        .snackbar(toastBarData: $model.toastBarData)
        .sheet(item: $model.middlewareShareFile) { link in
            ActivityView(activityItems: [link])
        }
        .sheet(item: $model.localStoreURL) { link in
            ActivityView(activityItems: [link])
        }
        .anytypeSheet(item: $model.secureAlertData) {
            SecureAlertView(data: $0)
        }
    }
    
    private var crashView: some View {
        VStack {
            Spacer()
            AnytypeText("🚨", style: .uxTitle1Semibold)
                .foregroundColor(.Text.white)
            AnytypeText("Previous run finished with crash", style: .uxTitle1Semibold)
                .foregroundColor(.Text.white)
            AnytypeText("You can copy and send your data (documents, files, etc.) to developers. If your data contains private information, do not send it to anyone.", style: .uxTitle2Medium)
                .foregroundColor(.Text.white)
                .multilineTextAlignment(.center)
            Spacer()
            StandardButton("Export full directory 🤐", style: .primaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.onShareMiddleware()
            }
            StandardButton(.text("Copy phrase 🔐"), style: .primaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.onCopyPhrase()
            }
            Spacer()
            StandardButton(.text("Continue"), style: .secondaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                model.onContinueCrashAlert()
            }
        }
        .padding(.horizontal, 16)
    }
}
