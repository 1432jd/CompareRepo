@isTest
public class FS_LMS_CreateRecieptPayOutAPITest {

    @isTest
    public static void testmethod1(){
        Test.setMock(HttpCalloutMock.class, new FS_LMS_CreateRecieptPayOutAPITestMock());
        FS_LMS_CreateRecieptPayOutAPI.createRecieptPayOut();
    }
     @isTest
    public static void testmethod2(){
       // Test.setMock(HttpCalloutMock.class, new FS_LMS_CreateRecieptPayOutAPITestMock());
        FS_LMS_CreateRecieptPayOutAPI.createRecieptPayOut();
    }
   
}