import Foundation
import RealmSwift

public class RealmVCSAWSkeys: Object, VCSRealmObject {
    public typealias Model = VCSAWSkeys
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic public var id: Int = 0
    @objc dynamic var awsSynced: Bool = false
    @objc dynamic var linksExpireAfter: Int = 0
    @objc dynamic var awskeysPrefix: String = ""
    @objc dynamic var s3Bucket: String = ""
    @objc dynamic var s3Key: String = ""
    @objc dynamic var s3Secret: String = ""
    @objc dynamic var sampleFilesCopied: Int = 0
    @objc dynamic var userData: String = ""
    @objc dynamic var initializedOn: String = ""
    @objc dynamic var resourceURI: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        self.id = model.id
        self.RealmID = String(self.id)
        self.awsSynced = model.awsSynced
        self.linksExpireAfter = model.linksExpireAfter
        self.awskeysPrefix = model.awskeysPrefix
        self.s3Bucket = model.s3Bucket
        self.s3Key = model.s3Key
        self.s3Secret = model.s3Secret
        self.sampleFilesCopied = model.sampleFilesCopied
        self.userData = model.userData
        self.initializedOn = model.initializedOn
        self.resourceURI = model.resourceURI
    }
    
    public var entity: Model {
        return VCSAWSkeys(awsSynced: self.awsSynced, linksExpireAfter: self.linksExpireAfter, awskeysPrefix: self.awskeysPrefix, s3Bucket: self.s3Bucket, s3Key: self.s3Key, s3Secret: self.s3Secret, sampleFilesCopied: self.sampleFilesCopied, userData: self.userData, id: self.id, initializedOn: self.initializedOn, resourceURI: self.resourceURI)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["awsSynced"] = self.awsSynced
        result["linksExpireAfter"] = self.linksExpireAfter
        result["awskeysPrefix"] = self.awskeysPrefix
        result["s3Bucket"] = self.s3Bucket
        result["s3Key"] = self.s3Key
        result["s3Secret"] = self.s3Secret
        result["sampleFilesCopied"] = self.sampleFilesCopied
        result["userData"] = self.userData
        result["initializedOn"] = self.initializedOn
        result["resourceURI"] = self.resourceURI
        
        return result
    }
}
