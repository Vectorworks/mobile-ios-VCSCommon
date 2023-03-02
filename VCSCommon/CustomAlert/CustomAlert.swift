import SwiftUI
import WindowSceneReader

/// Custom Alert
struct CustomAlert: View {
    @Binding var isPresented: Bool
    var title: String = ""
    @Binding var message: String
    var textFieldName: String = ""
    @Binding var textFieldValue: String
    var leftButtonName: String?
    var leftButtonAction: (() -> Void)?
    var rightButtonName: String?
    var rightButtonAction: (() -> Void)?
    
    @State private var isCreateButtonDisabled = false
    
    // Size holders to enable scrolling of the content if needed
    @State private var viewSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var actionsSize: CGSize = .zero
    
    @State private var fitInScreen = false
    
    // Used to animate the appearance
    @State private var isShowing = false
    
    var nameValidator = VCSAlertTextFieldValidator.defaultWithMessage("")
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                if isShowing {
                    alert
                        .animation(nil, value: height)
                }
                Spacer()
            }
        }
        .captureSize($viewSize)
        .onAppear {
            withAnimation {
                isShowing = true
            }
        }
    }
    
    var height: CGFloat {
        // View height - padding top and bottom - actions height
        let maxHeight = viewSize.height - 60 - actionsSize.height
        let min = min(maxHeight, contentSize.height)
        return max(min, 0)
    }
    
    var minWidth: CGFloat {
        // View width - padding leading and trailing
        let maxWidth = viewSize.width - 60
        // Make sure it fits in the content
        let min = min(maxWidth, contentSize.width)
        return max(min, 0)
    }
    
    var maxWidth: CGFloat {
        // View width - padding leading and trailing
        let maxWidth = viewSize.width - 60
        // Make sure it fits in the content
        let min = min(maxWidth, contentSize.width)
        // Smallest AlertView should be 270
        return max(min, 270)
    }
    
    var alert: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: 4) {
                        if title.isEmpty == false {
                            Text(title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        
                        if message.isEmpty == false {
                            Text(message)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        
                        //if textFieldValue.isEmpty == false {
                            TextField(textFieldName, text: $textFieldValue)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .onAppear() {
                                    self.checkNameAndSetButtonState(name: textFieldValue)
                                }
                                .onChange(of: textFieldValue) { newValue in
                                    self.checkNameAndSetButtonState(name: newValue)
                                }
                        //}
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .captureSize($contentSize)
                    // Force `Environment.isEnabled` to `true` because outer ScrollView is most likely disabled
                    .environment(\.isEnabled, true)
                }
                .frame(height: height)
                .onUpdate(of: contentSize) { contentSize in
                    fitInScreen = contentSize.height <= proxy.size.height
                }
                .disabled(fitInScreen)
            }
            .frame(height: height)
            
            VStack(spacing: 0) {
                Divider()
                Button(FolderChooserSettings.createButtonTitle.vcsLocalized) {
                    leftButtonAction?()
                }
                .disabled(self.isCreateButtonDisabled)
                Divider()
                Button(FolderChooserSettings.cancelButtonTitle.vcsLocalized, role: .cancel, action: {
                    rightButtonAction?()
                })
                Divider()

            }
            .buttonStyle(.alert)
            .captureSize($actionsSize)
        }
        .frame(minWidth: minWidth, maxWidth: maxWidth)
        .background(BlurView(style: .systemMaterial))
        .cornerRadius(13.3333)
        .padding(30)
        .transition(.opacity.combined(with: .scale(scale: 1.1)))
        .animation(.default, value: isPresented)
    }
    
    func checkNameAndSetButtonState(name: String) {
        if self.nameValidator.isNameValid(name, alertMessage: &message) {
            self.isCreateButtonDisabled = false
        } else {
            self.isCreateButtonDisabled = true
        }
    }
}

struct ContentLayout: _VariadicView_ViewRoot {
    @Binding var isPresented: Bool
    
    func body(children: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            ForEach(children) { child in
                Divider()
                child
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        isPresented = false
                        // Workaround for iOS 13
                        if #available(iOS 15, *) { } else {
                            AlertWindow.dismiss()
                        }
                    })
            }
        }
    }
}

public extension View {
    func customAlert(isPresented: Binding<Bool>, title: String = "", message: Binding<String>, textFieldName: String = "", textFieldValue: Binding<String>, leftButtonName: String?, leftButtonAction: (() -> Void)?, rightButtonName: String?, rightButtonAction: (() -> Void)?) -> some View {
        background(WindowSceneReader { windowScene in
            onChange(of: isPresented.wrappedValue) { value in
                if value {
                    AlertWindow.present(on: windowScene) {
                        CustomAlert(isPresented: isPresented, title: title, message: message, textFieldName: textFieldName, textFieldValue: textFieldValue, leftButtonName: leftButtonName, leftButtonAction: leftButtonAction, rightButtonName: rightButtonName, rightButtonAction: rightButtonAction)
                    }
                } else {
                    AlertWindow.dismiss(on: windowScene)
                }
            }
            .onAppear {
                guard isPresented.wrappedValue else { return }
                AlertWindow.present(on: windowScene) {
                    CustomAlert(isPresented: isPresented, title: title, message: message, textFieldName: textFieldName, textFieldValue: textFieldValue, leftButtonName: leftButtonName, leftButtonAction: leftButtonAction, rightButtonName: rightButtonName, rightButtonAction: rightButtonAction)
                }
            }
            .onDisappear {
                AlertWindow.dismiss(on: windowScene)
            }
        })
        .disabled(isPresented.wrappedValue)
    }
}
