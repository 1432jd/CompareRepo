/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-05-02
* @modified         2022-07-21
* @Description      This component is build to handle all the operations related to 
                    Collateral Tab In Verification-C in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, track } from 'lwc';
import getCollateralTabRecords from '@salesforce/apex/FIV_C_Controller.getCollateralTabRecords';
import getCollateralEnquiryRecords from '@salesforce/apex/FIV_C_Controller.getCollateralEnquiryRecords';
import getFIV_CRecordTypeId from '@salesforce/apex/FIV_C_Controller.getFIV_CRecordTypeId';
import getEnquiryMap from '@salesforce/apex/FIV_C_Controller.getEnquiryMap';
import deleteRecord from '@salesforce/apex/Utility.deleteRecord';
import deleteRelatedFloors from '@salesforce/apex/FS_BuildingFloorController.deleteRelatedFloors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const rowAction = [{
    //label: 'Edit',
    type: 'button-icon',
    fixedWidth: 50,
    typeAttributes: {
        iconName: 'utility:edit',
        title: 'Edit',
        variant: 'border-filled',
        alternativeText: 'Edit',
        name: 'edit'
    }
},
{
    //label: 'Delete',
    type: 'button-icon',
    fixedWidth: 50,
    typeAttributes: {
        iconName: 'utility:delete',
        title: 'Delete',
        variant: 'border-filled',
        alternativeText: 'Delete',
        name: 'delete'
    }
}];
export default class FivcCollateralLWC extends LightningElement {
    @api applicationId;
    @api verificationId;
    @api loginId;

    @track rowAction = rowAction;

    @track propertyIdFIVC;
    @track recordTypeId;
    @track propertyData;

    @track enquiryMap;
    @track enquiryData;
    @track enquiryId;
    @track highestMarketValue;

    @track isGeneralDetail = false;
    @track isLandarea = false;
    @track isDocBoundries = false;
    @track isMeasurement = false;
    @track isEnquiry = false;
    @track isValuation = false;
    @track isBuildingArea = false;

    @track totalArea;
    @track totalValue;
    @track landMeasurementArea;
    @track finalLandValue;
    @track pathwayVal;
    @track mortgagePropertyLivingProperty;

    @track showLoader = false;

    @track deedMonth;
    @track deedYear;
    @track distanceFromBranch;
    @track showAddProperty = false;
    @track showDeleteModal = false;
    @track collateralValidation = {
        generalDetail: false,
        landAreaVal: false,
        docBoundries: false,
        enquiry: false,
        buildingAreaVal: false,
        landMeasurement: false,
        valuation: false
    };

    @track natureOfProperty;
    @track propertyType;

    @track docNorth;
    @track docSouth;
    @track docEast;
    @track docWest;
    @track landNorth;
    @track landSouth;
    @track landEast;
    @track landWest;
    @track mortgagePropertyArea;
    @track boundariesAsPerInspectionAreSame;

    @track northByLandMes;
    @track southByLandMes;
    @track eastByLandMes;
    @track westByLandMes;
    @track northByLandMesPh;
    @track southByLandMesPh;
    @track eastByLandMesPh;
    @track westByLandMesPh;

    @track buildingAge;
    @track floorVal;
    @track buildingLength;
    @track buildingWidth;
    @track buildingValSqFt;

    @track totalFloorValue;
    @track totalFloorArea;
    @track totalAvgSqFtValue;

    @track enquiryNumber;
    @track enquiryMarketValue;

    @track isUnsaved = false;

    get showForm() {
        return (this.propertyIdFIVC);
    }

    get isVacantProperty() {
        return this.propertyType == 'Vacant Land' ? true : false;
    }

    get showPathwayRemark() {
        return this.pathwayVal == 'No' ? true : false;
    }

    get showMortgageLivingPropertyFields() {
        return this.mortgagePropertyLivingProperty == 'No' ? true : false;
    }

    get selectedRow() {
        let rows = [];
        if (this.propertyIdFIVC) {
            rows.push(this.propertyIdFIVC);
        }
        return rows;
    }

    get landMeaRemarkRequired() {
        return this.mortgagePropertyArea == 'Negative' ? true : false;
    }

    get propertyTypeOptions() {
        if (this.natureOfProperty == 'Vacant Land') {
            return [{ label: 'Vacant Land', value: 'Vacant Land' }];
        }
        else if (this.natureOfProperty == 'Residential') {
            return [{ label: 'Flat', value: 'Flat' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'House', value: 'House' }];
        }
        else if (this.natureOfProperty == 'Institutional') {
            return [{ label: 'Office', value: 'Office' },
            { label: 'Vacant Land', value: 'Vacant Land' }];
        }
        else if (this.natureOfProperty == 'Commercial') {
            return [{ label: 'Office', value: 'Office' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'Shop', value: 'Shop' }];
        }
    }

    get showBoundariesSameRemarks() {
        return this.boundariesAsPerInspectionAreSame == 'No' ? true : false;
    }

    // This Method Is Used To Get All Data At Initial Level(Loading).
    connectedCallback() {
        this.showLoader = true;
        this.handleGetFIVProperty();
        this.handleGetEnquiryMap();
        getFIV_CRecordTypeId().then((result) => {
            this.recordTypeId = result;
        }).catch((err) => {
            console.log('Error in getFIV_CRecordTypeId= ', err);
        });
    }

    // This Method Is Used To Handle Tab Activation Event.
    handleTabActivation(event) {
        this.isGeneralDetail = false;
        this.isLandarea = false;
        this.isDocBoundries = false;
        this.isEnquiry = false;
        this.isValuation = false;
        this.isBuildingArea = false;
        this.isMeasurement = false;

        if (event.target.value == 'general') {
            this.isGeneralDetail = true;
        } else if (event.target.value == 'landarea') {
            this.isLandarea = true;
        } else if (event.target.value == 'boundries') {
            this.isDocBoundries = true;
        } else if (event.target.value == 'measurement') {
            this.isMeasurement = true;
        } else if (event.target.value == 'enquiry') {
            this.isEnquiry = true;
        } else if (event.target.value == 'valuation') {
            this.isValuation = true;
        } else if (event.target.value == 'buildingarea') {
            this.isBuildingArea = true;
        }
    }

    // This Method Is Used To Handle Property Selection From Table.
    handleRadioButton(evt) {
        console.log('handleRadioButton= ', JSON.parse(JSON.stringify(evt.detail)));
        this.deedMonth = undefined;
        this.deedYear = undefined;
        this.distanceFromBranch = undefined;

        this.propertyIdFIVC = JSON.parse(JSON.stringify(evt.detail))[0].Id;
        this.handleGetEnquiryRecord();
        let row = JSON.parse(JSON.stringify(evt.detail))[0];
        this.propertyType = (row.Property_Type__c ? row.Property_Type__c.trim() : undefined);
        this.natureOfProperty = (row.Nature_Of_Property__c ? row.Nature_Of_Property__c.trim() : undefined);
        console.log('isVacant= ', this.isVacantProperty)
        this.pathwayVal = (row.Pathway_Available__c ? row.Pathway_Available__c.trim() : undefined);
        this.mortgagePropertyLivingProperty = (row.Mortgage_property_Living_property_are__c ? row.Mortgage_property_Living_property_are__c.trim() : undefined);
        this.docNorth = JSON.parse(evt.detail[0].North_By_Same_As_Document__c);
        this.docSouth = JSON.parse(evt.detail[0].South_By_Same_As_Document__c);
        this.docEast = JSON.parse(evt.detail[0].East_By_Same_As_Document__c);
        this.docWest = JSON.parse(evt.detail[0].West_By_Same_As_Document__c);

        this.landNorth = JSON.parse(evt.detail[0].North_By_Land_Same_As_Document__c);
        this.landSouth = JSON.parse(evt.detail[0].South_By_Land_Same_As_Document__c);
        this.landEast = JSON.parse(evt.detail[0].East_By_Land_Same_As_Document__c);
        this.landWest = JSON.parse(evt.detail[0].West_By_Land_Same_As_Document__c);

        this.northByLandMes = (evt.detail[0].North_by_land_measurements__c ? parseFloat(evt.detail[0].North_by_land_measurements__c.trim()) : undefined);
        this.southByLandMes = (evt.detail[0].South_by_land_measurements__c ? parseFloat(evt.detail[0].South_by_land_measurements__c.trim()) : undefined);
        this.eastByLandMes = (evt.detail[0].East_by_land_measurements__c ? parseFloat(evt.detail[0].East_by_land_measurements__c.trim()) : undefined);
        this.westByLandMes = (evt.detail[0].West_by_land_measurements__c ? parseFloat(evt.detail[0].West_by_land_measurements__c.trim()) : undefined);
        this.northByLandMesPh = (evt.detail[0].North_By_Land_Physical__c ? parseFloat(evt.detail[0].North_By_Land_Physical__c.trim()) : undefined);
        this.southByLandMesPh = (evt.detail[0].South_By_Land_Physical__c ? parseFloat(evt.detail[0].South_By_Land_Physical__c.trim()) : undefined);
        this.eastByLandMesPh = (evt.detail[0].East_By_Land_Physical__c ? parseFloat(evt.detail[0].East_By_Land_Physical__c.trim()) : undefined);
        this.westByLandMesPh = (evt.detail[0].West_By_Land_Physical__c ? parseFloat(evt.detail[0].West_By_Land_Physical__c.trim()) : undefined);

        this.mortgagePropertyArea = (row.Mortgage_Property_Area__c ? row.Mortgage_Property_Area__c.trim() : undefined);

        this.buildingAge = (row.Building_Age__c ? row.Building_Age__c.trim() : undefined);
        this.floorVal = (row.Floor__c ? row.Floor__c.trim() : undefined);
        this.buildingLength = (row.LengthSq_ft__c ? row.LengthSq_ft__c.trim() : undefined);
        this.buildingWidth = (row.WidthSq_ft__c ? row.WidthSq_ft__c.trim() : undefined);
        this.buildingValSqFt = (row.Value_per_sq_ft__c ? row.Value_per_sq_ft__c.trim() : undefined);

        this.boundariesAsPerInspectionAreSame = row.Boundaries_As_Per_Inspection_Are_Same__c;

        if (this.isGeneralDetail) {
            let data = JSON.parse(JSON.stringify(evt.detail))[0];
            if (data.Month__c) {
                this.deedMonth = data.Month__c.trim();
            } else {
                this.deedMonth = undefined;
            }
            if (data.Title_Deed_Year__c) {
                this.deedYear = data.Title_Deed_Year__c.trim();
            } else {
                this.deedYear = undefined;
            }
            if (data.Living_property_Distance_from_Branch__c) {
                this.distanceFromBranch = data.Living_property_Distance_from_Branch__c.trim();
            } else {
                this.distanceFromBranch = undefined;
            }
        }
    }

    updateBuildingValues(recordId) {
        this.showLoader = true;
        let tempId = this.propertyIdFIVC;
        deleteRelatedFloors({ propertyId: recordId }).then((result) => {
            console.log('deleteRelatedFloors = ', result);
            this.showLoader = false;
            this.propertyIdFIVC = tempId;
            if (result == 'success') {
                this.buildingAge = undefined;
                this.floorVal = undefined;
                this.totalFloorValue = undefined;
                this.totalAvgSqFtValue = undefined;
                this.totalFloorArea = undefined;
            }
        }).catch((err) => {
            this.showLoader = false;
            this.propertyIdFIVC = tempId;
            console.log('Error in Bulding Update = ', error);
        });
    }

    // This Method Is Used To Handle Enquiry Selection From Enquiry Table In Enquiry Tab.
    handleSelectedEnquiry(evt) {
        var data = evt.detail;
        if (data && data.ActionName == 'edit') {
            this.enquiryId = data.recordData.Id;
            this.enquiryNumber = data.recordData.Enquiry_Contact_Number__c;
            this.enquiryMarketValue = data.recordData.Enquiry_Market_Value__c;
        } else if (data && data.ActionName == 'delete') {
            this.enquiryId = data.recordData.Id;
            this.showDeleteModal = true;
        }
    }

    // This Method Is Used To Handle Form Values.
    handleFormValidation(evt) {
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (this.isGeneralDetail) {
            if (evt.target.name == 'Month__c') {
                this.deedMonth = evt.target.value;
            } else if (evt.target.name == 'Title_Deed_Year__c') {
                this.deedYear = evt.target.value;
            } else if (evt.target.name == 'Living_property_Distance_from_Branch__c') {
                this.distanceFromBranch = evt.target.value;
            } else if (evt.target.fieldName == 'Mortgage_property_Living_property_are__c') {
                this.mortgagePropertyLivingProperty = evt.target.value;
            } else if (evt.target.name == 'Property_Type__c') {
                this.propertyType = evt.target.value;
            } else if (evt.target.fieldName == 'Nature_Of_Property__c') {
                this.propertyType = undefined;
                this.natureOfProperty = evt.target.value;
            }
        } else if (this.isLandarea) {
            if (evt.target.fieldName == 'Pathway_Available__c') {
                this.pathwayVal = evt.target.value;
            }
        } else if (this.isMeasurement) {
            let fieldName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
            let fieldVal = evt.target.value;
            if (fieldName == 'North_By_Land_Same_As_Document__c') {
                this.landNorth = fieldVal;
                if (fieldVal) {
                    this.northByLandMesPh = this.northByLandMes;
                }
            } else if (fieldName == 'South_By_Land_Same_As_Document__c') {
                this.landSouth = fieldVal;
                if (fieldVal) {
                    this.southByLandMesPh = this.southByLandMes;
                }
            } else if (fieldName == 'East_By_Land_Same_As_Document__c') {
                this.landEast = fieldVal;
                if (fieldVal) {
                    this.eastByLandMesPh = this.eastByLandMes;
                }
            } else if (fieldName == 'West_By_Land_Same_As_Document__c') {
                this.landWest = fieldVal;
                if (fieldVal) {
                    this.westByLandMesPh = this.westByLandMes;
                }
            } else if (fieldName == 'North_by_land_measurements__c') {
                this.northByLandMes = parseFloat(fieldVal);
                if (this.landNorth) {
                    this.northByLandMesPh = fieldVal;
                }
            } else if (fieldName == 'South_by_land_measurements__c') {
                this.southByLandMes = parseFloat(fieldVal);
                if (this.landSouth) {
                    this.southByLandMesPh = fieldVal;
                }
            } else if (fieldName == 'East_by_land_measurements__c') {
                this.eastByLandMes = parseFloat(fieldVal);
                if (this.landEast) {
                    this.eastByLandMesPh = fieldVal;
                }
            } else if (fieldName == 'West_by_land_measurements__c') {
                this.westByLandMes = parseFloat(fieldVal);
                if (this.landWest) {
                    this.westByLandMesPh = fieldVal;
                }
            } else if (fieldName == 'Mortgage_Property_Area__c') {
                this.mortgagePropertyArea = fieldVal
            } else if (fieldName == 'North_By_Land_Physical__c') {
                this.northByLandMesPh = parseFloat(fieldVal);
            } else if (fieldName == 'South_By_Land_Physical__c') {
                this.southByLandMesPh = parseFloat(fieldVal);
            } else if (fieldName == 'East_By_Land_Physical__c') {
                this.eastByLandMesPh = parseFloat(fieldVal);
            } else if (fieldName == 'West_By_Land_Physical__c') {
                this.westByLandMesPh = parseFloat(fieldVal);
            }

            this.calculateLengthWidthArea();
        } else if (this.isDocBoundries) {
            let fieldName = evt.target.fieldName;
            let fieldVal = evt.target.value;
            console.log(fieldName, ' -> ', fieldVal)
            if (fieldName == 'North_By_Same_As_Document__c') {
                this.docNorth = fieldVal;
                if (fieldVal) {
                    this.template.querySelector('[data-id="North_By_Boundaries_Physical__c"]').value = this.template.querySelector('[data-id="North_by_boundaries__c"]').value;
                }
            } else if (fieldName == 'South_By_Same_As_Document__c') {
                this.docSouth = fieldVal;
                if (fieldVal) {
                    this.template.querySelector('[data-id="South_By_Boundaries_Physical__c"]').value = this.template.querySelector('[data-id="South_by_boundaries__c"]').value;
                }
            } else if (fieldName == 'East_By_Same_As_Document__c') {
                this.docEast = fieldVal;
                if (fieldVal) {
                    this.template.querySelector('[data-id="East_By_Boundaries_Physical__c"]').value = this.template.querySelector('[data-id="East_by_boundaries__c"]').value;
                }
            } else if (fieldName == 'West_By_Same_As_Document__c') {
                this.docWest = fieldVal;
                if (fieldVal) {
                    this.template.querySelector('[data-id="West_By_Boundaries_Physical__c"]').value = this.template.querySelector('[data-id="West_by_boundaries__c"]').value;
                }
            } else if (fieldName == 'North_by_boundaries__c') {
                let checkBoxValue = this.template.querySelector('[data-id="North_By_Same_As_Document__c"]').value;
                if (checkBoxValue) {
                    this.template.querySelector('[data-id="North_By_Boundaries_Physical__c"]').value = fieldVal;
                }
            } else if (fieldName == 'South_by_boundaries__c') {
                let checkBoxValue = this.template.querySelector('[data-id="South_By_Same_As_Document__c"]').value;
                if (checkBoxValue) {
                    this.template.querySelector('[data-id="South_By_Boundaries_Physical__c"]').value = fieldVal;
                }
            } else if (fieldName == 'East_by_boundaries__c') {
                let checkBoxValue = this.template.querySelector('[data-id="East_By_Same_As_Document__c"]').value;
                if (checkBoxValue) {
                    this.template.querySelector('[data-id="East_By_Boundaries_Physical__c"]').value = fieldVal;
                }
            } else if (fieldName == 'West_by_boundaries__c') {
                let checkBoxValue = this.template.querySelector('[data-id="West_By_Same_As_Document__c"]').value;
                if (checkBoxValue) {
                    this.template.querySelector('[data-id="West_By_Boundaries_Physical__c"]').value = fieldVal;
                }
            } else if (fieldName == 'Boundaries_As_Per_Inspection_Are_Same__c') {
                this.boundariesAsPerInspectionAreSame = evt.target.value;
            }
        } else if (this.isEnquiry) {
            if (evt.target.name == 'Enquiry_Contact_Number__c') {
                this.enquiryNumber = evt.target.value;
            } else if (evt.target.name == 'Enquiry_Market_Value__c') {
                this.enquiryMarketValue = evt.target.value;
            }
        }

        if (!this.isEnquiry) {
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Property__c', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.propertyIdFIVC }
            });
            this.dispatchEvent(selectedEvent);
        } else {
            let rcId = this.enquiryId ? this.enquiryId : '1';
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'CommonObject__c', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent);

            const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'CommonObject__c', subtabname: '', fieldapiname: 'Property__c', fieldvalue: this.propertyIdFIVC, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent2);

            const selectedEvent3 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'CommonObject__c', subtabname: '', fieldapiname: 'Object_Type__c', fieldvalue: 'Enquiry', recordId: rcId }
            });
            this.dispatchEvent(selectedEvent3);

            const selectedEvent4 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'CommonObject__c', subtabname: '', fieldapiname: 'Application__c', fieldvalue: this.applicationId, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent4);
        }
    }

    calculateLengthWidthArea() {
        let lengthPh = this.template.querySelector('[data-id="Land_Measurement_Length_Sq_ft__c"]').value;
        let widthPh = this.template.querySelector('[data-id="Land_Measurement_Width_Sq_ft__c"]').value;

        let lengthDoc = lengthPh;
        let widthDoc = widthPh;

        let northPh = this.northByLandMesPh ? parseFloat(this.northByLandMesPh) : 0;
        let southPh = this.southByLandMesPh ? parseFloat(this.southByLandMesPh) : 0;
        let eastPh = this.eastByLandMesPh ? parseFloat(this.eastByLandMesPh) : 0;
        let westPh = this.westByLandMesPh ? parseFloat(this.westByLandMesPh) : 0;

        let northDoc = this.northByLandMes ? parseFloat(this.northByLandMes) : 0;
        let southDoc = this.southByLandMes ? parseFloat(this.southByLandMes) : 0;
        let eastDoc = this.eastByLandMes ? parseFloat(this.eastByLandMes) : 0;
        let westDoc = this.westByLandMes ? parseFloat(this.westByLandMes) : 0;

        if (northPh > 0 || southPh > 0) {
            lengthPh = (northPh + southPh) / 2;
        } else {
            lengthPh = 0;
        }
        if (eastPh > 0 || westPh > 0) {
            widthPh = (eastPh + westPh) / 2;
        } else {
            widthPh = 0;
        }

        if (northDoc > 0 || southDoc > 0) {
            lengthDoc = (northDoc + southDoc) / 2;
        } else {
            lengthDoc = 0;
        }
        if (eastDoc > 0 || westDoc > 0) {
            widthDoc = (eastDoc + westDoc) / 2;
        } else {
            widthDoc = 0;
        }

        console.log('lengthPh= ', lengthPh);
        console.log('widthPh= ', widthPh);

        console.log('lengthDoc= ', lengthDoc);
        console.log('widthDoc= ', widthDoc);

        let finalLength = 0;
        let finalWidth = 0;

        if (lengthDoc && widthDoc) {
            this.template.querySelector('[data-id="Land_Total_Area_Doc__c"]').value = (lengthDoc * widthDoc);
        } else {
            this.template.querySelector('[data-id="Land_Total_Area_Doc__c"]').value = finalLength;
        }

        if (lengthPh && widthPh) {
            this.template.querySelector('[data-id="Land_Total_Area_Phy__c"]').value = (lengthPh * widthPh);
        } else {
            this.template.querySelector('[data-id="Land_Total_Area_Phy__c"]').value = 0;
        }

        if ((lengthDoc * widthDoc) < (lengthPh * widthPh)) {
            finalLength = lengthDoc;
            finalWidth = widthDoc;
            // if ((lengthDoc * widthDoc) != 0) {
            //     this.landMeasurementArea = finalLength * finalWidth;
            // } else {
            //     this.landMeasurementArea = 0;
            // }
        } else {
            finalLength = lengthPh;
            finalWidth = widthPh;
        }

        this.template.querySelector('[data-id="Land_Measurement_Length_Sq_ft__c"]').value = finalLength;
        this.template.querySelector('[data-id="Land_Measurement_Width_Sq_ft__c"]').value = finalWidth;

        if (finalLength && finalWidth) {
            this.landMeasurementArea = finalLength * finalWidth;
            console.log('this.landMeasurementArea= ', this.landMeasurementArea);
        } else {
            this.landMeasurementArea = 0;
        }
    }

    // This Method Is Used To Handle Form Calculations.
    handleFormCalculation(evt) {
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (evt.target.name == 'LengthSq_ft__c' || evt.target.name == 'WidthSq_ft__c' || evt.target.name == 'Value_per_sq_ft__c') {
            this.buildingLength = (evt.target.name == 'LengthSq_ft__c' ? evt.target.value : this.buildingLength);
            this.buildingWidth = (evt.target.name == 'WidthSq_ft__c' ? evt.target.value : this.buildingWidth);
            this.buildingValSqFt = (evt.target.name == 'Value_per_sq_ft__c' ? evt.target.value : this.buildingValSqFt);
            this.totalValue = this.buildingLength * this.buildingWidth * this.buildingValSqFt;
            this.totalArea = this.buildingLength * this.buildingWidth;
        } else if (evt.target.fieldName == 'Land_Measurement_Length_Sq_ft__c' || evt.target.fieldName == 'Land_Measurement_Width_Sq_ft__c') {
            let lengthSqFt = this.template.querySelector('[data-id="Land_Measurement_Length_Sq_ft__c"]').value !== undefined ? this.template.querySelector('[data-id="Land_Measurement_Length_Sq_ft__c"]').value : 0;
            let widthSqFt = this.template.querySelector('[data-id="Land_Measurement_Width_Sq_ft__c"]').value !== undefined ? this.template.querySelector('[data-id="Land_Measurement_Width_Sq_ft__c"]').value : 0;
            this.landMeasurementArea = lengthSqFt * widthSqFt;
        } else if (evt.target.fieldName == 'Adopted_Value_Per_SqFt__c') {
            console.log('Adopted_Value Changed = ', evt.target.value);
            let highestAdoptedValue = (this.highestMarketValue >= 0 ? (this.highestMarketValue / 100 * 90) : 0);
            let inputBox = this.template.querySelector('[data-id="Adopted_Value_Per_SqFt__c"]');
            let adoptedMarketValPerSqFt = inputBox.value !== undefined ? inputBox.value : 0;
            if (highestAdoptedValue < adoptedMarketValPerSqFt) {
                this.showNotifications('', 'Adopted Value can not be greater than 90% of Market Value', 'error');
                inputBox.reset();
                return;
            }

            let totalAreaValuation = 0;
            if (this.propertyData && this.propertyData.strDataTableData && JSON.parse(this.propertyData.strDataTableData).length) {
                JSON.parse(this.propertyData.strDataTableData).forEach(element => {
                    console.log('Property Ids = ', element.Id, ' == ', this.propertyIdFIVC);
                    if (element.Id == this.propertyIdFIVC) {
                        console.log('element.Land_Measurement_total_area__c= ', element.Land_Measurement_total_area__c);
                        totalAreaValuation = element.Land_Measurement_total_area__c;
                    }
                });
            }
            console.log('adoptedMarketValPerSqFt = ', adoptedMarketValPerSqFt);
            console.log('totalAreaValuation = ', totalAreaValuation);
            this.finalLandValue = totalAreaValuation * adoptedMarketValPerSqFt;
            console.log('finalLandValue = ', this.finalLandValue);
        } else if (evt.target.name == 'Building_Age__c') {
            this.buildingAge = evt.target.value;
        } else if (evt.target.name == 'Floor__c') {
            this.floorVal = evt.target.value;
            console.log('floor change= ', evt.target.value);
        }

        if (!this.isEnquiry) {
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Property__c', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.propertyIdFIVC }
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    makeAllBlank() {
        this.propertyType = undefined;
        this.pathwayVal = undefined;
        this.mortgagePropertyLivingProperty = undefined;
        this.docNorth = undefined;
        this.docSouth = undefined;
        this.docEast = undefined;
        this.docWest = undefined;
        this.landNorth = undefined;
        this.landSouth = undefined;
        this.landEast = undefined;
        this.landWest = undefined;
        this.mortgagePropertyArea = undefined;
        this.buildingAge = undefined;
        this.floorVal = undefined;
        this.buildingLength = undefined;
        this.buildingWidth = undefined;
        this.buildingValSqFt = undefined;
    }

    // This Method Is Used To Show Toast Notification.
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    // This Method Is Used To Check Collateral Validation.
    @api
    checkCollateralValidation() {
        console.log('Check Collateral Validation= ', this.propertyData);
        this.collateralValidation = {
            generalDetail: true,
            landAreaVal: true,
            docBoundries: true,
            enquiry: true,
            buildingAreaVal: true,
            landMeasurement: true,
            valuation: true
        };

        if ((this.propertyData && this.propertyData.strDataTableData && JSON.parse(this.propertyData.strDataTableData).length)) {
            JSON.parse(this.propertyData.strDataTableData).forEach(element => {
                if (!element.Document_Type__c) {
                    this.collateralValidation.generalDetail = false;
                    console.log('1');
                }
                else if (element.Document_Type__c && !element.Document_Type__c.trim()) {
                    this.collateralValidation.generalDetail = false;
                    console.log('1.5');
                }
                if (!element.Pathway_Available__c) {
                    this.collateralValidation.landAreaVal = false;
                    console.log('2');
                } else if (element.Pathway_Available__c && !element.Pathway_Available__c.trim()) {
                    this.collateralValidation.landAreaVal = false;
                    console.log('2.5');
                }
                if (element.Boundaries_As_Per_Inspection_Are_Same__c == null || element.Boundaries_As_Per_Inspection_Are_Same__c == undefined ||
                    element.Boundaries_As_Per_Inspection_Are_Same__c == '' || element.Boundaries_As_Per_Inspection_Are_Same__c.trim() == '') {
                    this.collateralValidation.docBoundries = false;
                    console.log('3');
                }
                if (element.Property_Type__c != 'Vacant Land') {
                    if (!element.Building_Age__c) {
                        this.collateralValidation.buildingAreaVal = false;
                        console.log('4');
                    } else if (element.Building_Age__c && !element.Building_Age__c.trim()) {
                        this.collateralValidation.buildingAreaVal = false;
                        console.log('4.5');
                    }
                }
                if (element.North_by_land_measurements__c == null || element.North_by_land_measurements__c == undefined || element.North_by_land_measurements__c == '' || element.North_by_land_measurements__c.trim() == '') {
                    this.collateralValidation.landMeasurement = false;
                    console.log('5');
                }
                if (element.Valuation_Market_Value_Per_SqFt__c == null || element.Valuation_Market_Value_Per_SqFt__c == undefined || element.Valuation_Market_Value_Per_SqFt__c == '' || element.Valuation_Market_Value_Per_SqFt__c.trim() == '') {
                    this.collateralValidation.valuation = false;
                    console.log('6');
                }

                if (!(this.enquiryMap && this.enquiryMap[element.Id] && this.enquiryMap[element.Id].length >= 3)) {
                    this.collateralValidation.enquiry = false;
                    console.log('7');
                }
            });
        }

        console.log('checkCollateralValidation = ', this.collateralValidation);
        this.dispatchEvent(new CustomEvent('collateralvalidation', {
            detail: this.collateralValidation
        }));
    }

    // This Method Is Used To Handle Cancel Action On Table.
    onCancel() {
        if (this.isEnquiry) {
            this.enquiryId = undefined;
            this.enquiryNumber = undefined;
            this.enquiryMarketValue = undefined;
            this.isEnquiry = false;
            let ref = this;
            this.showLoader = true;
            setTimeout(function () {
                ref.isEnquiry = true;
                ref.showLoader = false;
            }, 200);
        } else {
            this.propertyIdFIVC = undefined;
            this.handleGetFIVProperty();
            this.deedMonth = undefined;
            this.deedYear = undefined;
            this.distanceFromBranch = undefined;
        }
    }

    // This Method Is Used To Check Valid Inputs On Form.
    checkInputValidity() {
        if (this.isGeneralDetail) {
            console.log('checkinput= ', this.template.querySelectorAll(".general"));
            const allValid = [
                ...this.template.querySelectorAll(".general"),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            return allValid;
        } else if (this.isBuildingArea) {
            console.log('checkinput= ', this.template.querySelectorAll(".buildingarea"));
            const allValid = [
                ...this.template.querySelectorAll(".buildingarea"),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            return allValid;
        }
        return true;
    }

    // This Method Is Used To Show Loader For Short Time.
    showTemporaryLoader() {
        this.showLoader = true;
        let ref = this;
        setTimeout(function () {
            ref.showLoader = false;
        }, 500);
    }

    handleFloorValues(event) {
        console.log('handleFloorValues= ', JSON.parse(JSON.stringify(event.detail)));
        this.totalFloorValue = event.detail.totalValue;
        this.totalAvgSqFtValue = event.detail.averageValuePerSqFt;
        this.totalFloorArea = event.detail.totalArea;
        console.log('this.isUnsaved = ', this.isUnsaved);
        // this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log('FORM = ', this.template.querySelector('[data-id="buildingForm"]'));
        let formCmp = this.template.querySelector('[data-id="buildingForm"]');
        setTimeout(() => {
            formCmp.submit();
        }, 300);
    }

    // This Method Is Used To Handle Post Submit Actions.
    handleSubmit(event) {
        console.log('handleSubmit called= ', this.isUnsaved);
        let checkValidation = this.checkInputValidity();
        if (this.isBuildingArea && !this.isUnsaved) {
            console.log('INSIDE FLOOR UPDATE')
            this.isUnsaved = true;
            this.template.querySelector('c-fs-building-floor-cmp').handleSave();
            event.preventDefault();
            return;
        }
        if (!checkValidation) {
            event.preventDefault();
            this.showNotifications('Invalid input', 'You haven\'t entered correct data', 'error');
        } else {
            this.showTemporaryLoader();
            if (this.isGeneralDetail) {
                if (this.isVacantProperty) {
                    this.updateBuildingValues(this.propertyIdFIVC);
                }
            }
        }
    }

    // This Method Is Used To Handle Post Success Actions.
    handleSuccess(event) {
        this.isUnsaved = false;
        let propertyId = this.propertyIdFIVC;
        this.propertyIdFIVC = undefined;
        console.log('handleSuccess called');
        this.showNotifications('', 'Collateral Updated Successfully.', 'success')
        this.propertyData = undefined;

        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Property__c', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);

        setTimeout(() => {
            this.propertyIdFIVC = propertyId;
        }, 100);
        this.handleGetFIVProperty();
    }

    // This Method Is Used To Handle Post Enquiry Submit Actions.
    handleEnquirySubmit() {
        console.log('handleEnquirySubmit called');
    }

    // This Method Is Used To Handle Post Enquiry Success Actions.
    handleEnquirySuccess() {
        console.log('handleEnquirySuccess called');
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'CommonObject__c', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);
        this.isEnquiry = false;
        this.enquiryId = undefined;
        this.enquiryNumber = undefined;
        this.enquiryMarketValue = undefined;
        this.handleGetEnquiryRecord();
        this.handleGetEnquiryMap();
        let ref = this;
        setTimeout(() => {
            ref.isEnquiry = true;
        }, 100);
    }

    // This Method Is Used To Handle Delete Action On Enquiry Table.
    handleDelete(event) {
        console.log('handleDelete= ', event.target.label)
        let label = event.target.label;
        this.showDeleteModal = false;
        if (label == 'Yes') {
            this.handleDeleteRecord(this.enquiryId);
        } else if (label == 'No') {
            this.enquiryId = undefined;
        }
    }

    /* --------------------All Server Methods------------------- */

    // This Method Is Used To Get Property Table Records From Server Side.
    handleGetFIVProperty() {
        this.showLoader = true;
        this.propertyData = undefined;
        getCollateralTabRecords({ appId: this.applicationId, metadataName: 'FIV_C_Property' }).then((result) => {
            console.log('handleGetFIVProperty= ', result);
            this.propertyData = JSON.parse(JSON.stringify(result));
            this.checkCollateralValidation();
            if (this.propertyData && this.propertyData.strDataTableData && JSON.parse(this.propertyData.strDataTableData).length) {
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Property__c', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
            }
            this.showLoader = false;
        }).catch((err) => {
            console.log('Error in handleGetFIVProperty= ', err);
            this.checkCollateralValidation();
            this.showLoader = false;
        });
    }

    // This Method Is Used To Get Table Records For Enquiry Tab.
    handleGetEnquiryRecord() {
        this.showLoader = true;
        this.enquiryData = undefined;
        getCollateralEnquiryRecords({ appId: this.applicationId, propertyId: this.propertyIdFIVC }).then((result) => {
            console.log('handleGetEnquiryRecord= ', result);
            this.showLoader = false;
            this.enquiryData = JSON.parse(JSON.stringify(result));;
            if (this.enquiryData && this.enquiryData.strDataTableData && JSON.parse(this.enquiryData.strDataTableData).length) {
                this.highestMarketValue = 0;
                JSON.parse(this.enquiryData.strDataTableData).forEach(currentItem => {
                    if (this.highestMarketValue < parseFloat(currentItem.Enquiry_Market_Value__c)) {
                        this.highestMarketValue = parseFloat(currentItem.Enquiry_Market_Value__c);
                    }
                });
            }
            console.log('highestMarketValue = ', this.highestMarketValue);
        }).catch((err) => {
            console.log('Error in handleGetEnquiryRecord= ', err);
            this.showLoader = false;
        });
    }

    // This Method Is Used TO delete Records.
    handleDeleteRecord(recordIdToDelete) {
        this.showTemporaryLoader();
        deleteRecord({ recordId: recordIdToDelete }).then((result) => {
            console.log('handleDeleteRecord = ', result);
            if (result == 'success') {
                this.showNotifications('', 'Record deleted successfully', 'success');
                let ref = this;
                setTimeout(() => {
                    ref.handleEnquirySuccess();
                }, 400);
            }
        }).catch((err) => {
            console.log('Error in handleDeleteRecord = ', err);
        });
    }

    handleGetEnquiryMap() {
        this.enquiryMap = undefined;
        getEnquiryMap({ appId: this.applicationId }).then((result) => {
            console.log('GetEnquiryMap = ', result);
            this.enquiryMap = JSON.parse(JSON.stringify(result));
            if (this.enquiryMap) {
                for (let keyValue of Object.keys(JSON.parse(JSON.stringify(this.enquiryMap)))) {
                    console.log('GetEnquiryMap Rows= ', JSON.parse(JSON.stringify(this.enquiryMap[keyValue])))
                    if (this.enquiryMap[keyValue] && this.enquiryMap[keyValue]) {
                        JSON.parse(JSON.stringify(this.enquiryMap[keyValue])).forEach(enquiry => {
                            for (let keyValueChild of Object.keys(enquiry)) {
                                if (keyValueChild != 'Id') {
                                    const selectedEvent = new CustomEvent("handletabvaluechange", {
                                        detail: { tabname: 'CommonObject__c', subtabname: '', fieldapiname: keyValueChild, fieldvalue: enquiry[keyValueChild], recordId: enquiry.Id }
                                    });
                                    this.dispatchEvent(selectedEvent);
                                }
                            }
                        });
                    }
                }
            }
            this.checkCollateralValidation();
        }).catch((err) => {
            this.checkCollateralValidation();
            console.log('Error in GetEnquiryMap = ', err)
        });
    }
}