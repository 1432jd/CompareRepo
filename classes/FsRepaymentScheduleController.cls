public class FsRepaymentScheduleController {
    
    @AuraEnabled
    public static string generateRepaymentSchedule(String applicationId){    
        Application__c objApp = new Application__c();
        MS_Scheme__c objScheme = new MS_Scheme__c();
        String businessDate = System.Label.Business_Date;
        
        Double loanAmount;
        Decimal EMI;
        Integer tenor;
        Decimal ROI;
        Date cycleDate;
        Decimal IRR;
        Date disbursementDate = Date.parse(businessDate);
        objApp = [SELECT Id, Name, Tenor_In_Months__c , Total_Amount_Recommended_PcAc__c, Customer_Communicated__c,Emi_PcAc__c,Number_of_advance_EMI__c,Effective_IRR__c,LMS_Response_Reference__c  
                  FROM Application__c
                  WHERE Id = :applicationId AND Total_Amount_Recommended_PcAc__c != NULL AND Tenor_In_Months__c != NULL
                  AND Customer_Communicated__c != NULL AND Emi_PcAc__c != NULL];
        objScheme = [SELECT Id, Scheme_Code__c, Cycle_Date_Type__c
                     FROM MS_Scheme__c
                     WHERE Scheme_Code__c = 'LAP_BL' LIMIT 1];
        System.debug('objScheme '+objScheme);
        if(objScheme.Cycle_Date_Type__c == 'Range'){
            System.debug(objScheme.Cycle_Date_Type__c);
            System.debug(disbursementDate.day());
            if(disbursementDate.day() > 20){
                disbursementDate = disbursementDate.addMonths(1);
                cycleDate = date.newinstance(disbursementDate.year(), disbursementDate.month(), 5);
            }
            else{
                List<Cycle_Date__mdt> listMdt = [SELECT Id, From__c, To__c, Cycle_Date__c
                                                 FROM Cycle_Date__mdt];
                System.debug('listMdt '+listMdt);
                for(Cycle_Date__mdt objMdt : listMdt){
                    System.debug('From '+Integer.valueOf(objMdt.From__c)+' To '+Integer.valueOf(objMdt.To__c)+' Disb Date '+disbursementDate.day());
                    if(disbursementDate.day() >= Integer.valueOf(objMdt.From__c) && disbursementDate.day() <= Integer.valueOf(objMdt.To__c)){
                        System.debug('Inside '+Integer.valueOf(objMdt.Cycle_Date__c));
                        cycleDate = date.newinstance(disbursementDate.year(),disbursementDate.month(),Integer.valueOf(objMdt.Cycle_Date__c));
                        System.debug('cycleDate '+cycleDate.day()+'/'+cycleDate.month()+'/'+cycleDate.year());
                    }
                }
            }
        }
        else{
            Date firstDayOfMonth = disbursementDate.toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            System.debug(lastDayOfMonth);
            if(disbursementDate.day() <= 20){
                cycleDate = lastDayOfMonth;
                System.debug(cycleDate);
            }
            else{
				cycleDate = lastDayOfMonth.addMonths(1);
                System.debug(cycleDate);                
            }
        }
        if(objApp != null){
            System.debug('cycleDate '+cycleDate);
            loanAmount = objApp.Total_Amount_Recommended_PcAc__c;
            EMI = objApp.Emi_PcAc__c;
            tenor = Integer.valueOf(objApp.Tenor_In_Months__c);
            ROI = objApp.Customer_Communicated__c;
            IRR = objApp.Effective_IRR__c;
            List<WrapperEmi> wrapperEmiList = new List<WrapperEmi>();
            boolean isClosePos = false;
            Decimal temp=0.0;
            Date dueDate = cycleDate;
            //Integer.valueOf(objApp.Tenor_In_Months__c)
            for(Integer i = 0;i<=Integer.valueOf(objApp.Tenor_In_Months__c);i++){
                WrapperEmi wrapperEmiobj = new WrapperEmi();
                wrapperEmiobj.numberOfDaysBetweenInstallment = 30;
                if(Integer.valueOf(objApp.Number_of_advance_EMI__c) == 0){
                    wrapperEmiobj.month= i;
                    wrapperEmiobj.isAdvEMI = true;
                }
                else{
                    wrapperEmiobj.month= i+1;
                    if(i == 0)
                        wrapperEmiobj.isAdvEMI = false;
                    else
                        wrapperEmiobj.isAdvEMI = true;
                    //wrapperEmiobj.isAdvEMI = false;
                }
                if(objScheme.Cycle_Date_Type__c == 'Range'){
                    dueDate = cycleDate.addMonths(i);
                }
                else{
                    Date nextDate = cycleDate.addMonths(i).toStartOfMonth();
                    dueDate = nextDate.addDays(Date.daysInMonth(nextDate.year(), nextDate.month()) - 1);
                    System.debug(nextDate);
                }
                wrapperEmiobj.cycleDate = dueDate.format();
                //NEW LOGIC CR
                Integer year = dueDate.Year();
                Integer month = dueDate.Month();
                Boolean isLeapYear = (Math.mod(year, 4) == 0 && Math.mod(year, 100) != 0) || Math.mod(year, 400) == 0;
                if(month == 2){
                    wrapperEmiobj.numberOfDaysBetweenInstallment = isLeapYear ? 29 : 28;
                }
                if(month == 3){
                    wrapperEmiobj.numberOfDaysBetweenInstallment = isLeapYear ? 31 : 32;
                }
                //NEW LOGIC END 
                System.debug(wrapperEmiobj.cycleDate);
                if(i==0){
                    if(Integer.valueOf(objApp.Number_of_advance_EMI__c) == 0)
                        wrapperEmiObj.emi = 0;
                    else
                        wrapperEmiObj.emi = EMI*Integer.valueOf(objApp.Number_of_advance_EMI__c);
                    wrapperEmiObj.openPos = loanAmount;
                }
                else{
                    wrapperEmiObj.emi = EMI;
                    wrapperEmiObj.openPos = temp;
                    //wrapperEmiObj.interest = (IRR * wrapperEmiObj.openPos/1200);
                    wrapperEmiObj.interest = ((wrapperEmiObj.openPos*IRR)/36000 * wrapperEmiobj.numberOfDaysBetweenInstallment);
                    wrapperEmiObj.interest = wrapperEmiObj.interest.setScale(2,System.RoundingMode.CEILING); 
                }   
                if(i+1 == Integer.valueOf(objApp.Tenor_In_Months__c) && wrapperEmiObj.openPos - wrapperEmiObj.principle > 0){
                    wrapperEmiObj.principle = (wrapperEmiObj.emi - wrapperEmiObj.interest) + (wrapperEmiObj.openPos - wrapperEmiObj.principle);
                    wrapperEmiObj.emi += wrapperEmiObj.openPos + wrapperEmiObj.interest; 
                }
                else
               	 wrapperEmiObj.principle =  wrapperEmiObj.emi-wrapperEmiObj.interest;
                if(wrapperEmiObj.openPos- wrapperEmiObj.principle > 0 ){
                    wrapperEmiObj.closePos =  wrapperEmiObj.openPos- wrapperEmiObj.principle;
                }
                if(wrapperEmiObj.openPos- wrapperEmiObj.principle > 0){
                    temp = wrapperEmiObj.closePos;
                }
                else if(wrapperEmiObj.openPos - wrapperEmiObj.principle <= 0){
                    wrapperEmiObj.EMI = wrapperEmiObj.EMI > wrapperEmiObj.openPos + wrapperEmiObj.interest ? wrapperEmiObj.openPos + wrapperEmiObj.interest : wrapperEmiObj.EMI;
                    wrapperEmiObj.principle = wrapperEmiObj.EMI - wrapperEmiObj.interest;
                    isClosePos = TRUE;
                }
                wrapperEmiList.add(wrapperEmiObj);
                if(isClosePos == TRUE){
                    break;
                }
            }
            System.debug('wrapperEmiList  '+wrapperEmiList);
            System.debug(JSON.serialize(wrapperEmiList));
            
            /* Loan Maturity Date Updation */
            if(objApp.LMS_Response_Reference__c == null && String.isBlank(objApp.LMS_Response_Reference__c)){
                WrapperEmi wrapObj = new WrapperEmi();
                wrapObj = wrapperEmiList.get(wrapperEmiList.size()-1);
                objApp.Loan_Maturity_Date__c=Date.parse(wrapObj.cycleDate);
                System.debug('objApp Updated '+objApp);
                //UPDATE objApp;
            }
            
            return JSON.serialize(wrapperEmiList);
        }
        return null;
    }
    
    public class WrapperEmi{
        public Decimal openPos=0.0;
        public Decimal interest=0.0;
        public Decimal emi=0.0;
        public Decimal closePos=0.0;
        public Decimal principle=0.0;
        public Integer tenor=0;
        public Integer month=0;
        public Integer numberOfDaysBetweenInstallment=0;
        public String cycleDate;
        public Boolean isAdvEMI; 
    }
    
}