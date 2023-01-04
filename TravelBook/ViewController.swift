//
//  ViewController.swift
//  TravelBook
//
//  Created by Zeynep Bayrak Demirel on 3.01.2023.
//

import UIKit
import MapKit
import CoreLocation // kullanıcının konumunu almak için kulanacagımız sınıf
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate { //view controllera bu sınıflardan bazı fonksiyonlara erişim yetkisi vermemiz için bu sınıfları belirtmemiz gerekiyor.

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var locationManager = CLLocationManager()
    var chosenLatitude = Double ()
    var chosenLongitude = Double ()
    
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double ()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self // mapview ın delegasyonunu viewcontroller olarak değiştirmemiz gerekiyor.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // birebir nokta atışı konum belirlemek istersem.
        locationManager.requestWhenInUseAuthorization() // en mantıklısı bu uygulamayı kullanırken izin istemek
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer) // haritamıza ekledik.
        
        if selectedTitle != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                print("error")
            }
        }
        
        
        
    }
    
    @objc func chooseLocation (gestureRecognizer: UILongPressGestureRecognizer){ //fonksyionun içine değişken yazdık farklı olarak. bu fonksiyonun içinde gestureRecognizera ulaşmak istiyorum.
        if gestureRecognizer.state == .began { //gestureRecognizer başladıysa eğer. (denedim bu olmasa da çalışıyor.)
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // dokunulan nokta
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)//dokunulan noktayı koordinata çeviriyoruz.
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation() // annotation = pin oluşturuyoruz.
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
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
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context) //bunu kullanarak core data objemize ulaşıyoruz.
        newPlace.setValue(nameText.text, forKey: "title")//istediğim anahtar kelimeye karşılık istediğim değerleri kaydedebilirim
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
        try context.save()
            print("success")
        }catch {
            print("error")
        }
        
        
        
        
        
    }
    
    
    
}

