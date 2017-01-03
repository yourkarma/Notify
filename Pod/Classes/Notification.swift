public struct NotifyNotification {
    public enum Level {
        case error
        case success
        case `default`
    }

    public let level: NotifyNotification.Level
    public let message: String
    public let actions: [Action]

    public init(level: NotifyNotification.Level, message: String, actions: [Action] = []) {
        self.level = level
        self.message = message
        self.actions = actions
    }

    public struct Action {
        public typealias Handler = (Action) -> ()

        public let title: String
        public let handler: Handler?

        public init(title: String, handler: Handler?) {
            self.title = title
            self.handler = handler
        }
    }
}

extension NotifyNotification: Equatable {}
public func ==(lhs: NotifyNotification, rhs: NotifyNotification) -> Bool {
    return lhs.level == rhs.level
        && lhs.message == rhs.message
        && lhs.actions == rhs.actions
}

extension NotifyNotification.Action: Equatable {}
public func ==(lhs: NotifyNotification.Action, rhs: NotifyNotification.Action) -> Bool {
    return lhs.title == rhs.title
}
