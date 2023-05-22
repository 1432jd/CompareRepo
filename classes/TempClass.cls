public class TempClass {


    public static void getData(){
        String SystemObj = 'Application__c';
        String finalQuery = 'select'+'';
        List<String> datatoQueryList = new List<String>();
        datatoQueryList.add('Id');
        datatoQueryList.add('Name');

        Map<String,String> labelMap = new Map<String,String>();
        Map<String,String> valueMap = new Map<String,String>();
        Integer i=0;
        for(String str : datatoQueryList){
            ++i;
            if(i==datatoQueryList.size()){
                finalQuery+=str;
            }else{
                finalQuery+=str+',';
            }
            valueMap.put(str,'');
        }

        String myQuery = finalQuery+'from'+''+SystemObj;

        List<Application__c> appList = Database.query(myQuery);

        for(Application__c appObj : appList){

        }


       




    }




    public class reportWrapper{
        public Decimal sequence;
        public String SectionHeader;
        public String SubSectionHeader;        
        public List<SectionContent> SectionContentList;
    }
    
    public class SectionContent{
        public Decimal sequence;
        public String SubSubSectionHeader;
        public String fieldLabel;
        public String fieldValue;
    }


}