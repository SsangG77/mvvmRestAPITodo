//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/09.
//

import Foundation
import UIKit
import SwiftUI


class MainVC: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet var currentPageLabel: UILabel!
    
    var todos: [Todo] = []
    
    var todosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        self.todosVM.notifyTodosChanged = { todos in
            self.todos = todos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
        
        
        
        self.todosVM.notifyCurrentPage = { page in
            DispatchQueue.main.async {
                self.currentPageLabel.text = "페이지: \(page)"
            }
        }
        
        
        
    }// viewDidLoad
}


extension MainVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let contentYOffset = scrollView.contentOffset.y
        let distance = scrollView.contentSize.height - contentYOffset
        
        if distance < height {
            print("bottom")
            self.todosVM.fetchMore()
            
        }
        
    }
}



extension MainVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        cell.updateUI(cellData)
        
        return cell
    }
}



extension MainVC {
    
    private struct VCRepresentable : UIViewControllerRepresentable {
        
        let mainVC : MainVC
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}




//extension MainVC: UITableViewDelegate {
//    func tableView(
//        _ tableView: UITableView,
//        willDisplay cell: UITableViewCell,
//        forRowAt indexPath: IndexPath
//    ) {
//        let isLastCursor = indexPath.row == todos.count - 1
//        guard isLastCursor else { return }
//        print("load more")
//        tableView.reloadData()
//    }
//}
