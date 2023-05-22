/**
* @author            : Ashish Sharma/Navin Soni
* @group             : TechMatrix Consulting
* @description       :
* @created on        : 27-08-2022
* @last modified on  : 27-08-2022
* @last modified by  : Ashish Sharma
**/
public class FS_LMS_BookLoanAPI {
    // FS_LMS_BookLoanAPI.createLoan('a030w000008HwIQAA0');
    // Created by Ashish Sharma 24/08/2022 for store Application detail
    public static Application__c applicationRecord;
    
    @auraenabled
    public static String createLoan( String applicationRecordId ) {
        String APIResponse = '';
        if (String.isNotBlank(applicationRecordId)) {
            
            List<Sobject> listSobject = new List<Sobject>();
            
            fetchApplicationDetails( applicationRecordId );
            String payload = generateRequestJson( applicationRecordId );
            System.debug('requestJson>>>');
            //System.debug(payload);
            //String testPayload = '{"acknowledgement":null,"payload":{"paymentReferences":[{"sourcePaymentReferenceNumber":20221118162331,"neoLmsPaymentReferenceId":19758680}],"repaymentSchedule":[{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":390192,"dueDate":"05/05/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":1,"interestComponent":0,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":0,"openingPrincipalBalance":400000,"principalComponent":9808,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":388363.43,"dueDate":"05/06/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":2,"interestComponent":7979.43,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":390192,"principalComponent":1828.57,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":386497.47,"dueDate":"05/07/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":3,"interestComponent":7942.04,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":388363.43,"principalComponent":1865.96,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":384593.35,"dueDate":"05/08/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":4,"interestComponent":7903.88,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":386497.47,"principalComponent":1904.12,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":382650.29,"dueDate":"05/09/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":5,"interestComponent":7864.94,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":384593.35,"principalComponent":1943.06,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":380667.49,"dueDate":"05/10/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":6,"interestComponent":7825.2,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":382650.29,"principalComponent":1982.8,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":378644.15,"dueDate":"05/11/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":7,"interestComponent":7784.66,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":380667.49,"principalComponent":2023.34,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":376579.43,"dueDate":"05/12/2022","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":8,"interestComponent":7743.28,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":378644.15,"principalComponent":2064.72,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":374472.48,"dueDate":"05/01/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":9,"interestComponent":7701.05,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":376579.43,"principalComponent":2106.95,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":372322.45,"dueDate":"05/02/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":10,"interestComponent":7657.97,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":374472.48,"principalComponent":2150.03,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":370128.45,"dueDate":"05/03/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":11,"interestComponent":7614,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":372322.45,"principalComponent":2194,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":367889.58,"dueDate":"05/04/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":12,"interestComponent":7569.13,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":370128.45,"principalComponent":2238.87,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":365604.93,"dueDate":"05/05/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":13,"interestComponent":7523.35,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":367889.58,"principalComponent":2284.65,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":363273.56,"dueDate":"05/06/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":14,"interestComponent":7476.63,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":365604.93,"principalComponent":2331.37,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":360894.51,"dueDate":"05/07/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":15,"interestComponent":7428.95,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":363273.56,"principalComponent":2379.05,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":358466.81,"dueDate":"05/08/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":16,"interestComponent":7380.3,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":360894.51,"principalComponent":2427.7,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":355989.46,"dueDate":"05/09/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":17,"interestComponent":7330.65,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":358466.81,"principalComponent":2477.35,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":353461.45,"dueDate":"05/10/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":18,"interestComponent":7279.99,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":355989.46,"principalComponent":2528.01,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":350881.74,"dueDate":"05/11/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":19,"interestComponent":7228.29,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":353461.45,"principalComponent":2579.71,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":348249.28,"dueDate":"05/12/2023","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":20,"interestComponent":7175.54,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":350881.74,"principalComponent":2632.46,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":345562.98,"dueDate":"05/01/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":21,"interestComponent":7121.7,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":348249.28,"principalComponent":2686.3,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":342821.75,"dueDate":"05/02/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":22,"interestComponent":7066.77,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":345562.98,"principalComponent":2741.23,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":340024.46,"dueDate":"05/03/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":23,"interestComponent":7010.71,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":342821.75,"principalComponent":2797.29,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":337169.97,"dueDate":"05/04/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":24,"interestComponent":6953.51,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":340024.46,"principalComponent":2854.49,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":334257.1,"dueDate":"05/05/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":25,"interestComponent":6895.13,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":337169.97,"principalComponent":2912.87,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":331284.66,"dueDate":"05/06/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":26,"interestComponent":6835.56,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":334257.1,"principalComponent":2972.44,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":328251.44,"dueDate":"05/07/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":27,"interestComponent":6774.78,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":331284.66,"principalComponent":3033.22,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":325156.19,"dueDate":"05/08/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":28,"interestComponent":6712.75,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":328251.44,"principalComponent":3095.25,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":321997.64,"dueDate":"05/09/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":29,"interestComponent":6649.45,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":325156.19,"principalComponent":3158.55,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":318774.5,"dueDate":"05/10/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":30,"interestComponent":6584.86,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":321997.64,"principalComponent":3223.14,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":315485.44,"dueDate":"05/11/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":31,"interestComponent":6518.94,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":318774.5,"principalComponent":3289.06,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":312129.12,"dueDate":"05/12/2024","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":32,"interestComponent":6451.68,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":315485.44,"principalComponent":3356.32,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":308704.17,"dueDate":"05/01/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":33,"interestComponent":6383.05,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":312129.12,"principalComponent":3424.95,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":305209.18,"dueDate":"05/02/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":34,"interestComponent":6313.01,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":308704.17,"principalComponent":3494.99,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":301642.71,"dueDate":"05/03/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":35,"interestComponent":6241.53,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":305209.18,"principalComponent":3566.47,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":298003.31,"dueDate":"05/04/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":36,"interestComponent":6168.6,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":301642.71,"principalComponent":3639.4,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":294289.48,"dueDate":"05/05/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":37,"interestComponent":6094.17,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":298003.31,"principalComponent":3713.83,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":290499.7,"dueDate":"05/06/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":38,"interestComponent":6018.22,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":294289.48,"principalComponent":3789.78,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":286632.42,"dueDate":"05/07/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":39,"interestComponent":5940.72,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":290499.7,"principalComponent":3867.28,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":282686.06,"dueDate":"05/08/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":40,"interestComponent":5861.64,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":286632.42,"principalComponent":3946.36,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":278658.99,"dueDate":"05/09/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":41,"interestComponent":5780.93,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":282686.06,"principalComponent":4027.07,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":274549.57,"dueDate":"05/10/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":42,"interestComponent":5698.58,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":278658.99,"principalComponent":4109.42,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":270356.11,"dueDate":"05/11/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":43,"interestComponent":5614.54,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":274549.57,"principalComponent":4193.46,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":266076.9,"dueDate":"05/12/2025","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":44,"interestComponent":5528.79,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":270356.11,"principalComponent":4279.21,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":261710.18,"dueDate":"05/01/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":45,"interestComponent":5441.28,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":266076.9,"principalComponent":4366.72,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":257254.16,"dueDate":"05/02/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":46,"interestComponent":5351.98,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":261710.18,"principalComponent":4456.02,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":252707.01,"dueDate":"05/03/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":47,"interestComponent":5260.85,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":257254.16,"principalComponent":4547.15,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":248066.87,"dueDate":"05/04/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":48,"interestComponent":5167.86,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":252707.01,"principalComponent":4640.14,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":243331.84,"dueDate":"05/05/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":49,"interestComponent":5072.97,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":248066.87,"principalComponent":4735.03,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":238499.98,"dueDate":"05/06/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":50,"interestComponent":4976.14,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":243331.84,"principalComponent":4831.86,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":233569.31,"dueDate":"05/07/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":51,"interestComponent":4877.33,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":238499.98,"principalComponent":4930.67,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":228537.81,"dueDate":"05/08/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":52,"interestComponent":4776.5,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":233569.31,"principalComponent":5031.5,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":223403.41,"dueDate":"05/09/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":53,"interestComponent":4673.6,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":228537.81,"principalComponent":5134.4,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":218164.01,"dueDate":"05/10/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":54,"interestComponent":4568.6,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":223403.41,"principalComponent":5239.4,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":212817.47,"dueDate":"05/11/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":55,"interestComponent":4461.46,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":218164.01,"principalComponent":5346.54,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":207361.59,"dueDate":"05/12/2026","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":56,"interestComponent":4352.12,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":212817.47,"principalComponent":5455.88,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":201794.14,"dueDate":"05/01/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":57,"interestComponent":4240.55,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":207361.59,"principalComponent":5567.45,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":196112.84,"dueDate":"05/02/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":58,"interestComponent":4126.7,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":201794.14,"principalComponent":5681.3,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":190315.35,"dueDate":"05/03/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":59,"interestComponent":4010.51,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":196112.84,"principalComponent":5797.49,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":184399.3,"dueDate":"05/04/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":60,"interestComponent":3891.95,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":190315.35,"principalComponent":5916.05,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":178362.27,"dueDate":"05/05/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":61,"interestComponent":3770.97,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":184399.3,"principalComponent":6037.03,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":172201.78,"dueDate":"05/06/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":62,"interestComponent":3647.51,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":178362.27,"principalComponent":6160.49,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":165915.31,"dueDate":"05/07/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":63,"interestComponent":3521.53,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":172201.78,"principalComponent":6286.47,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":159500.28,"dueDate":"05/08/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":64,"interestComponent":3392.97,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":165915.31,"principalComponent":6415.03,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":152954.07,"dueDate":"05/09/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":65,"interestComponent":3261.79,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":159500.28,"principalComponent":6546.21,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":146273.99,"dueDate":"05/10/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":66,"interestComponent":3127.92,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":152954.07,"principalComponent":6680.08,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":139457.3,"dueDate":"05/11/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":67,"interestComponent":2991.31,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":146273.99,"principalComponent":6816.69,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":132501.21,"dueDate":"05/12/2027","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":68,"interestComponent":2851.91,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":139457.3,"principalComponent":6956.09,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":125402.86,"dueDate":"05/01/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":69,"interestComponent":2709.65,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":132501.21,"principalComponent":7098.35,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":118159.35,"dueDate":"05/02/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":70,"interestComponent":2564.49,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":125402.86,"principalComponent":7243.51,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":110767.71,"dueDate":"05/03/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":71,"interestComponent":2416.36,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":118159.35,"principalComponent":7391.64,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":103224.91,"dueDate":"05/04/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":72,"interestComponent":2265.2,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":110767.71,"principalComponent":7542.8,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":95527.86,"dueDate":"05/05/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":73,"interestComponent":2110.95,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":103224.91,"principalComponent":7697.05,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":87673.41,"dueDate":"05/06/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":74,"interestComponent":1953.55,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":95527.86,"principalComponent":7854.45,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":79658.34,"dueDate":"05/07/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":75,"interestComponent":1792.93,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":87673.41,"principalComponent":8015.07,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":71479.36,"dueDate":"05/08/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":76,"interestComponent":1629.02,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":79658.34,"principalComponent":8178.98,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":63133.12,"dueDate":"05/09/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":77,"interestComponent":1461.76,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":71479.36,"principalComponent":8346.24,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":54616.2,"dueDate":"05/10/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":78,"interestComponent":1291.08,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":63133.12,"principalComponent":8516.92,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":45925.11,"dueDate":"05/11/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":79,"interestComponent":1116.91,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":54616.2,"principalComponent":8691.09,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":37056.28,"dueDate":"05/12/2028","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":80,"interestComponent":939.17,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":45925.11,"principalComponent":8868.83,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":28006.09,"dueDate":"05/01/2029","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":81,"interestComponent":757.81,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":37056.28,"principalComponent":9050.19,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":18770.82,"dueDate":"05/02/2029","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":82,"interestComponent":572.73,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":28006.09,"principalComponent":9235.27,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":9346.69,"dueDate":"05/03/2029","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9808,"installmentIndicatorFlag":null,"installmentNumber":83,"interestComponent":383.87,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":18770.82,"principalComponent":9424.13,"tdsAmount":null,"tdsRate":null},{"advanceOrPrepaymentInstallment":"Y","billFlag":"N","billedDate":null,"calculatedInterestAmount":null,"closingBalance":0,"dueDate":"05/04/2029","effectiveInterestRate":24.54,"emiPemiFlag":"E","installmentAmount":9537.83,"installmentIndicatorFlag":null,"installmentNumber":84,"interestComponent":191.14,"netEffectiveInstallmentAmt":null,"numberOfDaysBetweenInstallments":30,"openingPrincipalBalance":9346.69,"principalComponent":9346.69,"tdsAmount":null,"tdsRate":null}],"requestReference":"20221118162331","responseReference":"FSTNLALONS000005277670"},"responseCode":null,"responseString":null}';
 
            //'{ "requestHeader": { "tenantId": 505, "userDetail": { "userCode": "cas_it1", "branchId": 5000342 } }, "loanBookingRequest": { "loanDetail": { "tag": "LOAN", "loanRefId": "12324578", "requestChannelCode": "CAS", "applicationTypeCode": "NewApplication", "branchCode": "TN031", "agreementDate": "18/01/2020", "applicationCreationDate": "18/01/2020", "productCode": "FSBL_LAP", "schemeCode": "LAP_ML", "currencyCode": "INR", "applicationFileNumber": "7000005", "applicationFormNumber": "", "customerNo": "GLBCUST00000825547", "multipleDisbursalFlag": "S", "netMarkup": 1.0, "accountingIRR": 1, "loanAssetCost": "95000.0", "ltv": "85.0", "loanPurpose": "", "loanAmountWithoutVAP": 63000.0, "tdsFlag": "N", "frequencyOfRepaymentCode": "2", "rateEMIFlagCode": "", "installmentTypeCode": "11", "interestTypeCode": "1", "keyMemberIdentifier": "", "cashbackFlag": "N", "unitOfTenure": "3", "repaymentScheduleSpecificationDetail": { "dueDay": "5", "repaymentPolicyCode": "FSBL_LAP", "repaymentStartDate": "05/12/2021", "interestStartDate": "05/12/2021", "installmentTypeCode": "", "anchorTypeCode": "KIFS", "rateTypeCode": "1", "anchorRate": 11.75, "interestRate": 12.75, "installmentAmount": "0", "tenure": "60", "installmentAmountDrawnOnCode": "", "balloonAmount": "", "gradedBasedOnCode": "", "tieredRateType": "", "brokenPeriodDays": 0, "numberOfAdvanceInstallments": "" }, "loanDisbursalDetails": [ { "tag": "DISB", "loanRefId": "TW_2019_9749", "referenceSubKey1": "DISB0001", "referenceSubKey2": "", "disbursalNo": "1", "disbursalTransactionDate": "05/12/2020", "disbursalAmount": "63000.0", "disbursalDate": "05/12/2020", "principalRecoveryFlag": "1", "disbursalRemarks": "", "disbursalTypeCode": "", "referenceLoanAccountNumber": "339", "referenceHostSystemCode": "", "trancheId": "", "reviewedByURI": "40002104", "disbursalReference": "20199749", "createdByURI": "40064296", "disbursalBreakUpDetails": [ { "tag": "DISBBU", "loanRefId": "TW_2019_9749", "referenceSubKey1": "DISB0001", "referenceSubKey2": "DISBBU0001", "bpTypeCode": null, "bpCode": null, "disbursalAmount": "63000.0", "additionalPayableCharge": 123, "disbursalChargeAmount": 0, "creditDays": 1, "disbursalPaymentDetails": [ { "tag": "DISBPM", "loanRefId": "TW_2019_9749", "referenceSubKey1": "DISBBU0001", "referenceSubKey2": "", "paymentModeCode": "ELECTRONIC_FUND_TRANSFER", "subPaymentModeCode": "NEFT", "paymentAmount": "63000.0", "accountByName": "TVHJ A", "instrumentNumber": "", "sourcePaymentReferenceNumber": "2021021151362", "instrumentDate": "21/02/2022", "accountTypeCode": "CurrentAccount", "accountNumber": "67092247422", "bankIdentificationType": "IFSC_CODE_KEY", "bankIdentificationCode": "SBIN0017930", "bankBranchCode": "", "ignoreForDownload": null, "payoutBankId": 5000141, "paymentMethod": "O" } ] } ] } ], "imdDetails": [] }, "sourcingDetail": { "subsidyFlag": "N", "employeeNumber": "40071285", "employeeName": "40071285", "employeeContactNumber": "", "sourcingChannelCode": "BRANCH" } } }';
            if(String.isNotBlank(payload)) {
                try {
                    API_Handler__mdt objLMS_BookLoanAPI = API_Handler__mdt.getInstance('LMS_BookLoan');
                    if(objLMS_BookLoanAPI !=null && objLMS_BookLoanAPI.isActive__c) {
                        RequestHeader objRequestHeader = parseRequestHeader(objLMS_BookLoanAPI.HeaderParameters__c);
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(objLMS_BookLoanAPI.Endpoint__c);
                        request.setMethod(objLMS_BookLoanAPI.Method__c);
                        request.setHeader('Authorization', objRequestHeader.Authorization);
                        request.setHeader('CORRELATION-ID', objRequestHeader.CORRELATIONID);
                        request.setHeader('CLIENT-ID', objRequestHeader.CLIENTID);
                        request.setHeader('CLIENT-SECRET', objRequestHeader.CLIENTSECRET);
                        request.setHeader('Content-Type', objRequestHeader.ContentType);
                        request.setBody(payload);
                        request.setTimeout(120000);
                        
                        HttpResponse response = new HttpResponse();
                        if(!Test.isRunningTest()){
                            response = http.send(request);
                        }else{
                            response.setBody(objLMS_BookLoanAPI.Mock_Response__c);
                            //response.setBody(getMock());
                            response.setStatusCode(201);
                        }
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com'});
                        mail.setSubject('UAT LMS_BookLoanAPI');
                        mail.setPlainTextBody('Response Body '+ response.getBody() + '\n\nRequest Body '+ payload);
                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                        API_Logger__c objAPILogger = new API_Logger__c();
                        objAPILogger.Name = 'FS_LMS_BookLoanAPI';
                        objAPILogger.API_Name__c = 'FS_LMS_BookLoanAPI';
                        objAPILogger.Application__c = applicationRecordId;
                        objAPILogger.Status__c = response.getStatus();
                        objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                        objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                        objAPILogger.EndPoint__c = request.getEndpoint();
                        listSobject.add(objAPILogger);

                        if (response != null && response.getStatusCode() == 201) {
                            Map<String, Object> bookloanResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
                            System.debug('bookloanResponseMap'+ bookloanResponseMap);
                            
                            if(bookloanResponseMap != null && bookloanResponseMap.containsKey('payload') &&
                                bookloanResponseMap.get('payload') != null) {
                                    Map<String,Object> payloadMap = (Map<String,Object>) bookloanResponseMap.get('payload');
                                    if(payloadMap != null && payloadMap.containsKey('responseReference') &&
                                payloadMap.get('responseReference') != null) {
                                    system.debug('responseReference '+ String.valueOf(payloadMap.get('responseReference')));
                                        APIResponse = 'Success_For ' + String.valueOf(payloadMap.get('responseReference')) + ' Bookloan API Executed Successfully.!';
                                        listSobject.add( new Application__c( Id = applicationRecordId, LMS_Response_Reference__c = String.valueOf(payloadMap.get('responseReference'))));
                                    }
                            }
                        }
                        else {
                            system.debug('API exception '+response);
                            system.debug('API exception getStatusCode '+response.getStatusCode());
                            Error_Logger__c objErrorLog = new Error_Logger__c();
                            //objErrorLog.Exception_Message__c = e.getMessage();
                            objErrorLog.Name = 'FS_LMS_BookLoanAPI';
                            objErrorLog.Description__c = response.getBody().length() > 30068 ? response.getBody().substring(0, 30068) : response.getBody();
                            cls_errorClass objclserrorClass = parseError(response.getBody());
                            APIResponse = 'Error_For ' +objclserrorClass.error.description;
                            listSobject.add( objErrorLog ) ;
                        }                        
                    }
                }
                catch(System.CalloutException e) {
                    system.debug('CalloutException '+ e.getLineNumber() + ' - ' + e.getMessage());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    //objErrorLog.Exception_Message__c = e.getMessage();
                    objErrorLog.Name = 'FS_LMS_BookLoanAPI';
                    objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                    objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                    listSobject.add( objErrorLog );
                    APIResponse = 'Error_For '+ e.getMessage();
                }
                catch(Exception e) {
                    system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    //objErrorLog.Exception_Message__c = e.getMessage();
                    objErrorLog.Name = 'FS_LMS_BookLoanAPI';
                    objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                    objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                    listSobject.add( objErrorLog );
                    APIResponse = 'Error_For '+ e.getMessage();
                }
                if( !listSobject.isEmpty() ) {
                    upsert  listSobject;
                }
            }
        }
        else {
            System.debug('Application record id not available');
            APIResponse = 'Error_Application Record Id Not Available.';
            //throw exception application record id not available
        }
        return APIResponse;
    }
    
    // Created by Ashish Sharma 24/08/2022
    private static void fetchApplicationDetails(String recordId) {
        List<Application__c> applicationRecords = new List<Application__c>();
        applicationRecords = [SELECT Id, Name, CreatedDate, Effective_IRR__c, Tenor_In_Months__c,
                                Group_Valuation__c, Number_of_advance_EMI__c, Channel__c, Combined_LTV__c, Scheme__c,
                                Staff_Loan__c, Loan_Purpose_1__c, Alternate_Channel_Mode__c, Disbursal_Maker_Completion_Date__c,
                              	Disbursal_Author_Completion_Date__c, Disbursal_Date__c,
                                //-----Branch Details---------------
                                Sourcing_Branch__r.State__c,Sourcing_Branch__r.Branch_Code__c,Sourcing_Branch__r.Lms_Branch_Code__c,
                                //-------Disbursals Details---------
                                (SELECT Id, Interest_Start_Date__c, Due_Date__c, Sanctioned_Loan_Amount__c,
                                    Disbursal_Author_ID__c, Total_Deductions__c, Ops_Comment__c,
                                    Monthly_Installment_EMI_Rs__c, First_Installment_Date__c
                                    FROM Disbursals__r Order by CreatedDate desc),// LIMIT 1
                                //-------Loan Applicant Details---------
                                (SELECT Id, Customer_Type__c, LMS_Customer_Info_File_Number__c, Relationship_With_Main_Applicant__c
                                    FROM Loan_Applicants__r Order by CreatedDate asc),// LIMIT 1
                                //-------Verifications Details----------
                                (SELECT Id, TYPEOF Owner WHEN User THEN EmployeeNumber END
                                    FROM Verifications__r WHERE RecordType.Name = 'AC'),
                                //-------Property Details---------------
                                (SELECT Id, LMS_Collateral_Number__c, Property_Type__c, Property__c 
                                    FROM Properties__r WHERE RecordType.Name = 'Pre Login Property Detail'),// LIMIT 1
                                //-------Property Details---------------
                                (SELECT Id, Amount__c, Receipt_Id__c, Fee_Code__c, Fee_Code__r.Fee_Code__c, Fee_Code__r.Fee_Type_Master__c, 
                                        Fee_Code__r.Fee_Type_Master__r.Fee_Type_Code__c, Fee_Code__r.Fee_Type_Master__r.API_Charge_Code_Id__c
                                    FROM Receipts__r WHERE Approval_Status__c='Approved'),
                                //-------Fee_Creation Details---------------
                                (SELECT Id, Name, Repayment_Type_2__c , Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Fee_Type_Code__c,
                                Total_Fee__c, Fee_Type_Master__r.API_Charge_Code__c, Fee_Type_Master__r.API_Charge_Code_Id__c FROM Fee_Creations__r)
                                FROM Application__c WHERE Id =: recordId LIMIT 1];
        if (applicationRecords.size() > 0) {
            FS_LMS_BookLoanAPI.applicationRecord = applicationRecords.get(0);
        }
    }
    
    // Created by Ashish Sharma 24/08/2022
    public static String generateRequestJson(String applicationRecordId) {
        String requestJson = '';
        try {
            System.debug('generateRequestJson');
            String repaymentSchedulesJSON = FsRepaymentScheduleController.generateRepaymentSchedule(applicationRecordId);
            System.debug('repaymentSchedulesJSON '+ repaymentSchedulesJSON);
            List<WrapperEmi> repaymentSchedules = new List<WrapperEmi>();
            if(String.isNotBlank(repaymentSchedulesJSON)) {
                repaymentSchedules = parseRepaymentSchedules(repaymentSchedulesJSON);
            }
            
            System.debug('repaymentSchedules '+ repaymentSchedules);
            /*List<MS_Scheme__c> SchemeData = new List<MS_Scheme__c>();
            SchemeData = [SELECT Id, Scheme_Code__c FROM MS_Scheme__c];
            
            MS_Scheme__c SchemeRecord = new MS_Scheme__c();
            SchemeRecord = [SELECT Id, Scheme_Code__c FROM MS_Scheme__c 
                            WHERE Product_Name__c = 'FSBL LAP Business Loan' LIMIT 1];*/
            
            Map<String,String> LMSDefaultValuesMap = new Map<String,String>();

            for (Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'BookLoan']) {
                LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
            }


            String employeeNumber = '';
            if ( applicationRecord.Verifications__r != null && applicationRecord.Verifications__r.size() > 0 ) {
                for (Verification__c verification : applicationRecord.Verifications__r) {
                    String objType = verification.Owner.getSobjectType().getDescribe().getName();
                    if (objType == 'User') {
                        employeeNumber =(String) verification.Owner.get('EmployeeNumber');
                    }
                }
            }
            
            Disbursal__c disburalRecord; 
            Set<Id> disburalIds = new Set<Id>();
            if(applicationRecord.Disbursals__r != null && applicationRecord.Disbursals__r.size() > 0) {
                for(Disbursal__c disbural : applicationRecord.Disbursals__r) {
                    disburalIds.add(disbural.Id);
                    if(disburalRecord == null) {
                        disburalRecord = disbural;
                    }
                }
            }

            Map<Id, List<Disbursal_Payee__c>> disbursalPaymentMap = new Map<Id, List<Disbursal_Payee__c>>();
            for(Disbursal_Payee__c disbursalPayment : [SELECT Id, Payment_Type__c, Beneficiary_Amount__c, Beneficiary_IFSC_Code__c, 
                                        Beneficiary_Name__c, Disbursal__c, Beneficiary_Bank_Account_Number__c, Beneficiary_Account_Type__c
                                        FROM Disbursal_Payee__c WHERE Disbursal__c IN:disburalIds]) {
                                            if(!disbursalPaymentMap.containsKey(disbursalPayment.Disbursal__c)) {
                                                disbursalPaymentMap.put(disbursalPayment.Disbursal__c, new List<Disbursal_Payee__c>());
                                            }
                                            disbursalPaymentMap.get(disbursalPayment.Disbursal__c).add(disbursalPayment);
                                    }

            
            Set<Id> feeTypeMasterIds = new Set<Id>();
            Map<Id, String> feeTypeValueMasterMap = new Map<Id, String>();
            Set<Id> receiptIds = new Set<Id>();
            Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>();
            if(applicationRecord.Fee_Creations__r != null && applicationRecord.Fee_Creations__r.size() > 0) {
                for(Fee_Creation__c feeCreation : [SELECT Id,Fee_Type_Master__c,(SELECT Id,Fee_Code__c,Receipt_Date__c
                                                    FROM Receipts__r Order By CreatedDate desc LIMIT 1)
                                                    FROM Fee_Creation__c WHERE Id IN : applicationRecord.Fee_Creations__r]) {
                                                        System.debug('feeCreation------> '+feeCreation);
                    if(feeCreation.Receipts__r != null && feeCreation.Receipts__r.size() > 0) {
                        for(Receipt__c receipt : feeCreation.Receipts__r) {
                            if(!receiptMap.containsKey(receipt.Fee_Code__c)) {
                                receiptMap.put(receipt.Fee_Code__c, new Receipt__c());
                            }
                            receiptMap.put(receipt.Fee_Code__c,receipt);
                        }
                    }
                    if(feeCreation.Fee_Type_Master__c != null) {
                        feeTypeMasterIds.add(feeCreation.Fee_Type_Master__c);
                    }
                }
                //System.debug('feeTypeMasterIds---> '+ feeTypeMasterIds);
                if(feeTypeMasterIds.size() > 0)
                for(Fee_Value_Master__c feeValueMaster : [SELECT Id,Fee_Value_Code__c,Fee_Type_Master__c
                                                        FROM Fee_Value_Master__c WHERE Fee_Type_Master__c IN : feeTypeMasterIds]) {
                                                            //System.debug('feeValueMaster------> '+feeValueMaster);
                                                            if(String.isNotBlank(feeValueMaster.Fee_Value_Code__c)) {
                                                                feeTypeValueMasterMap.put(feeValueMaster.Fee_Type_Master__c,feeValueMaster.Fee_Value_Code__c);
                                                            }
                }
                //System.debug('feeTypeValueMasterMap---> '+ feeTypeValueMasterMap);
            }

            String uniqueValue = System.now().Year()+''+System.now().Month()+''+System.now().day()+''+System.now().hour()+''+System.now().Minute()+''+System.now().Second();
            String disbursalAuthorCompletionDate = generateDateFormat(applicationRecord.Disbursal_Author_Completion_Date__c);
            String loanAppId = applicationRecord.Name != null ? applicationRecord.Name.replace(' - ', 'T'):'';
            System.debug('loanAppId '+ loanAppId);
            requestJson = '{';
            requestJson += '"loanBookingRequest": {';
            requestJson +=   '"collateralDetails": [';
            //Iteration Start
            if(applicationRecord.Properties__r != null && applicationRecord.Properties__r.size() > 0) {
                for(Property__c propObj : applicationRecord.Properties__r) {
                    requestJson += '{';
                    requestJson += '"applicationFileNumber": "';
                    requestJson += loanAppId;
                    requestJson += '",';
                    requestJson += '"collateralMappingType": "';
                    requestJson += LMSDefaultValuesMap.get('collateralMappingType') !=null ? LMSDefaultValuesMap.get('collateralMappingType'):'';
                    requestJson += '",';
                    requestJson += '"collateralNumber": "';
                    requestJson += String.isNotBlank(propObj.LMS_Collateral_Number__c) ? propObj.LMS_Collateral_Number__c : '';
                    requestJson += '",';
                    requestJson += '"collateralSubTypeCode": "';
                    requestJson += String.isNotBlank(propObj.Property_Type__c) ? propObj.Property_Type__c : '';
                    requestJson += '",';
                    requestJson += '"collateralTypeCode": "';
                    requestJson += LMSDefaultValuesMap.get('collateralTypeCode') != null ? LMSDefaultValuesMap.get('collateralTypeCode') :'';
                    requestJson += '",';
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '"';
                    requestJson += '},';
                }
            	requestJson = requestJson.removeEnd(',');
            }
            //Iteration End
            requestJson += '],';
            
            requestJson += '"documentDetails": ';
            requestJson += 'null,';
            //todo no need to remove commented code because its provided as blank section
            /*requestJson += '[{';
            requestJson += '"documentReferenceNumber": "';
            requestJson += LMSDefaultValuesMap.get('documentReferenceNumber') != null ? 
                LMSDefaultValuesMap.get('documentReferenceNumber') :'';
            requestJson += '",';
            requestJson += '"documentStage": "';
            requestJson += LMSDefaultValuesMap.get('documentStage') != null ? LMSDefaultValuesMap.get('documentStage') :'';
            requestJson += '",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '}';
            requestJson += '],';*/
            
            requestJson += '"gurantorCoapplicantDetails": [';
            //Iteration Start
            if(applicationRecord.Loan_Applicants__r != null && applicationRecord.Loan_Applicants__r.size() > 0) {
                for(Loan_Applicant__c loanAppObj : applicationRecord.Loan_Applicants__r) {
                    if(String.isNotBlank(loanAppObj.Customer_Type__c) && loanAppObj.Customer_Type__c != 'Primary Applicant') {
                        requestJson += '{';
                        requestJson += '"applicationFileNumber": "'+ loanAppId +'",';
                        requestJson += '"customerNumber": "';
                        requestJson += loanAppObj.LMS_Customer_Info_File_Number__c !=null ? loanAppObj.LMS_Customer_Info_File_Number__c : '';
                        requestJson += '",';
                        requestJson += '"customerType": "';
                        requestJson += LMSDefaultValuesMap.get('customerType') !=null ? LMSDefaultValuesMap.get('customerType') : '';
                        requestJson += '",';
                        requestJson += '"loanRefId": "';
                        requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') : '';
                        requestJson += '",';
                        String partyRelationshipValue = loanAppObj.Relationship_With_Main_Applicant__c !=null ?
                                                loanAppObj.Relationship_With_Main_Applicant__c : '';
                        partyRelationshipValue = LMSDefaultValuesMap.get(partyRelationshipValue) != null ?
                                                    LMSDefaultValuesMap.get(partyRelationshipValue) : '';
                        requestJson += '"partyRelationship": "';
                        requestJson += partyRelationshipValue;
                        requestJson += '",';
                        String relationshipTypeValue = String.isNotBlank(loanAppObj.Customer_Type__c) ? loanAppObj.Customer_Type__c : '';
                        relationshipTypeValue = LMSDefaultValuesMap.get(relationshipTypeValue) != null ?
                                                    LMSDefaultValuesMap.get(relationshipTypeValue) : '';
                        requestJson += '"relationshipType": "';
                        requestJson += relationshipTypeValue;
                        requestJson += '"';
                        requestJson += '},';
                    }
                }
                requestJson = requestJson.removeEnd(',');
            }
            //Iteration End
            requestJson += ' ],';
            
            requestJson += '"loanDetail": {';
            requestJson += '"accountingIRR": ';
            requestJson += applicationRecord.Effective_IRR__c != null ? applicationRecord.Effective_IRR__c : 0;
            requestJson += ',';
            requestJson += '"agreementDate": "';
            requestJson += generateDateFormat(applicationRecord.Disbursal_Date__c);
            requestJson += '",';
            String applicationCreationDate = applicationRecord.CreatedDate != null ?
                                            applicationRecord.CreatedDate.Day() + '/' +
                                            applicationRecord.CreatedDate.Month() + '/' +
                                            applicationRecord.CreatedDate.Year() : '';
            requestJson += '"applicationCreationDate": "';
            requestJson += applicationCreationDate;
            requestJson += '",';
            requestJson += '"applicationFileNumber": "'+ loanAppId +'",';
            requestJson += '"applicationFormNumber": "';
            requestJson += LMSDefaultValuesMap.get('applicationFormNumber') != null ? LMSDefaultValuesMap.get('applicationFormNumber'): '';
            requestJson += '",';
            requestJson += '"applicationTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('applicationTypeCode') == null ? '':
                            LMSDefaultValuesMap.get('applicationTypeCode');
            requestJson += '",';
            requestJson += '"branchCode": "';
            requestJson += applicationRecord.Sourcing_Branch__r != null ? applicationRecord.Sourcing_Branch__r.Branch_Code__c != null ? 
                            applicationRecord.Sourcing_Branch__r.Branch_Code__c : '' : '';
            requestJson += '",';
            requestJson += '"brokenPeriodInterestChargeTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('brokenPeriodInterestChargeTypeCode') == null ? '' :
                            LMSDefaultValuesMap.get('brokenPeriodInterestChargeTypeCode');
            requestJson += '",';
            requestJson += '"cashbackFlag": "';
            requestJson += LMSDefaultValuesMap.get('cashbackFlag') != null ? LMSDefaultValuesMap.get('cashbackFlag') : '';
            requestJson += '",';
            requestJson += '"contractChargeDetails": ';
            requestJson += 'null,';
            //todo no need to remove code here because its provided as blank section
            /*requestJson += '[';
            if(applicationRecord.Fee_Creations__r.size() > 0) {
                for(Fee_Creation__c feeCrObj : applicationRecord.Fee_Creations__r) {
                    requestJson += '{';
                    requestJson += '"chargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('chargeAmount') != null ? LMSDefaultValuesMap.get('chargeAmount') : '';
                    requestJson += '",';
                    requestJson += '"chargeId": "';
                    requestJson += LMSDefaultValuesMap.get('chargeId') != null ? LMSDefaultValuesMap.get('chargeId') : '';
                    requestJson += '",';
                    requestJson += '"chargeRate": "';
                    requestJson += LMSDefaultValuesMap.get('chargeRate') != null ? LMSDefaultValuesMap.get('chargeRate') : '';
                    requestJson += '",';
                    requestJson += '"chargeSlabDetails": [{';
                    requestJson += '"chargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('chargeAmount') != null ? LMSDefaultValuesMap.get('chargeAmount') : '';
                    requestJson += '",';
                    requestJson += '"chargeCode": "';
                    requestJson += LMSDefaultValuesMap.get('chargeCode') != null ? LMSDefaultValuesMap.get('chargeCode') : '';
                    requestJson += '",';
                    requestJson += '"chargeNature": "';
                    requestJson += LMSDefaultValuesMap.get('chargeNature') != null ? LMSDefaultValuesMap.get('chargeNature') : '';
                    requestJson += '",';
                    requestJson += '"chargeRate": "';
                    requestJson += LMSDefaultValuesMap.get('chargeRate') != null ? LMSDefaultValuesMap.get('chargeRate') : '';
                    requestJson += '",';
                    requestJson += '"chargeSlabFrom": "';
                    requestJson += LMSDefaultValuesMap.get('chargeSlabFrom') != null ? LMSDefaultValuesMap.get('chargeSlabFrom') : '';
                    requestJson += '",';
                    requestJson += '"chargeSlabTo": "';
                    requestJson += LMSDefaultValuesMap.get('chargeSlabTo') != null ? LMSDefaultValuesMap.get('chargeSlabTo') : '';
                    requestJson += '",';
                    requestJson += '"chargeType": "';
                    requestJson += LMSDefaultValuesMap.get('chargeType') != null ? LMSDefaultValuesMap.get('chargeType') : '';
                    requestJson += '",';
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '",';
                    requestJson += '"maxChargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('maxChargeAmount') != null ? LMSDefaultValuesMap.get('maxChargeAmount') : '';
                    requestJson += '",';
                    requestJson += '"minChargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('minChargeAmount') != null ? LMSDefaultValuesMap.get('minChargeAmount') : '';
                    requestJson += '"';
                    requestJson += '}],';
                    requestJson += '"contractChargeType": "';
                    requestJson += LMSDefaultValuesMap.get('contractChargeType') != null ? LMSDefaultValuesMap.get('contractChargeType') : '';
                    requestJson += '",';
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '",';
                    requestJson += '"maxChargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('maxChargeAmount') != null ? LMSDefaultValuesMap.get('maxChargeAmount') : '';
                    requestJson += '",';
                    requestJson += '"minChargeAmount": "';
                    requestJson += LMSDefaultValuesMap.get('minChargeAmount') != null ? LMSDefaultValuesMap.get('minChargeAmount') : '';
                    requestJson += '",';
                    requestJson += '"remarks": "';
                    requestJson += LMSDefaultValuesMap.get('remarks') != null ? LMSDefaultValuesMap.get('remarks') : '';
                    requestJson += '",';
                    requestJson += '"transactionType": "';
                    requestJson += LMSDefaultValuesMap.get('transactionType') != null ? LMSDefaultValuesMap.get('transactionType') : '';
                    requestJson += '"';
                    requestJson += '},';
                }
                requestJson = requestJson.removeEnd(',');
            }
            requestJson += '],';*/
            requestJson += '"creditApproverName": "';
            requestJson += applicationRecord.Id;
            requestJson += '",';
            requestJson += '"creditDaysAdvancementFlag": "';
            requestJson += LMSDefaultValuesMap.get('creditDaysAdvancementFlag') == null ? '' :
            LMSDefaultValuesMap.get('creditDaysAdvancementFlag');
            requestJson += '",';
            requestJson += '"currencyCode": "';
            requestJson += LMSDefaultValuesMap.get('currencyCode') != null ? LMSDefaultValuesMap.get('currencyCode') : '';
            requestJson += '",';

            String loanApplicantCustomerNo = '';
            if(applicationRecord.Loan_Applicants__r != null && applicationRecord.Loan_Applicants__r.size() > 0) {
                for(Loan_Applicant__c loanApplicant : applicationRecord.Loan_Applicants__r) {
                    if(loanApplicant.Customer_Type__c == 'Primary Applicant' && String.isNotBlank(loanApplicant.LMS_Customer_Info_File_Number__c)) {
                        loanApplicantCustomerNo = loanApplicant.LMS_Customer_Info_File_Number__c;
                    }
                }
            }

            requestJson += '"customerNo": "';
            requestJson += String.isNotBlank(loanApplicantCustomerNo) ? loanApplicantCustomerNo : '';
            requestJson += '",';
            requestJson += '"depositLinkedAccount": "';
            requestJson += LMSDefaultValuesMap.get('depositLinkedAccount') == null ? '' :
                            LMSDefaultValuesMap.get('depositLinkedAccount');
            requestJson += '",';
            requestJson += '"disbursalChargeDetails": [';
            
            if(applicationRecord.Fee_Creations__r != null && applicationRecord.Fee_Creations__r.size() > 0) {
                for(Fee_Creation__c feeCrObj : applicationRecord.Fee_Creations__r) {
                    requestJson += '{';
                    If (feeCrObj.Repayment_Type_2__c == 'Deduct from Disbursement') {
                        requestJson += '"adjustChargeAtDisbursement": "Y",';
                    } else {
                        requestJson += '"adjustChargeAtDisbursement": "N",';
                    }
                    requestJson += '"bpCode": "';
                    requestJson += LMSDefaultValuesMap.get('bpCode') == null ? '' :
                    LMSDefaultValuesMap.get('bpCode');
                    requestJson += '",';
                    requestJson += '"chargeAmount": "';
                    requestJson += feeCrObj.Total_Fee__c != null ? String.valueOf(feeCrObj.Total_Fee__c) : '';
                    requestJson += '",';
                    requestJson += '"chargeCode": "';
                    requestJson += feeCrObj.Fee_Type_Master__r != null ? feeCrObj.Fee_Type_Master__r.API_Charge_Code__c != null ?
                                    feeCrObj.Fee_Type_Master__r.API_Charge_Code__c : '' : '';
                    requestJson += '",';
                    requestJson += '"chargeId": "';
                    requestJson += feeTypeValueMasterMap.containsKey(feeCrObj.Fee_Type_Master__c) ? 
                                    feeTypeValueMasterMap.get(feeCrObj.Fee_Type_Master__c) : '';
                    //requestJson += LMSDefaultValuesMap.get('chargeId') != null ? LMSDefaultValuesMap.get('chargeId') : '';
                    requestJson += '",';
                    /*requestJson += '"dueDate": "';
                    requestJson += LMSDefaultValuesMap.get('dueDate') != null ? LMSDefaultValuesMap.get('dueDate') : '';
                    requestJson += '",';*/
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '",';
                    requestJson += '"originalChargeAmount": "';
                    requestJson += feeCrObj.Total_Fee__c != null ? String.valueOf(feeCrObj.Total_Fee__c) :'';
                    requestJson += '",';                                                    
                    String transactionChargeDate = receiptMap != null ? receiptMap.containsKey(feeCrObj.Id) ?
                    generateDateFormat(receiptMap.get(feeCrObj.Id).Receipt_Date__c) : '': '';

                    requestJson += '"transactionChargeDate": "';
                    requestJson += feeCrObj.Repayment_Type_2__c == 'Deduct from Disbursement' ?
                                    generateDateFormat(applicationRecord.Disbursal_Date__c) : transactionChargeDate;
                    //requestJson += feeCrObj.Repayment_Type_2__c == 'Deduct from Disbursement' ?
                      //              disbursalAuthorCompletionDate : transactionChargeDate;
                    requestJson += '"';
                    requestJson += '},';
                }
            	requestJson = requestJson.removeEnd(',');
            }
            
            requestJson += '],';
            requestJson += '"educationDetail": null,';
            requestJson += '"existingMandateId": "';
            requestJson += LMSDefaultValuesMap.get('existingMandateId') != null ? LMSDefaultValuesMap.get('existingMandateId') :'';
            requestJson += '",';
            requestJson += '"financedAmount":';
            requestJson += disburalRecord != null ? disburalRecord.Sanctioned_Loan_Amount__c != null ?
                            String.valueOf(disburalRecord.Sanctioned_Loan_Amount__c):'0':'0';
            requestJson += ',';
            requestJson += '"frequencyOfRepaymentCode": "';
            requestJson += LMSDefaultValuesMap.get('frequencyOfRepaymentCode') != null ? LMSDefaultValuesMap.get('frequencyOfRepaymentCode'):'';
            requestJson += '",';
            requestJson += '"gradedSlabDetails": null,';
            requestJson += '"groupId": "';
            requestJson += LMSDefaultValuesMap.get('groupId') != null ? LMSDefaultValuesMap.get('groupId') :'';
            requestJson += '",';
            requestJson += '"gstDetail": {},';
            requestJson += '"gurantorCoapplicantDetails": ';
            requestJson += 'null,';
            //todo no need to remove commented code here provided blank section
            /*requestJson += '[';
            requestJson += '{';
            requestJson += '"customerNumber": "';
            requestJson += LMSDefaultValuesMap.get('customerNumber') != null ? LMSDefaultValuesMap.get('customerNumber') :'';
            requestJson += '",';
            requestJson += '"guarantorCoApplicantType": "';
            requestJson += LMSDefaultValuesMap.get('guarantorCoApplicantType') != null ? 
                            LMSDefaultValuesMap.get('guarantorCoApplicantType') :'';
            requestJson += '",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '}';
            requestJson += '],';*/
            requestJson += '"insuranceFundingDetails": null,';
            requestJson += '"interestTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('interestTypeCode') != null ? LMSDefaultValuesMap.get('interestTypeCode') : '';
            requestJson += '",';
            requestJson += '"irrDetails": [{';
            requestJson += '"inflow": ';
            requestJson += 'null,';
            //requestJson += LMSDefaultValuesMap.get('inflow') != null ? '"'+LMSDefaultValuesMap.get('inflow') :'';
            //requestJson += '",';
            requestJson += '"irrCode": "';
            requestJson += LMSDefaultValuesMap.get('irrCode') != null ? LMSDefaultValuesMap.get('irrCode') : '';
            requestJson += '",';
            requestJson += '"irrPercentage": ';
            requestJson += applicationRecord.Effective_IRR__c != null ? String.valueOf(applicationRecord.Effective_IRR__c) : '';
            requestJson += ',';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '",';
            requestJson += '"outflow": ';
            requestJson += 'null';
            //requestJson += LMSDefaultValuesMap.get('outflow') != null ? '"'+LMSDefaultValuesMap.get('outflow') :'';
            //requestJson += '"';
            requestJson += '}],';
            requestJson += '"keyMemberIdentifier": "';
            requestJson += LMSDefaultValuesMap.get('keyMemberIdentifier') != null ? LMSDefaultValuesMap.get('keyMemberIdentifier') :'';
            requestJson += '",';
            requestJson += '"limitReferenceNumber": "'+ loanAppId +'",';
            requestJson += '"linkingDetail": ';
            requestJson += 'null,';
            //todo no need to remove commented code here all values blank
            /*requestJson += '{';
            requestJson += '"applicationDetails": [{';
            requestJson += '"applicationFileNumber": "",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '}],';
            requestJson += '"collateralDetails": [{';
            requestJson += '"collateralNumber": "",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '}],';
            requestJson += '"linkingReason": "",';
            requestJson += '"linkingRemarks": "",';
            requestJson += '"loanDetails": [{';
            requestJson += '"loanAccountNumber": "",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '}],';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '"';
            requestJson += '},';*/
            /*requestJson += '"loanAccountNumber": "';
            requestJson += LMSDefaultValuesMap.get('loanAccountNumber') != null ? LMSDefaultValuesMap.get('loanAccountNumber') :'';
            requestJson += '",';*/
            requestJson += '"loanAmountWithoutVAP": ';
            requestJson += disburalRecord !=null ? disburalRecord.Sanctioned_Loan_Amount__c !=null ? 
                            String.valueOf(disburalRecord.Sanctioned_Loan_Amount__c) : '0': '0';
            requestJson += ',';
            requestJson += '"loanAssetCost": "';
            requestJson += applicationRecord.Group_Valuation__c != null ? String.valueOf(applicationRecord.Group_Valuation__c) :'';
            requestJson += '",';
            //Iteration start for disbursal
            requestJson += '"loanDisbursalDetails": [';
            if(applicationRecord.Disbursals__r != null && applicationRecord.Disbursals__r.size() > 0){
                for(Disbursal__c disbural : applicationRecord.Disbursals__r) {
                    requestJson += '{';
                    requestJson += '"disbursalAmount": "';
                    requestJson += disbural.Sanctioned_Loan_Amount__c !=null ? String.valueOf(disbural.Sanctioned_Loan_Amount__c):'';
                    requestJson += '",';
                    requestJson += '"disbursalAuthorName": "';
                    requestJson += disbural.Disbursal_Author_ID__c !=null ? disbural.Disbursal_Author_ID__c:'';
                    requestJson += '",';
                    requestJson += '"disbursalBreakUpDetails": [{';
                    requestJson += '"additionalPayableCharge": ';
                    requestJson += LMSDefaultValuesMap.get('additionalPayableCharge') == null ? '0' :
                                    LMSDefaultValuesMap.get('additionalPayableCharge');
                    requestJson += ',';
                    requestJson += '"bpCode": "';
                    requestJson += LMSDefaultValuesMap.get('bpCode') == null ? '' :
                    LMSDefaultValuesMap.get('bpCode');
                    requestJson += '",';
                    requestJson += '"bpTypeCode": "';
                    requestJson += LMSDefaultValuesMap.get('bpTypeCode') == null ? '' :
                    LMSDefaultValuesMap.get('bpTypeCode');
                    requestJson += '",';
                    requestJson += '"creditDays": ';
                    requestJson += LMSDefaultValuesMap.get('creditDays') == null ? '0' :
                                    LMSDefaultValuesMap.get('creditDays');
                    requestJson += ',';
                    requestJson += '"disbursalAmount": "';
                    requestJson += disbural.Sanctioned_Loan_Amount__c !=null ? String.valueOf(disbural.Sanctioned_Loan_Amount__c):'';
                    requestJson += '",';
                    requestJson += '"disbursalChargeAmount": ';
                    requestJson += disbural.Total_Deductions__c !=null ? String.valueOf(disbural.Total_Deductions__c): '0';
                    requestJson += ',';

                    
                    requestJson += '"disbursalPaymentDetails": [';
                    //Iteration Start for disbursal Payments
                    if(disbursalPaymentMap != null && disbursalPaymentMap.size() > 0 && disbursalPaymentMap.containsKey(disbural.Id)) {
                        for(Disbursal_Payee__c disbursalPayment : disbursalPaymentMap.get(disbural.Id)) {
                            requestJson += '{';
                            requestJson += '"accountByName": "';
                            requestJson += String.isNotBlank(disbursalPayment.Beneficiary_Name__c) ? disbursalPayment.Beneficiary_Name__c:'';
                            requestJson += '",';
                            requestJson += '"accountNumber": "';
                            requestJson += String.isNotBlank(disbursalPayment.Beneficiary_Bank_Account_Number__c) ?
                                            disbursalPayment.Beneficiary_Bank_Account_Number__c:'';
                            requestJson += '",';
                            String accountTypeCodeValue = String.isNotBlank(disbursalPayment.Beneficiary_Account_Type__c) ? disbursalPayment.Beneficiary_Account_Type__c:'';
                            accountTypeCodeValue = String.isNotBlank(accountTypeCodeValue) ?
                                LMSDefaultValuesMap.get(disbursalPayment.Beneficiary_Account_Type__c) != null ?
                                LMSDefaultValuesMap.get(disbursalPayment.Beneficiary_Account_Type__c) : '': '';
                            requestJson += '"accountTypeCode": "'+ accountTypeCodeValue + '",';
                            requestJson += '"bankBranchCode": "';
                            requestJson += LMSDefaultValuesMap.get('bankBranchCode') != null ? LMSDefaultValuesMap.get('bankBranchCode') :'';
                            requestJson += '",';
                            requestJson += '"bankIdentificationCode": "';
                            requestJson += String.isNotBlank(disbursalPayment.Beneficiary_IFSC_Code__c) ?
                                            disbursalPayment.Beneficiary_IFSC_Code__c : '';
                            requestJson += '",';
                            requestJson += '"bankIdentificationType": "';
                            requestJson += LMSDefaultValuesMap.get('bankIdentificationType') != null ?
                                            LMSDefaultValuesMap.get('bankIdentificationType') :'';
                            requestJson += '",';
                            requestJson += '"ignoreForDownload": "';
                            requestJson += LMSDefaultValuesMap.get('ignoreForDownload') == null ? '' :
                                            LMSDefaultValuesMap.get('ignoreForDownload');
                            requestJson += '",';
                            requestJson += '"instrumentDate": "';
                            requestJson += LMSDefaultValuesMap.get('instrumentDate') == null ? '' :
                                                LMSDefaultValuesMap.get('instrumentDate');
                            requestJson += '",';
                            requestJson += '"instrumentNumber": "';
                            requestJson += LMSDefaultValuesMap.get('instrumentNumber') == null ? '' :
                            LMSDefaultValuesMap.get('instrumentNumber');
                            requestJson += '",';
                            requestJson += '"loanRefId": "';
                            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                            requestJson += '",';
                            requestJson += '"paymentAmount": "';
                            requestJson += disbursalPayment.Beneficiary_Amount__c !=null ? String.valueOf(disbursalPayment.Beneficiary_Amount__c) : '';
                            requestJson += '",';
                            
                            String paymentModeCode = String.isNotBlank(disbursalPayment.Payment_Type__c) ?
                                                    LMSDefaultValuesMap.get(disbursalPayment.Payment_Type__c) != null ?
                                                    LMSDefaultValuesMap.get(disbursalPayment.Payment_Type__c) : '': '';

                            requestJson += '"paymentModeCode": "';
                            requestJson += paymentModeCode;
                            requestJson += '",';
                            requestJson += '"payoutbankId": ';
                            requestJson += LMSDefaultValuesMap.get('payoutbankId') != null ? LMSDefaultValuesMap.get('payoutbankId') :'0';
                            //requestJson += applicationRecord.Sourcing_Branch__r != null ? applicationRecord.Sourcing_Branch__r.Lms_Branch_Code__c != null ? 
                              //              applicationRecord.Sourcing_Branch__r.Lms_Branch_Code__c : '0' : '0';
                            requestJson += ',';
                            String sourcePaymentReferenceNumber = '';
                            String printingBranchCode = '';
                            if( String.isNotBlank(disbursalPayment.Payment_Type__c)) {
                                if( disbursalPayment.Payment_Type__c == 'Electronic Fund Transfer' ||
                                    disbursalPayment.Payment_Type__c == 'Cash' ) {
                                        sourcePaymentReferenceNumber = uniqueValue;
                                }
                                else if( disbursalPayment.Payment_Type__c == 'Cheque' ||
                                        disbursalPayment.Payment_Type__c == 'DD' ) {
                                        printingBranchCode = LMSDefaultValuesMap.get('printingBranchCode') != null ? LMSDefaultValuesMap.get('printingBranchCode') :'';
                                }
                            }

                            requestJson += '"printingBranchCode": "';
                            requestJson += printingBranchCode;
                            requestJson += '",';
                            requestJson += '"sourcePaymentReferenceNumber": "';
                            //requestJson += LMSDefaultValuesMap.get('sourcePaymentReferenceNumber') != null ? 
                              //              LMSDefaultValuesMap.get('sourcePaymentReferenceNumber') : '';
                            requestJson += sourcePaymentReferenceNumber;  
                            requestJson += '",';
                            requestJson += '"subPaymentModeCode": "';
                            requestJson += LMSDefaultValuesMap.get('subPaymentModeCode') != null ?
                                            LMSDefaultValuesMap.get('subPaymentModeCode') : '';
                            requestJson += '"';
                            requestJson += '},';
                            //Break;
                        }
                        requestJson = requestJson.removeEnd(',');
                    }
                    requestJson += '],';
                    //Iteration End
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '"';
                    requestJson += '}],';
                    requestJson += '"disbursalDate": "';
                    requestJson += generateDateFormat(applicationRecord.Disbursal_Date__c);
                    //requestJson += disbursalAuthorCompletionDate;
                    requestJson += '",';
                    requestJson += '"disbursalNo": "';
                    requestJson += LMSDefaultValuesMap.get('disbursalNo') != null ? LMSDefaultValuesMap.get('disbursalNo') :'';
                    requestJson += '",';
                    requestJson += '"disbursalRemarks": "';
                    requestJson += disbural.Ops_Comment__c != null ? disbural.Ops_Comment__c.contains('\n') ? disbural.Ops_Comment__c.replaceAll('\r\n',' ') : disbural.Ops_Comment__c: '';
                    requestJson += '",';
                    requestJson += '"disbursalTransactionDate": "';
                    requestJson += generateDateFormat(applicationRecord.Disbursal_Maker_Completion_Date__c);
                    requestJson += '",';
                    requestJson += '"disbursalTypeCode": "';
                    requestJson += LMSDefaultValuesMap.get('disbursalTypeCode') != null ? LMSDefaultValuesMap.get('disbursalTypeCode') :'';
                    requestJson += '",';
                    requestJson += '"imdDetails": [';
                    if(applicationRecord.Receipts__r != null && applicationRecord.Receipts__r.size() > 0) {
                		for(Receipt__c receipt : applicationRecord.Receipts__r) {
                            requestJson += '{';
                            requestJson += '"allocatedAmount": "';
                            requestJson += receipt.Amount__c != null ? String.valueOf(receipt.Amount__c) : '';
                            requestJson += '",';
                            requestJson += '"chargeCodeId": "';
                            requestJson += receipt.Fee_Code__r != null ? receipt.Fee_Code__r.Fee_Type_Master__c !=null ?
                                          receipt.Fee_Code__r.Fee_Type_Master__r.API_Charge_Code_Id__c : '' : '';
                            requestJson += '",';
                            requestJson += '"chargeId": "';
                            requestJson += feeTypeValueMasterMap.containsKey(receipt.Fee_Code__r.Fee_Type_Master__c) ? 
                                    feeTypeValueMasterMap.get(receipt.Fee_Code__r.Fee_Type_Master__c) : '';
                            //requestJson += LMSDefaultValuesMap.get('chargeId') != null ? LMSDefaultValuesMap.get('chargeId') : '';
                            requestJson += '",';
                            requestJson += '"loanRefId": "';
                            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                            requestJson += '",';
                            requestJson += '"receiptAmount": "';
                            requestJson += receipt.Amount__c != null ? String.valueOf(receipt.Amount__c) : '';
                            requestJson += '",';
                            requestJson += '"receiptReference": "';
                            requestJson += receipt.Receipt_Id__c != null ? String.valueOf(receipt.Receipt_Id__c) : '';
                            requestJson += '",';
                            requestJson += '"refundAmount": "';
                            requestJson += LMSDefaultValuesMap.get('refundAmount') != null ? LMSDefaultValuesMap.get('refundAmount') :'0';
                            requestJson += '"';
                            requestJson += '},';
                        }
                        requestJson = requestJson.removeEnd(',');
                    }
                    requestJson += '],';
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '",';
                    requestJson += '"principalRecoveryFlag": "';
                    requestJson += LMSDefaultValuesMap.get('principalRecoveryFlag') != null ? LMSDefaultValuesMap.get('principalRecoveryFlag') : '0';
                    requestJson += '",';
                    requestJson += '"referenceHostSystemCode": "';
                    requestJson += LMSDefaultValuesMap.get('referenceHostSystemCode') != null ? LMSDefaultValuesMap.get('referenceHostSystemCode') :'';
                    requestJson += '",';
                    requestJson += '"referenceLoanAccountNumber": "';
                    requestJson += LMSDefaultValuesMap.get('referenceLoanAccountNumber') != null ? 
                        LMSDefaultValuesMap.get('referenceLoanAccountNumber') :'';
                    requestJson += '",';
                    requestJson += '"shortFallAmount": "';
                    requestJson += LMSDefaultValuesMap.get('shortFallAmount') != null ? LMSDefaultValuesMap.get('shortFallAmount') :'';
                    requestJson += '",';
                    requestJson += '"totalWaiverAmount": "';
                    requestJson += LMSDefaultValuesMap.get('totalWaiverAmount') != null ? LMSDefaultValuesMap.get('totalWaiverAmount') :'';
                    requestJson += '",';
                    requestJson += '"trancheId": "';
                    requestJson += LMSDefaultValuesMap.get('trancheId') != null ? LMSDefaultValuesMap.get('trancheId') :'';
                    requestJson += '",';
                    requestJson += '"waiverApplied": ';
                    requestJson += 'null,';
                    /*requestJson += '[';
                    requestJson += '{';
                    requestJson += '"chargeCode": "';
                    requestJson += LMSDefaultValuesMap.get('chargeCode') != null ? LMSDefaultValuesMap.get('chargeCode') :'';
                    requestJson += '",';
                    requestJson += '"loanRefId": "';
                    requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                    requestJson += '",';
                    requestJson += '"waiverAmount": "';
                    requestJson += LMSDefaultValuesMap.get('waiverAmount') != null ? LMSDefaultValuesMap.get('waiverAmount') :'';
                    requestJson += '"';
                    requestJson += '}';
                    requestJson += '],';*/
                    requestJson += '"waiverApprovedBy": ';
                    //requestJson += LMSDefaultValuesMap.get('waiverApprovedBy') != null ? '"'+LMSDefaultValuesMap.get('waiverApprovedBy') :'';
                    requestJson += 'null';
                    //requestJson += '"';
                    requestJson += '},';
                }
                requestJson = requestJson.removeEnd(',');
            }
            requestJson += '],';
            //Iteration End
            
            requestJson += '"loanRefId": "';
            requestJson += uniqueValue;
            requestJson += '",';
            requestJson += '"ltv": "';
            requestJson += applicationRecord.Combined_LTV__c == null ? '': String.valueOf(applicationRecord.Combined_LTV__c);
            requestJson += '",';
            requestJson += '"maturityOnInterestStartDueDay": "';
            requestJson += LMSDefaultValuesMap.get('maturityOnInterestStartDueDay') != null ? 
                LMSDefaultValuesMap.get('maturityOnInterestStartDueDay') :'';
            requestJson += '",';
            requestJson += '"moratoriumPeriod": "';
            requestJson += LMSDefaultValuesMap.get('moratoriumPeriod') != null ? LMSDefaultValuesMap.get('moratoriumPeriod') :'';
            requestJson += '",';
            requestJson += '"moratoriumTreatmentTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('moratoriumTreatmentTypeCode') != null ? 
                LMSDefaultValuesMap.get('moratoriumTreatmentTypeCode') :'';
            requestJson += '",';
            requestJson += '"multipleDisbursalFlag": "';
            requestJson += LMSDefaultValuesMap.get('multipleDisbursalFlag') != null ? LMSDefaultValuesMap.get('multipleDisbursalFlag') :'';
            requestJson += '",';
            String netMarkup = applicationRecord.Effective_IRR__c != null ? String.valueOf(applicationRecord.Effective_IRR__c - 
                                Decimal.valueOf(LMSDefaultValuesMap.get('anchorRate'))):'0';
            requestJson += '"netMarkup": ';
            requestJson += netMarkup;
            //requestJson += LMSDefaultValuesMap.get('netMarkup') != null ? LMSDefaultValuesMap.get('netMarkup') :'0';
            requestJson += ',';
            requestJson += '"noteCodeDetails": null,';
            requestJson += '"productCode": "';
            requestJson += LMSDefaultValuesMap.get('productCode') != null ? LMSDefaultValuesMap.get('productCode') :'';
            requestJson += '",';
            requestJson += '"promotionCode1": "';
            requestJson += LMSDefaultValuesMap.get('promotionCode1') != null ? LMSDefaultValuesMap.get('promotionCode1') :'';
            requestJson += '",';
            requestJson += '"promotionCode2": "';
            requestJson += LMSDefaultValuesMap.get('promotionCode2') != null ? LMSDefaultValuesMap.get('promotionCode2') :'';
            requestJson += '",';
            requestJson += '"promotionCode3": "';
            requestJson += LMSDefaultValuesMap.get('promotionCode3') != null ? LMSDefaultValuesMap.get('promotionCode3') :'';
            requestJson += '",';
            requestJson += '"rateEMIFlagCode": "",';
            requestJson += '"rateTierDetails": ';
            requestJson += 'null,';
            /*requestJson += '[';
            requestJson += '{';
            requestJson += '"fromInstallmentNo": "';
            requestJson += LMSDefaultValuesMap.get('fromInstallmentNo') != null ? LMSDefaultValuesMap.get('fromInstallmentNo') :'';
            requestJson += '",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '",';
            requestJson += '"netMarkup": "';
            requestJson += LMSDefaultValuesMap.get('netMarkup') != null ? LMSDefaultValuesMap.get('netMarkup') :'';
            requestJson += '",';
            requestJson += '"ratePercentage": "';
            requestJson += LMSDefaultValuesMap.get('ratePercentage') != null ? LMSDefaultValuesMap.get('ratePercentage') :'';
            requestJson += '",';
            requestJson += '"rateTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('rateTypeCode') != null ? LMSDefaultValuesMap.get('rateTypeCode') :'';
            requestJson += '",';
            requestJson += '"toInstallmentNo": "';
            requestJson += LMSDefaultValuesMap.get('toInstallmentNo') != null ? LMSDefaultValuesMap.get('toInstallmentNo') :'';
            requestJson += '"';
            requestJson += '}';
            requestJson += '],';*/
            requestJson += '"recoverySubTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('recoverySubTypeCode') != null ?
                LMSDefaultValuesMap.get('recoverySubTypeCode') :'';
            requestJson += '",';
            requestJson += '"refundDetails": {},';
            requestJson += '"renewalCounter": "';
            requestJson += LMSDefaultValuesMap.get('renewalCounter') != null ? LMSDefaultValuesMap.get('renewalCounter') :'';
            requestJson += '",';
            requestJson += '"renewalInitiatedBy": "';
            requestJson += LMSDefaultValuesMap.get('renewalInitiatedBy') != null ? LMSDefaultValuesMap.get('renewalInitiatedBy') :'';
            requestJson += '",';
            requestJson += '"repaymentScheduleSpecificationDetail": {';
            requestJson += '"anchorRate": ';
            requestJson += LMSDefaultValuesMap.get('anchorRate') != null ? LMSDefaultValuesMap.get('anchorRate') :'0';
            requestJson += ',';
            requestJson += '"balloonAmount": "';
            requestJson += LMSDefaultValuesMap.get('balloonAmount') != null ? LMSDefaultValuesMap.get('balloonAmount') :'';
            requestJson += '",';
            requestJson += '"brokenPeriodDays": ';
            requestJson += LMSDefaultValuesMap.get('brokenPeriodDays') != null ? LMSDefaultValuesMap.get('brokenPeriodDays') :'0';
            requestJson += ',';
            requestJson += '"dueDay": "';
            requestJson += disburalRecord != null ? disburalRecord.Due_Date__c != null ? String.valueOf(disburalRecord.Due_Date__c.day()):'':'';
            requestJson += '",';
            requestJson += '"gradedBasedOnCode": "';
            requestJson += LMSDefaultValuesMap.get('gradedBasedOnCode') != null ? LMSDefaultValuesMap.get('gradedBasedOnCode') :'';
            requestJson += '",';
            requestJson += '"installmentAmount": "';
            requestJson += LMSDefaultValuesMap.get('installmentAmount') != null ? LMSDefaultValuesMap.get('installmentAmount') :'';
            //requestJson += disburalRecord !=null ? disburalRecord.Monthly_Installment_EMI_Rs__c !=null ? 
              //              String.valueOf(disburalRecord.Monthly_Installment_EMI_Rs__c):'':'';
            requestJson += '",';
            requestJson += '"installmentAmountDrawnOnCode": "';
            requestJson += LMSDefaultValuesMap.get('installmentAmountDrawnOnCode') != null ? 
                LMSDefaultValuesMap.get('installmentAmountDrawnOnCode') :'';
            requestJson += '",';
            requestJson += '"installmentTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('installmentTypeCode') != null ? LMSDefaultValuesMap.get('installmentTypeCode') :'';
            requestJson += '",';
            requestJson += '"interestFreeDays": "';
            requestJson += LMSDefaultValuesMap.get('interestFreeDays') != null ? LMSDefaultValuesMap.get('interestFreeDays') :'';
            requestJson += '",';
            requestJson += '"interestRate": ';
            requestJson += applicationRecord.Effective_IRR__c != null ? String.valueOf(applicationRecord.Effective_IRR__c) : '0';
            requestJson += ',';
            requestJson += '"interestStartDate": "';
            requestJson += disburalRecord !=null ? generateDateFormat(disburalRecord.Interest_Start_Date__c) : '';
            requestJson += '",';
            requestJson += '"numberOfAdvanceInstallments": "';
            //requestJson += LMSDefaultValuesMap.get('numberOfAdvanceInstallments') != null ? LMSDefaultValuesMap.get('numberOfAdvanceInstallments') :'';
            requestJson += applicationRecord.Number_of_advance_EMI__c != null ? applicationRecord.Number_of_advance_EMI__c : '';
            requestJson += '",';
            requestJson += '"repaymentPolicyCode": "';
            requestJson += LMSDefaultValuesMap.get('repaymentPolicyCode') != null ? LMSDefaultValuesMap.get('repaymentPolicyCode') :'';
            requestJson += '",';
            requestJson += '"repaymentStartDate": "';
            requestJson += disburalRecord !=null ? generateDateFormat(disburalRecord.First_Installment_Date__c) : '';
            requestJson += '",';
            requestJson += '"tenure": "';
            requestJson += applicationRecord.Tenor_In_Months__c != null ? applicationRecord.Tenor_In_Months__c : '';
            requestJson += '",';
            requestJson += '"installmentMode": "';
            requestJson += LMSDefaultValuesMap.get('installmentMode') != null ? LMSDefaultValuesMap.get('installmentMode') :'';
            requestJson += '"},';
            
            requestJson += '"repaymentSchedules": [';

            //add iteration for repaymentSchedules
            //Iteration Start
       		if(repaymentSchedules != null && repaymentSchedules.size() > 0)
            for(WrapperEmi repaymentSchedule: repaymentSchedules) {
                requestJson += '{';
                requestJson += '"advanceOrPrepaymentInstallment": "';
                requestJson += repaymentSchedule.isAdvEMI == false ? 'Y' : 'N';
                requestJson += '",';
                requestJson += '"calculatedInterestAmount": "';
                requestJson += LMSDefaultValuesMap.get('calculatedInterestAmount') != null ? 
                                LMSDefaultValuesMap.get('calculatedInterestAmount') :'';
                requestJson += '",';
                requestJson += '"dueDate": "';
                requestJson += repaymentSchedule.cycleDate;
                requestJson += '",';
                requestJson += '"effectiveInterestRate": "';
                requestJson += applicationRecord.Effective_IRR__c != null ? String.valueOf(applicationRecord.Effective_IRR__c) : '';
                requestJson += '",';
                requestJson += '"emiPEMIFlag": "';
                requestJson += LMSDefaultValuesMap.get('emiPEMIFlag') != null ? LMSDefaultValuesMap.get('emiPEMIFlag') :'';
                requestJson += '",';
                requestJson += '"installmentIndicator": "';
                requestJson += LMSDefaultValuesMap.get('installmentIndicator') != null ? LMSDefaultValuesMap.get('installmentIndicator') :'';
                requestJson += '",';
                requestJson += '"installmentNumber": "';
                requestJson += repaymentSchedule.month != null ? String.valueOf(repaymentSchedule.month) : '';
                requestJson += '",';
                requestJson += '"interestComponent": "';
                requestJson += repaymentSchedule.interest != null ? String.valueOf(repaymentSchedule.interest) : '';
                requestJson += '",';
                requestJson += '"loanRefId": "';
                requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
                requestJson += '",';
                requestJson += '"principalComponent": "';
                requestJson += repaymentSchedule.principle != null ? String.valueOf(repaymentSchedule.principle) : '';
                requestJson += '",';
                requestJson += '"tdsAmount": "';
                requestJson += LMSDefaultValuesMap.get('tdsAmount') != null ? LMSDefaultValuesMap.get('tdsAmount') :'';
                requestJson += '",';
                requestJson += '"tdsRate": "';
                requestJson += LMSDefaultValuesMap.get('tdsRate') != null ? LMSDefaultValuesMap.get('tdsRate') :'';
                requestJson += '"';
                requestJson += '},';
            }
            //Iteration End
            
            requestJson = requestJson.removeEnd(',');
            requestJson += '],';

            //requestJson += '}],';
            requestJson += '"requestChannelCode": "';
            requestJson += LMSDefaultValuesMap.get('requestChannelCode') != null ? LMSDefaultValuesMap.get('requestChannelCode') :'';
            requestJson += '",';
            String schemeCode = String.isNotBlank(applicationRecord.Scheme__c) ? applicationRecord.Scheme__c : '';
            requestJson += '"schemeCode": "';
            //requestJson += LMSDefaultValuesMap.get('schemeCode') != null ? LMSDefaultValuesMap.get('schemeCode') :'';
            requestJson += LMSDefaultValuesMap.get(schemeCode) != null ? LMSDefaultValuesMap.get(schemeCode) :'';
            requestJson += '",';
            requestJson += '"staffLoanFlag": "';
            requestJson += applicationRecord.Staff_Loan__c == true ? 'Y' : 'N';
            requestJson += '",';
            requestJson += '"subsidyFlag": "';
            requestJson += LMSDefaultValuesMap.get('subsidyFlag') != null ? LMSDefaultValuesMap.get('subsidyFlag') :'';
            requestJson += '",';
            requestJson += '"subsidyLockInPeriod": "';
            requestJson += LMSDefaultValuesMap.get('subsidyLockInPeriod') != null ? LMSDefaultValuesMap.get('subsidyLockInPeriod') :'';
            requestJson += '",';
            requestJson += '"subsidyTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('subsidyTypeCode') != null ? LMSDefaultValuesMap.get('subsidyTypeCode') :'';
            requestJson += '",';
            requestJson += '"subventionDetails": null,';
            requestJson += '"tdsEffectiveFromDate": '+ null;
            requestJson += ',';
            requestJson += '"tdsFlag": "';
            requestJson += LMSDefaultValuesMap.get('tdsFlag') != null ? LMSDefaultValuesMap.get('tdsFlag') :'';
            requestJson += '",';
            requestJson += '"tdsPolicyCode": "';
            requestJson += LMSDefaultValuesMap.get('tdsPolicyCode') != null ? LMSDefaultValuesMap.get('tdsPolicyCode') :'';
            requestJson += '",';
            requestJson += '"totalVAPAmount": "';
            requestJson += LMSDefaultValuesMap.get('totalVAPAmount') != null ? LMSDefaultValuesMap.get('totalVAPAmount') :'';
            requestJson += '",';
            requestJson += '"transferType": "';
            requestJson += LMSDefaultValuesMap.get('transferType') != null ? LMSDefaultValuesMap.get('transferType') :'';
            requestJson += '",';
            requestJson += '"unitOfTenure": "';
            requestJson += LMSDefaultValuesMap.get('unitOfTenure') != null ? LMSDefaultValuesMap.get('unitOfTenure') :'';
            requestJson += '",';
            requestJson += '"vapDetailsUpload": null';
            requestJson += '},';
            
            requestJson += '"sourcingDetail": {';
            requestJson += '"alternateChannelModeCode": "';
            requestJson += applicationRecord.Alternate_Channel_Mode__c != null ? applicationRecord.Alternate_Channel_Mode__c : '';
            requestJson += '",';
            requestJson += '"dSACode": "';
            requestJson += LMSDefaultValuesMap.get('dSACode') != null ? LMSDefaultValuesMap.get('dSACode') :'';
            requestJson += '",';
            requestJson += '"dsaName": "';
            requestJson += LMSDefaultValuesMap.get('dsaName') != null ? LMSDefaultValuesMap.get('dsaName') :'';
            requestJson += '",';
            requestJson += '"dseCode": "';
            requestJson += LMSDefaultValuesMap.get('dseCode') != null ? LMSDefaultValuesMap.get('dseCode') :'';
            requestJson += '",';
            requestJson += '"employeeContactNumber": "';
            requestJson += LMSDefaultValuesMap.get('employeeContactNumber') != null ? LMSDefaultValuesMap.get('employeeContactNumber') :'';
            requestJson += '",';
            requestJson += '"employeeName": "';
            requestJson += LMSDefaultValuesMap.get('employeeName') != null ? LMSDefaultValuesMap.get('employeeName') :'';
            requestJson += '",';
            requestJson += '"employeeNumber": "';
            requestJson += LMSDefaultValuesMap.get('employeeNumber') != null ? LMSDefaultValuesMap.get('employeeNumber') :'';
            requestJson += '",';
            requestJson += '"loanPurpose": "';
            requestJson += applicationRecord.Loan_Purpose_1__c != null ? applicationRecord.Loan_Purpose_1__c :'';
            requestJson += '",';
            requestJson += '"loanPurposeRemarks": "';
            requestJson += LMSDefaultValuesMap.get('loanPurposeRemarks') != null ? LMSDefaultValuesMap.get('loanPurposeRemarks') :'';
            requestJson += '",';
            requestJson += '"loanRefId": "';
            requestJson += LMSDefaultValuesMap.get('loanRefId') != null ? LMSDefaultValuesMap.get('loanRefId') :'';
            requestJson += '",';
            requestJson += '"reportingManagerName": "';
            requestJson += LMSDefaultValuesMap.get('reportingManagerName') != null ? LMSDefaultValuesMap.get('reportingManagerName') :'';
            requestJson += '",';
            requestJson += '"reportingSupervisorName": "';
            requestJson += LMSDefaultValuesMap.get('reportingSupervisorName') != null ? LMSDefaultValuesMap.get('reportingSupervisorName') :'';
            requestJson += '",';
            requestJson += '"sourcingBranchCode": "';
            requestJson += applicationRecord.Sourcing_Branch__r == null ? '' : applicationRecord.Sourcing_Branch__r.Branch_Code__c == null ? '':
                            applicationRecord.Sourcing_Branch__r.Branch_Code__c;
            requestJson += '",';
            String sourcingChannelCode = String.isNotBlank(applicationRecord.Channel__c) ?
                                        LMSDefaultValuesMap.get(applicationRecord.Channel__c) != null ?
                                        LMSDefaultValuesMap.get(applicationRecord.Channel__c) : '': '';
            requestJson += '"sourcingChannelCode": "';
            requestJson += sourcingChannelCode;
            requestJson += '",';
            requestJson += '"subsidyFlag": "';
            requestJson += LMSDefaultValuesMap.get('subsidyFlag') != null ? LMSDefaultValuesMap.get('subsidyFlag') :'';
            requestJson += '"';
            requestJson += '}';
            requestJson += '},';
            requestJson += '"requestHeader": {';
            requestJson += '"tenantId": ';
            requestJson += LMSDefaultValuesMap.get('tenantId') != null ? LMSDefaultValuesMap.get('tenantId') :'0';
            requestJson += ',';
            requestJson += '"userDetail": {';
            requestJson += '"branchId": ';
            requestJson += applicationRecord.Sourcing_Branch__r != null ? applicationRecord.Sourcing_Branch__r.Lms_Branch_Code__c != null ? 
                            applicationRecord.Sourcing_Branch__r.Lms_Branch_Code__c : '0' : '0';
            requestJson += ',';
            requestJson += '"userCode": "';
            requestJson += LMSDefaultValuesMap.get('userCode') != null ? LMSDefaultValuesMap.get('userCode') :'';
            requestJson += '"';
            requestJson += '}}}';
            
        }
        catch(Exception e){
            System.debug( e.getMessage()+' Line No. : '+e.getLineNumber() );
            throw new CalloutException( e.getMessage()+' Line No. : '+ e.getLineNumber() );
        }
        return requestJson;
    }
    
    public static String generateDateFormat(Date dateValue) {
        if(dateValue != null ) {
            return dateValue.Day() +'/'+ dateValue.Month() +'/'+ dateValue.Year();
        }
        return '';
    }

    public class cls_errorClass{
        public cls_error error;
    }

    public class cls_error {
		public String source;	//Portal
		public String target;	//LMS
		public String errorCode;	//500
		public String message;	//Internal Server Error
		public String description;	// internal server error (500).
		public String timestamp;	//2022-10-07 05:29:13+0000
	}
	public static cls_errorClass parseError(String json){
		return (cls_errorClass) System.JSON.deserialize(json, cls_errorClass.class);
	}

    /*public class RepaymentSchedule {
        public Integer installmentNumber;
        public Integer installmentAmount;
        public Integer openingPrincipalBalance;
        public Double principalComponent;
        public Double interestComponent;
        public Double closingBalance;
        public Double effectiveInterestRate;
        public Integer numberOfDaysBetweenInstallments;
        public String advanceOrPrepaymentInstallment;
        public String dueDate;
        public String emiPEMIFlag;
        public Object tdsRate;
        public Object tdsAmount;
        public Object netEffectiveInstallmentAmt;
        public Object installmentIndicatorFlag;
        public Object calculatedInterestAmount;
        public String billFlag;
        public Object billedDate;
    }
    
    public Object acknowledgement;
    public Object responseCode;
    public Object responseString;
    public Payload payload;
    
    public class Payload {
        public String requestReference;
        public String responseReference;
        public Object paymentReferences;
        public List<RepaymentSchedule> repaymentSchedule;
    }
    
    public static FS_LMS_BookLoanAPI parse(String json) {
        return (FS_LMS_BookLoanAPI) System.JSON.deserialize(json, FS_LMS_BookLoanAPI.class);
    }*/
    
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
    
    public static List<WrapperEmi> parseRepaymentSchedules(String json) {
        return (List<WrapperEmi>) System.JSON.deserialize(json, List<WrapperEmi>.class);
    }
    
    public class RequestHeader {
        public String Authorization;	//Basic YWRtaW46YWRtaW4=
        public String CORRELATIONID;	//123456789
        public String CLIENTID;	//78g659ed2a0dfa2b
        public String CLIENTSECRET;	//f56f68b65739bd8a
        public String ContentType;	//application/json
    }
	public static RequestHeader parseRequestHeader(String json) {
		return (RequestHeader) System.JSON.deserialize(json, RequestHeader.class);
	}
}