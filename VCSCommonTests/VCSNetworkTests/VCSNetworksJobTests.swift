import PromisedFuture
import XCTest
import VCSNetwork


class VCSNetworksJobTests: XCTestCase {
    
    override func setUp() {
        TestHelper.testsSetUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testJobData() {
        let expectation = self.expectation(description: "JobData")
        let expectationFail = self.expectation(description: "JobDataFailed")
        expectationFail.isInverted = true
        
        let jobID = "76621"
        
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
                    return jobID
                })
                .andThen(APIClient.jobData).execute(completion: { (result: Result<VCSJobResponse, Error>) in
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
    
    func testListJobs() {
        let expectation = self.expectation(description: "ListJobs")
        let expectationFail = self.expectation(description: "ListJobsFailed")
        expectationFail.isInverted = true
        
        let currentJobs = false
        
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
                    return currentJobs
                })
                .andThen(APIClient.listJobs).execute(completion: { (result: Result<JobsResponse, Error>) in
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
