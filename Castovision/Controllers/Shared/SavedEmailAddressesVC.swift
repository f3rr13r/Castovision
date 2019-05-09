//
//  SavedEmailAddressesVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/24/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol SavedEmailAddressesVCDelegate {
    func updateMailingList(withUpdatedMailingList updatedMailingList: [String])
}

class SavedEmailAddressesVC: UIViewController {
    
    // views
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Addresses"
        label.font = smallTitleFont
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Select the saved email addresses that you would like to send to, and then confirm your selection by clicking the 'add' button"
        label.font = defaultContentFont
        label.textColor = darkGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let confirmButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Add to Mailing List", buttonColour: UIColor.red, isDisabled: true)
    
    private let _savedEmailAddressCellId: String = "savedEmailAddressCellId"
    lazy var savedEmailAddressesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.contentInsetAdjustmentBehavior = .never
        cv.delegate = self
        cv.dataSource = self
        cv.register(SavedAddressCell.self, forCellWithReuseIdentifier: self._savedEmailAddressCellId)
        return cv
    }()
    
    // variables
    private var _savedAddresses: [String] = [] {
        didSet {
            savedEmailAddressesCollectionView.reloadData()
        }
    }
    private var _emailAddresses: [String] = [] {
        didSet {
            savedEmailAddressesCollectionView.reloadData()
        }
    }
    
    private var _disabledEmailAddresses: [String] = [] {
        didSet {
            savedEmailAddressesCollectionView.reloadData()
        }
    }

    // delegate
    var delegate: SavedEmailAddressesVCDelegate?
    
    init(savedAddresses: [String], emailAddresses: [String], disabledEmailAddresses: [String] = []) {
        self._savedAddresses = savedAddresses
        self._emailAddresses = emailAddresses
        
        /*-- for when you have already sent project, and are sending to more
             then we will be disabling previously send to email addresses --*/
        if disabledEmailAddresses.count > 0 {
            self._disabledEmailAddresses = disabledEmailAddresses
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        anchorSubviews()
        handleChildDelegates()
    }
    
    func anchorSubviews() {
        self.view.addSubview(titleLabel)
        titleLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 42.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: titleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(confirmButton)
        confirmButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        self.view.addSubview(savedEmailAddressesCollectionView)
        savedEmailAddressesCollectionView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: confirmButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: -12.0, right: 0.0))
    }
    
    func handleChildDelegates() {
        confirmButton.delegate = self
    }
}

// collection view delegate and datasource methods
extension SavedEmailAddressesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._savedAddresses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let addressCell = collectionView.dequeueReusableCell(withReuseIdentifier: _savedEmailAddressCellId, for: indexPath) as? SavedAddressCell else {
            return UICollectionViewCell()
        }
        addressCell.configureCell(withEmailAddress: _savedAddresses[indexPath.item], andSelectableState: !_emailAddresses.contains(_savedAddresses[indexPath.item]), andDisabledState: _disabledEmailAddresses.contains(_savedAddresses[indexPath.item]))

        return addressCell
    }
    
    /*-- disable the cell selection if it has already been sent to --*/
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return !_disabledEmailAddresses.contains(_savedAddresses[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if _emailAddresses.contains(_savedAddresses[indexPath.item]) {
            _emailAddresses.removeAll { $0 == _savedAddresses[indexPath.item] }
        } else {
            _emailAddresses.append(_savedAddresses[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24.0, left: 0.0, bottom: 24.0, right: 0.0)
    }
}

// main action button delegate methods
extension SavedEmailAddressesVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        delegate?.updateMailingList(withUpdatedMailingList: _emailAddresses)
        self.dismiss(animated: true, completion: nil)
    }
}
