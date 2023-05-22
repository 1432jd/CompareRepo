public class fsGetReceiptSyncError {


    @AuraEnabled
    public static String  getReceiptStatus(String recordId){

        List<Receipt__c> receiptList = [select Id,Sync_Error__c,Approval_Status__c from Receipt__c where Id=:recordId];

       if(receiptList.size()>0){
           Wrapper wrapObj = new Wrapper();
           Error errorObj = new Error();
           if(receiptList[0].Sync_Error__c!=null){
                wrapObj = (Wrapper)System.JSON.deserialize(receiptList[0].Sync_Error__c, Wrapper.class);
                errorObj= wrapObj.error; 
           }
           
           if(errorObj.description !=null){
                return errorObj.description;
           }else if(receiptList[0].Sync_Error__c==null && receiptList[0].Approval_Status__c=='Approved'){
              return 'Approved Successfully';
           }else{
               return '';
           }
       }
    return '';
    }


    public class Wrapper{
         public Error error;
    }

    public class Error{
        public String description;
    }
    
}