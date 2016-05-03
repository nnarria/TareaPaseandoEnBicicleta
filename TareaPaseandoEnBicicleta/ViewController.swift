//
//  ViewController.swift
//  TareaPaseandoEnBicicleta
//
//  Created by Nicolás Narria on 5/2/16.
//  Copyright © 2016 Nicolás Narria. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var distanciaText: UITextField!
    
    private let manejador = CLLocationManager()
    private var distanciaAcumulada = 0.0
    private var posicionRefencia = CLLocation()
    
    private var lecturaIniciada = false
    private var primerAlfiler = false
    private let RANGO_METRO = 50.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
            
            mapa.mapType = MKMapType.Standard
        }
        else {
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var distanciaEnMetrosRef = 0.0
        
        if (lecturaIniciada == false) {
            var region = MKCoordinateRegion()
            var location = CLLocationCoordinate2D()
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.08
            span.longitudeDelta = 0.08

            
            location.latitude = manejador.location!.coordinate.latitude;
            location.longitude = manejador.location!.coordinate.longitude;
            region.span = span;
            region.center = location;

            //inicio punto referencia
            posicionRefencia = manager.location!
            mapa.setRegion(region, animated: true)
            
            //para que te siga
            mapa.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            lecturaIniciada = true
        }
        else {
        
            let tmp_loc = manager.location
            distanciaEnMetrosRef = posicionRefencia.distanceFromLocation(tmp_loc!)
            
            //una vez
            if (distanciaEnMetrosRef >= RANGO_METRO && primerAlfiler == false) {
                distanciaAcumulada = RANGO_METRO
                primerAlfiler = true
                agregarAlfiler(tmp_loc!)
            }
            else if (distanciaEnMetrosRef >= RANGO_METRO){
                distanciaAcumulada += distanciaEnMetrosRef
                agregarAlfiler(tmp_loc!)
            }
            else {
                print("continuo calculando: \(distanciaEnMetrosRef)")
            }
            
            distanciaText.text = "\(round(distanciaAcumulada))" + " Mts"
        }
    }
    
    func agregarAlfiler (loc: CLLocation) {
        print("Debo agregar alfiler")
        var punto = CLLocationCoordinate2D()
        punto.latitude = (loc.coordinate.latitude)
        punto.longitude = (loc.coordinate.longitude)
        
        let pin = MKPointAnnotation()
        pin.title = "\(punto.latitude), \(punto.longitude)"
        pin.subtitle = "\(distanciaAcumulada)"
        pin.coordinate = punto
        
        mapa.addAnnotation(pin)
        posicionRefencia = loc
    }

   
    
    @IBAction func cambiarTipoMapa(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            print ("Map Standard selected")
            mapa.mapType = MKMapType.Standard
            break
        case 1:
            print ("Map Hybrid selected")
            mapa.mapType = MKMapType.Hybrid
            break
        case 2:
            print ("Map Satellite selected")
            mapa.mapType = MKMapType.Satellite
            break
        default:
            break; 
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController (title: "ERROR", message: "error \(error.code)", preferredStyle:.Alert)
        let accionOk = UIAlertAction (title: "OK", style: .Default, handler:
            {accion in
                //...
        })
        
        alerta.addAction(accionOk)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    
    @IBAction func resetRutaActual() {
        print ("se limpia el mapa2")
        distanciaAcumulada = 0.0
        mapa.removeAnnotations(mapa.annotations)
        primerAlfiler = false
        distanciaText.text = "0.0 Mts"
    }
    
}

