//
//  ViewController.swift
//  ArtBook2
//
//  Created by ufuk can yüksel on 12.06.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController  , UITableViewDelegate , UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    // eklenecek elemanlar için name ve id değerleri için String ve UUID dizileri oluşturuyorum
    var nameArray = [String]( )
    var idArray = [UUID]( )
    
    //seçilen isim ve id değerlerini alıp diğer activity'e göndermek için
    var selectedPain = ""
    var selectedPainId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // navigation bar'ın sağ üst köşesine + şeklinde button ekleme
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClick))
        
        getData()
        
       
    }
    
    // yeni bir eleman save edildiğinde tekrar ViewController'a döneceğim. bu yüzden hem yeni kaydedilen elemanın görünmesi için viewWillAppear kullanıyorum
    // çünkü viewController her başladığından tetiklenecek.
    override func viewWillAppear(_ animated: Bool) {
       
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue : "newData"), object: nil)
    }
    
    // kayıt işlemi sonrası diziyi yenilemek için
    @objc func getData( ){
        
        // dizilerin içini boşaltır
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        // bu metodun bundan sonrası biraz ezber
        
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        
        //EntityName = Artbook2 de oluşturduğum tablonun adı
        // sorgu oluşturulsun... hemde Pain tablosunda
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pain")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do{
            // pain tablosuna ulaştım
           let results =  try context.fetch(fetchRequest)
            // eleman 0 dan büyükse
            if results.count > 0{
                
                // for ile elemanları dolaşıp boşalttığım dizilere isimleri ekliyorum
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    // for ile elemanları dolaşıp boşalttığım dizilere id'leri ekliyorum
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    
                    //yeni data gelince kendini yenile
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
    }
    
    
    // + butonuna basınca segue ile diğer ViewController'a gitmek için
    @objc func addButtonClick( ){
        selectedPain = ""
        performSegue(withIdentifier: "vc1tovc2", sender: nil)
        
    }
    
    // tableView işlemleri
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    // tableView işlemleri
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell( )
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    // tableView'de seçilen elemanın bilgilerini alıp diğer viewController'a yollamak için
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedPain = nameArray[indexPath.row]
        self.selectedPainId = idArray[indexPath.row]
        performSegue(withIdentifier: "vc1tovc2", sender: nil)
    }
    
    // segue ile yapılacak işlemler 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vc1tovc2"{
            let destinatinonVC = segue.destination as! ViewCont2
            destinatinonVC.chosenPain = selectedPain
            destinatinonVC.chosenPainId = selectedPainId
            
        }
    }

    // silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pain")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results =  try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]  {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                                
                            }
                            
                        }
                    }
                }
            }catch{
                print("error")
            }
           
            
            
        }
    }

}

