public without sharing class EncryptDecryptController {
    
    public static String encryptData(String data){
        String base64Content = EncodingUtil.Base64Encode(Blob.valueOf(data));
        return base64Content;
    }
    
    public static String decryptData(String encryptedData){
        Blob blobContent = EncodingUtil.base64Decode(encryptedData);
        return blobContent.toString();   
    }
    
}