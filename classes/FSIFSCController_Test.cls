@isTest
private class FSIFSCController_Test {
    @isTest
    static void testMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FsIFSCControllerTestMock());
        FSIFSCController.getIFSCData('PUNB0013600');
        Test.stopTest();
    }
    @isTest
    static void testMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FsIFSCControllerTestMock());
        FSIFSCController.getIFSCData('HDFC0001636');
        Test.stopTest();
    }
    @isTest
    static void testMethod3(){
        Test.startTest();
        FSIFSCController.getIFSCData(null);
        Test.stopTest();
    }
}