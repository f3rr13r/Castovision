//
//  MainActionButton.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType)
}

class MainActionButton: UIButton {

    // views
    var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .white
        spinner.style = .white
        spinner.isHidden = true
        return spinner
    }()
    
    // variables
    var buttonUseType: MainActionButtonType = .unspecified
    
    var buttonTitle: String {
        didSet {
            self.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var buttonColor: UIColor {
        didSet {
            self.backgroundColor = buttonColor
        }
    }
    
    var isDisabled: Bool {
        didSet {
            if self.isDisabled {
                enableButton()
            } else {
                disableButton()
            }
        }
    }
    
    var isLoading: Bool {
        didSet {
            if self.isLoading {
                disableLoadingState()
            } else {
                enableLoadingState()
            }
        }
    }
    
    var hasBorderStyling: Bool = false
    
    // delegate
    var delegate: MainActionButtonDelegate?
    
    required init(buttonUseType: MainActionButtonType, buttonTitle: String, buttonColour: UIColor, isDisabled: Bool, isLoading: Bool = false, hasBorderStyling: Bool = false) {
        self.buttonUseType = buttonUseType
        self.buttonTitle = buttonTitle
        self.buttonColor = buttonColour
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.hasBorderStyling = hasBorderStyling
        
        super.init(frame: .zero)
        
        self.configureGeneralButtonStyling()
        self.anchorSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureGeneralButtonStyling() {
        backgroundColor = hasBorderStyling ? .clear : buttonColor
        setTitleColor(hasBorderStyling ? buttonColor : .white, for: .normal)
        setTitle(buttonTitle, for: .normal)
        layer.cornerRadius = 4.0
        layer.borderWidth = hasBorderStyling ? 1.0 : 0.0
        layer.borderColor = hasBorderStyling ? buttonColor.cgColor : nil
        titleLabel?.font = defaultButtonFont
        addTarget(self, action: #selector(buttonWasTapped), for: .touchUpInside)
    }
    
    private func configureBorderButtonStyling() {
        layer.borderWidth = 1.0
        layer.borderColor = buttonColor.cgColor
        backgroundColor = .clear
        setTitleColor(buttonColor, for: .normal)
    }
    
    func anchorSubviews() {
        addSubview(loadingSpinner)
        loadingSpinner.fillSuperview()
    }
    
    func disableButton() {
        self.backgroundColor = buttonColor.withAlphaComponent(0.4)
        self.isUserInteractionEnabled = false
    }
    
    func enableButton() {
        self.backgroundColor = buttonColor
        self.isUserInteractionEnabled = true
    }
    
    func disableLoadingState() {
        loadingSpinner.isHidden = true
        loadingSpinner.stopAnimating()
        self.setTitleColor(self.hasBorderStyling ? buttonColor : UIColor.white, for: .normal)
        enableButton()
    }
    
    func enableLoadingState() {
        disableButton()
        self.setTitleColor(UIColor.clear, for: .normal)
        loadingSpinner.startAnimating()
        loadingSpinner.isHidden = false
    }
    
    private func updateButtonDisabledState() {
        self.backgroundColor = !isDisabled ? buttonColor : buttonColor.withAlphaComponent(0.4)
        self.isUserInteractionEnabled = !isDisabled
    }
    
    private func updateButtonLoadingState() {
        loadingSpinner.isHidden = self.isLoading ? false : true
        self.isLoading ? loadingSpinner.startAnimating() : loadingSpinner.stopAnimating()
    }
}

// button selector method
extension MainActionButton {
    @objc func buttonWasTapped() {
        delegate?.mainActionButtonPressed(fromButtonUseType: buttonUseType)
    }
}
