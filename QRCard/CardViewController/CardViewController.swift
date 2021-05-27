//
//  ViewController.swift
//  QRCard
//
//  Created by Дмитрий on 5/25/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    // - UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var sphereTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    // - Constraints
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func createButtonAction(_ sender: Any) {
        self.refreshQRCode()
    }
    
}

// MARK: -
// MARK: Configure
extension CardViewController {
    func configure() {
        configureNavigationController()
        configureConstraint()
        configureAddButton()
        registerForKeyboardNotifications()
        configureTextFields()
    }
    
    func configureNavigationController() {
        title = "Визитка"
    }
    
    func configureConstraint() {
        imageViewHeightConstraint.constant = imageView.frame.width
    }
    
    func configureTextFields() {
        sphereTextField.delegate = self
        nameTextField.delegate = self
        mailTextField.delegate = self
        websiteTextField.delegate = self
        phoneTextField.delegate = self
        addressTextField.delegate = self
    }
}

// MARK: -
// MARK: - Keyboard
extension CardViewController {
    // - Handling
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ aNotification: NSNotification) {
        let info = aNotification.userInfo!
        let kbSize:CGSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(_ aNotification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
}

// MARK: -
// MARK: - Generate QR Code
extension CardViewController {
    func refreshQRCode() {
        if let sphere = sphereTextField.text, let name = nameTextField.text, let mail = mailTextField.text, let website = websiteTextField.text, let phone = phoneTextField.text, let address = addressTextField.text {
            if sphere.count > 0 && name.count > 0 && mail.count > 0 && address.count > 0 && website.count > 0 && phone.count > 0 {
                let text = "\(sphere)\n\(name)\n\(mail)\n\(website)\n\(phone)\n\(address)"
                // Generate the image
                guard let qrCode:CIImage = self.createQRCodeForString(text) else {
                    print("Failed to generate QRCode")
                    self.imageView.image = nil
                    return
                }
                let viewWidth = self.imageView.bounds.size.width;
                let scale = viewWidth/qrCode.extent.size.width;
                let scaledImage = qrCode.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                self.imageView.image = UIImage(ciImage: scaledImage)
            } else {
                showAlert()
            }
        }
    }
    
    func createQRCodeForString(_ text: String) -> CIImage?{
        let data = text.data(using: .isoLatin1)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        // Input text
        qrFilter?.setValue(data, forKey: "inputMessage")
        // Error correction
        let values = ["L", "M", "Q", "H"]
        // Trick to limit the result to the bounds (0, array.maxIndex) - max(_MIN_, min(_value_, _MAX_))
        let index = max(0, min(self.correctionLevelSegmentControl.selectedSegmentIndex, (values.count-1)))
        let correctionLevel = values[index]
        qrFilter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return qrFilter?.outputImage
    }
}

// MARK: -
// MARK: Show Allert
extension CardViewController {
    func showAlert () {
        let alertController = UIAlertController(title: "Ошибка", message: "Введите все данные", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: -
// MARK: Share Image
extension CardViewController {
    func configureAddButton() {
        let rightButton = UIBarButtonItem.init(image: UIImage(named: "share"), style: .done, target: self, action: #selector(self.shareImage))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func shareImage() {
        guard let image = self.imageView.image else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [ self.sharableImage(image) ], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.imageView // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    func sharableImage(_ image: UIImage) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: image.size, format: image.imageRendererFormat)
        let img = renderer.image { ctx in
            image.draw(at: CGPoint.zero)
        }
        return img
    }
}

// MARK: -
// MARK: TextFieldDelegate
extension CardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == sphereTextField {
            nameTextField.becomeFirstResponder()
        } else if textField == nameTextField {
            mailTextField.becomeFirstResponder()
        } else if textField == mailTextField {
            websiteTextField.becomeFirstResponder()
        } else if textField == websiteTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            addressTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}

