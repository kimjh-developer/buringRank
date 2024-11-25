//
//  MapView.swift
//  iphoneapp
//
//  Created by mac on 11/25/24.
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @EnvironmentObject var workoutManager : WorkoutManager
    @Binding var locations: [CLLocation]
    @Binding var userLocation: CLLocationCoordinate2D?
    @State private var annotations: [CustomAnnotation] = []
    
    @State private var cumulativeDistance: CLLocationDistance = 0.0
    @State private var cumulativeTime: TimeInterval = 0.0

    var lineColor: UIColor = .blue
    var lineWidth: CGFloat = 4.0
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard !locations.isEmpty else {
            print("경로 데이터가 없습니다.")
            return
        }
        
        // 내 위치로 확대하여 지도 표시
        if let userCoordinate = userLocation {
            let region = MKCoordinateRegion(
                center: userCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            uiView.setRegion(region, animated: true)
        }

        // 경로 표시
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        if !uiView.overlays.contains(where: { $0 is MKPolyline }) {
            uiView.addOverlay(polyline)
//        }
        
        // 1km마다 핀 추가
        var totalDistance: CLLocationDistance = 0
        var segmentLocations: [CLLocation] = []
        var totalDuration: TimeInterval = 0
        
        
        // 새로운 핀만 추가
        if annotations.isEmpty {
            for i in 1..<locations.count {
                let previousLocation = locations[i - 1]
                let currentLocation = locations[i]
                
                segmentLocations.append(previousLocation)

                
                
                let distance = currentLocation.distance(from: previousLocation)
                totalDistance += distance
                cumulativeDistance += distance
                
                let timeInterval = currentLocation.timestamp.timeIntervalSince(previousLocation.timestamp)
                totalDuration += timeInterval
                cumulativeTime += timeInterval
                if totalDistance >= 1000 || i == locations.count - 1 {
                    segmentLocations.append(currentLocation)
                    
                    let segmentTime = segmentLocations.last!.timestamp.timeIntervalSince(segmentLocations.first!.timestamp)
                    
                    if segmentTime > 0 {
                        let maxSpeed = segmentLocations.map { $0.speed }.max() ?? 0.0
                        let maxSpeedKmH = maxSpeed * 3.6
                        let maxPaceInSeconds = maxSpeedKmH > 0 ? 3600 / maxSpeedKmH : Double.infinity
                        let paceMinutes = Int(maxPaceInSeconds) / 60
                        let paceSeconds = Int(maxPaceInSeconds) % 60
                        
                        let annotation = CustomAnnotation(
                            coordinate: segmentLocations[segmentLocations.count / 2].coordinate,
                            cumulativeDistance: cumulativeDistance / 1000,
                            cumulativeTime: totalDuration / 60,
                            pace: (paceMinutes, paceSeconds),
                            cadence: calculateCadence(for: segmentLocations),
                            sequence: annotations.count + 1
                        )
                        
                        // 핀 추가는 UI 관련 작업으로, 비동기로 처리
                        DispatchQueue.main.async {
                            uiView.addAnnotation(annotation)
                        }
                        // `annotations`는 직접 수정하지 않음
                    }
                    
                    totalDistance -= 1000.0
                    segmentLocations.removeAll()
                }
            }
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 케이던스 계산 (데이터가 제공되는 경우)
    private func calculateCadence(for locations: [CLLocation]) -> Double? {
        
        // 케이던스 계산 로직
        // 여기에 위치 기반의 케이던스를 계산하는 로직을 추가 (예: 발걸음 데이터가 필요함)
        return nil // 데이터가 없을 경우 nil 반환
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = parent.lineColor
                renderer.lineWidth = parent.lineWidth
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomAnnotation else {
                return nil
            }

            let identifier = "CustomPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = false

                // 핀 이미지
                annotationView!.image = UIImage(systemName: "mappin.and.ellipse")
                annotationView!.frame.size = CGSize(width: 20, height: 20)
                annotationView!.tintColor = .systemRed

                // 정보 텍스트 추가
                let label = UILabel()
                let paceString = String(format: "%d'%02d''", customAnnotation.pace.0, customAnnotation.pace.1)
                label.text = String(format: """
                거리: %.2f km
                시간: %.0f 분
                페이스: %@
                케이던스: %@
                """,
                                    customAnnotation.cumulativeDistance,
                                    customAnnotation.cumulativeTime,
                                    paceString,
                                    customAnnotation.cadence != nil ? "\(customAnnotation.cadence!) spm" : "N/A")

                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = .black
                label.numberOfLines = 4
                label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                label.layer.cornerRadius = 5
                label.layer.masksToBounds = true
                label.textAlignment = .left
                label.sizeToFit()

                // 레이블 추가
                annotationView!.addSubview(label)

                // 텍스트 위치 조정
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: annotationView!.trailingAnchor, constant: 8),
                    label.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor)
                ])

            } else {
                annotationView!.annotation = customAnnotation
            }

            return annotationView
        }

    }
}
class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let cumulativeDistance: Double
    let cumulativeTime: Double
    let pace: (Int, Int) // 페이스 (분, 초)
    let cadence: Double?
    let sequence: Int // 핀 순서를 나타내는 값

    init(coordinate: CLLocationCoordinate2D,
         cumulativeDistance: Double,
         cumulativeTime: Double,
         pace: (Int, Int),
         cadence: Double?,
         sequence: Int) {
        self.coordinate = coordinate
        self.cumulativeDistance = cumulativeDistance
        self.cumulativeTime = cumulativeTime
        self.pace = pace
        self.cadence = cadence
        self.sequence = sequence
        super.init()
    }
}

