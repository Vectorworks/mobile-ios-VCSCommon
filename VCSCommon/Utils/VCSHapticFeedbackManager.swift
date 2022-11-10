import Foundation
import UIKit

public class VCSHapticFeedbackManager {
    public static let `default` = VCSHapticFeedbackManager()
    
    private init(){}
    
    public func triggerImpactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactHaptic = UIImpactFeedbackGenerator(style: style)
        impactHaptic.prepare()
        impactHaptic.impactOccurred()
    }
    
    public func triggerNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationHaptic = UINotificationFeedbackGenerator()
        notificationHaptic.prepare()
        notificationHaptic.notificationOccurred(type)
    }
    
    func triggerRigidImpactHaptic() {
        let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        rigidImpact.prepare()
        rigidImpact.impactOccurred()
    }
    
    public func triggerSelectionHaptic() {
        let selectionHaptic = UISelectionFeedbackGenerator()
        selectionHaptic.prepare()
        selectionHaptic.selectionChanged()
    }
}
