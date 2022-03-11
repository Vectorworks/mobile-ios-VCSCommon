import PromisedFuture
import XCTest
import VCSNetwork

class VCSNetworkAnnouncementsTests: XCTestCase {
    
    override func setUp() {
        TestHelper.testsSetUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNewAnnouncements() {
        let expectation = self.expectation(description: "NewAnnouncements")
        let expectationFail = self.expectation(description: "NewAnnouncementsFailed")
        expectationFail.isInverted = true
        
        TestHelper.networkTestsSetUp()
        
        AuthCenter.shared.updateLogginSettings() { (result) in
            switch result {
            case .success(_):
                APIClient.oauth2Client?.accessToken = TestHelper.testUserAPIToken
                
                APIClient.vcsUser().map({
                    $0.objects.first?.updateIsLoggedIn(true)
                })
                .andThen(APIClient.awsKeys).map({
                    AuthCenter.shared.awsKeys = $0.objects.first
                    return ()
                })
                .andThen(APIClient.newNotifications).execute(completion: { (result: Result<AnnouncementsResponse, Error>) in
                    switch result {
                    case .success(_):
                        expectation.fulfill()
                    case .failure(let err):
                        print(err)
                        expectationFail.fulfill()
                    }
                })
            case .failure(let error):
                print(error)
                expectationFail.fulfill()
            }
        }
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
    
    func testOldAnnouncements() {
        let expectation = self.expectation(description: "OldAnnouncements")
        let expectationFail = self.expectation(description: "OldAnnouncementsFailed")
        expectationFail.isInverted = true
        
        TestHelper.networkTestsSetUp()
        
        AuthCenter.shared.updateLogginSettings() { (result) in
            switch result {
            case .success(_):
                APIClient.oauth2Client?.accessToken = TestHelper.testUserAPIToken
                
                APIClient.vcsUser().map({
                    $0.objects.first?.updateIsLoggedIn(true)
                })
                .andThen(APIClient.awsKeys).map({
                    AuthCenter.shared.awsKeys = $0.objects.first
                    return ()
                })
                .andThen(APIClient.oldNotifications).execute(completion: { (result: Result<AnnouncementsResponse, Error>) in
                    switch result {
                    case .success(_):
                        expectation.fulfill()
                    case .failure(let err):
                        print(err)
                        expectationFail.fulfill()
                    }
                })
            case .failure(let error):
                print(error)
                expectationFail.fulfill()
            }
        }
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
    
}
