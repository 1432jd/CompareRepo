@IsTest
public class GenericEditPagesControllerTest {
    
    @isTest
    public static void testMethod1(){
        GenericEditPagesController gepc = new GenericEditPagesController();
        gepc.METADATA_NAME = 'Lead_Details_Personal_Information';
        Set<String> idset = new Set<String>{'xyz'};
        gepc.IDS_SET = idset ;
        List<Generic_Detail_page__mdt> METADATA_QUERY = [Select Id from Generic_Detail_page__mdt];
        List<String> fieldToQuery = new List<String>{'AC_User__c','Agreement_Execution_Status__c'};
        Application__c app =new Application__c();
        
        gepc.getSectionContent();
        gepc.parseQuery(app,fieldToQuery);
    }
}