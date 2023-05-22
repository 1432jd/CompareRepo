@isTest
public class ContentVerisonTriggerHandlerTest {
    
    @isTest
    public static void test(){
        Contentversion cv =  new Contentversion(Title = 'ABC', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert cv;
    }
}