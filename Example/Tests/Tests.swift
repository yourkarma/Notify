// https://github.com/Quick/Quick

import Quick
import Nimble
import Notify

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        context("here be tests") {
            
            it("can notify about errors") {
                expect(Notification(level: .Error, message: "Error")) == Notification(level: .Error, message: "Error")
            }
            
            it("can notify about successes") {
                expect(Notification(level: .Success, message: "Success")) == Notification(level: .Success, message: "Success")
            }
        }
    }
}
