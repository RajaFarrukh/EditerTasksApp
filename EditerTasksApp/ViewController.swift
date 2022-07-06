//
//  ViewController.swift
//  EditerTasksApp
//
//  Created by Shahid on 17/06/2022.
//

import UIKit
import YPImagePicker
import iOSPhotoEditor
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import MBProgressHUD
import FirebaseStorage
import AVFoundation
import Photos
import Metal
import MetalKit
import PixelSDK

class ViewController: UIViewController {
    
    var ypImagePickerReturendImage:UIImage? = nil
    var imageFianle:UIImage? = nil
    var videoURl:URL? = nil
    var isVideoEdttingDone:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
        present(photoEditor, animated: true, completion: nil)
    }
    
    /*
     Method: uploadVideoToFirebase
     Description: Method to upload video to firebase storage folder
     Params: localUrl:String
     */
    func uploadVideoToFirebase(localUrl:URL) {
        self.uploadTOFireBaseVideo(url: localUrl) { result in
            print("Video Upload Successfully")
            let alert = UIAlertController(title: "Editor Task App", message: "Video Upload Successfully", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } failure: { error in
            print(error.localizedDescription)
            let alert = UIAlertController(title: "Editor Task App", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveVideoToDevice(localUrl:URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localUrl)
        }) { saved, error in
            if saved {
                print("Your video was successfully saved")
//                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    /*
     Method: uploadTOFireBaseVideo
     Description: Method to upload TO Fire Base Video
     Params: url: URL
     */
    func uploadTOFireBaseVideo(url: URL,
                               success : @escaping (String) -> Void,
                               failure : @escaping (Error) -> Void) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        //        let path = NSTemporaryDirectory() + name
        let data = NSData(contentsOf: url)
        
        let storageRef = Storage.storage().reference().child("Videos").child(name)
        if let uploadData = data as Data? {
            let metaData = StorageMetadata()
            metaData.contentType = "video/mp4"
            storageRef.putData(uploadData, metadata: metaData
                               , completion: { (metadata, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                if let error = error {
                    failure(error)
                }else{
                    // let strPic:String = (metadata?.downloadURL()?.absoluteString)!
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    success("Upload Done")
                }
            })
        } else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    // MARK: - IBAction Methods
    
    
    /*
     Method: onBtnEditPhoto
     Description: IBAction for edit photo button
     */
    @IBAction func onBtnEditPhoto(_ sender:AnyObject) {
        
        ImagePickerManager().pickImage(self){ image in
            //here is the image
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let editorController = mainStoryBoard.instantiateViewController(withIdentifier: "EditPhotoViewController") as? EditPhotoViewController else {
                return
            }
            editorController.croppedImage = image
            
            self.navigationController?.pushViewController(editorController, animated: false)
        }
        
    }
    
    /*
     Method: onBtnRecordVideo
     Description: IBAction for record video button
     */
    @IBAction func onBtnRecordVideo(_ sender:AnyObject) {
        
        // Show only the library and video camera modes in the tab bar
        let container = ContainerController(modes: [.library, .video])
        container.editControllerDelegate = self
        
        // Include only videos from the users photo library
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        // Include only videos from the users drafts
        container.libraryController.draftMediaTypes = [.video]
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
        // Here we configure the picker to only show videos, no photos.
        //        var config = YPImagePickerConfiguration()
        //        config.screens = [.library, .video]
        //        config.library.mediaType = .video
        //
        //        let picker = YPImagePicker(configuration: config)
        //        picker.didFinishPicking { [unowned picker] items, _ in
        //            if let video = items.singleVideo {
        //                //                print(video.fromCamera)
        //                //                print(video.thumbnail)
        //                //                print(video.url)
        //               // self.uploadVideoToFirebase(localUrl: video.url)
        //
        //            }
        //            picker.dismiss(animated: true, completion: nil)
        //        }
        //        present(picker, animated: true, completion: nil)
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

extension ViewController: EditControllerDelegate {
    
    func editController(_ editController: EditController, didFinishEditing session: Session) {
        if let video = session.video {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            VideoExporter.shared.export(video: video, progress: { progress in
                print("Export progress: \(progress)")
            }, completion: { error in
                if let error = error {
                    print("Unable to export video: \(error)")
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    return
                }
                self.videoURl = video.exportedVideoURL
                print("Finished video export at URL: \(video.exportedVideoURL)")
                
                editController.dismiss(animated: true) {
                    if let url = self.videoURl {
                        self.saveVideoToDevice(localUrl: url)
                        self.uploadVideoToFirebase(localUrl: url)
                    }
                }
            })
        }
    }
}
