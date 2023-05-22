public without sharing class FS_SaveAndSubmitController {
    
    @AuraEnabled
    public static string saveAllRecordsPCAC(String jsonStr){
        try {
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            List<Property__c> properties = (List<Property__c>)JSON.deserialize( JSON.serialize(root.get('Collateral')), List<Property__c>.class);
            System.debug('properties = '+properties);
            List<Capability__c> capabilities = (List<Capability__c>)JSON.deserialize( JSON.serialize(root.get('Capability')), List<Capability__c>.class);
            System.debug('capabilities = '+capabilities);
            List<Application__c> financials = (List<Application__c>)JSON.deserialize( JSON.serialize(root.get('Financial')), List<Application__c>.class);
            System.debug('financials = '+financials);

            if(properties != NULL && !properties.isEmpty()){
                for(Property__c pro : properties){
                    Id rcId;
                    if(String.valueOf(pro.Id) == '1'){
                        pro.Id = rcId;
                    }
                }
                update properties;
            }
            if(capabilities != NULL && !capabilities.isEmpty()){
                for(Capability__c cap : capabilities){
                    Id rcId;
                    if(String.valueOf(cap.Id) == '1'){
                        cap.Id = rcId;
                    }
                }
                upsert capabilities;
            }
            if(financials != NULL && !financials.isEmpty()){
                upsert financials;
            }

            Map<String, Object> characters = (Map<String, Object>)root.get('Character');
            List<Character__c> familtyDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Family Detail')), List<Character__c>.class);
            System.debug('familtyDetails = '+familtyDetails);
            if(familtyDetails != NULL && !familtyDetails.isEmpty()){
                for(Character__c chr : familtyDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert familtyDetails;
            }

            List<Character__c> neighbourInfo = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Neighbour Detail')), List<Character__c>.class);
            System.debug('neighbourInfo = '+neighbourInfo);
            if(neighbourInfo != NULL && !neighbourInfo.isEmpty()){
                for(Character__c chr : neighbourInfo){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert neighbourInfo;
            }

            List<Character__c> affiliationDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Affiliation Detail')), List<Character__c>.class);
            System.debug('affiliationDetails = '+affiliationDetails);
            if(affiliationDetails != NULL && !affiliationDetails.isEmpty()){
                for(Character__c chr : affiliationDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert affiliationDetails;
            }

            List<Character__c> livingDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Living Standard Detail')), List<Character__c>.class);
            System.debug('livingDetails = '+livingDetails);
            if(livingDetails != NULL && !livingDetails.isEmpty()){
                for(Character__c chr : livingDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert livingDetails;
            }

            return 'success';
        } catch (Exception e) {
            System.debug('Errorr = '+e.getMessage() + ' = '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveAllRecordsFIVC(String jsonStr){
        try {
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            List<Property__c> properties = (List<Property__c>)JSON.deserialize( JSON.serialize(root.get('Property__c')), List<Property__c>.class);
            System.debug('properties = '+properties);
            List<Capability__c> capabilities = (List<Capability__c>)JSON.deserialize( JSON.serialize(root.get('Capability__c')), List<Capability__c>.class);
            System.debug('capabilities = '+capabilities);
            List<CommonObject__c> enquiries = (List<CommonObject__c>)JSON.deserialize( JSON.serialize(root.get('CommonObject__c')), List<CommonObject__c>.class);
            System.debug('enquiries = '+enquiries);
            List<Verification__c> verifications = (List<Verification__c>)JSON.deserialize( JSON.serialize(root.get('Decesion')), List<Verification__c>.class);
            System.debug('verifications = '+verifications);

            if(verifications != NULL && !verifications.isEmpty()){
                update verifications;
            }
            if(properties != NULL && !properties.isEmpty()){
                update properties;
            }
            if(capabilities != NULL && !capabilities.isEmpty()){
                for(Capability__c cap : capabilities){
                    Id rcId;
                    if(String.valueOf(cap.Id) == '1'){
                        cap.Id = rcId;
                    }
                }
                upsert capabilities;
            }
            if(enquiries != NULL && !enquiries.isEmpty()){
                for(CommonObject__c enq : enquiries){
                    Id rcId;
                    if(String.valueOf(enq.Id) == '1'){
                        enq.Id = rcId;
                    }
                }
                upsert enquiries;
            }

            Map<String, Object> characters = (Map<String, Object>)root.get('Character__c');
            List<Character__c> familtyDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Family Detail')), List<Character__c>.class);
            System.debug('familtyDetails = '+familtyDetails);
            if(familtyDetails != NULL && !familtyDetails.isEmpty()){
                for(Character__c chr : familtyDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert familtyDetails;
            }

            List<Character__c> neighbourInfo = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Neighbour Detail')), List<Character__c>.class);
            System.debug('neighbourInfo = '+neighbourInfo);
            if(neighbourInfo != NULL && !neighbourInfo.isEmpty()){
                for(Character__c chr : neighbourInfo){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert neighbourInfo;
            }

            List<Character__c> affiliationDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Affiliation Detail')), List<Character__c>.class);
            System.debug('affiliationDetails = '+affiliationDetails);
            if(affiliationDetails != NULL && !affiliationDetails.isEmpty()){
                for(Character__c chr : affiliationDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert affiliationDetails;
            }

            List<Character__c> livingDetails = (List<Character__c>)JSON.deserialize( JSON.serialize(characters.get('Living Standard Detail')), List<Character__c>.class);
            System.debug('livingDetails = '+livingDetails);
            if(livingDetails != NULL && !livingDetails.isEmpty()){
                for(Character__c chr : livingDetails){
                    Id rcId;
                    if(String.valueOf(chr.Id) == '1'){
                        chr.Id = rcId;
                    }
                }
                upsert livingDetails;
            }

            Map<String, Object> revisits = (Map<String, Object>)root.get('Revisit__c');
            List<Revisit__c> generalRevisits = (List<Revisit__c>)JSON.deserialize( JSON.serialize(revisits.get('General Revisit')), List<Revisit__c>.class);
            System.debug('generalRevisits = '+generalRevisits);
            if(generalRevisits != NULL && !generalRevisits.isEmpty()){
                for(Revisit__c rvst : generalRevisits){
                    Id rcId;
                    if(String.valueOf(rvst.Id) == '1'){
                        rvst.Id = rcId;
                    }
                }
                upsert generalRevisits;
            }

            List<Revisit__c> seniorRevisits = (List<Revisit__c>)JSON.deserialize( JSON.serialize(revisits.get('Senior Revisit')), List<Revisit__c>.class);
            System.debug('seniorRevisits = '+seniorRevisits);
            if(seniorRevisits != NULL && !seniorRevisits.isEmpty()){
                for(Revisit__c rvst : seniorRevisits){
                    Id rcId;
                    if(String.valueOf(rvst.Id) == '1'){
                        rvst.Id = rcId;
                    }
                }
                upsert seniorRevisits;
            }
            return 'success';
        } catch (Exception e) {
            System.debug('Errorr = '+e.getMessage() + ' = '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveAllRecordsLeadDetails(String jsonStr){
        try {
            //String jsonStr = '{"Application Information":{"Aplication Type":[],"Applicant Information":[{"Name":"k"},{"Name":"U"}],"Education":[],"Family":[],"Employment Details":[],"Income Details":[],"Bank Details":[],"Reference Details":[]},"Loan Details":{"Loan Type":[],"Property Details":[],"Property Boundaries":[],"Property Measurement":[],"Property Address":[],"Ownership Details":[]},"Sourcing Details":{"Application Details":[]}}';
            system.debug('saveAllRecordsLeadDetails jsonstr'+jsonStr);
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            System.debug('Root = '+root);
            Map<String, Object> applicationInformation = (Map<String, Object>)root.get('Application Information');
            Map<String, Object> loanDetails = (Map<String, Object>)root.get('Loan Details');
            Map<String, Object> sourcingDetails = (Map<String, Object>)root.get('Sourcing Details');
            System.debug('applicationInformation= '+applicationInformation);
            System.debug('loanDetails= '+loanDetails);
            System.debug('sourcingDetails= '+sourcingDetails);

            List<Application__c> applicationType = (List<Application__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Application Type')), List<Application__c>.class);
            System.debug('applicationType = '+applicationType);
            if(applicationType != NULL && !applicationType.isEmpty()){
                update applicationType;
            }

            // List<String> applicantInformation = (List<String>)applicationInformation.get('Applicant Information');
            List<Loan_Applicant__c> applicantInformation = (List<Loan_Applicant__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Applicant Information')), List<Loan_Applicant__c>.class);
            System.debug('applicantInformation = '+applicantInformation);
            if(applicantInformation != NULL && !applicantInformation.isEmpty()){
                update applicantInformation;
            }

            List<Account> accountInformation = (List<Account>)JSON.deserialize( JSON.serialize(applicationInformation.get('Customer Information')), List<Account>.class);
            System.debug('accountInformation = '+accountInformation);
            if(accountInformation != NULL && !accountInformation.isEmpty()){
                 update accountInformation;
            }

            List<Education__c> educationDetails = (List<Education__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Education')), List<Education__c>.class);
            System.debug('educationDetails = '+educationDetails);
            if(educationDetails != NULL && !educationDetails.isEmpty()){
                for(Education__c edu : educationDetails){
                    Id rcId;
                    if(String.valueOf(edu.Id) == '1'){
                        edu.Id = rcId;
                    }
                }
                upsert educationDetails;
            }
            List<Family_Detail__c> familyDetails = (List<Family_Detail__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Family')), List<Family_Detail__c>.class);
            System.debug('familyDetails = '+familyDetails);
            if(familyDetails != NULL && !familyDetails.isEmpty()){
                for(Family_Detail__c fam : familyDetails){
                    Id rcId;
                    if(String.valueOf(fam.Id) == '1'){
                        fam.Id = rcId;
                    }
                }
                upsert familyDetails;
            }
            List<Employment_Details__c> employmentDetails = (List<Employment_Details__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Employment Details')), List<Employment_Details__c>.class);
            System.debug('employmentDetails = '+employmentDetails);
            if(employmentDetails != NULL && !employmentDetails.isEmpty()){
                for(Employment_Details__c emp : employmentDetails){
                    Id rcId;
                    if(String.valueOf(emp.Id) == '1'){
                        emp.Id = rcId;
                    }
                }
                upsert employmentDetails;
            }
            List<Income__c> incomeDetails = (List<Income__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Income Details')), List<Income__c>.class);
            System.debug('incomeDetails = '+incomeDetails);
            if(incomeDetails != NULL && !incomeDetails.isEmpty()){
                for(Income__c income : incomeDetails){
                    Id rcId;
                    if(String.valueOf(income.Id) == '1'){
                        income.Id = rcId;
                    }
                }
                upsert incomeDetails;
            }
            List<Bank_Detail__c> bankDetails = (List<Bank_Detail__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Bank Details')), List<Bank_Detail__c>.class);
            System.debug('bankDetails = '+bankDetails);
            if(bankDetails != NULL && !bankDetails.isEmpty()){
                for(Bank_Detail__c bnk : bankDetails){
                    Id rcId;
                    if(String.valueOf(bnk.Id) == '1'){
                        bnk.Id = rcId;
                    }
                }
                upsert bankDetails;
            }
            List<Application__c> referenceDetail = (List<Application__c>)JSON.deserialize( JSON.serialize(applicationInformation.get('Reference Details')), List<Application__c>.class);
            System.debug('referenceDetail = '+referenceDetail);
            if(referenceDetail != NULL && !referenceDetail.isEmpty()){
                update referenceDetail;
            }

            List<Application__c> loanTypeDetail = (List<Application__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Loan Type')), List<Application__c>.class);
            System.debug('loanTypeDetail = '+loanTypeDetail);
            if(loanTypeDetail != NULL && !loanTypeDetail.isEmpty()){
                update loanTypeDetail;
            }
            List<Property__c> propertyDetails = (List<Property__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Property Details')), List<Property__c>.class);
            System.debug('propertyDetails = '+propertyDetails);
            if(propertyDetails != NULL && !propertyDetails.isEmpty()){
                update propertyDetails;
            }
            // List<Property__c> propertyBoundaries = (List<Property__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Property Boundaries')), List<Property__c>.class);
            // System.debug('propertyBoundaries = '+propertyBoundaries);
            // if(propertyBoundaries != NULL && !propertyBoundaries.isEmpty()){
            //     update propertyBoundaries;
            // }
            // List<Property__c> propertyMeasurement = (List<Property__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Property Measurement')), List<Property__c>.class);
            // System.debug('propertyMeasurement = '+propertyMeasurement);
            // if(propertyMeasurement != NULL && !propertyMeasurement.isEmpty()){
            //     update propertyMeasurement;
            // }
            // List<Property__c> propertyAddress = (List<Property__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Property Address')), List<Property__c>.class);
            // System.debug('propertyAddress = '+propertyAddress);
            // if(propertyAddress != NULL && !propertyAddress.isEmpty()){
            //     update propertyAddress;
            // }
            // List<Property__c> ownershipDetails = (List<Property__c>)JSON.deserialize( JSON.serialize(loanDetails.get('Ownership Details')), List<Property__c>.class);
            // System.debug('ownershipDetails = '+ownershipDetails);
            // if(ownershipDetails != NULL && !ownershipDetails.isEmpty()){
            //     update ownershipDetails;
            // }

            List<Application__c> applicationDetails = (List<Application__c>)JSON.deserialize( JSON.serialize(sourcingDetails.get('Application Details')), List<Application__c>.class);
            System.debug('applicationDetails = '+applicationDetails);
            if(applicationDetails != NULL && !applicationDetails.isEmpty()){
                update applicationDetails;
            }

            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class LeadDetailWrapper{
        @AuraEnabled public ApplicationInformation applicationInformation;
        @AuraEnabled public LoanDetails loanDetails;
        @AuraEnabled public SourcingDetails sourcingDetails;
    }

    public class ApplicationInformation{
        @AuraEnabled public List<Application__c> applicationType;
        @AuraEnabled public List<Loan_Applicant__c> applicantInformation;
        @AuraEnabled public List<Education__c> education;
        @AuraEnabled public List<Family_Detail__c> family;
        @AuraEnabled public List<Employment_Details__c> employmentDetails;
        @AuraEnabled public List<Income__c> incomeDetails;
        @AuraEnabled public List<Bank_Detail__c> bankDetails;
        @AuraEnabled public List<Application__c> referenceDetails;
    }
    public class LoanDetails{
        @AuraEnabled public List<Application__c> loanType;
        @AuraEnabled public List<Property__c> propertyDetails;
        @AuraEnabled public List<Property__c> propertyBoundaries;
        @AuraEnabled public List<Property__c> propertyMeasurement;
        @AuraEnabled public List<Property__c> propertyAddress;
        @AuraEnabled public List<Property__c> ownershipDetails;
    }

    public class SourcingDetails{
        @AuraEnabled public List<Application__c> applicationDetails;
    }
}