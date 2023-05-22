/**
* @File Name          : FSIFSCController.cls
* @Description        : To Get Bank Detail Using IFSC Code.
* @Author             : Arnav Chaudhary
* @Created On         : 30/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         30/09/2022              Arnav Chaudhary       Initial Version
*/
public without sharing class FsIFSCController {
    @AuraEnabled
    public static WrapperResponse getIFSCData(String ifscCode){
        WrapperResponse response = new WrapperResponse();
        if(String.isNotBlank(ifscCode)){
            List<API_Handler__mdt> listOfIFSC = [SELECT ID, isActive__c, Endpoint__c, Method__c FROM API_Handler__mdt WHERE DeveloperName = 'Bank_IFSC' AND isActive__c = TRUE];
            if(listOfIFSC != null && listOfIFSC.size() > 0){
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                req.setEndpoint(listOfIFSC[0].Endpoint__c + ifscCode);
                req.setMethod(listOfIFSC[0].Method__c);
                res = http.send(req);
                if(res.getstatusCode() == 200 && res.getStatus() == 'Ok' && res.getbody() != null){
                    response.isSuccess = true;
                    response.result = res.getbody();
                }else if(res.getStatus() == 'Not Found' && res.getstatusCode() == 404){
                    response.isSuccess = false;
                    response.result = 'No Data Found';
                }
            }else{
                response.isSuccess = false;
                response.result = 'Metadata Not Configured.';
            }
        } else{
            response.isSuccess = false;
            response.result = 'Not A Valid IFSC.';
        }
        return response;
    }
    public class WrapperResponse{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String result;
        public WrapperResponse(){
            isSuccess = false;
            result = '';
        }
    }
}