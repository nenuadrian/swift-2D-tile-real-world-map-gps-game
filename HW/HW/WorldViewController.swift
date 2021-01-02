//
//  ViewController.swift
//  HW
//
//  Created by Adrian Nenu on 27/03/2017.
//  Copyright © 2017 Adrian Nenu. All rights reserved.
//

import UIKit
import QuartzCore
import CoreMotion


class WorldViewController: UIViewController, UIScrollViewDelegate {
    var tilesDataCache = [Vector2: JSON]()
    static var mapTiles = [Vector2: Tile2D]()
    
    var mapView: UIView!
   // var mapScrollView: UIScrollView!
    var primordialTile: Vector2!
    var player: Player!
    var locationMaster: LocationMaster!
    let manager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
       /* mapScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        mapScrollView.contentSize = CGSize(width: 1000, height: 1000)
        mapScrollView.contentOffset = CGPoint(
            x: mapScrollView.contentSize.width/2-UIScreen.main.bounds.width/2,
            y: mapScrollView.contentSize.height/2-UIScreen.main.bounds.height/2)


        mapScrollView.delegate = self
        mapScrollView.bounces = false*/
        
        player = Player(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        //self.view.addSubview(mapScrollView)

        
        mapView = UIView(frame: CGRect(
            x: -5000 + UIScreen.main.bounds.width / 2,
            y: -5000 + UIScreen.main.bounds.height / 2, width: 10000, height: 10000
        ))
        
        
       // mapScrollView.addSubview(mapView)
        //self.mapScrollView.addSubview(player)
        mapView.addSubview(player)
        self.view.addSubview(mapView)
        
        locationMaster = LocationMaster()
        Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: self.computeTiles)
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(self.panYellowView))
        mapView.addGestureRecognizer(panGesture)
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        mapView.addGestureRecognizer(rotation)

    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            recognizer.view!.transform = recognizer.view!.transform.rotated(by: recognizer.rotation)
            
            recognizer.rotation = 0
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
    
    func renderTile(tileKey: Vector2) {
        let tile = tilesDataCache[tileKey]!
        let delta = (Vector2(Scalar(tile["x"].int!), Scalar(tile["y"].int!)) - self.primordialTile) * 611.5 + Vector2(5000, 5000)
        DispatchQueue.main.async {
            let tile2d = Tile2D(frame: CGRect(x: Double(delta.x), y: Double(delta.y), width: 611.5, height: 611.5), data: tile, tileKey: tileKey)
            self.mapView.addSubview(tile2d)
            self.mapView.bringSubviewToFront(self.player)
            WorldViewController.mapTiles[tileKey] = tile2d
        }
    }
    
    func computeTiles(timer: Timer) {
        if LocationMaster.last != nil {
            let locMeters = Utils.latLonToMeters(coord: LocationMaster.last)
            let currentTile = Utils.latLonToTile(coord: LocationMaster.last)
            let currentTileLatLon = Utils.tileToLatLon(tile: currentTile)
            let currentTileMeters = Utils.latLonToMeters(coord: currentTileLatLon)
            var playerOffsetInsideTile = locMeters - currentTileMeters
            playerOffsetInsideTile = Vector2(abs(playerOffsetInsideTile.x), abs(playerOffsetInsideTile.y))
            if primordialTile == nil {
                primordialTile = currentTile
            }
            
            let primordialLatLon = Utils.tileToLatLon(tile: primordialTile)
            let primordialMeters = Utils.latLonToMeters(coord: primordialLatLon)
            
            let primordialOffset = primordialMeters - currentTileMeters
            
            
            
            
           // let prepare = Vector2(Scalar(mapScrollView.contentSize.width), Scalar(mapScrollView.contentSize.height)) / 2 - primordialOffset + Vector2(-5000, -5000) - playerOffsetInsideTile
            //mapView.frame.origin =  CGPoint(x: Double(prepare.x), y: Double(prepare.y))
            
            let playerPosition = (currentTile - self.primordialTile) * 611.5 + Vector2(5000, 5000) + playerOffsetInsideTile
            print(playerPosition)
            player.frame.origin = CGPoint(x: Double(playerPosition.x), y: Double(playerPosition.y))
            
            var tilesToFetch: [String] = []
            
            for i in -1...1 {
                for j in -1...1 {
                    let tileKey = currentTile + Vector2(Scalar(i), Scalar(j))
                    if WorldViewController.mapTiles[tileKey] == nil {
                        if tilesDataCache[tileKey] != nil {
                            renderTile(tileKey: tileKey)
                        } else {
                            tilesToFetch.append("[\(Int(tileKey.x)),\(Int(tileKey.y))]")
                        }
                    }
                }
            }
            
            if tilesToFetch.count > 0 {
                let utf8str = "[\(tilesToFetch.joined(separator: ","))]".data(using: String.Encoding.utf8)

                if let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                {
                    API.get(endpoint: "tiles/" + base64Encoded, callback: { (data) in
                        if "\(data["message"])" != "null" {
                            print("Error \(data["message"])")
                        } else {
                            
                            for tile in data.array! {
                                let tileKey = Vector2(Scalar(truncating: tile["x"].number!), Scalar(truncating: tile["y"].number!))
                                
                                self.tilesDataCache[tileKey] = tile
                                self.renderTile(tileKey: tileKey)
                            }
                        }

                    })
                }
            }
        }

      
    }

    @objc func panYellowView(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

