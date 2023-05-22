public class EncryptData {
    
    public static Blob cryptoKey; 

    public static string expMsg; 
    
    /* 
     * String enc = EncryptData.processEncryption('939678454038');
       System.debug(enc);
       String en = 'p8zww9AyDiL21hsqNYjbqunJicVro/ON0gHNT47Xq9A=';
       String key = '58TN/5XIW90Ta9pMDwDVpA==';
       String dec = EncryptData.processDecryption(en, key);
       System.debug(dec);
        */
    
    public static string processEncryption(string name){ 
        
        cryptoKey = Crypto.generateAesKey(128); 
        
        System.debug(EncodingUtil.base64Encode(cryptoKey));
                
        Blob data = Blob.valueOf(name); 
        
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 
        
        string b64Data = EncodingUtil.base64Encode (encryptedData);  
        
        return b64Data; 
        
    } 
    
    public static String processDecryption(string encryptedData, String key){ 
        
        String decryptedData; 
        
        Blob data = EncodingUtil.base64Decode(encryptedData); 
        
        Blob privateKey = EncodingUtil.base64Decode(key);  
        
        try{ 
            
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data); 
            
            decryptedData = dataToDecrypt.toString(); 
            
        } 
        
        catch(Exception e){ 
            
            expMsg = e.getMessage();  
            
        } 
        
        return (string.isEmpty(expMsg) ?  decryptedData :  null);  
        
    } 
    
    
}