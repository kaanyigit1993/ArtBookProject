//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by KAAN YİĞİT on 17.04.2021.
//
import CoreData
import UIKit

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    var chosenPainting = ""
    var chosenPaintingId : UUID?

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
   
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String
                        {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch  {
                print("error!")
            }
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        //Recognizers
        //textview da klavyenin kapanmaması sorununun çözümü.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // keyboard vs açıksa kapatması için kullanılır.
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController() // kullanıcının galerisine erişmek.
        picker.delegate = self //fonksiyonlarını çağırmak için delege olarak tanımlıyoruz.
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true //fotoğrafı kaydederken zoomlamak yada uzaklaştırmak için gerekli.
        present(picker, animated: true, completion: nil) //şuana kadar yapılan işlemler resmi seçmek,resmi seçtikten sonra yapılacaklar aşağıda devam ediyor.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true //resim seçildikten sonra saveButton u aktif yapmak.
        self.dismiss(animated: true, completion: nil) //açılan picker ı kapatmak.
    }
    
    
    
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //context in içine ne koyulacağını söylüyoruz.
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //verileri database imize aktarıyoruz.
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("saved!")
        } catch  {
            print("error")
        }
        
        // kayıt olan veriler için,gözlemcilere mesaj yollama olanağı sağlar.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)

        //save dedikten sonra bir önce ki sayfaya geri gitmesini sağlar.
        self.navigationController?.popViewController(animated: true)
    }
    
  
    
    


}
