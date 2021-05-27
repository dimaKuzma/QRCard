//
//  WebsiteViewController.swift
//  QRCard
//
//  Created by Дмитрий on 5/25/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit

class WebsiteViewController: UIViewController {
    // - UI
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
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

extension WebsiteViewController {
    func configure() {
        configureNavigationController()
        configureConstraint()
        configureAddButton()
        registerForKeyboardNotifications()
    }
    
    func configureNavigationController() {
        title = "Сайт"
    }
    
    func configureConstraint() {
        imageViewHeightConstraint.constant = imageView.frame.width
    }
}

// MARK: -
// MARK: - Generate QR Code
extension WebsiteViewController {
    func refreshQRCode() {
        if let text = websiteTextField.text {
            if text.count > 0 {
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
        qrFilter?.setValue(data, forKey: "inputMessage")
        let values = ["L", "M", "Q", "H"]
        let index = max(0, min(self.correctionLevelSegmentControl.selectedSegmentIndex, (values.count-1)))
        let correctionLevel = values[index]
        qrFilter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return qrFilter?.outputImage
    }
}

// MARK: -
// MARK: Show Allert
extension WebsiteViewController {
    func showAlert () {
        let alertController = UIAlertController(title: "Ошибка", message: "Введите данные", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: -
// MARK: Share Image
extension WebsiteViewController {
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
// MARK: - Keyboard
extension WebsiteViewController {
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


