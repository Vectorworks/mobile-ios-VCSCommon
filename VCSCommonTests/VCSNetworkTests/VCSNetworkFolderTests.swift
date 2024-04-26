import PromisedFuture
import XCTest
import VCSNetwork

class VCSNetworkFolderTests: XCTestCase {
    
    override func setUp() {
        TestHelper.testsSetUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testListFolder() {
        let expectation = self.expectation(description: "ListFolder")
        let expectationFail = self.expectation(description: "ListFolderFailed")
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
                    return "restapi/public/v2/s3/folder/o:vcs.mobile.jenkins@gmail.com/p:uTest/"
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
    
    func testListFolderWithFlags() {
        let expectation = self.expectation(description: "ListFolderWithFlags")
        let expectationFail = self.expectation(description: "ListFolderWithFlagsFailed")
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
                    return ("restapi/public/v2/s3/folder/o:vcs.mobile.jenkins@gmail.com/p:uTest/", true, true, true, true, true)
                })
                .andThen(APIClient.folderAsset).execute(completion: { (result: Result<VCSFolderResponse, Error>) in
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
    
    func testCreateDeleteFolder() {
        let expectation = self.expectation(description: "CreateDeleteFolder")
        let expectationFail = self.expectation(description: "CreateDeleteFolderFailed")
        expectationFail.isInverted = true
        let folderName = "TEST_CREATE_DELETE"
        
        TestHelper.networkTestsSetUp()
        
        AuthCenter.shared.updateLogginSettings() { (result) in
            switch result {
            case .success(_):
                APIClient.oauth2Client?.accessToken = TestHelper.testUserAPIToken
                
                APIClient.vcsUser().map({
                    $0.objects.first?.updateIsLoggedIn(true)
                }).andThen(APIClient.awsKeys).map({
                    AuthCenter.shared.awsKeys = $0.objects.first
                    return (storage: StorageType.S3, name: folderName, parentFolderPrefix: nil, owner: VCSUser.savedUser?.login)
                }).andThen(APIClient.createFolder).map({
                    return $0.resourceURI
                }).andThen(APIClient.deleteData).execute(completion: { (result: Result<VCSEmptyResponse, Error>) in
                    switch result {
                    case .success(_):
                        expectation.fulfill()
                    case .failure(_):
                        print(APIClient.lastErrorResponse!)
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
    
    func testFolderStats() {
        let expectation = self.expectation(description: "FolderStats")
        let expectationFail = self.expectation(description: "FolderStatsFailed")
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
                    return (owner: "vcs.mobile.jenkins@gmail.com", possibleFolderURI: "restapi/public/v2/s3/folder/o:vcs.mobile.jenkins@gmail.com/p:uTest/")
                })
                .andThen(APIClient.folderStats).execute(completion: { (result: Result<VCSFolderStatResponse, Error>) in
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
