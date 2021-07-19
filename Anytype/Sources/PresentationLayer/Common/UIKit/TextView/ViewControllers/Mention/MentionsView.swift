
protocol MentionsView: AnyObject {
    func display(_ list: [MentionDisplayData])
    func update( mention: MentionDisplayData)
    func dismiss()
}
