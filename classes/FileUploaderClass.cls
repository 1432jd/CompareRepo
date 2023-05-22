public class FileUploaderClass{
    public static String uploadFile(String base64, String filename, String recordId, String category, String loanAppId) {
        System.debug('File Uploader Class '+filename+' : '+recordId+' : '+base64+' : '+category+' : '+loanAppId);
        ContentVersion cv = createContentVersion(base64, filename, category, loanAppId,recordId);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename, String category, String loanAppId, String recordId) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.Category__c = category;
        cv.Loan_Applicant__c = loanAppId;
        cv.Parent_Id__c = recordId;
        cv.Uploaded_From__c = 'Login';
        cv.Is_Additional_Document__c  = true;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
}