import Foundation

enum BlocksViews {
    enum Supplement {} // Contains Supplement entries that Serve functionality over ViewModels and Views.
    enum Toolbar {} // Contains Toolbar Views. Possibly that we need another namespace for Views that provides UserActions GUI for BlocksViews.

    
    // New
    enum Base {}
    enum Text {}
    enum File {}
    enum Tools {}
    enum Bookmark {}
    enum Other {}
    enum Unknown {}
}
