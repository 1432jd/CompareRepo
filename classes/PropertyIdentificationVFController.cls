public class PropertyIdentificationVFController {
    public String recordId{get;set;}
    public Property__c objProp{get;set;}
    public PropertyWrapper objPropWrap{get;set;}
    public List<Loan_Applicant__c> loanAppList {get;set;}
    public PropertyIdentificationVFController(){
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        System.debug('recordId '+recordId);
        objProp = new Property__c();
        objPropWrap = new PropertyWrapper();
        objProp = [Select Id,Application__c,East_by_boundaries__c,East_By_Boundaries_Physical__c,West_by_boundaries__c ,West_By_Boundaries_Physical__c,
                          North_by_boundaries__c , North_By_Boundaries_Physical__c, South_by_boundaries__c , South_By_Boundaries_Physical__c,
                          East_by_land_measurements__c , East_By_Land_Physical__c, West_by_land_measurements__c , West_By_Land_Physical__c,
                          North_by_land_measurements__c , North_By_Land_Physical__c, South_by_land_measurements__c , South_By_Land_Physical__c
                   FROM Property__c WHERE Id = :recordId AND RecordType.Name = 'FIV-C Property Detail'];
        if(objProp.East_by_land_measurements__c != null && objProp.West_by_land_measurements__c != null)
            objPropWrap.eastToWestTitleDeed = (objProp.East_by_land_measurements__c+objProp.West_by_land_measurements__c)/2;
        if(objProp.North_by_land_measurements__c != null && objProp.South_by_land_measurements__c != null)
            objPropWrap.northToSouthTitleDeed = (objProp.North_by_land_measurements__c+objProp.South_by_land_measurements__c)/2;
        if(objProp.East_By_Land_Physical__c != null && objProp.West_By_Land_Physical__c != null)
            objPropWrap.eastToWestPhysical = (objProp.East_By_Land_Physical__c+objProp.West_By_Land_Physical__c)/2;
        if(objProp.North_By_Land_Physical__c != null && objProp.South_By_Land_Physical__c != null) 
            objPropWrap.northToSouthPhysical = (objProp.North_By_Land_Physical__c+objProp.South_By_Land_Physical__c)/2;
        loanAppList = new List<Loan_Applicant__c>();
        loanAppList = [SELECT Id, Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.PersonBirthdate, Application__r.Name, Application__r.Sourcing_Branch__r.Name,
                       Residence_Address_Line_1__c, Residence_City__c, Residence_State__c, Residence_Country__c, Residence_Pincode__r.Name,Customer_Type__c 
                       FROM Loan_Applicant__c
                       WHERE Application__c = :objProp.Application__c
                       ORDER BY Customer_Type__c];
    }
    
    public class PropertyWrapper{
        public Decimal eastToWestTitleDeed{get;set;}
        public Decimal northToSouthTitleDeed{get;set;}
        public Decimal eastToWestPhysical{get;set;}
        public Decimal northToSouthPhysical{get;set;}
    }

}