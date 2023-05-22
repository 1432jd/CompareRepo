@isTest
public class fsVendorhandoff_Test {
    @TestSetup
    static void createTestData(){      
        Application__c app1 = new Application__c();
        app1.Applicant_Name__c = 'App2';
        app1.File_Inward_Status__c = 'Pending';
        app1.Remarks__c = 'ss';
        app1.Stage__c ='Closed';
        app1.File_Status__c ='In';
        app1.Name = 'ee';
        insert app1;
        
        Disbursal__c disbObj = new Disbursal__c();
        disbObj.Application__c = app1.Id;
        disbObj.Disbursal_Type__c = 'Full Disb';
        insert disbObj;
    }
    @isTest
    static void testAllMethod(){
        List<Application__c> appList = [SELECT Id,Applicant_Name__c,File_Status__c,Name FROM Application__c WHERE Applicant_Name__c = 'App2'];
        List<Disbursal__c> disbList = [Select Id,Disbursal_Type__c,Application__c FROM Disbursal__c WHERE Disbursal_Type__c ='Full Disb'];
        test.startTest();
        fsVendorhandoff.getRepaymentDoc(appList[0].Id);
        fsVendorhandoff.getApplicationData(Date.today(),Date.today()+5,'app','22');
        fsVendorhandoff.getApplicationData(Date.today(),null,'app','22');
        fsVendorhandoff.getApplicationData(null,Date.today()+6,'app','22');
        fsVendorhandoff.getApplicationData(Date.today(),Date.today()+6,'','');
        fsVendorhandoff.getApplicationData(null,Date.today()+3,'','');
        fsVendorhandoff.getApplicationData(Date.today()+6,null,'','');
        fsVendorhandoff.getApplicationData(null,null,'222','rfr');
        fsVendorhandoff.getApplicationData(null,null,'','rfeer');
        fsVendorhandoff.getApplicationData(null,null,'red','');
        fsVendorhandoff.getApplicationData(null,null,'','');
        List<fsVendorhandoff.VendorHandoffWrapper> wrapList = new List<fsVendorhandoff.VendorHandoffWrapper>();
        fsVendorhandoff.VendorHandoffWrapper vendorObj = new fsVendorhandoff.VendorHandoffWrapper();
        Application__c app = new Application__c(); 
        vendorObj.Id = appList[0].Id;
        vendorObj.serialNumber = 11;
        vendorObj.applicationNo = appList[0].Name;
        vendorObj.sourcingBranchName = 'Noida';
        vendorObj.handoffDate = String.valueOf(date.today());
        vendorObj.fileBarCode = 'gg';
        vendorObj.boxBarCode = 'kgiu';
        vendorObj.storageVendorName = 'yufg';
        vendorObj.fileStatus = appList[0].File_Status__c;
        vendorObj.isError = false;
        vendorObj.isChanged=true;
        vendorObj.storageVendorNameError = false;
        vendorObj.boxBarCodeError = false;
        vendorObj.fileBarCodeError =false;
        vendorObj.handoffDateError =false;
        vendorObj.storageVendorNameError=false;
        wrapList.add(vendorObj);
        fsVendorhandoff.saveApplications(json.serialize(wrapList));
        fsVendorhandoff.submitApplications(json.serialize(wrapList));
        test.stopTest();
    }
}