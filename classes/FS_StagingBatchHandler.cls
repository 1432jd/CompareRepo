global without sharing class FS_StagingBatchHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String subToCompare = System.Label.Email_Subject;
        String bodyToCompare = System.Label.Email_Body;      
        System.debug('subToCompare = '+subToCompare);
        System.debug('bodyToCompare = '+bodyToCompare);
        System.debug('email.subject = '+email.subject);
        System.debug('email.plainTextBody = '+email.plainTextBody);
        System.debug('email.subject condition= '+email.subject.contains(subToCompare));
        System.debug('email.plainTextBody condition = '+email.plainTextBody.contains(bodyToCompare));
        if(email.subject != NULL && email.subject.contains(subToCompare) && email.plainTextBody != NULL && email.plainTextBody.contains(bodyToCompare)){
            System.debug('Batch Run ');
            StagingLoanBatchController stg = new StagingLoanBatchController(false);
        	Database.executeBatch(stg,1000);
        }  
        return result;
    }
}