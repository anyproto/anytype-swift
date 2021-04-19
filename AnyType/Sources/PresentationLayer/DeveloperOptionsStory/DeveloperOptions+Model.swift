import Foundation

struct DeveloperOptionsSettings: CodableAndDictionary {
    let debug: Debug
    let workflow: Workflow
    private init() {
        self.debug = .init(enabled: false)
        self.workflow = .init(
            authentication: .init(shouldSkipLogin: false, alphaInvitePasscode: "", shouldShowFocusedPageId: false, focusedPageId: ""),
            dashboard: .init(cellsHaveActionsOnLongTap: true),
            mainDocumentEditor: .init(textEditor: .init(), listView: .init())
        )
    }
    static let `default`: Self = .init()

    struct Debug: CodableAndDictionary {
        let enabled: Bool // should be set to true to allow other options.
    }
    
    struct Workflow: CodableAndDictionary {
        struct Authentication: CodableAndDictionary {
            let shouldSkipLogin: Bool
            let alphaInvitePasscode: String
            let shouldShowFocusedPageId: Bool
            let focusedPageId: String
        }
        
        struct Dashboard: CodableAndDictionary {
            let cellsHaveActionsOnLongTap: Bool
        }
        
        struct MainDocumentEditor: CodableAndDictionary {
            struct TextEditor: CodableAndDictionary {}
            struct ListView: CodableAndDictionary {}
            let textEditor: TextEditor
            let listView: ListView
        }
        
        let authentication: Authentication
        let dashboard: Dashboard
        let mainDocumentEditor: MainDocumentEditor
    }
    
    func isRelease() -> Bool {
        self.debug.enabled == false
    }
}
