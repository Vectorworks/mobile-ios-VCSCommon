import Foundation
import OAuth2
import VCSNetwork

class TestHelper {
    //vcs.mobile.jenkins@gmail.com - token
    internal static var testUserAPIToken = "fc7bbf1c49cc6f30e38070a95049ed4ef20e7b14"
    private static var didOneTimeSetup = false
    static let defaultDelayWaitTime = TimeInterval(2)
    static let extendedDelayWaitTime = TimeInterval(4)
    
    static func testsSetUp() {
        TestHelper.globalTestsSetUp()
        TestHelper.networkTestsSetUp()
    }
    
    static func networkTestsSetUp() {
        APIClient.clearAllFields()
        
        //Why not cached
        APIClient.loggingEnabled = true
        VCSServer.setDefaultServer(server: .test)
        ClientVersion.setDefault(version: "9.2")
    }
    
    static func networkTestsTearDown() {
    }
    
    static func globalTestsSetUp() {
        //ONE TIME// - NSPrincipalClass
        guard TestHelper.didOneTimeSetup else { return }
        TestHelper.didOneTimeSetup = true
        
//        APIClient.loggingEnabled = true
        VCSServer.setDefaultServer(server: .test)
        ClientVersion.setDefault(version: "9.2")
        VCSRealmDB.runMigrations(appGroup: "tests")
        
    }
}
