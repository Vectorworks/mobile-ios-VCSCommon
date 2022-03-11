import PromisedFuture
import XCTest
import VCSNetwork

class VCSNetworkSharedLinkTest: XCTestCase {

    override func setUp() {
        TestHelper.testsSetUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //Folder link
    func testSharedLinkFolder() {
        let expectation = self.expectation(description: "SharedLink")
        let expectationFail = self.expectation(description: "SharedLinkFailed")
        expectationFail.isInverted = true
        
        let sharedLink = SharedLink(link: "https://test.vcs.vectorworks.net/links/11eae39b00f8f7f8bac80e4716e232f5/")
        
        guard let folderURI = sharedLink.metadataURLSuffixForRequest else { expectationFail.fulfill(); return }
        
        APIClient.linkSharedAsset(assetURI: folderURI).execute(onSuccess: { (result: VCSShareableLinkResponse) in
            print(result.asJSON())
            expectation.fulfill()
        }, onFailure: { (error: Error) in
            print(error)
            expectationFail.fulfill()
        })
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
    
    //With 3D model
    func testSharedLink3D() {
        let expectation = self.expectation(description: "SharedLink")
        let expectationFail = self.expectation(description: "SharedLinkFailed")
        expectationFail.isInverted = true
        
        let sharedFileLink = "https://test.vcs.vectorworks.net/links/11eae39b494c200cbac80e4716e232f5/"
        let link = SharedLink(link: sharedFileLink)
        
        guard let fileURI = link.metadataURLSuffixForRequest else {
            XCTAssert(false)
            return
        }
        
        APIClient.linkSharedAsset(assetURI: fileURI).execute(completion: { (result: Result<VCSShareableLinkResponse, Error>) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let err):
                print(err)
                expectationFail.fulfill()
            }
        })
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
    
    //Without 3D model
    func testSharedLinkNo3D() {
        let expectation = self.expectation(description: "SharedLink")
        let expectationFail = self.expectation(description: "SharedLinkFailed")
        expectationFail.isInverted = true
        
        let sharedFileLink = "https://test.vcs.vectorworks.net/links/11eae39b7d12cd6ebac80e4716e232f5/"
        let link = SharedLink(link: sharedFileLink)
        
        guard let fileURI = link.metadataURLSuffixForRequest else {
            XCTAssert(false)
            return
        }
        
        APIClient.linkSharedAsset(assetURI: fileURI).execute(completion: { (result: Result<VCSShareableLinkResponse, Error>) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let err):
                print(err)
                expectationFail.fulfill()
            }
        })
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
    
    //Folder link visit
    func testSharedLinkVisiting() {
        let expectation = self.expectation(description: "SharedLink")
        let expectationFail = self.expectation(description: "SharedLinkFailed")
        expectationFail.isInverted = true
        
        let sharedFileLink = "https://test.vcs.vectorworks.net/links/11eae39b00f8f7f8bac80e4716e232f5/"
        let link = SharedLink(link: sharedFileLink)
        
        APIClient.markLinkAsVisited(assetURI: link.visitLinkURLSuffixForRequest).execute(completion: { (result: Result<VCSEmptyResponse, Error>) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let err):
                print(err)
                expectationFail.fulfill()
            }
        })
        
        wait(for: [expectation, expectationFail], timeout: TestHelper.extendedDelayWaitTime)
    }
}
