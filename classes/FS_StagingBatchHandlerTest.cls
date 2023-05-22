@isTest
public class FS_StagingBatchHandlerTest {
	
    @isTest 
    public static void testStagingBatchHandler(){
        FS_StagingBatchHandler clsObj = new FS_StagingBatchHandler();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //clsObj.handleInboundEmail(email, envelope);
        
        email.subject = '!!CSV Uploaded – SUCCESS';
        email.plainTextBody = 'SUCCESSFULLY UPLOADED THE FILES IN PRODUCTION';
        envelope.fromAddress = 'test@test.com';
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        clsObj.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = clsObj.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    }
}