//
//  CustomInputView.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

enum CustomInputType: String {
    case unspecified = "Loading..."
    case emailAddress = "Email Address"
    case name = "First and Last Name(s)"
    case password = "Password"
    case reEnterPassword = "Re-enter Password"
    case projectName = "Enter the project name"
    case projectPassword = "Enter an access password"
    case reEnterProjectPassword = "Re-enter the access password"
}

protocol CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String)
    func inputClearButtonPressed(inputType: CustomInputType)
    func forgotPasswordButtonPressed()
}

extension CustomInputViewDelegate {
    func forgotPasswordButtonPressed() { }
}

class CustomInputView: BaseView {
    
    // injector variables
    private var _inputType: CustomInputType = .unspecified
    private var _placeholderText: String = "Loading..."
    private var _initialInputValue: String = ""
    private var _showForgotPasswordButton: Bool = false
    
    var updatedInitialInputValue: String = "" {
        didSet {
            _initialInputValue = updatedInitialInputValue
            input.text = updatedInitialInputValue
        }
    }
    
    init(inputType: CustomInputType, initialInputValue: String = "", showForgotPasswordButton: Bool = false) {
        
        /*-- input type --*/
        self._inputType = inputType
        if inputType == .password || inputType == .reEnterPassword {
            input.isSecureTextEntry = true
        }
        
        /*-- placeholder text --*/
        self._placeholderText = inputType.rawValue
        input.attributedPlaceholder = NSAttributedString(string: self._placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        /*-- initial input value --*/
        self._initialInputValue = initialInputValue
        input.text = self._initialInputValue
        
        /*-- show forgot password button --*/
        self._showForgotPasswordButton = showForgotPasswordButton
        
        super.init(frame: .zero)
        
        anchorChildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let input: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 4.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.font = UIFont.systemFont(ofSize: 14.0)
        textField.textColor = .black
        textField.clearButtonMode = .whileEditing
        textField.adjustsFontSizeToFitWidth = true
        textField.returnKeyType = .done
        textField.keyboardAppearance = .dark
        textField.addTarget(self, action: #selector(inputValueChanged(_:)), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16.0, height: 50.0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        return button
    }()
    
    var bottomConstraintAnchor: NSLayoutConstraint!
    
    
    // delegate
    var delegate: CustomInputViewDelegate?
    
    override func setupView() {
        super.setupView()
        backgroundColor = .white
        setupChildDelegates()
    }
    
    func setupChildDelegates() {
        input.delegate = self
    }
    
    func anchorChildViews() {
        self.addSubview(input)
        input.anchor(withTopAnchor: topAnchor, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0)
        
        if self._showForgotPasswordButton {
            self.addSubview(forgotPasswordButton)
            forgotPasswordButton.anchor(withTopAnchor: input.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 107.0, heightAnchor: 20.0, padding: .init(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0))
            
            bottomConstraintAnchor = NSLayoutConstraint(item: forgotPasswordButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.1)
            addConstraint(bottomConstraintAnchor)
        } else {
            bottomConstraintAnchor = NSLayoutConstraint(item: input, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.1)
            addConstraint(bottomConstraintAnchor)
        }
    }
}


// input and selector delegates
extension CustomInputView: UITextFieldDelegate {
    
    @objc func forgotPasswordButtonPressed() {
        delegate?.forgotPasswordButtonPressed()
    }
    
    @objc func inputValueChanged(_ input: UITextField) {
        guard let updatedInputText = input.text else { return }
        delegate?.inputValueDidChange(inputType: self._inputType, inputValue: updatedInputText)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.inputClearButtonPressed(inputType: self._inputType)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        if input.isFirstResponder {
            input.resignFirstResponder()
        }
    }
}
