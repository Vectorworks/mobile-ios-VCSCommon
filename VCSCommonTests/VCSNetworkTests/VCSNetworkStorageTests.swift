import PromisedFuture
import XCTest
import VCSNetwork

class VCSNetworkStorageTests: XCTestCase {

    override func setUp() {
        TestHelper.testsSetUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testListStorage() {
        let expectation = self.expectation(description: "ListStorage")
        let expectationFail = self.expectation(description: "ListStorageFailed")
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
                .andThen(APIClient.listStorage).execute(completion: { (result: Result<StorageList, Error>) in
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
    
    func testSharedFolder() {
        let expectation = self.expectation(description: "SharedFolder")
        let expectationFail = self.expectation(description: "SharedFolderFailed")
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
                .andThen(APIClient.listSharedFolder).execute(completion: { (result: Result<SharedFolderResponse, Error>) in
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
    
    func testSharedWithMe() {
        let expectation = self.expectation(description: "SharedWithMe")
        let expectationFail = self.expectation(description: "SharedWithMeFailed")
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
                .andThen(APIClient.listSharedWithMe).execute(completion: { (result: Result<VCSSharedWithMeResponse, Error>) in
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
    
    func testSharedWithMeFolder() {
        let expectation = self.expectation(description: "SharedWithMeFolder")
        let expectationFail = self.expectation(description: "SharedWithMeFolderFailed")
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
                .andThen(APIClient.listSharedWithMe).execute(completion: { (result: Result<VCSSharedWithMeResponse, Error>) in
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
    
    func testS3Folder() {
        let expectation = self.expectation(description: "S3Folder")
        let expectationFail = self.expectation(description: "S3FolderFailed")
        expectationFail.isInverted = true
        
        let folderURI = "/restapi/public/v2/s3/folder/o:vcs.mobile.jenkins@gmail.com/p:uTest/"
        
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
                    return folderURI
                })
                .andThen(APIClient.listFolder).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
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
