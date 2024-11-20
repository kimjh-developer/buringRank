//
//  MapRecord.swift
//  iphoneapp
//
//  Created by mac on 11/19/24.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapRecord: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm = MapRecordVM()
    @State private var userLocation: CLLocationCoordinate2D?

    var body: some View {
        MapView(locations: $workoutManager.locations, userLocation: $userLocation)
            .onAppear {
                locationManager.requestAuthorization { status in
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways:
                        locationManager.startUpdatingLocation()
                        if let date = workoutManager.dateFromComponents(year: 2024, month: 11, day: 11) {
                            workoutManager.fetchWorkoutRoute(for: date)
                        }
                    case .denied, .restricted:
                        print("❌ 위치 권한이 거부되었습니다.")
                        // 사용자에게 설정에서 권한을 변경하도록 안내
                    case .notDetermined:
                        print("🔄 위치 권한이 아직 결정되지 않았습니다.")
                    @unknown default:
                        print("❓ 알 수 없는 권한 상태")
                    }
                }
            }
            .onAppear(perform: {
                vm.requestAuthorization { success, error in
                    print(success)
                    let specificDate = Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 12))!
                    vm.fetchWorkoutRoutes(for: specificDate) { workouts, routes in
                        print("운동 기록: \(workouts)")
                        print("운동 경로: \(routes)")
                    }
                }
            })
            .onReceive(locationManager.$currentLocation) { location in
                if let location = location {
                    userLocation = location.coordinate
                }
            }
            .ignoresSafeArea(edges: .top)
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                .foregroundColor(.black) // 커스텀 뒤로가기 버튼 색상
                            }
                        }
                    }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            
    }
}

struct MapView: UIViewRepresentable {
    @Binding var locations: [CLLocation]
    @Binding var userLocation: CLLocationCoordinate2D?
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
        uiView.removeOverlays(uiView.overlays)

        if let userLocation = userLocation {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            uiView.setRegion(region, animated: true)
        }

        guard !locations.isEmpty else {
            print("경로 데이터가 없습니다.")
            return
        }

        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        uiView.addOverlay(polyline)
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
    }
}


