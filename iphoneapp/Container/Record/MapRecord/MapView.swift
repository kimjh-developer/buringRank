//
//  MapView.swift
//  iphoneapp
//
//  Created by mac on 11/25/24.
import SwiftUI
import MapKit
import CoreLocation
/*
 .onReceive(locationManager.$currentLocation) { location in
     if let location = location {
         userLocation = location.coordinate
     }
 }
 */

struct MapView: UIViewRepresentable {
    @EnvironmentObject var workoutManager : WorkoutManager
    var segments: [StepSegment]
    var userCoordinate : CLLocationCoordinate2D?
    @State private var annotations: [CustomAnnotation] = []
    
    @Binding var CumulativeDistance: String?
    @Binding var CumulativeTime: String?
    @Binding var EveragePace: String?
    
    var lineColor: UIColor = .blue
    var lineWidth: CGFloat = 4.0
    
    // 중복 핀 확인을 위한 목록
    @State private var addedPinLocations: [CLLocationCoordinate2D] = []
    
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
        guard !segments.isEmpty else {
            print("경로 데이터가 없습니다.")
            return
        }

        // 내 위치로 확대하여 지도 표시
        if let userCoordinate = userCoordinate {
            let region = MKCoordinateRegion(
                center: userCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            uiView.setRegion(region, animated: true)
        }

        // 경로 표시
        let coordinates = segments.flatMap { $0.locations.map { $0.coordinate } }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        uiView.addOverlay(polyline)

        
        

        // 1km마다 핀 추가
        var totalDistance: CLLocationDistance = 0
        var cumulativeDistance: CLLocationDistance = 0.0
        var cumulativeTime: TimeInterval = 0.0
        var avgTime: [TimeInterval] = []
        var segmentLocations: [CLLocation] = []
        var totalStep: [Int] = []

//        var lastLocation: CLLocation?  마지막 위치를 저장

        // `for segment in segments` 루프
        for segment in segments {
            guard let steps = segment.steps else { continue } // 걸음 수가 없는 경우 무시
            for i in 1..<segment.locations.count {
                let previousLocation = segment.locations[i - 1]
                let currentLocation = segment.locations[i]
//                lastLocation = currentLocation // 마지막 위치 갱신

                let distance = currentLocation.distance(from: previousLocation)
                totalDistance += distance
                cumulativeDistance += distance

                cumulativeTime += currentLocation.timestamp.timeIntervalSince(previousLocation.timestamp)
                segmentLocations.append(previousLocation)

                totalStep.append(steps)
                avgTime.append(currentLocation.timestamp.timeIntervalSince(previousLocation.timestamp))

                if totalDistance >= 1000 {
                    segmentLocations.append(currentLocation)

                    let segmentTime = segmentLocations.last!.timestamp.timeIntervalSince(segmentLocations.first!.timestamp)

                    if segmentTime > 0 {
                        // 케이던스 계산 (1km 기준)
                        let stepSum = totalStep.reduce(0, +) // 걸음 수 합계
                        let totalAvgTime = avgTime.reduce(0, +) // 평균 시간 총합

                        let cadence: Int = totalAvgTime > 0 ? Int(Double(stepSum) / totalAvgTime * 60 / 100) : 0

                        // 평균 페이스 계산
                        let paceInSeconds = segmentTime / (totalDistance / 1000)
                        let paceMinutes = Int(paceInSeconds) / 60
                        let paceSeconds = Int(paceInSeconds) % 60

                        let annotationCoordinate = segmentLocations[segmentLocations.count / 2].coordinate
                        
                        // 중복 확인
                        if !self.addedPinLocations.contains(where: { $0.latitude == annotationCoordinate.latitude && $0.longitude == annotationCoordinate.longitude }) {
                            // 좌표가 중복되지 않으면 추가
                            
                            
                            let annotation = CustomAnnotation(
                                coordinate: annotationCoordinate,
                                cumulativeDistance: cumulativeDistance / 1000,
                                cumulativeTime: cumulativeTime / 60,
                                pace: (paceMinutes, paceSeconds),
                                cadence: Double(cadence),
                                sequence: addedPinLocations.count
                            )

                            DispatchQueue.main.async {
                                self.addedPinLocations.append(annotationCoordinate)
                                uiView.addAnnotation(annotation)
                                print("핀 추가: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
                            }
                        } else {
                            print("중복 핀 발견: \(annotationCoordinate.latitude), \(annotationCoordinate.longitude)")
                        }
                        
                    }

                    // 1km 처리 후 초기화
                    totalStep.removeAll()
                    avgTime.removeAll()
                    totalDistance -= 1000.0

                    segmentLocations = [currentLocation] // 마지막 위치를 다음 구간의 시작으로
                }
                
                
            }

            // 마지막 세그먼트 처리
            if segment == segments.last {
                
                if let lastCoordinate = segment.locations.last?.coordinate {
                    // CLLocationCoordinate2D -> CLLocation 변환
                    let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
                    var addedPinLocationsAsCLLocation = addedPinLocations.map {
                        CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                    }
                    
                    
                    if let lastCoordinate = segmentLocations.last?.coordinate{
                        if !self.addedPinLocations.contains(where: { $0.latitude == lastCoordinate.latitude && $0.longitude == lastCoordinate.longitude }) {
                            DispatchQueue.main.async {
                                self.addedPinLocations.append(lastCoordinate)
                                print("마지막핀 추가: \(lastCoordinate.latitude), \(lastCoordinate.longitude)")
                                lastPin(
                                    uiView: uiView,
                                    addedPinLocations: &addedPinLocationsAsCLLocation, // 변환된 배열 전달
                                    segmentLocations: segmentLocations,
                                    cumulativeDistance: cumulativeDistance,
                                    cumulativeTime: cumulativeTime,
                                    totalStep: totalStep,
                                    avgTime: avgTime
                                )
                            }
                        }else{
                            print("중복 마지막핀 발견: \(lastCoordinate.latitude), \(lastCoordinate.longitude)")
                        }
                    }
                }
            }

        }

        // 누적 정보 업데이트
        DispatchQueue.main.async {
            self.CumulativeDistance = (cumulativeDistance / 1000).toString(withDecimalPlaces: 1)
            // TimeInterval -> "00:00:00" 형식으로 변환
            let hours = Int(cumulativeTime) / 3600
            let minutes = (Int(cumulativeTime) % 3600) / 60
            let seconds = Int(cumulativeTime) % 60
            self.CumulativeTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // 평균 페이스 계산 (초/킬로미터 -> 분/킬로미터)
                                   if cumulativeDistance > 0 {
                                       let averagePaceInSeconds = cumulativeTime / (cumulativeDistance / 1000)
                                       let averagePaceMinutes = Int(averagePaceInSeconds) / 60
                                       let averagePaceSeconds = Int(averagePaceInSeconds) % 60
                                       
                                       // 평균 페이스 문자열로 저장
                                       let averagePaceString = String(format: "%d'%02d''/km", averagePaceMinutes, averagePaceSeconds)
                                       print("평균 페이스: \(averagePaceString)") // 디버깅용
                                       self.EveragePace = averagePaceString
                                   }
        }
    }



    func lastPin(uiView: MKMapView, addedPinLocations: inout [CLLocation], segmentLocations: [CLLocation], cumulativeDistance: CLLocationDistance, cumulativeTime: TimeInterval, totalStep: [Int], avgTime: [TimeInterval]) {
        guard let lastLocation = segmentLocations.last else { return }
        
        let annotationCoordinate = lastLocation.coordinate
        let annotationLocation = CLLocation(latitude: annotationCoordinate.latitude, longitude: annotationCoordinate.longitude)
        
        let stepSum = totalStep.reduce(0, +) // 걸음 수 합계
        let totalAvgTime = avgTime.reduce(0, +) // 평균 시간 총합
        
        // 케이던스 계산
        let cadence: Int = totalAvgTime > 0 ? Int(Double(stepSum) / totalAvgTime * 60 / 100) : 0
        
        // 평균 페이스 계산
        let segmentTime = segmentLocations.last!.timestamp.timeIntervalSince(segmentLocations.first!.timestamp)
        let paceInSeconds = segmentTime / (cumulativeDistance / 1000)
        let paceMinutes = Int(paceInSeconds) / 60
        let paceSeconds = Int(paceInSeconds) % 60
        
        // 중복 핀 확인
        let isNearby = addedPinLocations.contains { $0.distance(from: annotationLocation) < 500 }
        
        if !isNearby {
            addedPinLocations.append(annotationLocation)
            
            let annotation = CustomAnnotation(
                coordinate: annotationCoordinate,
                cumulativeDistance: cumulativeDistance / 1000,
                cumulativeTime: cumulativeTime / 60,
                pace: (paceMinutes, paceSeconds),
                cadence: Double(cadence),
                sequence: addedPinLocations.count
            )
            
            DispatchQueue.main.async {
                uiView.addAnnotation(annotation)
                print("마지막 핀 추가: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
            }
        } else {
            print("마지막 핀 중복으로 추가하지 않음: \(annotationCoordinate.latitude), \(annotationCoordinate.longitude)")
        }
    }


    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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




