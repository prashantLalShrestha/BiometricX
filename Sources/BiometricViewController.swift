//
//  BiometricViewController.swift
//  BiometricX
//
//  Created by Prashant Shrestha on 5/25/20.
//  Copyright © 2020 Inficare. All rights reserved.
//

import UIKit
import BiometricAuthentication

public typealias BiometricCompletion = (Result<Bool, Error>) -> Void

fileprivate struct BaseDimensions {
    static var buttonHeight: CGFloat {
        return 40
    }
    
    static var inset: CGFloat {
        return 16
    }
    
    static var viewMargin: CGFloat {
        return 24
    }
    
    static var footerViewSpacing: CGFloat {
        return 8
    }
    
    static var viewSpacing: CGFloat {
        return 16
    }
}

public class BiometricViewController: UIViewController {
       
       // MARK: Outlets
    private lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
       let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.touchIdImage().withRenderingMode(.alwaysTemplate)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var imageContainerView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var enableButton: UIButton = {
       let view = UIButton()
        view.layer.cornerRadius = BaseDimensions.buttonHeight * 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: BaseDimensions.buttonHeight).isActive = true
        view.addTarget(self, action: #selector(enableTouchIDAction), for: .touchUpInside)
       return view
    }()

    lazy var skipButton: UIButton = {
       let view = UIButton()
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = BaseDimensions.buttonHeight * 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: BaseDimensions.buttonHeight).isActive = true
        view.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
       return view
    }()
    
    lazy var buttonStackView: UIStackView = {
        let subViews = [enableButton, skipButton]
        let view = UIStackView(arrangedSubviews: subViews)
        view.axis = NSLayoutConstraint.Axis.vertical
        view.spacing = BaseDimensions.inset
        view.alignment = UIStackView.Alignment.fill
        view.distribution = UIStackView.Distribution.fill
        return view
    }()
    
    lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: BaseDimensions.viewMargin).isActive = true
        buttonStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -BaseDimensions.viewMargin).isActive = true
        buttonStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: BaseDimensions.viewMargin).isActive = true
        buttonStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -BaseDimensions.viewMargin).isActive = true
        buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        return view
    }()

    private lazy var scrollView: UIScrollView = {
       let view = UIScrollView()
       self.contentView.addSubview(view)
       view.translatesAutoresizingMaskIntoConstraints = false
       view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
       view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
       view.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
       view.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
       view.isScrollEnabled = false
       return view
    }()

    private lazy var scrollContentView: UIView = {
       let view = UIView()
       scrollView.addSubview(view)
       view.translatesAutoresizingMaskIntoConstraints = false
       view.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
       view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
       view.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor).isActive = true
       view.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor).isActive = true
       view.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
       view.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
       return view
    }()
    
    private let credential: String
    private let userId: String
    private let biometricCompletion: BiometricCompletion
    
    init(userId: String, password: String, biometricCompletion: @escaping BiometricCompletion) {
        self.userId = userId
        self.credential = password
        self.biometricCompletion = biometricCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController Lifecycles
    public override func viewDidLoad() {
       super.viewDidLoad()
        makeUI()
        languageChanged()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        
    }

    func makeUI() {
       
       self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        scrollContentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: BaseDimensions.viewMargin),
            titleLabel.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: BaseDimensions.viewMargin),
            titleLabel.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -BaseDimensions.viewMargin),
            
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        
        scrollContentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionLabelConstraints = [
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: BaseDimensions.footerViewSpacing),
            descriptionLabel.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: BaseDimensions.viewMargin),
            descriptionLabel.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -BaseDimensions.viewMargin),
            
        ]
        NSLayoutConstraint.activate(descriptionLabelConstraints)
        
        scrollContentView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        let imageContainerViewConstraints = [
            imageContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: BaseDimensions.viewSpacing),
            imageContainerView.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: BaseDimensions.viewMargin),
            imageContainerView.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -BaseDimensions.viewMargin),
            
        ]
        NSLayoutConstraint.activate(imageContainerViewConstraints)
        
        imageContainerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewConstraints = [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: imageContainerView.bottomAnchor, constant: BaseDimensions.viewMargin),
            imageView.leftAnchor.constraint(greaterThanOrEqualTo: imageContainerView.leftAnchor, constant: BaseDimensions.viewMargin),
            imageView.rightAnchor.constraint(lessThanOrEqualTo: imageContainerView.rightAnchor, constant: -BaseDimensions.viewMargin),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: imageContainerView.bottomAnchor, constant: -BaseDimensions.viewMargin),
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 0.8),
            imageView.widthAnchor.constraint(equalTo: imageContainerView.widthAnchor, multiplier: 0.48),
            imageView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor, multiplier: 0.48),
            
        ]
        NSLayoutConstraint.activate(imageViewConstraints)
        
        
        scrollContentView.addSubview(buttonContainerView)
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        let buttonContainerViewConstraints = [
            buttonContainerView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            buttonContainerView.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor),
            buttonContainerView.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(buttonContainerViewConstraints)
        
    }

    func languageChanged() {
       
        if BioMetricAuthenticator.shared.faceIDAvailable() {
            titleLabel.text = "Make signing in faster with Face ID"
            descriptionLabel.text = "Authenticate using app's Face ID instead of entering your password."
            
             enableButton.setTitle("Set up Face ID", for: .normal)
             skipButton.setTitle("Not Now", for: .normal)
            
            imageView.image = UIImage.faceIdImage().withRenderingMode(.alwaysTemplate)
        } else if BioMetricAuthenticator.shared.touchIDAvailable() {
            titleLabel.text = "Make signing in faster with Touch ID"
            descriptionLabel.text = "Authenticate using app's Touch ID instead of entering your password."
            
             enableButton.setTitle("Set up Touch ID", for: .normal)
             skipButton.setTitle("Not Now", for: .normal)
            imageView.image = UIImage.touchIdImage().withRenderingMode(.alwaysTemplate)
        }
        
    }

    func applyTheme(backgroundColor: UIColor, tintColor: UIColor, textColor: UIColor) {
       
       self.navigationController?.navigationBar.tintColor = tintColor
       self.navigationController?.navigationBar.barTintColor = backgroundColor
       self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        
        self.view.backgroundColor = backgroundColor
       
        titleLabel.textColor = textColor
        descriptionLabel.textColor = textColor
        imageView.tintColor = tintColor
        
        enableButton.setTitleColor(backgroundColor, for: .normal)
        enableButton.backgroundColor = tintColor
        
        skipButton.setTitleColor(tintColor, for: .normal)
        skipButton.layer.borderColor = tintColor.cgColor
        
    }

    // MARK: Actions
}


extension BiometricViewController {
    @objc func enableTouchIDAction() {
        if BioMetricAuthenticator.canAuthenticate() {
            BiometricKeychainAccess.keychain.updateCredential(credential, for: userId, with: nil) { (result) in
                switch result {
                case .success:
                    self.biometricCompletion(.success(true))
                case .failure(let error):
                self.biometricCompletion(.failure(error))
                }
            }
        }
    }
    
    @objc func skipAction() {
        BiometricKeychainAccess.keychain.deleteCredential(for: userId) { (result) in
            switch result {
            case .success:
                self.biometricCompletion(.success(true))
            case .failure:
                self.biometricCompletion(.success(false))
            }
        }
    }
}
