//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation

class TodosVM {
    
    var todos:[Todo] = [] {
        didSet {
            self.notifyTodosChanged?(todos)
        }
    }
    
    var notifyTodosChanged: (([Todo]) ->Void)? = nil
    
    
    
    init(){
        print(#fileID, #function, #line, "- ")
        fetchTodos()
    }// init
    
    func fetchTodos() {
        TodosAPI.fetchTodos(completion: { result in
            switch result {
            case .success(let response):
//                guard let fetchedTodos:[Todo] = response.data else {
//                    print("데이터(할일) 없음")
//                    return
//                }
//                self.todos = fetchedTodos
                if let fetchedTodos:[Todo] = response.data {
                    self.todos = fetchedTodos
                } else {
                    print("데이터 없다니까 상진")
                    
                }
                
                
                
            case .failure(let fail):
                print("failure: \(fail)")
            }
            
        })
    }
    
    
    
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증안됨")
            case .decodingError:
                print("디코딩 에러입니당ㅇㅇ")
            default:
                print("default")
            }
        }
        
    }// handleError
    
}
