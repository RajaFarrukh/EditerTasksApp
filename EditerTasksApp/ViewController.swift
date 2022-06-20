//
//  ViewController.swift
//  EditerTasksApp
//
//  Created by Shahid on 17/06/2022.
//

import UIKit
import YPImagePicker
import iOSPhotoEditor


class ViewController: UIViewController {

    var ypImagePickerReturendImage:UIImage? = nil
    var imageFianle:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    
    // MARK: - Other Methods
    
    /*
     Method: configPhotoEditer
     Description: Method to config photo editer
     */
    func configPhotoEditer() {
        var config = YPImagePickerConfiguration()
        // [Edit configuration here ...]
        // Build a picker with your configuration
        let picker = YPImagePicker(configuration: config)
        
        
    }

    /*
     Method: openPhotoEditorViewController
     Description: Method to open PhotoEditorViewController
     */
    func openPhotoEditorViewController(image:UIImage) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = image
        //Colors for drawing and Text, If not set default values will be used
        //photoEditor.colors = [.red, .blue, .green]
        
        //Stickers that the user will choose from to add on the image
//        for i in 0...10 {x
//            photoEditor.stickers.append(UIImage(named: i.description ?? "Text_here") )
//        }
        
        //To hide controls - array of enum control
        //photoEditor.hiddenControls = [.crop, .draw, .share]
        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
        present(photoEditor, animated: true, completion: nil)
    }
    
    // MARK: - IBAction Methods
 
    
    /*
     Method: onBtnEditPhoto
     Description: IBAction for edit photo button
     */
    @IBAction func onBtnEditPhoto(_ sender:AnyObject) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
//                print(photo.fromCamera) // Image source (camera or library)
//                print(photo.image) // Final image selected by the user
//                print(photo.originalImage) // original image selected by the user, unfiltered
//                print(photo.modifiedImage) // Transformed image, can be nil
//                print(photo.exifMeta) // Print exif meta data of original image.
                self.ypImagePickerReturendImage = photo.image
                
            }
            picker.dismiss(animated: true) {
                if let image = self.ypImagePickerReturendImage {
                    self.openPhotoEditorViewController(image: image)
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    /*
     Method: onBtnRecordVideo
     Description: IBAction for record video button
     */
    @IBAction func onBtnRecordVideo(_ sender:AnyObject) {
        // Here we configure the picker to only show videos, no photos.
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .video

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imageFianle = image
        
        if let img = self.imageFianle {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: img)
        }
        
    }
    
    func canceledEditing() {
        print("Canceled")
    }
    
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
