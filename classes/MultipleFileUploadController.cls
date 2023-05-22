public without sharing class MultipleFileUploadController {

    @RemoteAction
    public static String doUploadAttachment(String recordId, String attachmentBody, String attachmentName,String fileId, String uploadedFrom, String userId){
        System.debug('Called');
        ContentVersion cv = new ContentVersion();
        if(!String.isNotBlank(fileId) && !String.isNotEmpty(fileId)){
            User ur = [SELECT Name FROM User WHERE Id =:userId];
            cv.VersionData = EncodingUtil.base64Decode(attachmentBody);
            cv.Title = attachmentName;
            cv.PathOnClient = attachmentName;
            cv.Uploaded_By__c = ur.Name;
            cv.Document_Name__c = attachmentName;
            cv.Parent_Id__c = recordId;
            cv.OwnerId = UserInfo.getUserId();
            cv.Is_Additional_Document__c = true;
            cv.Uploaded_From__c = uploadedFrom;
            cv.IsMajorVersion = false;
            cv.File_Type__c = uploadedFrom+' Photo';
            insert cv;
        }
        else{
            cv = [SELECT VersionData FROM ContentVersion WHERE Id=:fileId LIMIT 1];
            cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData)+attachmentBody);
            cv.Id = fileId;
            update cv;
        }
        return cv.Id;
    }
}