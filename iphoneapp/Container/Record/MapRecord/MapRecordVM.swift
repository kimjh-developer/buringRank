import Foundation
import HealthKit

class MapRecordVM: ObservableObject {
    let healthStore = HKHealthStore()
    
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
    
    // 특정 날짜의 운동 기록과 경로 데이터 가져오기
    func fetchWorkoutRoutes(for date: Date, completion: @escaping ([HKWorkout], [HKWorkoutRoute]) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let workoutQuery = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("운동 데이터 가져오기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                completion([], [])
                return
            }
            
            self.fetchRoutes(for: workouts) { routes in
                completion(workouts, routes)
            }
        }
        
        healthStore.execute(workoutQuery)
    }
    
    // 특정 운동에 대한 경로 데이터 가져오기
    private func fetchRoutes(for workouts: [HKWorkout], completion: @escaping ([HKWorkoutRoute]) -> Void) {
        var allRoutes: [HKWorkoutRoute] = []
        let dispatchGroup = DispatchGroup()
        
        for workout in workouts {
            let predicate = HKQuery.predicateForObjects(from: workout)
            let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, _, _, error in
                guard let routes = samples as? [HKWorkoutRoute], error == nil else {
                    print("경로 데이터 가져오기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    return
                }
                
                dispatchGroup.enter()
                allRoutes.append(contentsOf: routes)
                dispatchGroup.leave()
            }
            
            healthStore.execute(routeQuery)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allRoutes)
        }
    }
}
