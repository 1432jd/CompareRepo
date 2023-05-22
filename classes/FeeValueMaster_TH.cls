public class FeeValueMaster_TH extends AbstractTriggerContext{
	public override void beforeDelete(List<sobject> newList, Map<Id,sObject> newMap){
        System.debug('Fee Value MasterTriggerHelper');
        showErrorForDelete((List<Fee_Value_Master__c>)newList);
    }
    
    public static void showErrorForDelete(List<Fee_Value_Master__c> newList){
        
        for(Fee_Value_Master__c feeValue : newList) {
			if(feeValue != null ) {
				feeValue.addError('You are not allowed to delete Fee Value Master');
			}
		}
        
    }
}