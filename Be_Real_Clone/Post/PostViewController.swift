//
//  PostViewController.swift
//  Be_Real_Clone
//
//  Created by Jonathan Velez on 3/27/23.
//

import UIKit
import PhotosUI
import ParseSwift



class PostViewController: UIViewController {

    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        

        // Do any additional setup after loading the view.
        
        //Looks for single or multiple taps.
             let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            view.addGestureRecognizer(tap)
        }

        //Calls this function when the tap is recognized.
        @objc func dismissKeyboard() {
            //Causes the view (or one of its embedded text fields) to resign the first responder status.
            view.endEditing(true)
        }
    
  
    @IBAction func onAttachPhotoTapped(_ sender: UIButton){
        
        // TODO: Pt 1 - Present Image picker
        
        var config = PHPickerConfiguration()
        
        config.filter = .images
        
        config.preferredAssetRepresentationMode = .current
        
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = self
        
        present(picker, animated: true)

    }
    
    
    @IBAction func onTakePhotoTapped(_ sender: UIButton) {
        
        // Make sure the user's camera is available
        // NOTE: Camera only available on physical iOS device, not available on simulator.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }

        // Instantiate the image picker
        let imagePicker = UIImagePickerController()

        // Shows the camera (vs the photo library)
        imagePicker.sourceType = .camera

        // Allows user to edit image within image picker flow (i.e. crop, etc.)
        // If you don't want to allow editing, you can leave out this line as the default value of `allowsEditing` is false
        imagePicker.allowsEditing = true

        // The image picker (camera in this case) will return captured photos via it's delegate method to it's assigned delegate.
        // Delegate assignee must conform and implement both `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate`
        imagePicker.delegate = self

        // Present the image picker (camera)
        present(imagePicker, animated: true)
        
    }
    
    

    @IBAction func onShareTapped(_ sender: Any) {

        // Dismiss Keyboard
        view.endEditing(true)

        // TODO: Pt 1 - Create and save Post
        
        guard let image = pickedImage,
              
            let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        var post = Post()
        
        post.imageFile = imageFile
        post.caption = captionTextField.text
        
        post.user = User.current
        
        post.save {[weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print(" Post Saved! \(post)")
                    
                    //Get the current user
                    // Get the current user
                    if var currentUser = User.current {

                        // Update the `lastPostedDate` property on the user with the current date.
                        currentUser.lastPostedDate = Date()

                        // Save updates to the user (async)
                        currentUser.save { [weak self] result in
                            switch result {
                            case .success(let user):
                                print("✅ User Saved! \(user)")

                                // Switch to the main thread for any UI updates
                                DispatchQueue.main.async {
                                    // Return to previous view controller
                                    self?.navigationController?.popViewController(animated: true)
                                }

                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }
                        }
                    }
                    
                    self?.navigationController?.popViewController(animated: true)
                    
                    case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// TODO: Pt 1 - Add PHPickerViewController delegate and handle picked image.

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else {
                
                // ❌ Unable to cast to UIImage
                self?.showAlert()
                return
            }
            
            // Check for and handle any errors
            if let error = error {
                
                self?.showAlert(description: error.localizedDescription)
                
                return
                
            } else {
                
                // UI updates (like setting image on image view) should be done on main thread
                DispatchQueue.main.async {
                    
                    // Set image on preview image view
                    self?.previewImageView.image = image
                    
                    // Set image to use when saving post
                    self?.pickedImage = image
                }
            }
        }
    }
}
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss the image picker
            picker.dismiss(animated: true)

            // Get the edited image from the info dictionary (if `allowsEditing = true` for image picker config).
            // Alternatively, to get the original image, use the `.originalImage` InfoKey instead.
            guard let image = info[.editedImage] as? UIImage else {
                print("❌📷 Unable to get image")
                return
            }

            // Set image on preview image view
            previewImageView.image = image

            // Set image to use when saving post
            pickedImage = image
        }
    }
