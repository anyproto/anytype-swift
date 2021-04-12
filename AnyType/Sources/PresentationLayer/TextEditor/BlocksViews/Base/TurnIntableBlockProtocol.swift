
/// Block which can perform turn into action
protocol TurnIntableBlockProtocol {
    
    /// Available types to which block can be converted
    var availableTurnIntoTypes: [BlocksViews.Toolbar.BlocksTypes] { get }
}
