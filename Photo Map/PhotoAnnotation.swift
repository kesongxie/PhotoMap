//
//  PhotoAnnotation.swift
//  Photo Map
//
//  Created by Xie kesong on 4/19/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//


import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}
