import PromisedFuture
import XCTest
import VCSNetwork

class VCSNetworkLoginTest: XCTestCase {

    override func setUp() {
        TestHelper.testsSetUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoginSettings() {
        let expectation = self.expectation(description: "LoginSettings")
        let expectationFail = self.expectation(description: "LoginSettingsFailed")
        expectationFail.isInverted = true
        
        APIClient.loginSettings().execute(onSuccess: { (res: VCSLoginSettingsResponse) in
            expectation.fulfill()
        }, onFailure: { (err: Error) in
            print(err)
            expectationFail.fulfill()
        })

        wait(for: [expectation, expectationFail], timeout: TestHelper.defaultDelayWaitTime)
    }
    
}
