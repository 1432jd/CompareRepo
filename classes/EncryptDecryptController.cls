public without sharing class EncryptDecryptController {
    public static String encryptionKey = 'oPghTmqa=b'; 
    
    public static String encryptData(String data){        
        List<Integer> vals;
        String encryptedNumber = '';
        for(Integer index = 0; index < data.length(); index=index+1){
            Integer keyIndex = Integer.valueOf(data.split('').get(index));
         	encryptedNumber = encryptedNumber + encryptionKey.split('').get(keyIndex);   
        }
        System.debug('encryptedNumber = '+encryptedNumber);
        return encryptedNumber;
    }
    
    public static String decryptData(String encryptedNumber){        
        String decryptedNumber = '';
        for(Integer index = 0; index < encryptedNumber.length(); index=index+1){
            String character = encryptedNumber.split('').get(index);
         	decryptedNumber = decryptedNumber + encryptionKey.indexOf(character);   
        }
        System.debug('decryptedNumber = '+decryptedNumber);
        return decryptedNumber;   
    }
    
    public static String maskData(String encryptedData){        
        String maskAadhaar = '';
        String decryptedData = decryptData(encryptedData);
        String lastFourDigit = decryptedData.left(4);
        System.debug(lastFourDigit);
        maskAadhaar = 'XXXXXXXX'+lastFourDigit;
        System.debug(maskAadhaar);
        return maskAadhaar;
    }
}