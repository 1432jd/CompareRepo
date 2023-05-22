@isTest
public class FS_SaveAndSubmitControllerTest {
    
      @TestSetup
    static void createTestData(){
       
        Application__c appObj = new Application__c(Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,Tranche_Disbursal__c='I',
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =appObj.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('PC Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        prop1.Mortgage_property_Living_property_are__c = 'No';
        prop1.Boundaries_As_Per_Inspection_Are_Same__c = 'No';
        prop1.Pathway_Available__c = 'No';
        prop1.Land_Area_Sq_Ft__c = 22.0;
        prop1.Valuation_Market_Value_Per_SqFt__c = 22;
        prop1.Total_Floor_Area__c = 22;
        prop1.Avg_Floor_Value_Per_Sq_Ft__c = 22;
        prop1.Total_Floor_Value__c = 22;
        prop1.Existing_Encumberances__c = 'Yes';
        insert prop1;
}
    @isTest
    public static void saveAllRecordsLeadDetailsTest(){
        Property__c prop = [Select id from Property__c Limit 1];   

        String jsonStrPCAC = '{"Character":{"Family Detail":[{"Id":"1"}],"Neighbour Detail":[{"Id":"1"}],"Affiliation Detail":[{"Id":"1"}],"Living Standard Detail":[{"Id":"1"}]},"Capability":[{"Id":"1"}],"Collateral":[{"Id":"'+prop.Id+'"}],"Financial":[],"Decision":[{"Id":"1"}]}';
        FS_SaveAndSubmitController.saveAllRecordsPCAC(jsonStrPCAC);
		
        String jsonStrFIVC = '{"Character__c":{"Family Detail":[{"Id":"1"}],"Neighbour Detail":[{"Id":"1"}],"Affiliation Detail":[{"Id":"1"}],"Living Standard Detail":[{"Id":"1"}]},"Capability__c":[{"Id":"1"}],"Property__c":[],"CommonObject__c":[],"Revisit__c":{"General Revisit":[{"Id":"1"}],"Senior Revisit":[{"Id":"1"}]},"Decision":[]}';
        FS_SaveAndSubmitController.saveAllRecordsFIVC(jsonStrFIVC);
        
        String jsonStrLeadDetails = '{"Application Information":{"Application Type":[],"Applicant Information":[],"Customer Information":[],"Education":[{"Id":"1"}],"Family":[{"Id":"1"}],"Employment Details":[{"Id":"1"}],"Income Details":[{"Id":"1"}],"Bank Details":[{"Id":"1"}],"Reference Details":[]},"Loan Details":{"Loan Type":[],"Property Details":[],"Property Boundaries":[],"Property Measurement":[],"Property Address":[],"Ownership Details":[]},"Sourcing Details":{"Application Details":[]}}';
        FS_SaveAndSubmitController.saveAllRecordsLeadDetails(jsonStrLeadDetails);
    }

}