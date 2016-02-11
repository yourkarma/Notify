public struct Notification {
    public enum Level {
        case Error
        case Success
        case Default
    }

    public let level: Notification.Level
    public let message: String
    public let actions: [Action]

    public init(level: Notification.Level, message: String, actions: [Action] = []) {
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

extension Notification: Equatable {}
public func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.level == rhs.level
        && lhs.message == rhs.message
        && lhs.actions == rhs.actions
}

extension Notification.Action: Equatable {}
public func ==(lhs: Notification.Action, rhs: Notification.Action) -> Bool {
    return lhs.title == rhs.title
}