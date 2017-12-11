import UIKit
import FirebaseStorage
import Firebase
/// Structure
struct Constants {
    ///l'image model á charger vers firebase
    struct ImageFB {
        static let imagesFolder: String = "FBImages"
    }
    
}
///cette classe prend en charge la tache de chargement des photos vers le firebase storage
class ImageUploadManager: NSObject {
    //LA methode uploadImage telecharge la photo passé en parametre .
    // MARK: Public methods
    
    /**
        uploadImage telecharge la photo passé en parametre .
     - parameter image:   l'image qui va etre charger vers firebase storage.
     - parameter progressBlock:   le block d'instructions à executer durant le chargement
     - parameter completionBlock: le block d'instructions à executer à la fin du chargement
     */
    
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Double) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        // storage/carImages/image.jpg
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imagesReference = storageReference.child(Constants.ImageFB.imagesFolder).child(imageName)
        
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imagesReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                if let metadata = metadata {
                    completionBlock(metadata.downloadURL(), nil)
                } else {
                    completionBlock(nil, error?.localizedDescription)
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                
                let percentage = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100
                progressBlock(percentage)
            })
        } else {
            completionBlock(nil, "Image couldn't be converted to Data.")
        }
    }
    
}
