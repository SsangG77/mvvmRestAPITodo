//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation

class TodosVM {
    
    //API를 통해 불러온 데이터들
    var todos:[Todo] = [] {
        didSet {
            self.notifyTodosChanged?(todos)
        }
    }
    //데이터들이 변경되었을 때 호출됨
    var notifyTodosChanged: (([Todo]) ->Void)? = nil
    
    //현재 페이지 값
    var currentPage:Int = 1 {
        didSet {
            self.notifyCurrentPage?(currentPage)
        }
    }
    //페이지 값이 변경될 때 호출됨
    var notifyCurrentPage: ((Int) -> Void)? = nil
    
    //데이터를 불러오는 중인지 아닌지
    var isLoading = false {
        didSet {
            self.notifyIsLoading?(isLoading)
        }
    }
    //데이터를 불러오거나 끝났을 때 호출됨
    var notifyIsLoading: ((Bool) -> Void)? = nil
    
    
    
    var notifyRefresh: (() -> Void)? = nil
    
    // 검색 결과 유무 변수
    var notifyNotFoundSearchResult: ((Bool) -> Void)? = nil
    
    
    //search word
    var searchTerm: String = "" {
        didSet {
            
            //MARK: - sangjin change
            if searchTerm.count > 0 {
                self.searchTodos(searchTerm: searchTerm)
            } else {
                self.fetchTodos()
            }
        }
    }

    
    //MARK: - sangjin 할일 추가 변수
    var todoText: String = "" {
        didSet {
            self.addTodo()
        }
    }
    
    //MARK: - sangjin
    var addTodoError: (() -> Void)? = nil
    
    var addTodoSuccess: (() -> Void)? = nil
    
    
    //MARK: - error 발생 이벤트
    var notifyError: ((String) -> Void)? = nil
    
    
    
    init(){
        fetchTodos()
    }// init
    
    
    
    //할일 처리 함수
    func addTodo() {
        if todoText.count < 1 {
            return
        }
        
        //MARK: - sangjin
        TodosAPI.addATodo(title: self.todoText) { result in
            switch result {
            case .success(let response):
                print("addTodo success: \(response)")
                self.addTodoSuccess?()
            case .failure(let fail):
                print("failure: \(fail)")
                
                
                //MARK: - sangjin
                self.addTodoError?()
                
                
                //MARK: - 강의
//                self.handleError(fail)
                
            }
        }
        

//        TodosAPI.addATodoAndFetchTodos(title: self.todoText, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let response):
//                self.isLoading = false
//                
//                if let fetchedTodos: [Todo] = response.data
////                    , let pageInfo: Meta = response.meta
//                {
//                    self.todos = fetchedTodos
//                }
//            case .failure(let fail):
//                self.isLoading = false
//            }
//        })
    }// addTodo()
  
    
    
    //MARK: - sangjin delete todo
//    func deleteTodo(_ cell: Todo?) {
//        guard let id: Int = cell?.id
//        else {
//            print("id, title none")
//            return
//        }
//        guard let cell: Todo = cell else {
//            print("cell none")
//            return
//        }
//        
//        TodosAPI.deleteATodo(id: id) { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let response):
//                if let cellId = response.data?.id {
//                    self.todos = self.todos.filter{ $0.id ?? 0 != cellId }
//                    self.fetchTodos()
//                }
//                
//            case .failure(let error):
//                print(error)
//                
//            }
//        }
//    }
    
    
    //할일 삭제
    func deleteTodo(_ id: Int) {
        
        if isLoading {
            return
        }
        self.isLoading = true
        
        TodosAPI.deleteATodo(id: id, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.isLoading = false
                if let deletedTodo: Todo = response.data,
                   let id = deletedTodo.id {
                    self.todos = self.todos.filter{ $0.id ?? 0 != id }
                }
                
                
            case .failure(let fail):
                print("fail: \(fail)")
            }
        })
    }
    
    
    //할 일 수정
    func editTodo(_ id: Int, _ title: String) {
        print(#file, #function, #line, "- id: \(id) / title: \(title)")
        
        if isLoading {
            return
        }
        self.isLoading = true
        
        TodosAPI.editTodo(id: id, title: title, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.isLoading = false
                print(#file, #function, #line, response)
                
                if let editTodo = response.data,
                   let editTodoId = response.data?.id,
                   let editedIndex = self.todos.firstIndex(where: { $0.id ?? 0 == editTodoId})
                {
                    self.todos[editedIndex] = editTodo
                }
                
                
                
            case .failure(let fail):
                print(fail)
                self.isLoading = false
            }
            
        })
    }
    
        
    
    
    
} //TodosVM


//search 관련 함수
extension TodosVM {
    
    func searchTodos(searchTerm: String, page: Int = 1) {
        
        if searchTerm.count < 0 {
            print("검색어가 없습니다.")
            return
        }
        
        if isLoading {
            return
        }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            TodosAPI.searchTodos(searchTerm: searchTerm, completion: { result in
                switch result {
                case .success(let response):
                    self.currentPage = page
                    if let fetchedTodos:[Todo] = response.data {
                        
                        if page == 1 {
                            //MARK: - sangjin
//                            if fetchedTodos.isEmpty {
//                                print("검색 결과가 없습니다. 차상진")
//                            }
                            
                            self.todos = fetchedTodos.shuffled()
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        
                    } else {
                        print("데이터 없다니까 상진")
                    }
                    
                case .failure(let fail):
                    print("failure: \(fail)")
                    
                    //MARK: - sangjin
                    self.todos = []
                }
                
                //MARK: - sangjin
                if self.todos.isEmpty && searchTerm.count > 0 {
                    print(#file, #function, #line, "- 검색 결과가 없습니다. 차상진")
                    self.todos = []
                    self.notifyNotFoundSearchResult?(true)
                } else {
                    self.notifyNotFoundSearchResult?(false)
                }
                
                self.notifyRefresh?()
                self.isLoading = false
                
            })
            
        })
    } // searchTodos
}


//fetch 관련
extension TodosVM {
    
    func fetchRefresh() {
        fetchTodos(page: 1)
    }
    
    
    func fetchMore() {
        if self.currentPage < 3 {
            fetchTodos(page: currentPage + 1)
        }
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
                self.notifyRefresh?()
                self.isLoading = false
                
            })
            
        })
    }
    
    
}


//handleError
extension TodosVM {
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
                print("디코딩 에러입니다")
            case .enoughLetter:
                print("6자 이상 입력해주세요.")
            default:
                print("default")
            }
        }
        
    }// handleError
}
