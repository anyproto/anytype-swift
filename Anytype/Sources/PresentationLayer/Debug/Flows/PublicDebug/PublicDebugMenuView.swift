import SwiftUI
import AnytypeCore
import Logger

struct PublicDebugMenuView: View {
    
    @StateObject private var model = PublicDebugMenuViewModel()
    @State private var toggle = false
    
    var body: some View {
        VStack {
            DragIndicator()
            VStack {
                AnytypeText("Y0u h4ve f0und secr3t D3bug m3nu 🎉", style: .title)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.padding()
            
            ScrollView {
                VStack(spacing: 0) {
                    actions
                    Spacer.fixedHeight(20)
                }
                .padding(.horizontal)
                
            }
        }
        .background(Color.Background.primary)
        .navigationBarHidden(true)
        .embedInNavigation()
        
        .sheet(isPresented: $model.showZipPicker) {
            DocumentPicker(contentTypes: [.zip]) { url in
                model.onSelectUnzipFile(url: url)
            }
        }
        .sheet(item: $model.shareUrlFile) { url in
            ActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        .anytypeSheet(item: $model.secureAlertData) {
            SecureAlertView(data: $0)
        }
    }
    
    private var actions: some View {
        VStack {
            AsyncStandardButton("Download debug info 😋", style: .primaryLarge) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try await model.getGoroutinesData()
            }
            
            DisclosureGroup(isExpanded: $toggle) {
                if case .done(url: let url) = model.debugRunProfilerData {
                    StandardButton("Download Debug Run Profiler Data 💿", style: .secondaryLarge) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        model.shareUrlContent(url: url)
                    }
                }
            
                StandardButton(model.debugRunProfilerData.text, style: .primaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    model.onDebugRunProfiler()
                }
                
                AsyncStandardButton("Export localstore 📁", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try await model.getLocalStoreData()
                }
                
                AsyncStandardButton("Debug stat 🫵🐭", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try await model.debugStat()
                }

                AsyncStandardButton("Generate report 📦", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try await model.generateReport(full: false)
                }

                AsyncStandardButton("Generate full report 📦💪", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try await model.generateReport(full: true)
                }
                
                StandardButton("Export full directory 🤐", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    model.zipWorkingDirectory()
                }
                StandardButton("Import full directory 📲", style: .secondaryLarge) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    model.unzipWorkingDirectory()
                }
                
                Toggle(isOn: Binding(
                    get: { model.shouldRunDebugProfilerOnNextStartup } ,
                    set: { model.shouldRunDebugProfilerOnNextStartup = $0 }
                )) {
                    AnytypeText("Run Debug Profiler On Next Startup", style: .bodyRegular)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }.padding()
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText("Advanced stuff 🤓", style: .subheading)
                    AnytypeText("ĐØ ₦Ø₮ Ɇ₦₮ɆⱤ, ⱤɄ₦", style: .bodyRegular)
                        .foregroundStyle(Color.Text.secondary)
                }
                    .padding()
            }
        }
    }
}

#Preview {
    PublicDebugMenuView()
}
