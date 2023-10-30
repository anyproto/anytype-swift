import Foundation
import SwiftUI

struct ServerConfigurationView: View {
    
    private let serverConfigurationStorage = ServerConfigurationStorage.shared
    
    @State private var servers: [String] = []
    @State private var selectedServer: String?
    @State private var showDocumentPicker: Bool = false
    @State private var showRestartAlert: Bool = false
    @State private var showErrorInstallAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                DragIndicator()
                AnytypeText("Server configuration", style: .title, color: .Text.primary)
                Spacer.fixedHeight(10)
                
                ScrollView {
                    VStack {
                        row(title: "Production", isSelected: selectedServer.isNil)
                            .onTapGesture {
                                serverConfigurationStorage.setupCurrentConfiguration(fileName: nil)
                                updateViewState()
                                showRestartAlert.toggle()
                            }
                        ForEach(servers, id: \.self) { server in
                            row(title: server, isSelected: server == selectedServer)
                                .onTapGesture {
                                    serverConfigurationStorage.setupCurrentConfiguration(fileName: server)
                                    updateViewState()
                                    showRestartAlert.toggle()
                                }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20, style: .continuous)
                    .padding(16)
                }
                .background(UIColor.systemGroupedBackground.suColor)
                
                StandardButton("Add server", style: .secondaryMedium) {
                    showDocumentPicker.toggle()
                }
                .padding(16)
            }
            .background(Color.Background.primary)
            .navigationBarHidden(true)
        }
        .onAppear {
            updateViewState()
        }
        .sheet(isPresented: $showDocumentPicker) {
            ServerDocumentPicker { url in
                do {
                    try serverConfigurationStorage.addConfiguration(filePath: url, setupAsCurrent: true)
                    updateViewState()
                    showRestartAlert.toggle()
                } catch {
                    showErrorInstallAlert.toggle()
                }
            }
        }
        .alert("Application will be closed", isPresented: $showRestartAlert) {
            Button("Close", role: .none) {
                exit(0)
            }
        }
        .alert("Error", isPresented: $showErrorInstallAlert) {
            Button("Ok", role: .cancel) { }
        }
        
    }
    
    private func row(title: String, isSelected: Bool) -> some View {
        HStack {
            AnytypeText(title, style: .bodyRegular, color: .black)
            Spacer()
            if isSelected {
                Image(asset: .X24.tick)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .fixTappableArea()
        .newDivider()
    }
    
    private func updateViewState() {
        servers = serverConfigurationStorage.configurations()
        selectedServer = serverConfigurationStorage.currentConfiguration()
    }
}
