//
//  TodoCell.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/10.
//

import Foundation
import UIKit

class TodoCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    //테이블뷰가 있는 뷰 컨트롤러
    var parentVC: UIViewController!
    
    
    var cellData : Todo? = nil
    
//    lazy var todosVM: TodosVM = TodosVM()
    
    
    var deletedActionEvent: ((Int) -> Void)? = nil
    
    var editActionEvent: ((Int, String) -> Void)? = nil
    
    
    
    //MARK: - sangjin delete todo
    //할일 삭제 알림창
//    lazy var deleteTodoAlert: UIAlertController = {
//        let alert = UIAlertController(title: "할일 삭제", message: "할일을 삭제하시겠습니까?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
//        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { (_) in
//            self.todosVM.deleteTodo(self.cellData)
//        }))
//        return alert
//        
//    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        print(#fileID, #function, #line, "- ")
    }
    
    
    ///셀 데이터 적용
    func updateUI(_ cellData: Todo) {
        
        self.cellData = cellData
        
        guard let id: Int = cellData.id, let title: String = cellData.title
        else {
            print("id, title none")
            return
        }
        
        self.titleLabel.text = "아이디: \(id)"
        self.contentLabel.text = "Title: \(title)"
        
    }
    
    
    @IBAction func onEditBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- edit")
        guard
            let id = cellData?.id,
            let title = cellData?.title
        else { return }
        
        self.editActionEvent?(id, title)
        
    }
    
    
    @IBAction func onDeleteBtnClicked(_ sender: UIButton) {
        
        //MARK: - sangjin delete todo
//        parentVC.present(deleteTodoAlert, animated: true, completion: nil)
        
        
        guard let id = cellData?.id else { return }
        self.deletedActionEvent?(id)
    }
    
  
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        guard let id = cellData?.id else { return }
        sender.isOn ? print("on") : print("off")
        print(#file, #function, #line, "switch value changed")
    }
    
   
    
   
}
