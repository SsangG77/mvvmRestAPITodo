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
    
    var currentPage:Int = 1 {
        didSet {
            self.notifyCurrentPage?(currentPage)
        }
    }
    var isLoading = false
    
    
    
    
    
    var notifyTodosChanged: (([Todo]) ->Void)? = nil
    var notifyCurrentPage: ((Int) -> Void)? = nil
    
    
    
    init(){
//        print(#fileID, #function, #line, "- ")
        fetchTodos()
    }// init
    
    
    func fetchMore() {
        fetchTodos(page: currentPage + 1)
    }
    
    
    func fetchTodos(page: Int = 1) {
        
        if isLoading {
            return
        }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            TodosAPI.fetchTodos(completion: { result in
                switch result {
                case .success(let response):
                    self.currentPage = page
                    if let fetchedTodos:[Todo] = response.data {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        
                    } else {
                        print("데이터 없다니까 상진")
                    }
                    
                case .failure(let fail):
                    print("failure: \(fail)")
                }
                self.isLoading = false
                
            })
            
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
