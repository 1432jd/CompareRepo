/**
* @File Name          : fsGenericUploadDocumentsController_Test.cls
* @Description        : Service Class For fsGenericUploadDocuments Lightning Component
* @Author             : Suresh Gupta
* @Created On         : 29/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         29/09/2022              Suresh Gupta       Initial Version
*/

@isTest

public class fsGenericUploadDocumentsController_Test {
    @TestSetup
    static void testData(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        Application__c app1 = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',LMS_Response_Reference__c='asds',application_status__c='Active', EMI__c=23443, Loan_Amount__c =2334, Nach_Party__c='sdssd', Nach_Party_2__c='sdssd'); 
        insert app1;
        
        ContentVersion cv1 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = false, Parent_Id__c = app1.id, ContentUrl ='www.test.com', Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = false, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Application');
        insert cv1;
        ContentVersion cv2 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = True, Parent_Id__c = app1.id, ContentUrl ='www.test.com',Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = true, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Applicant');
        insert cv2;
        ContentVersion cv3 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = True, Parent_Id__c = app1.id, ContentUrl ='www.test.com',Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = true, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Asset');
        insert cv3;
        Account acc = new Account(Name ='Test1', Type = 'Customer');
        insert acc;
        Document_Master__c dm1 = new Document_Master__c(Name='Test1', Active__c = 'Yes', Description__c='Test1', Family__c = 'Address Proof', Type__c ='Application');
        insert dm1;
        Document_Master__c dm2 = new Document_Master__c(Name='Test2',Active__c = 'Yes', Description__c='Test2', Family__c = 'Address Proof', Type__c ='Applicant');
        insert dm2;
        Document_Master__c dm3 = new Document_Master__c(Name='Test3',Active__c = 'Yes', Description__c='Test3', Family__c = 'Address Proof', Type__c ='Asset');
        insert dm3;
        
        Document_Set_Code__c dsc1 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Application', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm1.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Family__c='Address Proof');
        insert dsc1;
        Document_Set_Code__c dsc2 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Applicant', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm2.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Applicable_For__c = 'All', Income_Type__c = 'All');
        insert dsc2;
        Document_Set_Code__c dsc3 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Asset', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm3.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Asset_Type__c = 'All', Sub_Type__c = 'All');
        insert dsc3;
        
        
        Property__c pobj1 = new Property__c (Application__c = app1.id, Property_Type__c = 'Flat');
        insert pobj1;
        Deferral_Document__c dd1 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = true, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Application' );
        insert dd1;
        Deferral_Document__c dd2 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = false, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Applicant' );
        insert dd2;
        Deferral_Document__c dd3 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = true, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Asset' );
        insert dd3;
        fsGenericUploadDocumentsController.fileData fd1 = new fsGenericUploadDocumentsController.fileData();
        fd1.base64='base64';
        fd1.filename='TestFile';
        
        
        fsGenericUploadDocumentsController.WrapperCV wCV1 = new fsGenericUploadDocumentsController.WrapperCV();
        wCV1.documentCode = 'Test1';
        wCV1.docSetCodeId = 'Test1';
        wCV1.serialNumber = 'Test1';
        wCV1.parentPropertyId = pobj1.id;
        wCV1.applicantId = app1.id;
        wCV1.applicableFor = 'Test1';
        wCV1.customerType = 'Customer';
        wCV1.customerName = 'Test1';
        wCV1.documentName = dsc1.Name;
        wCV1.documentFamily = dsc1.Family__c;
        wCV1.documentType = dsc1.Type__c;
        wCV1.agreementDocumentType = dsc1.Type__c;
        wCV1.documentCondition = dsc1.id;
        wCV1.mandatory = 'Yes';
        
        wCV1.status = 'Waived';
        wCV1.stage = 'Lead Detail';
        wCV1.deferredDate = date.today();
        wCV1.waiverReason = 'Test1';
        wCV1.receivedDate = date.today();
        wCV1.noOfPages = '20';
        wCV1.remarks = 'remarks';
        wCV1.isNewRowAdded = true;
        wCV1.fileName = 'Test';
        wCV1.original ='original';
        wCV1.propertyId = pobj1.id;
        wCV1.isDeferalRecord = true;
        wCV1.deferalRecordId = dd1.id;
        
        wCV1.contentDocumentId = cv1.id;
        wCV1.isDocumentMaster = true;
        wCV1.fileData = fd1;
        String myJSON = JSON.serialize(wCV1);
        
        
    }
    @isTest
    public static void getUploadedRecordsTest1(){
        List<ContentVersion> cvList = [SELECT id, Parent_Id__c FROM ContentVersion];
        Test.startTest();
        fsGenericUploadDocumentsController.getUploadedRecords(cvList[1].Parent_Id__c, '') ;    
        Test.stopTest();
    }
    
    @isTest
    public static void getAllRequiredDataTest1(){
        list<Application__c> appList = [SELECT Id FROM Application__c];
        list<Document_Set_Code__c> dscList= [SELECt id, Stage__c FROM Document_Set_Code__c]; 
        list<Document_Master__c> dmList= [SELECt id FROM Document_Master__c];
        Test.startTest();
        fsGenericUploadDocumentsController.getAllRequiredData(dscList[0].Stage__c, appList[0].id, '0120w000001HWhbAAG');
        Test.stopTest();
    } 
    @isTest
    public static void getUploadedDataTest1(){
        list<Application__c> appList = [SELECT Id FROM Application__c];
        //list<Deferral_Document__c> appList = [SELECT Id,  FROM Deferral_Document__c];
        Test.startTest();
        fsGenericUploadDocumentsController.getUploadedData('Lead Detail',appList[0].id) ; 
        Test.stopTest();
    }
    
    @isTest
    public static void createCVRecordTest1(){
        //list<Application__c> appList = [SELECT Id FROM Application__c];
        list<Document_Set_Code__c> dscList= [SELECt id, Stage__c, Name,Family__c, Type__c FROM Document_Set_Code__c]; 
        list<Application__c> appList = [SELECT Id FROM Application__c];
        list<Property__c> proList = [SELECT Id FROM Property__c];
        list<Deferral_Document__c> ddList = [SELECT Id FROM Deferral_Document__c];
        list<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
        //list<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
        
        fsGenericUploadDocumentsController.fileData fd1 = new fsGenericUploadDocumentsController.fileData();
        fd1.base64='base64';
        fd1.filename='Test1';
        fd1.recordId=appList[0].id;
          
        fsGenericUploadDocumentsController.WrapperCV wCV1 = new fsGenericUploadDocumentsController.WrapperCV();
        wCV1.documentCode = dscList[0].Name;
        wCV1.docSetCodeId = dscList[0].Id;
        wCV1.serialNumber = '23';
        wCV1.parentPropertyId = proList[0].id;
        wCV1.applicantId =appList[0].id ;
        wCV1.applicableFor = 'All';
        wCV1.customerType = 'Primary Applicant';
        wCV1.customerName = 'Test1';
        wCV1.documentName = 'Test';
        wCV1.documentFamily = '';
        wCV1.documentType = 'Applicant';
        wCV1.agreementDocumentType = 'Original';
        
        wCV1.documentCondition = 'In good order';
        wCV1.mandatory = 'Yes';
        wCV1.status = 'Deferred';
        wCV1.stage = 'Lead Detail';
        wCV1.deferredDate = date.today();
        wCV1.waiverReason = '';
        wCV1.receivedDate = date.today();
        wCV1.noOfPages = '';
        wCV1.remarks = '';
        wCV1.isNewRowAdded = true;
        wCV1.fileName = '';
        wCV1.original = '';
        wCV1.propertyId = '';
        wCV1.isDeferalRecord = true;
        wCV1.deferalRecordId = ddList[0].id;
        wCV1.contentDocumentId = '';
        wCV1.isDocumentMaster = true;
        wCV1.fileData = fd1;
        String myJSON = JSON.serialize(wCV1);
        Test.startTest();
        fsGenericUploadDocumentsController.createCVRecord(myJSON,'Lead Detail') ; 
        Test.stopTest();
    }
    
     @isTest
    public static void createDeferralRecordTest1(){
        list<Document_Set_Code__c> dscList= [SELECt id, Stage__c, Name,Family__c, Type__c FROM Document_Set_Code__c]; 
        list<Application__c> appList = [SELECT Id FROM Application__c];
        list<Property__c> proList = [SELECT Id FROM Property__c];
        list<Deferral_Document__c> ddList = [SELECT Id FROM Deferral_Document__c];
        list<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
        //list<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
        
        fsGenericUploadDocumentsController.fileData fd1 = new fsGenericUploadDocumentsController.fileData();
        fd1.base64='';
        fd1.filename='';
        fd1.recordId='';
        
        
        fsGenericUploadDocumentsController.DeferralWrapper wCV1 = new fsGenericUploadDocumentsController.DeferralWrapper();
        wCV1.serialNumber = 3;
        wCV1.docSetCodeId = dscList[0].id;
        wCV1.documentName = '';
        wCV1.documentFamily = '';
        wCV1.parentPropertyId = proList[0].id;
        wCV1.applicableFor = '';
        wCV1.customerType = '';
        wCV1.customerName = '';
        wCV1.mandatory = '';
        wCV1.documentType = 'Applicant';
        wCV1.status = 'Deferred';
        wCV1.stage = '';
        
        wCV1.deferredStageDisable = true;
        wCV1.deferredRequired = true;
        wCV1.deferredDate = date.today();
        wCV1.receivedDate = date.today();
        wCV1.isReceivedDateRequired = true;
        wCV1.receivedDateDisable = true;
        wCV1.noOfPages ='4';
        wCV1.isWaiverRequired = true;
        wCV1.waiverReasonDisable = true;
        wCV1.remarks = '';
        wCV1.isNewRowAdded = true;
        wCV1.fileName = '';
        wCV1.isFileUploadDisabled = true;
        wCV1.isFileUploadRequired = true;
        wCV1.original = '';
        wCV1.isoriginalDisabled = true;
        wCV1.fileData = '';
        wCV1.isAgreementExecution = true;
        
        wCV1.applicationId = applIst[0].id;
        wCV1.applicantId = '';
        wCV1.propertyId = proList[0].id;
        wCV1.isDeferalRecord = true;
        wCV1.deferalRecordId = ddList[0].id;
        wCV1.contentDocumentId = '';
        wCV1.isDocumentMaster = true;
        wCV1.isDeferred = false;
        String myJSON = JSON.serialize(wCV1);
       
        Test.startTest();
        fsGenericUploadDocumentsController.createDeferralRecord(myJSON, 'Lead Detail', appList[0].id) ; 
        Test.stopTest();
    }
    
     @isTest
    public static void uploadAddtionalDocumentTest1(){
        list<Application__c> appList = [SELECT Id, Stage__c FROM Application__c];
        list<Document_Set_Code__c> dscList= [SELECt id, Stage__c FROM Document_Set_Code__c]; 
        list<Document_Master__c> dmList= [SELECt id FROM Document_Master__c];
        Test.startTest();
        fsGenericUploadDocumentsController.uploadAddtionalDocument('Base64' ,'TestFile1',appList[0].id,'Description For TestFile1', applist[0].Stage__c );
        List<PhotosWrapper> obj = new List<PhotosWrapper>();
        PhotosWrapper photo = new PhotosWrapper();
        photo.base64 = 'base64';
        photo.recordId = appList[0].Id;
        photo.fileName = 'Test';
        photo.stagName = 'FIV - C';
        obj.add(photo);
        //obj.add(new PhotosWrapper(base64 = 'base64', recordId = appList[0].Id, fileName = 'Test', stagName = 'FIV - C'));
        fsGenericUploadDocumentsController.uploadPhotos(JSON.serialize(photo), null, null);
        fsGenericUploadDocumentsController.getHackURL(JSON.serialize(new List<String>{appList[0].Id}));
        Test.stopTest();
    } 

    @isTest
    public static void uploadedDocumentsTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        ContentVersion cv =  new Contentversion(Title = 'ABC', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'), Parent_Id__c = app.Id);
        insert cv;
        fsGenericUploadDocumentsController.uploadedDocuments(app.Id);
        fsGenericUploadDocumentsController.updateContentVersion([SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId, '');
    }
     
    public class PhotosWrapper{
        @AuraEnabled public String base64;
        @AuraEnabled public String recordId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String stagName;
    }
}