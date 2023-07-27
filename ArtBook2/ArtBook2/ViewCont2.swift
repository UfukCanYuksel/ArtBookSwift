//
//  ViewCont2.swift
//  ArtBook2
//
//  Created by ufuk can yüksel on 12.06.2023.
//

import UIKit
import CoreData

// Galeriden görsel almak için Picker ve Navigatinon kullanılır.
class ViewCont2: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var namText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    // Seçilen satırın isim ve id değerleri için
    var chosenPain = ""
    var chosenPainId : UUID?
    
    // saave butonunun görünmezlik ve tıklanamazlık ayarları için
    @IBOutlet weak var saveBut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // isme tıklanarak gelindi
        if chosenPain != ""{
            
            // button görünmez kılınır
            saveBut.isHidden = true
            
            // CoreData için ezber işlemler
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            // Pain tablosunda sorgu yapıcam
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pain")
            
            // UUID değeri string'e çevirme
            let idString = chosenPainId?.uuidString
            // %@ ile pain tablosundan id karşılığını alıyorum
            fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            // eğer sorgu sonucunda eleman varsa text'leri dolduruyoruz
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            namText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
            
        }else { // button görünür ama tıklanamaz
            
            namText.text = ""
            artistText.text = ""
            yearText.text = ""
            imageView.image = UIImage(named: "indir")
            // görünmezlik kaldırıldı
            saveBut.isHidden = false
            // tıklanabilirlik de şuan kaldırıldı
            saveBut.isEnabled = false
        }

        // keybord' da klavye dışında bir yere tıklandığında klavye kapansın diye jest algılayıcı.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // imageView'in tıklanabilirliğini açıp jest algılayıcısı ve  tıklanınca ne olacağını belirtiyorum.
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    // picker galeriden foto çekme işlemleri
    @objc func selectImage( ){
        let picker = UIImagePickerController( )
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true , completion: nil)
        
    }
    
    // selectImage'in devamı didFinish ile görsel seçim sonrası ne olacağı falan
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        // image seçimi sonrası tıklanabilirlik açıldı.
        // tabi name kontrolü falan olsa başka senaryo olurdu
        saveBut.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Keyboard saklama selector'ü
    @objc func hideKeyboard( ){
        view.endEditing(true)
        
    }

    
    //save button'a basınca
    @IBAction func saveButton(_ sender: Any) {
        
        // CoreData ezberleri
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        
        let newPain = NSEntityDescription.insertNewObject(forEntityName: "Pain", into: context)
        
        // elaman kaydetme işlemleri
        newPain.setValue(namText.text!, forKey: "name")
        newPain.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newPain.setValue(year, forKey: "year")
        }
        newPain.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPain.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        // yeni data kaydı sonrası listeleri güncellemek için yollanır.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // bir önceki vc ye yollar
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
