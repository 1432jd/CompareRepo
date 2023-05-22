@isTest
private class EncryptDecryptControllerTest {
    @isTest
    static void testEncryptData() {
        String data = '123456';
        String expected = 'PghTmq';
        String result = EncryptDecryptController.encryptData(data);
        System.assertEquals(expected, result);
    }
    
    @isTest
    static void testDecryptData() {
        String encryptedNumber = 'PghTmq';
        String expected = '123456';
        String result = EncryptDecryptController.decryptData(encryptedNumber);
        System.assertEquals(expected, result);
    }
    
    @isTest
    static void testMaskData() {
        String encryptedData = 'PghTmq';
        String expected = 'XXXXXXXX3456';
        String result = EncryptDecryptController.maskData(encryptedData);
        System.assertEquals(expected, result);
    }
}