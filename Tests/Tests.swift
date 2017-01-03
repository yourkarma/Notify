// https://github.com/Quick/Quick

import Quick
import Nimble
import Notify

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        context("here be tests") {
            
            it("can notify about errors") {
                expect(NotifyNotification(level: .error, message: "Error")) == NotifyNotification(level: .error, message: "Error")
            }
            
            it("can notify about successes") {
                expect(NotifyNotification(level: .success, message: "Success")) == NotifyNotification(level: .success, message: "Success")
            }
        }
    }
}
