import Foundation
import HealthKit
import CoreLocation

struct StepSegment : Equatable {
    let locations: [CLLocation]
    let steps: Int? // 구간 걸음수
}

class MapRecordVM: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var segments: [StepSegment] = []
    // 읽기 권한 요청할 데이터 타입 설정
    let typesToRead: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKSeriesType.workoutRoute()
    ]
    
    // 권한 요청 함수
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if success {
                    self.checkAuthorizationStatus()  // 권한 상태 재확인
                } else {
                    print("권한 요청 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
                completion(success, error)
            }
        }
    }

    // 권한 상태 확인 함수
    func checkAuthorizationStatus() {
        for type in typesToRead {
            let status = healthStore.authorizationStatus(for: type)
            switch status {
            case .sharingAuthorized:
                print("\(type.identifier): 권한 허용됨")
            case .sharingDenied:
                print("\(type.identifier): 권한 거부됨")
            case .notDetermined:
                print("\(type.identifier): 권한 미결정")
            @unknown default:
                print("\(type.identifier): 알 수 없는 상태")
            }
        }
    }
    
    
    // MARK: - 특정 날짜의 운동 데이터를 가져옴
    func fetchWorkoutRoute(for date: Date) {
        let workoutType = HKObjectType.workoutType()
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("잘못된 날짜 범위 설정")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: [])
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 0, sortDescriptors: nil) { [weak self] _, samples, error in
            
            if let error = error {
                print("운동 데이터 쿼리 오류: \(error.localizedDescription)")
                return
            }
            
            guard let self = self,
                  let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                print("운동 데이터가 없습니다.")
                return
            }
            
            for workout in workouts {
                print("운동 유형: \(workout.workoutActivityType.rawValue)")
                self.fetchRoute(for: workout)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 운동의 경로 데이터를 가져옴
    private func fetchRoute(for workout: HKWorkout) {
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)

        let query = HKAnchoredObjectQuery(type: routeType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, error in

            if let error = error {
                print("경로 데이터 쿼리 오류: \(error.localizedDescription)")
                return
            }

            guard let self = self, let routes = samples as? [HKWorkoutRoute], !routes.isEmpty else {
                print("❌ 경로 데이터가 없습니다.")
                return
            }

            var segments: [StepSegment] = []
            let dispatchGroup = DispatchGroup()

            for route in routes {
                dispatchGroup.enter()
                let routeQuery = HKWorkoutRouteQuery(route: route) { _, locations, done, error in
                    if let error = error {
                        print("경로 쿼리 중 오류 발생: \(error.localizedDescription)")
                    }
                    if let locations = locations {
                        self.processLocations(locations, workout: workout) { segment in
                            segments.append(segment)
                        }
                    }
                    if done {
                        dispatchGroup.leave()
                    }
                }
                self.healthStore.execute(routeQuery)
            }

            dispatchGroup.notify(queue: .main) {
                self.segments = segments
                print("총 \(self.segments.count)개의 세그먼트 데이터를 가져왔습니다.")
            }
        }

        healthStore.execute(query)
    }

    private func processLocations(_ locations: [CLLocation], workout: HKWorkout, completion: @escaping (StepSegment) -> Void) {
        guard locations.count > 1 else { return }

        let startLocation = locations.first!
        let endLocation = locations.last!
        let predicate = HKQuery.predicateForSamples(
            withStart: startLocation.timestamp,
            end: endLocation.timestamp,
            options: .strictStartDate
        )
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            var Steps = 0
            if let error = error {
                print("걸음수 쿼리 오류: \(error.localizedDescription)")
            } else if let sum = statistics?.sumQuantity() {
                Steps = Int(sum.doubleValue(for: HKUnit.count()))
            }

            let segment = StepSegment(locations: locations, steps: Steps)
            DispatchQueue.main.async {
                completion(segment)
//                print("""
//                위치: \(locations.first?.coordinate ?? CLLocationCoordinate2D())
//                종료 위치: \(locations.last?.coordinate ?? CLLocationCoordinate2D())
//                걸음수: \(Steps)
//                """)
            }
        }

        healthStore.execute(query)
    }

}



