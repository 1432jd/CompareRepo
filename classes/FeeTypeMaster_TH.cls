public class FeeTypeMaster_TH extends AbstractTriggerContext{
    public override void beforeDelete(List<sobject> newList, Map<Id,sObject> newMap){
        System.debug('Fee Type MasterTriggerHelper');
        showErrorForDelete((List<Fee_Type_Master__c>)newList);
    }
    
    public static void showErrorForDelete(List<Fee_Type_Master__c> newList){
        for(Fee_Type_Master__c feeType : newList) {
			if(feeType != null) {
				feeType.addError('You are not allowed to delete Fee Type Master');
			}
		}
    }

}