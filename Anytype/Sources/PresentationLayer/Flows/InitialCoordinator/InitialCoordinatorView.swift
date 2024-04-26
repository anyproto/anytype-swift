import Foundation
import SwiftUI

struct InitialCoordinatorView: View {
    
    @StateObject var model: InitialCoordinatorViewModel
    
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
            if UserDefaultsConfig.usersId.isNotEmpty {
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
        .preferredColorScheme(.dark)
        .snackbar(toastBarData: $model.toastBarData)
        .anytypeShareView(item: $model.middlewareShareFile)
        .anytypeShareView(item: $model.localStoreURL)
    }
    
    private var crashView: some View {
        VStack {
            Spacer()
            AnytypeText("🚨", style: .uxTitle1Semibold, color: .Text.white)
            AnytypeText("Previous run finished with crash", style: .uxTitle1Semibold, color: .Text.white)
            AnytypeText("You can copy and send your data (documents, files and etc) to developers. If your data contains private information, do not send it to the anyone.", style: .uxTitle2Medium, color: .Text.white)
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
