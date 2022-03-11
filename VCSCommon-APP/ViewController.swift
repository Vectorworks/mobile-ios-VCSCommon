import UIKit
import VCSCommon

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(VCSUserDefaults.default)
        VCSUserDefaults.useProvidedAppGroupDefaults(VCSUserDefaults(suiteName: nil))
        print(VCSUserDefaults.default)
        // Do any additional setup after loading the view.
        VCSReachability.default.setWhenReachable({ (reachability: Reachability) in
            print("Back online.".vcsLocalized)
        }, forKey: "VCSCommon-APP-ViewController")
        VCSReachability.default.setWhenUnreachable({ (reachability: Reachability) in
            print("No internet.".vcsLocalized)
        }, forKey: "VCSCommon-APP-ViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.testAlertView()
        
        self.imageView.image =
//            LetterAvatar.avatar(name: "Ivaylo Iliev", email: "", login: "" , size: CGSize(width: 150, height: 150))
            LetterAvatar.avatar(name: "Guest User", email: "", login: "" , size: CGSize(width: 150, height: 150))
//            LetterAvatar.avatar(name: "Anna Zumpalova", email: "azumpalova@vectorworks.net", login: "annazumpalova" , size: CGSize(width: 150, height: 150))
        
        self.view.makeToast("Test toast")
    }
    
    func testAlertView() {
        let title = "Test Alert View With Text Field"
        let message = "Original Message :)"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.clearButtonMode = .whileEditing
            textField.placeholder = "Enter your memories"
            textField.delegate = VCSAlertTextFieldValidator.defaultWithPresenter(self)
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction) in
            guard let outputTextField = alert.textFields?.first?.text else { return }
            print(outputTextField)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel)
        
        yesAction.isEnabled = false
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        testZip()
    }
    
    func testZip() {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        let cachesDirectory = paths.first!
        let oldSkyboxDirectory = cachesDirectory.appendingPathComponent("skybox_images")
        let skyboxDirectory = cachesDirectory.appendingPathComponent("skybox_images_2_0")
        
        // delete the old skybox images
        let exists = FileManager.default.fileExists(atPath: oldSkyboxDirectory)
        if (exists)
        {
            try? FileManager.default.removeItem(atPath: oldSkyboxDirectory)
        }
        
//        exists = FileManager.default.fileExists(atPath: skyboxDirectory)
//        if (!exists)
//        {
        let skyboxImageZipPath = Bundle.main.url(forResource: "SkyboxImages", withExtension: "zip")!
        print("Unzipping sky box images from \(skyboxImageZipPath.path) to \(skyboxDirectory)")
        print(try? FileUtils.unzipFile(skyboxImageZipPath.path, to: skyboxDirectory))
//        }
    }
}

