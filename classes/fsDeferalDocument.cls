/**
* @File Name          : fsDeferalDocument.cls
* @Description        : Service Class For fsDeferalDocument Lightning Component
* @Author             : Yogendra Degra
* @Created On         : 28/07/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         28/07/2022              Yogendra Degra       Initial Version
*/

public Without Sharing class fsDeferalDocument {   
    @AuraEnabled
    public static List<ViewDocument> getDeferalDocument(String parentId){
        System.debug(':: parentId :: '+parentId);
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        List<String> documentRoles = DatabaseUtililty.getDocumentRoles();
        List<ViewDocument> viewDocumentList = new List<ViewDocument>();
        for (ContentVersion cv :[SELECT Id, ContentDocumentId, Deferal_Stage__c, Uploaded_From__c, Parent_Id__c, Document_Name__c, Owner.Name, Number_of_Pages__c,Remarks__c, Deferal_Date__c,Status__c FROM ContentVersion WHERE Parent_Id__c =: parentId]) {
            ViewDocument obj = new ViewDocument();
            obj.contentDocumentId = cv.ContentDocumentId;
            obj.numberOfPages = String.valueOf(cv.Number_of_Pages__c);
            obj.uploadedFrom = cv.Uploaded_From__c;
            obj.documentName = cv.Document_Name__c;
            obj.ownerName = cv.Owner.Name;
            obj.remarks = cv.Remarks__c;
            if(documentRoles == null){
                obj.isDocumentView = true;
                obj.isCheckboxDisabled = false;
            }
            else if(documentRoles!=null && !documentRoles.isEmpty() && profileName == 'System Administrator'){
                obj.isDocumentView = true;
                obj.isCheckboxDisabled = false;
            }
            else{
                if(documentRoles!=null && !documentRoles.isEmpty() && documentRoles.contains(cv.Uploaded_From__c)){
                    obj.isDocumentView = true;
                    obj.isCheckboxDisabled = false;
                }
                else{
                    obj.isDocumentView = false;
                    obj.isCheckboxDisabled = true;
                }
            }
            viewDocumentList.add(obj);
        }
        return viewDocumentList;
        //return [SELECT Id, ContentDocumentId, Deferal_Stage__c, Uploaded_From__c, Parent_Id__c, Document_Name__c, Owner.Name, Number_of_Pages__c,
        //Remarks__c, Deferal_Date__c,Status__c FROM ContentVersion WHERE Parent_Id__c =: parentId];
    }
    
    @AuraEnabled
    public static List<Deferral_Document__c> getAllDefferalDocuments(String applicationId){
        return [SELECT 
                Id, Waive_Off_Date__c, Name, Application__c, Is_Deferral_Document__c, Customer_Information__c, Property__c, 
                Deferral_Stage__c, Document_Name__c, Document_Family__c, Applicable_For__c, Mandatory__c, 
                Type__c, Document_Set_Code__c, Waiver_Reason__c ,Remarks__c, Current_Record_Id__c
                FROM Deferral_Document__c 
                WHERE Application__c =: applicationId AND Deferral_Stage__c = 'Document Deferral' AND Is_Deferral_Document__c = TRUE AND Status__c = 'Deferred'];
    }
    
    @AuraEnabled
    public static String updateDeferralRecord(String data){
        Deferral_Document__c defObj = (Deferral_Document__c)JSON.deserialize(data, Deferral_Document__c.class);
        update defObj;
        return defObj.Id;
    }
    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String jsonWrapper) {
        Wrapper data = (Wrapper)JSON.deserialize(jsonWrapper, Wrapper.class);

        ContentVersion cv = createContentVersion(base64, filename, data);
        //ContentDocumentLink cdl = createContentLink(cv.Id, data.applicationId);
        if (String.isNotBlank(data.documentDefId) && String.isNotEmpty(data.documentDefId)){ 
            Deferral_Document__c objDef = new Deferral_Document__c();
            objDef.Id = data.documentDefId;
            objDef.Is_Deferral_Document__c = false;
            update objDef;
            return objDef.Id;
        }
        return cv.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename, Wrapper data) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.Deferred_From__c = 'Document Deferral';
        cv.Deferal_Stage__c = 'Document Deferral';
        cv.Deferal_Record_Id__c = data.documentDefId;
        cv.Document_Name__c = data.documentName;
        cv.Parent_Id__c = data.applicationId;
        cv.Document_Family__c = data.documentFamily;
        cv.Received_Date__c = data.receivedDate;
        cv.Number_of_Pages__c = data.noOfPages;
        cv.Remarks__c = data.remarks;
        cv.Uploaded_From__c = 'Document Deferral';
        cv.Document_Set_Code_Id__c = data.docSetCodeId;
        cv.Current_Record_Id__c = data.parentRecordId;
        cv.Document_Type__c = data.documentType;
        cv.Status__c = data.status;
        insert cv;
        return cv;
    }
    
    // private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
    //     if (contentVersionId == null || recordId == null) { return null; }
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.ContentDocumentId = [
    //         SELECT ContentDocumentId 
    //         FROM ContentVersion 
    //         WHERE Id =: contentVersionId
    //     ].ContentDocumentId;
    //     cdl.LinkedEntityId = UserInfo.getOrganizationId();
    //     cdl.ShareType = 'V';
    //     try {
    //         insert cdl;
    //         return cdl;
    //     } catch(DMLException e) {
    //         System.debug(e);
    //         return null;
    //     }
    // }

    public class Wrapper{
        @AuraEnabled public String applicationId;   
        @AuraEnabled public String documentDefId;   
        @AuraEnabled public String documentName;   
        @AuraEnabled public String documentFamily;   
        @AuraEnabled public String status;   
        @AuraEnabled public Date receivedDate;   
        @AuraEnabled public String noOfPages;
        @AuraEnabled public String remarks;   
        @AuraEnabled public String docSetCodeId;
        @AuraEnabled public String parentRecordId;
        @AuraEnabled public String documentType;
    }

    public class ViewDocument{
        @AuraEnabled public String documentName;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String numberOfPages;
        @AuraEnabled public String remarks;
        @AuraEnabled public String uploadedFrom;
        @AuraEnabled public Boolean isCheckboxDisabled;
        @AuraEnabled public Boolean isDocumentView;
    }
}