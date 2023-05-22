@isTest
public class GenericFormBuilderControllerTest {
    
      @isTest
    public static void testMethod1(){
        GenericFormBuilderController gfbc = new GenericFormBuilderController();
        gfbc.METADATA_NAME = 'fs_Prelogin_Property_Details';
        Set<String> idset = new Set<String>{'xyz'};
        gfbc.IDS_SET = idset ;
        List<Generic_Detail_page__mdt> METADATA_QUERY = [Select Id from Generic_Detail_page__mdt];
        List<String> fieldToQuery = new List<String>{'Taluka__c','Title_Deed_Number__c'};
        Property__c app =new Property__c();
        app.Taluka__c = 'abc';
        app.Title_Deed_Number__c = '1212';
        insert app;
        gfbc.initialize();
    }

}