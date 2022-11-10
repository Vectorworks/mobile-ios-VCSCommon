import Foundation
import UIKit

class VCSHapticFeedbackManager {
    static let shared = VCSHapticFeedbackManager()
    
    private init(){}
    
    func triggerRigidImpactHaptic() {
        let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        rigidImpact.prepare()
        rigidImpact.impactOccurred()
    }
    
    func triggerSelectionHaptic() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
}
