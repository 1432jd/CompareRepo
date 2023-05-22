public class KYCTriggerHelper {
    public static void callHighMarkAPI(Map<Id,KYC__C> newloginMap){
        list<id> idList=new list<id>();
        for(string idd:newloginMap.keyset()){
            idList.add(idd);
        }
        system.debug('hiii');
        HighMarkAPI.getHighMarkReport(idList);
    }

}