//
//  PaymentOptionButton.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/6/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol PaymentOptionButtonActionDelegate {
    func paymentOptionButtonTapped(withPaymentOptionType paymentOptionType: PaymentOptionType)
}

class PaymentOptionButton: UIButton {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 4.0
        return view
    }()
    
    let gigabytesTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = largeTitleFont
        label.text = "-"
        label.textAlignment = .center
        return label
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = defaultButtonFont
        label.text = "-"
        label.textAlignment = .center
        return label
    }()
    
    let discountImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "discount-25-label")
        return iv
    }()
    
    private var _paymentOption: PaymentOptionType!
    
    var delegate: PaymentOptionButtonActionDelegate?
    
    init(paymentOption: PaymentOptionType) {
        self._paymentOption = paymentOption
        super.init(frame: .zero)
        handleContent(withPaymentOptionType: self._paymentOption)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleContent(withPaymentOptionType paymentOptionType: PaymentOptionType) {
        self.gigabytesTitleLabel.text = paymentOptionType == .twoGigabytes ? "2GB" : "5GB"
        self.priceTitleLabel.text = paymentOptionType == .twoGigabytes ? "£4.99" : "£9.99"
        self.discountImageView.isHidden = paymentOptionType == .twoGigabytes
    }
    
    func setupView() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 6.0
        
        self.layer.shadowColor = darkGrey.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
        
        self.setupTapGesture()
        self.anchorChildViews()
    }
    
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.userDidTap))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    func anchorChildViews() {
        self.addSubview(containerView)
        containerView.anchor(withTopAnchor: self.topAnchor, leadingAnchor: self.leadingAnchor, bottomAnchor: self.bottomAnchor, trailingAnchor: self.trailingAnchor, centreXAnchor: self.centerXAnchor, centreYAnchor: self.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 4.0, left: 4.0, bottom: -4.0, right: -4.0))
        
        self.containerView.addSubview(gigabytesTitleLabel)
        gigabytesTitleLabel.anchor(withTopAnchor: containerView.topAnchor, leadingAnchor: containerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: containerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: 12.0, bottom: 0.0, right: -12.0))
        
        self.containerView.addSubview(dividerView)
        dividerView.anchor(withTopAnchor: gigabytesTitleLabel.bottomAnchor, leadingAnchor: containerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: containerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 1.0, padding: .init(top: 8.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.containerView.addSubview(priceTitleLabel)
        priceTitleLabel.anchor(withTopAnchor: dividerView.bottomAnchor, leadingAnchor: containerView.leadingAnchor, bottomAnchor: containerView.bottomAnchor, trailingAnchor: containerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 8.0, left: 12.0, bottom: -12.0, right: -12.0))
        
        self.containerView.addSubview(discountImageView)
        discountImageView.anchor(withTopAnchor: containerView.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: containerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 90.0, heightAnchor: 90.0, padding: .init(top: -2, left: 0.0, bottom: 0.0, right: 2.0))
    }
}

// selector methods
extension PaymentOptionButton {
    
    @objc func userDidTap() {
        delegate?.paymentOptionButtonTapped(withPaymentOptionType: self._paymentOption)
    }
}
