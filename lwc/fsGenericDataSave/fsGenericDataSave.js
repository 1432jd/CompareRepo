export var pc_data_template = {
    "Character": {
        "Family Detail": [],
        "Neighbour Detail": [],
        "Affiliation Detail": [],
        "Living Standard Detail": []
    },
    "Capability": [],
    "Collateral": [],
    "Financial": [],
    "Decision": []
};


export var ac_data_template = {
    "Character": {
        "Family Detail": [],
        "Neighbour Detail": [],
        "Affiliation Detail": [],
        "Living Standard Detail": [],
        "Repayment_Behaviour_Detail": []
    },
    "Capability": [],
    "Collateral": [],
    "Financial": [],
    "Decision": []
};

export var lead_detail_data_template = {
    "Application Information": {
        "Application Type": [],
        "Applicant Information": [],
        "Customer Information": [],
        "Education": [],
        "Family": [],
        "Employment Details": [],
        "Income Details": [],
        "Bank Details": [],
        "Reference Details": []
    },
    "Loan Details": {
        "Loan Type": [],
        "Property Details": []
    },
    "Sourcing Details": {
        "Application Details": []
    }
};

export var fivc_datatemplete = {
    "Character__c": {
        "Family Detail": [],
        "Neighbour Detail": [],
        "Affiliation Detail": [],
        "Living Standard Detail": []
    },
    "Capability__c": []
    ,
    "Property__c": [],
    "CommonObject__c": [],
    "Revisit__c": {
        "General Revisit": [],
        "Senior Revisit": []
    },
    "Decision": []
};

export function loadAllData() {
    pc_data_template = {
        "Character": {
            "Family Detail": [],
            "Neighbour Detail": [],
            "Affiliation Detail": [],
            "Living Standard Detail": []
        },
        "Capability": [],
        "Collateral": [],
        "Financial": [],
        "Decision": []
    };


    ac_data_template = {
        "Character": {
            "Family Detail": [],
            "Neighbour Detail": [],
            "Affiliation Detail": [],
            "Living Standard Detail": [],
            "Repayment_Behaviour_Detail": []
        },
        "Capability": [],
        "Collateral": [],
        "Financial": [],
        "Decision": []
    };

    lead_detail_data_template = {
        "Application Information": {
            "Application Type": [],
            "Applicant Information": [],
            "Customer Information": [],
            "Education": [],
            "Family": [],
            "Employment Details": [],
            "Income Details": [],
            "Bank Details": [],
            "Reference Details": []
        },
        "Loan Details": {
            "Loan Type": [],
            "Property Details": []
        },
        "Sourcing Details": {
            "Application Details": []
        }
    };

    fivc_datatemplete = {
        "Character__c": {
            "Family Detail": [],
            "Neighbour Detail": [],
            "Affiliation Detail": [],
            "Living Standard Detail": []
        },
        "Capability__c": []
        ,
        "Property__c": [],
        "CommonObject__c": [],
        "Revisit__c": {
            "General Revisit": [],
            "Senior Revisit": []
        },
        "Decision": []
    };
}

export function isDate(value) {
    if (isNan(value)) {
        let dt = new Date(value);
        return (dt > 0);
    }
    return false;
}

export function checkValidationPCAC(stage) {
    let errorMsg = [];
    let myTemplate = JSON.parse(JSON.stringify(dataTemplete(stage)));
    console.log('checkValidationPCAC = ', JSON.parse(JSON.stringify(myTemplate)));

    let familyDetails = myTemplate["Character"]["Family Detail"];
    if (familyDetails && familyDetails.length) {
        let isInvalid = false;
        familyDetails.forEach(fam => {
            if (!fam.Customer_Type__c || !fam.Customer_Type__c.trim() || !fam.Family_Member_Name__c || !fam.Family_Member_Name__c.trim() ||
                !fam.Relationship__c || !fam.Relationship__c.trim() || !fam.Overall_Remarks__c || !fam.Overall_Remarks__c.trim()) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Family Detail in Character section.');
        }
    }

    let neighbourDetails = myTemplate["Character"]["Neighbour Detail"];
    if (neighbourDetails && neighbourDetails.length) {
        let isInvalid = false;
        neighbourDetails.forEach(nei => {
            if (!nei.FeedBack__c || !nei.FeedBack__c.trim()) {
                isInvalid = true;
            } else if ((nei.FeedBack__c == 'Negative' || nei.FeedBack__c == 'Neutral') && (!nei.Remarks__c || !nei.Remarks__c.trim())) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Neighnour Detail in Character section.');
        }
    }

    let affiliationDetails = myTemplate["Character"]["Affiliation Detail"];
    if (affiliationDetails && affiliationDetails.length) {
        let isInvalid = false;
        affiliationDetails.forEach(aff => {
            if (aff.Is_Involved__c == 'Yes' && (!aff.Customer_Type__c || !aff.Customer_Type__c.trim() || !aff.Affiliation_Name__c || !aff.Affiliation_Name__c.trim() ||
                !aff.Affiliation_with__c || !aff.Affiliation_with__c.trim() || !aff.Affiliation_Remarks__c || !aff.Affiliation_Remarks__c.trim())) {
                isInvalid = true;
            } else if (!aff.Is_Involved__c || !aff.Is_Involved__c.trim()) {
                isInvalid = true;
            }

            if (aff.Is_Involved__c && aff.Is_Involved__c != 'No' && (aff.Affiliation_with__c.includes('Politics') && (!aff.Current_position_Position_held_in_Past__c || !aff.Current_position_Position_held_in_Past__c.trim() || !aff.Name_of_party__c || !aff.Name_of_party__c.trim() ||
                !aff.No_of_years_in_politics__c || !aff.No_of_years_in_politics__c.trim() || !aff.Present_Political_Status__c || !aff.Present_Political_Status__c.trim() || !aff.Character_Of_Affiliated_Person__c || !aff.Character_Of_Affiliated_Person__c.trim()))) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Affiliation Detail in Character section.');
        }
    }

    let livingStandardDetail = myTemplate["Character"]["Living Standard Detail"];
    if (livingStandardDetail && livingStandardDetail.length) {
        let isInvalid = false;
        livingStandardDetail.forEach(liv => {
            if (!liv.Consumer_Durables__c || !liv.Consumer_Durables__c.trim() || !liv.Lifestyle__c || !liv.Lifestyle__c.trim() || !liv.Living_Standard_Remarks__c || !liv.Living_Standard_Remarks__c.trim()) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Living Standard Detail in Character section.');
        }
    }

    let capabilities = myTemplate["Capability"];
    if (capabilities && capabilities.length) {
        capabilities.forEach(cap => {
            let isInvalid = false;
            if (cap.Income_segment__c == 'Salaried') {
                if (!cap.Name_of_the_Employer__c || !cap.Name_of_the_Employer__c.trim() || !cap.Year_of_Service_With_Employer__c || !cap.Year_of_Service_With_Employer__c.trim() || !cap.Nature_of_Job__c || !cap.Nature_of_Job__c.trim() ||
                    !cap.Total_Work_Experience__c || !cap.Total_Work_Experience__c.trim() || !cap.Monthly_Salary__c || !cap.Monthly_Salary__c.trim() || !cap.Mode_of_Salary__c || !cap.Mode_of_Salary__c.trim() ||
                    !cap.Employment_Document_Proof__c || !cap.Employment_Document_Proof__c.trim() || !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.IncomePincode__c || !cap.IncomePincode__c.trim() ||
                    !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Pension') {
                if (!cap.Income_per_month__c || !cap.Income_per_month__c.trim() || !cap.considered_for_DBR__c || !cap.considered_for_DBR__c.trim() || !cap.Income_Remarks__c || !cap.Income_Remarks__c.trim() ||
                    !cap.Spouse_alive__c || !cap.Spouse_alive__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Income_Proof_Pension__c || !cap.Income_Proof_Pension__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Daily wages') {
                if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Proof__c || !cap.Proof__c.trim() || !cap.Proof_Remarks_Daily_Wages__c || !cap.Proof_Remarks_Daily_Wages__c.trim() ||
                    !cap.Other_Confirmations_Daily_Wages__c || !cap.Other_Confirmations_Daily_Wages__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() || !cap.Number_of_days__c || !cap.Number_of_days__c.trim() ||
                    !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Income from Abroad') {
                if (!cap.Income_per_month__c || !cap.Income_per_month__c.trim() || !cap.Income_Remarks__c || !cap.Income_Remarks__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() ||
                    !cap.Proof__c || !cap.Proof__c.trim() || !cap.Proof_Remarks__c || !cap.Proof_Remarks__c.trim() || !cap.Other_Confirmations_Daily_Wages__c || !cap.Other_Confirmations_Daily_Wages__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Self Employed') {
                if (cap.Day_Margin_Basis__c == 'Day Basis') {
                    if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Ownership_document_proof__c || !cap.Ownership_document_proof__c.trim() || !cap.Nature_of_Document_Proof_Self_Employed__c || !cap.Nature_of_Document_Proof_Self_Employed__c.trim() ||
                        !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.Overall_Remarks_Regarding_Business__c || !cap.Overall_Remarks_Regarding_Business__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim()) {
                        isInvalid = true;
                    }
                } else if (cap.Day_Margin_Basis__c == 'Margin Basis') {
                    if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Ownership_document_proof__c || !cap.Ownership_document_proof__c.trim() || !cap.Nature_of_Document_Proof_Self_Employed__c || !cap.Nature_of_Document_Proof_Self_Employed__c.trim() ||
                        !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.Overall_Remarks_Regarding_Business__c || !cap.Overall_Remarks_Regarding_Business__c.trim() || !cap.Sales_per_day__c || !cap.Sales_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.Margin__c || !cap.Margin__c.trim() || !cap.Electricity__c || !cap.Electricity__c.trim() ||
                        !cap.Salary__c || !cap.Salary__c.trim() || !cap.Rent__c || !cap.Rent__c.trim() || !cap.Others__c || !cap.Others__c.trim() ||
                        !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim()) {
                        isInvalid = true;
                    }
                }
            } else if (cap.Income_segment__c == 'Transport business') {
                if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership_Transport__c || !cap.Nature_of_Ownership_Transport__c.trim() ||
                    !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() || !cap.Nature_of_Ownership_Proof__c || !cap.Nature_of_Ownership_Proof__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim() ||
                    !cap.Income_per_day__c || !cap.Income_per_day__c.trim() || !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() ||
                    !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.BusinessPincode__c || !cap.BusinessPincode__c.trim() ||
                    !cap.Overall_Remarks__c || !cap.Overall_Remarks__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Rental Income') {
                if (cap.Subsegment__c == 'Commercial - mortgage proeprty' || cap.Subsegment__c == 'Residential - Mortgage property') {
                    if (!cap.No_of_Units__c || !cap.No_of_Units__c.trim() || !cap.Rental_Income__c || !cap.Rental_Income__c.trim() ||
                        !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim()) {
                        isInvalid = true;
                    }
                } else if (cap.Subsegment__c == 'Commercial - Other property' || cap.Subsegment__c == 'Residential - Other proeprty') {
                    if (!cap.Rental_Property_Owner_name__c || !cap.Rental_Property_Owner_name__c.trim() || !cap.Rental_income_property_address__c || !cap.Rental_income_property_address__c.trim() || !cap.Proof__c || !cap.Proof__c.trim() ||
                        !cap.Proof_of_Ownership__c || !cap.Proof_of_Ownership__c.trim() || !cap.FC_Enquiry_with__c || !cap.FC_Enquiry_with__c.trim() || !cap.No_of_Units__c || !cap.No_of_Units__c.trim() ||
                        !cap.Rental_Income__c || !cap.Rental_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim()) {
                        isInvalid = true;
                    }
                }
            } else {
                console.log('cap.Income_segment__c= ', cap.Income_segment__c, cap.Day_Margin_Basis__c, 'cap=>', cap);
                if (cap.Day_Margin_Basis__c == 'Day Basis') {
                    if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Business_Nature__c || !cap.Business_Nature__c.trim() || !cap.Year_of_Business__c || !cap.Year_of_Business__c.trim() ||
                        !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership__c || !cap.Nature_of_Ownership__c.trim() || !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() ||
                        !cap.Ownership_Proof__c || !cap.Ownership_Proof__c.trim() || !cap.regular_business_activity__c || !cap.regular_business_activity__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.BusinessPincode__c || !cap.BusinessPincode__c.trim() ||
                        !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.Overall_Remarks__c || !cap.Overall_Remarks__c.trim()) {
                        isInvalid = true;
                    }
                } else if (cap.Day_Margin_Basis__c == 'Margin Basis') {
                    if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Business_Nature__c || !cap.Business_Nature__c.trim() || !cap.Year_of_Business__c || !cap.Year_of_Business__c.trim() ||
                        !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership__c || !cap.Nature_of_Ownership__c.trim() || !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() ||
                        !cap.Ownership_Proof__c || !cap.Ownership_Proof__c.trim() || !cap.regular_business_activity__c || !cap.regular_business_activity__c.trim() || !cap.Sales_per_day__c || !cap.Sales_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.Margin__c || !cap.Margin__c.trim() || !cap.Electricity__c || !cap.Electricity__c.trim() ||
                        !cap.Salary__c || !cap.Salary__c.trim() || !cap.Rent__c || !cap.Rent__c.trim() || !cap.Others__c || !cap.Others__c.trim() ||
                        !cap.BusinessPincode__c || !cap.BusinessPincode__c.trim() || !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() ||
                        !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Overall_Remarks__c || !cap.Overall_Remarks__c.trim()) {
                        isInvalid = true;
                    }
                }
            }
            if (isInvalid) {
                errorMsg.push('Complete information of ' + cap.Income_segment__c + ' income segment in Capability section.');
            }
        });

    }

    let properties = myTemplate["Collateral"];
    if (properties && properties.length) {
        let isInvalid1 = false;
        let isInvalid2 = false;
        let isInvalid6 = false;
        properties.forEach(pro => {
            if (!pro.Title_Deed_Number__c || !pro.Title_Deed_Number__c.trim() || !pro.Document_Type__c || !pro.Document_Type__c.trim() ||
                !pro.Title_Deed_Date__c || !pro.Title_Deed_Date__c.trim() || !pro.Land_Ownership__c || !pro.Land_Ownership__c.trim() || !pro.Building_Ownership__c || !pro.Building_Ownership__c.trim() ||
                !pro.Property_Surrounding__c || !pro.Property_Surrounding__c.trim() || !pro.Nature_Of_Property__c || !pro.Nature_Of_Property__c.trim() ||
                !pro.Mortgage_property_distance_from_branch__c || !pro.Mortgage_property_distance_from_branch__c.trim() || !pro.Property_Type__c || !pro.Property_Type__c.trim()) {
                isInvalid1 = true;
            }

            if (!pro.Pathway_Available__c || !pro.Pathway_Available__c.trim() || !pro.Boundaries_As_Per_Inspection_Are_Same__c || !pro.Boundaries_As_Per_Inspection_Are_Same__c.trim() ||
                !pro.Mortgage_Property_Area__c || !pro.Mortgage_Property_Area__c.trim() || !pro.Land_Area_Sq_Ft__c || !pro.Land_Area_Sq_Ft__c.trim() || !pro.Land_area_valuation_remarks__c || !pro.Land_area_valuation_remarks__c.trim() ||
                !pro.Valuation_Market_Value_Per_SqFt__c || !pro.Valuation_Market_Value_Per_SqFt__c.trim() || !pro.Overall_Land_Remarks__c || !pro.Overall_Land_Remarks__c.trim()) {
                isInvalid2 = true;
            }

            if (pro.Property_Type__c != 'Vacant Land') {
                if (!pro.Building_Constructed_with_Remarks__c || !pro.Building_Constructed_with_Remarks__c.trim() || !pro.Building_Age__c || !pro.Building_Age__c.trim() || !pro.Building_Type__c || !pro.Building_Type__c.trim() ||
                    !pro.Avg_Floor_Value_Per_Sq_Ft__c || !pro.Avg_Floor_Value_Per_Sq_Ft__c.trim() || !pro.Total_Floor_Area__c || !pro.Total_Floor_Area__c.trim()) {
                    isInvalid6 = true;
                }
            }
        });
        if (isInvalid1) {
            errorMsg.push('Complete information in Property Details in Collateral section.');
        }
        if (isInvalid2) {
            errorMsg.push('Complete information in Land Area and Valuation in Collateral section.');
        }
        if (isInvalid6) {
            errorMsg.push('Complete information in Building Area & Valuation in Collateral section.');
        }
    }

    let financials = myTemplate["Financial"];
    if (financials && financials.length) {
        let isInvalidAppDetail = false;
        let isInvalidLoanDetail = false;
        let isInvalidTranche = false;
        let isInvalidLoanAmount = false;
        let isInvalidInsuranceParty = false;
        let isInvalidDisbursementDetail = false;
        let isInvalidRiskRating = false;
        let isInvalidOthers = false;
        let isInvalidExecutive = false;

        financials.forEach(fan => {
            let isTranchTab = (fan.Tranche_Disbursal__c == 'I' || fan.Tranche_Disbursal__c == 'II') ? true : false;
            if (isTranchTab) {
                if (!fan.Tranche_2__c || !fan.Tranche_1__c || !fan.Total_net_income_after_2nd_tranche__c ||
                    !fan.Final_Collateral_value_for_Tranche_2__c) {
                    isInvalidTranche = true;
                }
            }

            if (!fan.Loan_Purpose_2__c || !fan.Loan_Purpose_2__c.trim() || !fan.Loan_Purpose_1__c || !fan.Loan_Purpose_1__c.trim()) {
                isInvalidAppDetail = true;
            }
            console.log('fan', fan);
            if (!fan.Balance_Transfer__c || !fan.Balance_Transfer__c.trim() || (fan.Balance_Transfer__c != 'No' && !fan.Balance_Transfer_Amount__c)
                || !fan.Tranche_Disbursal__c || !fan.Tranche_Disbursal__c.trim() || !fan.Tenor_In_Months__c || !fan.Tenor_In_Months__c.trim() || !fan.Customer_Communicated__c
                || fan.Margin_ROI__c == null || !fan.Number_of_advance_EMI__c || !fan.Number_of_advance_EMI__c.trim() || !fan.Effective_IRR__c
                || !fan.Risk_Document__c || !fan.Risk_Document__c.trim()) {
                isInvalidLoanDetail = true;
            }

            if (!fan.Amount_Recommended__c) {
                isInvalidLoanAmount = true;
            }

            if (!fan.Name__c || !fan.Name__c.trim() || !fan.Nominee__c || !fan.Nominee__c.trim()
                || !fan.Nominee_Party__c || !fan.Nominee_Party__c.trim() || !fan.Nominee_Party_Relationship_with_Insured__c || !fan.Nominee_Party_Relationship_with_Insured__c.trim()
                || !fan.Nominee_Relationship_Type__c || !fan.Nominee_Relationship_Type__c.trim()) {
                isInvalidInsuranceParty = true;
            }

            if (!fan.Nach_Party__c || !fan.Nach_Party__c.trim() || !fan.Nach_Party_2__c || !fan.Nach_Party_2__c.trim() || (fan.Disbursement_party__c == 'Disbursement Party Name' && (!fan.Disbursement_Party_Name__c.trim()
                || !fan.Disbursement_Party_Name__c)) || (fan.Disbursement_party__c == 'Third Party' && (!fan.Third_Party_Name__c.trim() || !fan.Third_Party_Name__c))
            ) {
                isInvalidDisbursementDetail = true;
            }

            if (!fan.KYC_Risk_Rating__c || !fan.KYC_Risk_Rating__c.trim()) {
                isInvalidRiskRating = true;
            }

            if (!fan.Discussion_done_with__c || !fan.Discussion_done_with__c.trim()) {
                isInvalidOthers = true;
            }

            if (!fan.Comment_Remarks__c || !fan.Comment_Remarks__c.trim()) {
                isInvalidExecutive = true;
            }

        });

        if (isInvalidAppDetail) {
            errorMsg.push('Complete information in Application details in Financial section.');
        }
        if (isInvalidLoanDetail) {
            errorMsg.push('Complete information in Loan details in Financial section.');
        }
        if (isInvalidLoanAmount) {
            errorMsg.push('Complete information in Loan Amount in Financial section.');
        }
        if (isInvalidTranche) {
            errorMsg.push('Complete information in Tranche in Financial section.');
        }
        if (isInvalidInsuranceParty) {
            errorMsg.push('Complete information in Insurance party in Financial section.');
        }
        if (isInvalidDisbursementDetail) {
            errorMsg.push('Complete information in Disbursement/Repayment detail in Financial section.');
        }
        if (isInvalidRiskRating) {
            errorMsg.push('Complete information in Risk Rating in Financial section.');
        }
        if (isInvalidOthers) {
            errorMsg.push('Complete information in Others in Financial section.');
        }
        if (isInvalidExecutive) {
            errorMsg.push('Complete information in Executive Summary detail in Financial section.');
        }
    }

    let decision = myTemplate["Decision"];
    if (decision && decision.length) {
        decision.forEach(dec => {
            if (stage == 'PC') {
                if (!dec.PC_Decision__c || !dec.PC_Decision__c.trim() || !dec.Recommended_AC_User__c || !dec.Recommended_AC_User__c.trim())
                    errorMsg.push('Complete information in Decision Section.');
            }
            if (stage == 'AC') {
                if (!dec.AC_Decision__c || !dec.AC_Decision__c.trim() || (dec.AC_Decision__c == 'Reject' && (!dec.Rejection_Reason__c || !dec.Rejection_Reason__c.trim())
                    && (!dec.AC_Remarks__c || !dec.AC_Remarks__c.trim()))
                    || (dec.AC_Decision__c == 'Recommend to Another AC' && (!dec.AC_User__c || !dec.AC_User__c.trim()))) { 
                        console.log('check dec');
                        errorMsg.push('Complete information in Decision Section.'); }
            }

        });
    }

    return errorMsg;
}

export function checkValidationFIVC() {
    let errorMsg = [];
    let myTemplate = JSON.parse(JSON.stringify(dataTemplete("FIV-C")));
    console.log('checkValidationFIVC = ', JSON.parse(JSON.stringify(myTemplate)));
    let familyDetails = myTemplate["Character__c"]["Family Detail"];
    if (familyDetails && familyDetails.length) {
        let isInvalid = false;
        familyDetails.forEach(fam => {
            if (!fam.Customer_Type__c || !fam.Customer_Type__c.trim() || !fam.Family_Member_Name__c || !fam.Family_Member_Name__c.trim() ||
                !fam.Relationship__c || !fam.Relationship__c.trim() || !fam.Overall_Remarks__c || !fam.Overall_Remarks__c.trim()) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Family Detail in Character section.');
        }
    }

    let neighbourDetails = myTemplate["Character__c"]["Neighbour Detail"];
    if (neighbourDetails && neighbourDetails.length) {
        let isInvalid = false;
        neighbourDetails.forEach(nei => {
            if (!nei.Neighbour_Name__c || !nei.Neighbour_Name__c.trim() || !nei.FeedBack__c || !nei.FeedBack__c.trim()) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Neighnour Detail in Character section.');
        }
    }

    let affiliationDetails = myTemplate["Character__c"]["Affiliation Detail"];
    if (affiliationDetails && affiliationDetails.length) {
        let isInvalid = false;
        affiliationDetails.forEach(aff => {
            if (aff.Is_Involved__c == 'Yes' && (!aff.Customer_Type__c || !aff.Customer_Type__c.trim() || !aff.Affiliation_Name__c || !aff.Affiliation_Name__c.trim() ||
                !aff.Affiliation_with__c || !aff.Affiliation_with__c.trim() || !aff.Affiliation_Remarks__c || !aff.Affiliation_Remarks__c.trim())) {
                isInvalid = true;
            } else if (!aff.Is_Involved__c || !aff.Is_Involved__c.trim()) {
                isInvalid = true;
            }

            if (aff.Is_Involved__c && aff.Is_Involved__c != 'No' && (aff.Affiliation_with__c.includes('Politics') && (!aff.Current_position_Position_held_in_Past__c || !aff.Current_position_Position_held_in_Past__c.trim() || !aff.Name_of_party__c || !aff.Name_of_party__c.trim() ||
                !aff.No_of_years_in_politics__c || !aff.No_of_years_in_politics__c.trim() || !aff.Present_Political_Status__c || !aff.Present_Political_Status__c.trim() || !aff.Character_Of_Affiliated_Person__c || !aff.Character_Of_Affiliated_Person__c.trim()))) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Affiliation Detail in Character section.');
        }
    }

    let livingStandardDetail = myTemplate["Character__c"]["Living Standard Detail"];
    if (livingStandardDetail && livingStandardDetail.length) {
        let isInvalid = false;
        livingStandardDetail.forEach(liv => {
            if (!liv.Consumer_Durables__c || !liv.Consumer_Durables__c.trim() || !liv.Lifestyle__c || !liv.Lifestyle__c.trim()) {
                isInvalid = true;
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Living Standard Detail in Character section.');
        }
    }

    let capabilities = myTemplate["Capability__c"];
    if (capabilities && capabilities.length) {
        capabilities.forEach(cap => {
            let isInvalid = false;
            if (cap.Income_segment__c == 'Salaried') {
                if (!cap.Name_of_the_Employer__c || !cap.Name_of_the_Employer__c.trim() || !cap.Year_of_Service_With_Employer__c || !cap.Year_of_Service_With_Employer__c.trim() || !cap.Nature_of_Job__c || !cap.Nature_of_Job__c.trim() ||
                    !cap.Total_Work_Experience__c || !cap.Total_Work_Experience__c.trim() || !cap.Monthly_Salary__c || !cap.Monthly_Salary__c.trim() || !cap.Mode_of_Salary__c || !cap.Mode_of_Salary__c.trim() ||
                    !cap.Employment_Document_Proof__c || !cap.Employment_Document_Proof__c.trim() || !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.IncomePincode__c || !cap.IncomePincode__c.trim() ||
                    !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Pension') {
                if (!cap.Income_per_month__c || !cap.Income_per_month__c.trim() || !cap.considered_for_DBR__c || !cap.considered_for_DBR__c.trim() || !cap.Income_Remarks__c || !cap.Income_Remarks__c.trim() ||
                    !cap.Spouse_alive__c || !cap.Spouse_alive__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Income_Proof_Pension__c || !cap.Income_Proof_Pension__c.trim()) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Daily wages') {
                if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Proof__c || !cap.Proof__c.trim() || !cap.Proof_Remarks_Daily_Wages__c || !cap.Proof_Remarks_Daily_Wages__c.trim() ||
                    !cap.Other_Confirmations_Daily_Wages__c || !cap.Other_Confirmations_Daily_Wages__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() || !cap.Number_of_days__c || !cap.Number_of_days__c.trim() ||
                    !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Reference_Name__c || !cap.Reference_Name__c.trim() ||
                    !cap.Feedback__c || !cap.Feedback__c.trim() || !cap.Reference_Name_2__c || !cap.Reference_Name_2__c.trim() || !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                    isInvalid = true;
                } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Remarks__c || !cap.Remarks__c.trim())) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Income from Abroad') {
                if (!cap.Income_per_month__c || !cap.Income_per_month__c.trim() || !cap.Income_Remarks__c || !cap.Income_Remarks__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() ||
                    !cap.Proof__c || !cap.Proof__c.trim() || !cap.Proof_Remarks__c || !cap.Proof_Remarks__c.trim() || !cap.Other_Confirmations_Daily_Wages__c || !cap.Other_Confirmations_Daily_Wages__c.trim() ||
                    !cap.Income_reference_name__c || !cap.Income_reference_name__c.trim() || !cap.Income_reference_Contact_Number__c || !cap.Income_reference_Contact_Number__c.trim() || !cap.Feedback__c || !cap.Feedback__c.trim()) {
                    isInvalid = true;
                } else if (cap.Feedback__c != 'Positive' && (!cap.Remarks__c || !cap.Remarks__c.trim())) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Self Employed') {
                if (cap.Day_Margin_Basis__c == 'Day Basis') {
                    if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Ownership_document_proof__c || !cap.Ownership_document_proof__c.trim() || !cap.Nature_of_Document_Proof_Self_Employed__c || !cap.Nature_of_Document_Proof_Self_Employed__c.trim() ||
                        !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.Overall_Remarks_Regarding_Business__c || !cap.Overall_Remarks_Regarding_Business__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() ||
                        !cap.Business_Reference_Name__c || !cap.Business_Reference_Name__c.trim() || !cap.Business_Reference_Contact_Number__c || !cap.Business_Reference_Contact_Number__c.trim() || !cap.Feedback__c || !cap.Feedback__c.trim() ||
                        !cap.Business_Reference_Name_2__c || !cap.Business_Reference_Name_2__c.trim() || !cap.Business_Reference_Contact_Number_2__c || !cap.Business_Reference_Contact_Number_2__c.trim() || !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                        isInvalid = true;
                    } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Business_Reference_Remarks__c || !cap.Business_Reference_Remarks__c.trim())) {
                        isInvalid = true;
                    }
                } else if (cap.Day_Margin_Basis__c == 'Margin Basis') {
                    if (!cap.Year_of_Occupation__c || !cap.Year_of_Occupation__c.trim() || !cap.Ownership_document_proof__c || !cap.Ownership_document_proof__c.trim() || !cap.Nature_of_Document_Proof_Self_Employed__c || !cap.Nature_of_Document_Proof_Self_Employed__c.trim() ||
                        !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.Overall_Remarks_Regarding_Business__c || !cap.Overall_Remarks_Regarding_Business__c.trim() || !cap.Sales_per_day__c || !cap.Sales_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.Margin__c || !cap.Margin__c.trim() || !cap.Electricity__c || !cap.Electricity__c.trim() ||
                        !cap.Salary__c || !cap.Salary__c.trim() || !cap.Rent__c || !cap.Rent__c.trim() || !cap.Others__c || !cap.Others__c.trim() ||
                        !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() ||
                        !cap.Business_Reference_Name__c || !cap.Business_Reference_Name__c.trim() || !cap.Business_Reference_Contact_Number__c || !cap.Business_Reference_Contact_Number__c.trim() || !cap.Feedback__c || !cap.Feedback__c.trim() ||
                        !cap.Business_Reference_Name_2__c || !cap.Business_Reference_Name_2__c.trim() || !cap.Business_Reference_Contact_Number_2__c || !cap.Business_Reference_Contact_Number_2__c.trim() || !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                        isInvalid = true;
                    } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Business_Reference_Remarks__c || !cap.Business_Reference_Remarks__c.trim())) {
                        isInvalid = true;
                    }
                }
            } else if (cap.Income_segment__c == 'Transport business') {
                if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership_Transport__c || !cap.Nature_of_Ownership_Transport__c.trim() ||
                    !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() || !cap.Nature_of_Ownership_Proof__c || !cap.Nature_of_Ownership_Proof__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim() ||
                    !cap.Income_per_day__c || !cap.Income_per_day__c.trim() || !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() ||
                    !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.Other_Confirmations__c || !cap.Other_Confirmations__c.trim() || !cap.IncomePincode__c || !cap.IncomePincode__c.trim() ||
                    !cap.Overall_Remarks__c || !cap.Overall_Remarks__c.trim() || !cap.Business_Reference_Name__c || !cap.Business_Reference_Name__c.trim() || !cap.Business_Reference_Contact_Number__c || !cap.Business_Reference_Contact_Number__c.trim() ||
                    !cap.Feedback__c || !cap.Feedback__c.trim() || !cap.Business_Reference_Name_2__c || !cap.Business_Reference_Name_2__c.trim() || !cap.Business_Reference_Contact_Number_2__c || !cap.Business_Reference_Contact_Number_2__c.trim() ||
                    !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                    isInvalid = true;
                } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Business_Reference_Remarks__c || !cap.Business_Reference_Remarks__c.trim())) {
                    isInvalid = true;
                }
            } else if (cap.Income_segment__c == 'Rental Income') {
                if (cap.Subsegment__c == 'Commercial - mortgage proeprty' || cap.Subsegment__c == 'Residential - Mortgage property') {
                    if (!cap.No_of_Units__c || !cap.No_of_Units__c.trim() || !cap.Rental_Income__c || !cap.Rental_Income__c.trim() ||
                        !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim()) {
                        isInvalid = true;
                    }
                } else if (cap.Subsegment__c == 'Commercial - Other property' || cap.Subsegment__c == 'Residential - Other proeprty') {
                    if (!cap.Rental_Property_Owner_name__c || !cap.Rental_Property_Owner_name__c.trim() || !cap.Rental_income_property_address__c || !cap.Rental_income_property_address__c.trim() || !cap.Proof__c || !cap.Proof__c.trim() ||
                        !cap.Proof_of_Ownership__c || !cap.Proof_of_Ownership__c.trim() || !cap.FC_Enquiry_with__c || !cap.FC_Enquiry_with__c.trim() || !cap.No_of_Units__c || !cap.No_of_Units__c.trim() ||
                        !cap.Rental_Income__c || !cap.Rental_Income__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Remarks__c || !cap.Remarks__c.trim()) {
                        isInvalid = true;
                    }
                }
            } else {
                if (cap.Day_Margin_Basis__c == 'Day Basis') {
                    if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Business_Nature__c || !cap.Business_Nature__c.trim() || !cap.Year_of_Business__c || !cap.Year_of_Business__c.trim() ||
                        !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership__c || !cap.Nature_of_Ownership__c.trim() || !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() ||
                        !cap.Ownership_Proof__c || !cap.Ownership_Proof__c.trim() || !cap.regular_business_activity__c || !cap.regular_business_activity__c.trim() || !cap.Income_per_day__c || !cap.Income_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.IncomePincode__c || !cap.IncomePincode__c.trim() ||
                        !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() || !cap.Business_Reference_Name__c || !cap.Business_Reference_Name__c.trim() || !cap.Business_Reference_Contact_Number__c || !cap.Business_Reference_Contact_Number__c.trim() ||
                        !cap.Feedback__c || !cap.Feedback__c.trim() || !cap.Business_Reference_Name_2__c || !cap.Business_Reference_Name_2__c.trim() || !cap.Business_Reference_Contact_Number_2__c || !cap.Business_Reference_Contact_Number_2__c.trim() ||
                        !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                        isInvalid = true;
                    } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Business_Reference_Remarks__c || !cap.Business_Reference_Remarks__c.trim())) {
                        isInvalid = true;
                    }
                } else if (cap.Day_Margin_Basis__c == 'Margin Basis') {
                    if (!cap.Business_name__c || !cap.Business_name__c.trim() || !cap.Business_Nature__c || !cap.Business_Nature__c.trim() || !cap.Year_of_Business__c || !cap.Year_of_Business__c.trim() ||
                        !cap.Total_experience_in_this_business_yrs__c || !cap.Total_experience_in_this_business_yrs__c.trim() || !cap.Nature_of_Ownership__c || !cap.Nature_of_Ownership__c.trim() || !cap.Ownership_Proof_available__c || !cap.Ownership_Proof_available__c.trim() ||
                        !cap.Ownership_Proof__c || !cap.Ownership_Proof__c.trim() || !cap.regular_business_activity__c || !cap.regular_business_activity__c.trim() || !cap.Sales_per_day__c || !cap.Sales_per_day__c.trim() ||
                        !cap.Number_of_days__c || !cap.Number_of_days__c.trim() || !cap.Margin__c || !cap.Margin__c.trim() || !cap.Electricity__c || !cap.Electricity__c.trim() ||
                        !cap.Salary__c || !cap.Salary__c.trim() || !cap.Rent__c || !cap.Rent__c.trim() || !cap.Others__c || !cap.Others__c.trim() ||
                        !cap.IncomePincode__c || !cap.IncomePincode__c.trim() || !cap.Assumptions_for_Income__c || !cap.Assumptions_for_Income__c.trim() ||
                        !cap.of_income_transacted_through_bank_acco__c || !cap.of_income_transacted_through_bank_acco__c.trim() || !cap.Business_Reference_Name__c || !cap.Business_Reference_Name__c.trim() || !cap.Business_Reference_Contact_Number__c || !cap.Business_Reference_Contact_Number__c.trim() ||
                        !cap.Feedback__c || !cap.Feedback__c.trim() || !cap.Business_Reference_Name_2__c || !cap.Business_Reference_Name_2__c.trim() || !cap.Business_Reference_Contact_Number_2__c || !cap.Business_Reference_Contact_Number_2__c.trim() ||
                        !cap.Feedback_2__c || !cap.Feedback_2__c.trim()) {
                        isInvalid = true;
                    } else if ((cap.Feedback__c != 'Positive' || cap.Feedback_2__c != 'Positive') && (!cap.Business_Reference_Remarks__c || !cap.Business_Reference_Remarks__c.trim())) {
                        isInvalid = true;
                    }
                }
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information of ' + cap.Income_segment__c + ' income segment in Capability section.');
        }
    }

    let properties = myTemplate["Property__c"];
    if (properties && properties.length) {
        let isInvalid1 = false;
        let isInvalid2 = false;
        let isInvalid3 = false;
        let isInvalid4 = false;
        let isInvalid5 = false;
        let isInvalid6 = false;
        properties.forEach(pro => {
            if (!pro.Original_Mortgage_Document__c || !pro.Original_Mortgage_Document__c.trim() || !pro.Title_Deed_Number__c || !pro.Title_Deed_Number__c.trim() || !pro.Document_Type__c || !pro.Document_Type__c.trim() ||
                !pro.Title_Deed_Date__c || !pro.Title_Deed_Date__c.trim() || !pro.MS_Pincode__c || !pro.MS_Pincode__c.trim() || !pro.Mortgage_property_distance_from_branch__c || !pro.Mortgage_property_distance_from_branch__c.trim() ||
                !pro.Nature_Of_Property__c || !pro.Nature_Of_Property__c.trim() || !pro.Property_Type__c || !pro.Property_Type__c.trim() || !pro.Mortgage_property_Living_property_are__c || !pro.Mortgage_property_Living_property_are__c.trim() ||
                !pro.Landmark__c || !pro.Landmark__c.trim() || !pro.Overall_Remarks__c || !pro.Overall_Remarks__c.trim()) {
                isInvalid1 = true;
            } else if (pro.Mortgage_property_Living_property_are__c == 'No' && (!pro.Pincode__c || !pro.Pincode__c.trim())) {
                isInvalid1 = true;
            }

            if (!pro.Pathway_Available__c || !pro.Pathway_Available__c.trim() || !pro.All_four_boundaries_mentioned_in_doc__c || !pro.All_four_boundaries_mentioned_in_doc__c.trim()) {
                isInvalid2 = true;
            } else if (pro.Pathway_Available__c == 'No' && (!pro.Land_area_valuation_remarks__c || !pro.Land_area_valuation_remarks__c.trim())) {
                isInvalid2 = true;
            }

            if (!pro.North_by_boundaries__c || !pro.North_by_boundaries__c.trim() || !pro.North_By_Boundaries_Physical__c || !pro.North_By_Boundaries_Physical__c.trim() || !pro.South_by_boundaries__c || !pro.South_by_boundaries__c.trim() ||
                !pro.South_By_Boundaries_Physical__c || !pro.South_By_Boundaries_Physical__c.trim() || !pro.East_by_boundaries__c || !pro.East_by_boundaries__c.trim() || !pro.East_By_Boundaries_Physical__c || !pro.East_By_Boundaries_Physical__c.trim() ||
                !pro.West_by_boundaries__c || !pro.West_by_boundaries__c.trim() || !pro.West_By_Boundaries_Physical__c || !pro.West_By_Boundaries_Physical__c.trim()) {
                isInvalid3 = true;
            }

            if (!pro.North_by_land_measurements__c || !pro.North_by_land_measurements__c.trim() || !pro.North_by_land_measurements__c || !pro.North_by_land_measurements__c.trim() || !pro.South_by_land_measurements__c || !pro.South_by_land_measurements__c.trim() ||
                !pro.South_By_Land_Physical__c || !pro.South_By_Land_Physical__c.trim() || !pro.East_by_land_measurements__c || !pro.East_by_land_measurements__c.trim() || !pro.East_By_Land_Physical__c || !pro.East_By_Land_Physical__c.trim() ||
                !pro.West_by_land_measurements__c || !pro.West_by_land_measurements__c.trim() || !pro.West_By_Land_Physical__c || !pro.West_By_Land_Physical__c.trim() || !pro.Land_Measurement_Length_Sq_ft__c || !pro.Land_Measurement_Length_Sq_ft__c.trim() ||
                !pro.Land_Measurement_Width_Sq_ft__c || !pro.Land_Measurement_Width_Sq_ft__c.trim() || !pro.Remarks_land_measurements__c || !pro.Remarks_land_measurements__c.trim() ||
                !pro.Location_of_Mortgage_Property__c || !pro.Location_of_Mortgage_Property__c.trim() || !pro.Remarks__c || !pro.Remarks__c.trim() || !pro.Mortgage_Property_Area__c || !pro.Mortgage_Property_Area__c.trim()) {
                isInvalid4 = true;
            }

            if (!pro.Adopted_Value_Per_SqFt__c || !pro.Adopted_Value_Per_SqFt__c.trim()) {
                isInvalid5 = true;
            }

            if (pro.Property_Type__c != 'Vacant Land') {
                if (!pro.Building_Age__c || !pro.Building_Age__c.trim() || !pro.Building_Type__c || !pro.Building_Type__c.trim()) {
                    isInvalid6 = true;
                }
            }
        });
        if (isInvalid1) {
            errorMsg.push('Complete information in Property Details in Collateral section.');
        }
        if (isInvalid2) {
            errorMsg.push('Complete information in Land Area and Valuation in Collateral section.');
        }
        if (isInvalid3) {
            errorMsg.push('Complete information in As Per Document Boundaries in Collateral section.');
        }
        if (isInvalid4) {
            errorMsg.push('Complete information in Land Measurement in Collateral section.');
        }
        if (isInvalid5) {
            errorMsg.push('Complete information in Valuation in Collateral section.');
        }
        if (isInvalid6) {
            errorMsg.push('Complete information in Building Area & Valuation in Collateral section.');
        }
    }

    let revisitRecords = myTemplate["Revisit__c"]["General Revisit"];
    if (revisitRecords && revisitRecords.length) {
        let isInvalid = false;
        revisitRecords.forEach(item => {
            if (item.Revisit_done__c && item.Revisit_done__c == 'Yes') {
                if (!item.Revisit_date__c || !item.Revisit_date__c.trim() || !item.Reason_for_revist__c || !item.Reason_for_revist__c.trim() || !item.Applicant_is_owner_of_the_property__c || !item.Applicant_is_owner_of_the_property__c.trim() ||
                    !item.Years_of_possession_of_the_property__c || !item.Years_of_possession_of_the_property__c.trim() || !item.Does_property_mortgaged_with_any_financi__c || !item.Does_property_mortgaged_with_any_financi__c.trim() ||
                    !item.Mortgage_details_of_property__c || !item.Mortgage_details_of_property__c.trim()) {
                    isInvalid = true;
                }
            }
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Revisit section.');
        }
    }

    // Modified 11.05.23 as fields made non-mandatory on Senior Revisit Records
    let seniorRevisitRecords = myTemplate["Revisit__c"]["Senior Revisit"];
    console.log ('Senior Revisit Records', seniorRevisitRecords);
    if (seniorRevisitRecords && seniorRevisitRecords.length) {
        let isInvalid = false;
        seniorRevisitRecords.forEach(item => {
            if (!item.Senior_Auditor_Confirmation_Visit__c || !item.Senior_Auditor_Confirmation_Visit__c.trim()) { 
                console.log('Is Invalid ###',isInvalid);           
                    isInvalid = true;            
            }
            console.log('Is Invalid ###',isInvalid);
        });
        if (isInvalid) {
            errorMsg.push('Complete information in Senior/Auditor Confirmation Revisit section.');
        }
    }

    let decisions = myTemplate["Decision"];
    if (decisions && decisions.length) {
        decisions.forEach(dec => {
            if (!dec.Result__c || !dec.Is_applicant_co_applicant_related_kn__c || !dec.Is_applic_co_applic_related__c) {
                errorMsg.push('Complete information in Decision section.');
            } else if ((dec.Result__c == 'Negative' || dec.Result__c == 'Neutral') && !dec.Remarks__c) {
                errorMsg.push('Complete information in Decision section.');
            } else if ((dec.Is_applicant_co_applicant_related_kn__c == 'Yes' || dec.Is_applic_co_applic_related__c == 'Yes') && !dec.Remarks_Declaration__c) {
                errorMsg.push('Complete information in Decision section.');
            }
        });
    }
    return errorMsg;
}

export function checkValidationLeadDetails() {
    let myTemplate = JSON.parse(JSON.stringify(dataTemplete("Lead Detail")));
    console.log('checkValidationLeadDetails = ', JSON.parse(JSON.stringify(myTemplate)));

    let errorMsg = [];

    let applicationTypeDetails = myTemplate["Application Information"]["Application Type"];
    applicationTypeDetails.forEach(currentItem => {
        if (!currentItem.Constitution__c) {
            errorMsg.push('Constitution__c field is missing in Application Type sub section of Application Information secion.');
        }
    });

    let validateMap = new Map();
    let customerInformation = myTemplate["Application Information"]["Customer Information"];
    console.log('customerInformation>>>. ', customerInformation)
    var custInfoFlag = false;
    customerInformation.forEach(currentItem => {//Customer information fiedls for appliocant information
        validateMap.set(currentItem.Id, currentItem)
    });

    let applicantInformation = myTemplate["Application Information"]["Applicant Information"];
    console.log('applicantInformation>>>. ', applicantInformation)
    console.log('custInfoFlag 11>> ', custInfoFlag)
    var appInfoFlag = false;
    if (applicantInformation && applicantInformation.length) {
        applicantInformation.forEach(currentItem => {//custInfoFlag === true ||
            console.log('currentItem.Customer_Information__r.Id>>> ', currentItem.Customer_Information__c)
            if (validateMap.has(currentItem.Customer_Information__c)) {
                let tempObj = Object.assign(validateMap.get(currentItem.Customer_Information__c), currentItem);
                validateMap.set(currentItem.Customer_Information__c, tempObj);
            }
        });
    }

    for (let [key, value] of validateMap) {
        console.log('validateMap sizeee>> ', validateMap.size)
        let currentItem = value;
        if (validateMap.size > 0) {
            if (!currentItem.Salutation || !currentItem.FirstName || !currentItem.LastName ||
                !currentItem.Father_s_Name__c ||!currentItem.Mother_s_Name__c || !currentItem.PersonBirthdate || !currentItem.Gender__c
                || !currentItem.Category__c || !currentItem.Resident_Type__c || !currentItem.KYC_Id_1__c || !currentItem.KYC_ID_Type_1__c || !currentItem.KYC_Id_2__c || !currentItem.KYC_ID_Type_2__c
                || !currentItem.Marital_Status__c || !currentItem.Mobile__c || !currentItem.Relationship_With_Main_Applicant__c ||
                !currentItem.Communication_Address__c || !currentItem.Residence_Address_Line_1__c || !currentItem.Residence_Address_Line_2__c || !currentItem.Residence_Pincode__c || currentItem.Residence_Pincode__c == true ||
                !currentItem.Residence_Flat_Plot_Number__c || !currentItem.Residence_Village__c || !currentItem.Residence_Taluka__c || !currentItem.Residence_Country__c
                || !currentItem.Permanent_Address_Line_1__c || !currentItem.Permanent_Address_Line_2__c || !currentItem.Permanent_Pincode__c || currentItem.Permanent_Pincode__c == true || !currentItem.Permanent_Village__c
                || !currentItem.Permanent_Taluka__c || !currentItem.Permanent_Country__c || !currentItem.Permanent_Flat_Plot_Number__c ||
                !currentItem.Business_Flat_Plot_Number__c || !currentItem.Business_Address_Line_1__c || !currentItem.Business_Address_Line_2__c || !currentItem.Business_Pincode__c || currentItem.Business_Pincode__c == true
                || !currentItem.Business_Village__c || !currentItem.Business_Taluka__c || !currentItem.Business_Country__c) {
                errorMsg.push('Complete missing fields for Applicant# ' + currentItem.FirstName + ' ' + currentItem.LastName + ' in Applicant Information sub section of Application Information section');
            } else if ((currentItem.KYC_ID_Type_1__c === 'Passport' || currentItem.KYC_ID_Type_2__c === 'Passport') && (!currentItem.Passport_File_Number__c || !currentItem.Issue_Date__c || !currentItem.Expiry_Date__c)) {
                console.log('seconddd currentItem', currentItem)
                errorMsg.push('Complete missing fields for Applicant# ' + currentItem.FirstName + ' ' + currentItem.LastName + ' in Applicant Information sub section of Application Information section');
            }
        } else {
            errorMsg.push('Atleast one record is mandatory for Applicant Information sub section of Application Information section');
        }
    }

    //delete applicantInformation['Customer_Infomation__c'];

    //Employment Details Have conditionally reuired!!!!!  Need discussion 
    let employmentDetails = myTemplate["Application Information"]["Employment Details"];
    console.log('employmentDetails>>>>111 ', employmentDetails)
    if (employmentDetails && employmentDetails.length) {
        employmentDetails.forEach(emp => {
            if (!emp.Occupation__c) {
                errorMsg.push('Complete missing fields in Employment Details sub section of Application Information section');
            } else if (emp.Occupation__c == 'Salaried' && (!emp.No_of_years_Employment_Business__c || !emp.Name_of_Employer__c)) {
                errorMsg.push('Complete missing fields in Employment Details sub section of Application Information section');
            } else if (emp.Occupation__c == 'Self Employed Non Professional' && (!emp.No_of_years_Employment_Business__c || !emp.Nature_of_Business__c || !emp.Name_of_Business__c)) {
                errorMsg.push('Complete missing fields in Employment Details sub section of Application Information section');
            } else if (emp.Occupation__c == 'Self Employed Professional' && (!emp.No_of_years_Employment_Business__c || !emp.Name_of_Business__c)) {
                errorMsg.push('Complete missing fields in Employment Details sub section of Application Information section');
            }
        });
    } else {
        errorMsg.push('Atleast one record is mandatory for Employment Details sub section of Application Information section');
    }

    let bankDetails = myTemplate["Application Information"]["Bank Details"];
    console.log('bankDetails>>>. ', bankDetails)
    bankDetails.forEach(bank => {
        if (!bank.IFSC_Code__c) {
            errorMsg.push('Complete missing fields in Bank Details sub section of Application Information section');
        }
    });

    //Conditonally required
    let referenceDetails = myTemplate["Application Information"]["Reference Details"];
    console.log('referenceDetails>>>. ', referenceDetails)
    referenceDetails.forEach(currentItem => {
        if (currentItem.Refered_By_Existing_Customer__c == 'Yes' && !currentItem.Refered_By_Customer_Loan_Accoount_No__c) {
            errorMsg.push('Refered By Customer Loan Account No. field is missing in Reference Details sub section of Application Information secion.');
        } else if ((!currentItem.Refered_By_Existing_Customer__c || currentItem.Refered_By_Existing_Customer__c == 'No') && !currentItem.Refered_By_Introducer_Broker_Name__c) {
            errorMsg.push('Refered By Introducer / Broker Name field is missing in Reference Details sub section of Application Information secion.');
        }
    });

    let loanTypeDetail = myTemplate["Loan Details"]["Loan Type"];
    console.log('loanTypeDetail>>>. ', loanTypeDetail)
    loanTypeDetail.forEach(currentItem => {
        if (!currentItem.Tenure_Requested__c || !currentItem.Loan_Purpose__c || !currentItem.Loan_Categorisation__c
            || !currentItem.Requested_Loan_Amount__c || (!currentItem.Take_Over_Amount__c && currentItem.Take_Over__c == 'Yes')) {
            errorMsg.push('Required details are missing in Loan Type sub section of Loan Details secion.');
        } else if (!currentItem.Tenure_Requested__c || !currentItem.Loan_Purpose__c || !currentItem.Take_Over__c || !currentItem.Loan_Categorisation__c
            || !currentItem.Requested_Loan_Amount__c) {
            errorMsg.push('Required details are missing in Loan Type sub section of Loan Details secion.');
        }
    });

    let propertyDetails = myTemplate["Loan Details"]["Property Details"];
    if (!propertyDetails || !propertyDetails.length) {
        errorMsg.push('Atleast one property is required.');
    } else {
        propertyDetails.forEach(pro => {
            if (!pro.Property_Type__c || !pro.Property_Identified__c || !pro.Property_Purchased_Type__c || !pro.Title_Deed_Date__c || !pro.Title_Deed_Type__c || !pro.Title_Deed_Number__c
                || !pro.Land_Area_Sq_Ft__c || !pro.Building_Area_Sq_Ft__c || !pro.Age_Of_Property__c || !pro.Nature_Of_Property__c || !pro.Property_Purpose__c || !pro.Property_Location_Classification__c || !pro.Residual_Age_Of_Property__c) {
                errorMsg.push('Complete entry for Property# ' + pro.Name_LABEL + ' in Property Details sub section of Loan Details section.');
            }
        });

        let propertyAddress = myTemplate["Loan Details"]["Property Details"];
        propertyAddress.forEach(pro => {
            if (!pro.Address_Type__c || !pro.Flat_Plot_Number__c || !pro.Address_Line_3__c || !pro.Address_Line_2__c || !pro.Village__c
                || !pro.Survey_Number__c || !pro.MS_Pincode__c || pro.MS_Pincode__c == true) {// !pro.City__c || !pro.Taluka__c || !pro.State__c || !pro.District__c ||
                errorMsg.push('Complete entry for Property# ' + pro.Name_LABEL + ' in Property Address sub section of Loan Details section.');
            }
        });

        let ownershipDetails = myTemplate["Loan Details"]["Property Details"];
        ownershipDetails.forEach(pro => {
            if (!pro.Ownership_Date__c || !pro.Percent_Share__c || !pro.Ownership_Status__c) {
                errorMsg.push('Complete entry for Property# ' + pro.Name_LABEL + ' in Ownership Details sub section of Loan Details section.');
            }
        });
    }

    let applicationDetails = myTemplate["Sourcing Details"]["Application Details"];
    applicationDetails.forEach(currentItem => {
        if (!currentItem.Field_Officer_Emp_Id__c) {
            errorMsg.push('Field Officer details are missing in Application Details sub section of Sourcing Details secion.');
        }
    });
    return errorMsg;
}

export function populateData(StageName, TabName, SubTabName, FieldName, FieldValue, UniqueLabel, UniqueValue) {
    try {
        var dt = dataTemplete(StageName);
        //var dataMap = {};
        if (TabName) {
            if (SubTabName) {
                var dataList = dt[TabName][SubTabName];
                dt[TabName][SubTabName] = checkAndPopulateData(dataList, UniqueLabel, UniqueValue, FieldName, FieldValue);
            } else {
                var dataList = dt[TabName];
                dt[TabName] = checkAndPopulateData(dataList, UniqueLabel, UniqueValue, FieldName, FieldValue);
            }
        }
        assignValueDataTemplete(StageName, dt);
        console.log('populateData = ', JSON.parse(JSON.stringify(dt)));
    } catch (error) {
        console.log(error);
    }
}

export function removeData(StageName, TabName, SubTabName) {
    try {
        var dt = dataTemplete(StageName);
        if (TabName) {
            if (SubTabName) {
                dt[TabName][SubTabName] = [];
            } else {
                dt[TabName] = [];
            }
        }
    } catch (error) {
        console.log(error);
    }
}

function dataTemplete(StageName) {
    if (StageName === 'FIV-C') {
        return fivc_datatemplete;
    }
    if (StageName === 'Lead Detail') {
        return lead_detail_data_template;
    }
    if (StageName === 'PC') {
        return pc_data_template;
    }
    if (StageName === 'AC') {
        return ac_data_template;
    }
}

function assignValueDataTemplete(StageName, values) {
    if (StageName === 'FIV-C') {
        fivc_datatemplete = values;
    }
    if (StageName === 'Lead Detail') {
        lead_detail_data_template = values;
    }
    if (StageName === 'PC') {
        pc_data_template = values;
    }
    if (StageName === 'AC') {
        ac_data_template = values;
    }
}

function checkAndPopulateData(arr, UniqueIdLabel, UniqueIdValue, FieldLabel, FieldValue) {
    /*var obj = {};
    if(dataMap && dataMap.length > 0){
        for (var i = 0; i < dataMap.length; i++) {
            //obj = {};
            obj[UniqueIdLabel] = UniqueIdValue;
            obj[FieldLabel] = FieldValue;
            if(dataMap[i].hasOwnProperty(UniqueIdLabel) && dataMap[i][UniqueIdLabel] === UniqueIdValue){
                console.log('CHCK1 obj ::::',obj);
                console.log('CHCK1 dataMap[i] ::::',dataMap[i]);
                Object.assign(dataMap[i], obj);
                break;
            }else{
                console.log('CHCK2 obj ::::',obj);
                console.log('CHCK2 dataMap[i] ::::',dataMap[i]);
                dataMap.push(obj);
            }
        }
    }else{
        console.log('CHCK3 ::::');
        obj[UniqueIdLabel] = UniqueIdValue;
        obj[FieldLabel] = FieldValue;
        dataMap.push(obj);
    }
    return dataMap;*/
    var obj = {};
    obj[UniqueIdLabel] = UniqueIdValue;
    obj[FieldLabel] = FieldValue;
    const index = arr.findIndex((e) => e.Id === obj.Id);
    console.log('::INDEX::', index);
    if (index === -1) {
        arr.push(obj);
    } else {
        //arr[index] = obj;
        Object.assign(arr[index], obj);
    }
    return arr;
}