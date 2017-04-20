//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

fileprivate let tagSegueIden = "tagSegue"
fileprivate let annotationViewReuseIden = "pinReuseIden"
fileprivate let fullImageSegueIden = "fullImageSegue"


class PhotoMapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            self.mapView.delegate = self
        }
    }
    
    @IBOutlet weak var captureIcon: UIButton!{
        didSet{
            self.captureIcon.layer.cornerRadius = self.captureIcon.frame.size.width / 2
            self.captureIcon.layer.borderWidth = 8.0
            self.captureIcon.layer.borderColor = UIColor.white.cgColor
            self.captureIcon.clipsToBounds = true
        }
    }
    @IBAction func captureIconTapped(_ sender: UIButton) {
        self.presentImagepicker()
    }
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let center = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        
        self.presentImagepicker()
    }
    
    
    func presentImagepicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            picker.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            picker.sourceType = .photoLibrary
        }
        self.present(picker, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let iden = segue.identifier{
            switch iden{
            case tagSegueIden:
                if let locationVC = segue.destination as? LocationsViewController{
                    locationVC.delegate = self
                }
            case fullImageSegueIden:
                if let fullImageVC = segue.destination as? FullImageViewController{
                    if let photo = (sender as? PhotoAnnotation)?.photo{
                        fullImageVC.image = photo
                    }
                }
            default:
                break
            }
        }
    }
    
    func resize(image: UIImage?, newSize: CGSize) -> UIImage? {
        if let image = image{
            let resizeImageView = UIImageView(frame: CGRect(x: 0, y:0, width: newSize.width, height: newSize.height))
            resizeImageView.contentMode = .scaleAspectFill
            resizeImageView.image = image
            
            UIGraphicsBeginImageContext(resizeImageView.frame.size)
            resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    lazy var annotations = [MKAnnotation]()
    
    func addPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let annotation = PhotoAnnotation()
        annotation.photo = self.selectedImage
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = locationCoordinate
        self.mapView.addAnnotation(annotation)
        self.annotations.append(annotation)
        self.mapView.showAnnotations(self.annotations, animated: true)
    }
   

}

extension PhotoMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.selectedImage = originalImage
        }
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: tagSegueIden, sender: self)
        })
    }
}

extension PhotoMapViewController: LocationsViewControllerDelegate{
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        self.addPin(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        
    }
}

extension PhotoMapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIden)
        if annotationView == nil{
            annotationView = MKAnnotationView()
        }
        
        let thumbnail = self.resize(image: self.selectedImage, newSize: CGSize(width: 60, height: 60))

        //set the pin image
        annotationView?.image = thumbnail

        
        //configure left accessory view
        let leftViewFrame = CGRect(x: 0, y: 0, width: 60, height: 60)
        let imageLeftView = UIImageView(frame: leftViewFrame)

        imageLeftView.layer.borderColor = UIColor.white.cgColor
        imageLeftView.contentMode = .scaleAspectFill
        imageLeftView.image = (annotation as? PhotoAnnotation)?.photo
        imageLeftView.image = thumbnail
        imageLeftView.backgroundColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1.0)
        annotationView?.leftCalloutAccessoryView = imageLeftView
        
        //configure right accessory view
        let arrowBtnFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let arrowBtn = UIButton(frame: arrowBtnFrame)
        arrowBtn.setImage( #imageLiteral(resourceName: "arrow-icon"), for: .normal)
        annotationView?.rightCalloutAccessoryView = arrowBtn
        
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: fullImageSegueIden, sender: view.annotation)
    }
}
