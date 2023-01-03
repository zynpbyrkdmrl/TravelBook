//
//  ViewController.swift
//  TravelBook
//
//  Created by Zeynep Bayrak Demirel on 3.01.2023.
//

import UIKit
import MapKit
import CoreLocation // kullanıcının konumunu almak için kulanacagımız sınıf

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate { //view controllera bu sınıflardan bazı fonksiyonlara erişim yetkisi vermemiz için bu sınıfları belirtmemiz gerekiyor.

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self // mapview ın delegasyonunu viewcontroller olarak değiştirmemiz gerekiyor.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // birebir nokta atışı konum belirlemek istersem.
        locationManager.requestWhenInUseAuthorization() // en mantıklısı bu uygulamayı kullanırken izin istemek
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer) // haritamıza ekledik
    }
    
    @objc func chooseLocation (gestureRecognizer: UILongPressGestureRecognizer){ //fonksyionun içine değişken yazdık farklı olarak. bu fonksiyonun içinde gestureRecognizera ulaşmak istiyorum.
        if gestureRecognizer.state == .began { //gestureRecognizer başladıysa eğer
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // dokunulan nokta
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)//dokunulan noktayı koordinata çeviriyoruz.
            
            let annotation = MKPointAnnotation() // annotation = pin oluşturuyoruz.
            annotation.coordinate = touchedCoordinates
            annotation.title = "New Annotation"
            annotation.subtitle = "Travel Book"
            self.mapView.addAnnotation(annotation)//haritamıza ekledik
        }
        
    }
    
    //güncellenen lokasyonları bana dizi içerisinde veren fonksiyon
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D (latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //latitude:enlem, longitude:boylam
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // zoom seviyesine span denilir. ne kadar küçültürsek o kadar zoomlar
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    
    
}

