//
//  ViewController.swift
//  SpotSample
//
//  Created by 村田真矢 on 2018/05/16.
//  Copyright © 2018年 村田真矢. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    let infoMarker = GMSMarker()

    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LocationManagerのインスタンスの生成
        locationManager = CLLocationManager()
        
        // LocationManagerの位置情報変更などで呼ばれるfunctionを自身で受けるように設定
        locationManager.delegate = self
        
        // 位置情報取得をユーザーに認証してもらう
        locationManager.requestAlwaysAuthorization()
    }


    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view = mapView
        mapView.settings.myLocationButton = true

    }
    
    private func startGeofenceMonitering(location: CLLocationCoordinate2D, locationName: String) {

        // 位置情報の取得開始
        locationManager.startUpdatingLocation()

        // モニタリングしたい場所の緯度経度を設定
        let moniteringCordinate = location

        // モニタリングしたい領域を作成
        let moniteringRegion = CLCircularRegion.init(center: moniteringCordinate, radius: 20.0, identifier: locationName)

        // モニタリング開始
        locationManager.startMonitoring(for: moniteringRegion)
    }
    
    private func showAlert(title :String, message: String) -> UIAlertController{
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
         alert.addAction(defaultAction)
        
     return alert
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String, name:String, location:CLLocationCoordinate2D) {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        marker.title = name
        marker.snippet = placeID
        marker.map = mapView
        
        // モニタリング開始
        self.startGeofenceMonitering(location: location, locationName: name)
    }
    
    // MARK: - CLocationManagerDelegate
    // ジオフェンスモニタリング
    // モニタリング開始成功時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("モニタリング開始")
        print(manager.monitoredRegions)
    }
    
    // モニタリングに失敗したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("モニタリングに失敗しました。")
    }
    
    // ジオフェンス領域に侵入時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = self.showAlert(title: region.identifier + "のジオフェンスに入りました。", message: "")
        present(alert, animated: true, completion: nil)
    }
    
    // ジオフェンス領域から出たときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.locationManager.stopMonitoring(for: region)
        
        let alert = self.showAlert(title: region.identifier + "のジオフェンスから出ました。", message: "")
        present(alert, animated: true, completion: nil)
    }
    
    // ジオフェンスの情報が取得できないときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("モニタリングエラーです。")
    }
}
