import { LightningElement, api, track, wire } from 'lwc';
import getPropertyData from '@salesforce/apex/FSFivBLwcController.getPropertyData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FSFivBLwcController.getAllApplicantMeta';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import saveRecord from '@salesforce/apex/FSFivBLwcController.saveRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSectionContent from '@salesforce/apex/FSFivBLwcController.getSectionContent';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import Nature_Of_Property from '@salesforce/schema/Property__c.Nature_Of_Property__c';
import FINAL_COLLATERAL_VALUES from '@salesforce/schema/Application__c.FIVB_Final_Collateral_Value__c';
import TOTAL_LAND_AREA from '@salesforce/schema/Application__c.FIVB_Total_Land_Area__c';
import TOTAL_BUILDING_AREA from '@salesforce/schema/Application__c.FIVB_Total_Building_Area__c';
import APPLICATION_ID from '@salesforce/schema/Application__c.Id';
import getPincodeDetails from '@salesforce/apex/DatabaseUtililty.getPincodeDetails';
import getCollateralTabRecords from '@salesforce/apex/FIV_C_Controller.getCollateralTabRecords';

const Property_FIELDS = [
    'Property__c.Property_Type__c',
    'Property__c.Nature_Of_Property__c'
]

export default class fsFiv_B_Collateral extends LightningElement {
    @api allLoanApplicant;
    @track rowAction = [
        {
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
    ]
    @api applicationId;
    @track isSpinnerActive = true;
    @track tableData;
    @track fieldsContent;
    @track objectIdMap = { 'Property__c': '' };
    @track recordIds;
    @track showDeleteModal = false;
    @track recordIdForDelete;
    @track isApplicantEdit = true;
    @track selectedApplicant;
    @api allApplicantData;
    @api verificationStatus;
    @track propertyRecordTypeId;
    @track natureOfProperty;
    @api typeofProperty;
    @track natureOfPropertyTypeOptions;

    @track propertyIdFIVC;
    @track propertyData;

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

    @track enquiryMap;
    @track enquiryData;
    @track enquiryId;
    @track highestMarketValue;

    @track isSpinnerActive = false;
    @track isUnsaved = false;

    @track city;
    @track state;
    @track district;
    @track taluka;

    get propertyTypeOptions() {
        if (this.natureOfProperty == 'Vacant Land') {
            return [{ label: 'Vacant Land', value: 'Vacant Land' }];
        }
        else if (this.natureOfProperty == 'Residential') {
            return [{ label: 'Flat', value: 'Flat' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'House', value: 'House' }];
        }
        // else if (this.natureOfProperty == 'Institutional') {
        //     return [{ label: 'Office', value: 'Office' },
        //     { label: 'Vacant Land', value: 'Vacant Land' }];
        // }
        else if (this.natureOfProperty == 'Commercial') {
            return [{ label: 'Office', value: 'Office' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'Shop', value: 'Shop' }];
        }
    }

    get showBoundariesSameRemarks() {
        return this.boundariesAsPerInspectionAreSame == 'No' ? true : false;
    }

    get isVacantProperty() {
        return this.propertyType == 'Vacant Land' ? true : false;
    }

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getPropertyObjectData({ data, error }) {
        if (data) {
            var recordTypeData = data.recordTypeInfos;
            this.propertyRecordTypeId = Object.keys(recordTypeData).find(rti => recordTypeData[rti].name === 'FIV-B Property Detail');
        }
    }
    connectedCallback() {
        this.getPropertyData();
        console.log('allApplicantData ## ', JSON.stringify(this.allApplicantData));
        this.verificationStatus == 'Completed' ? true : false;

    }

    @wire(getPicklistValues, {
        recordTypeId: "$propertyRecordTypeId",
        fieldApiName: Nature_Of_Property
    })
    natureOfproperties;



    @wire(getRecord, { recordId: '$recordIds', fields: Property_FIELDS })
    property({ error, data }) {
        if (data) {

            if (data.fields.Nature_Of_Property__c.value != undefined && data.fields.Nature_Of_Property__c.value != null &&
                data.fields.Nature_Of_Property__c.value != '') {
                this.natureOfProperty = data.fields.Nature_Of_Property__c.value;
            }
            if (data.fields.Property_Type__c.value != undefined && data.fields.Property_Type__c.value != null &&
                data.fields.Property_Type__c.value != '') {
                this.typeofProperty = data.fields.Property_Type__c.value;
            }
        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }

    getAllPincodeDetails(pinId) {
        getPincodeDetails({ pinId: pinId })
            .then(result => {
                console.log(result);
                this.city = result.city;
                this.state = result.state;
                this.district = result.district;
                this.taluka = result.taluka;
                let genericedit = this.template.querySelector('c-generic-edit-pages-l-w-c');
                console.log('field ', this.fieldsContent);
                console.log('check ', this.setValues('City__c', this.city));
                this.fieldsContent = (JSON.stringify(this.setValues('City__c', this.city)));
                this.fieldsContent = (JSON.stringify(this.setValues('District__c', this.district)));
                this.fieldsContent = (JSON.stringify(this.setValues('State__c', this.state)));
                this.fieldsContent = (JSON.stringify(this.setValues('Taluka__c', this.taluka)));

                genericedit.refreshData((this.fieldsContent));
            })
            .catch(error => {
                console.log(error);
            })
    }


    todayDate() {
        var today = new Date();
        var dd = today.getDate() - 1;
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var todayDate = yyyy + '-' + mm + '-' + dd;
        return todayDate;
    }

    getPropertyData() {
        getPropertyData({ applicationId: this.applicationId })
            .then(result => {
                if (result && result.strDataTableData) {
                    this.handleApplicationUpdation(result);
                }
                console.log('api called from property', result);
                this.isApplicantEdit = true;
                this.tableData = result;
                this.isSpinnerActive = false;
            })
            .catch(error => {

            })
    }

    handleApplicationUpdation(result) {
        if (result && result.strDataTableData) {
            var totalCollateralValue = 0;
            var totalLandAreaValue = 0;
            var totalBuildingAreaValue = 0;
            // JSON.parse(result.strDataTableData).forEach(currentItem => {
            //     totalCollateralValue += (currentItem.Total_Value__c != undefined ? Number(currentItem.Total_Value__c) : 0);
            //     totalLandAreaValue += (currentItem.Land_Area_Sq_Ft__c != undefined ? Number(currentItem.Land_Area_Sq_Ft__c) : 0);
            //     totalBuildingAreaValue += (currentItem.Building_Area_Sq_Ft__c != undefined ? Number(currentItem.Building_Area_Sq_Ft__c) : 0);
            // });
            JSON.parse(result.strDataTableData).forEach(currentItem => {
                totalCollateralValue += (currentItem.Total_Collateral_Value__c  != undefined ? Number(currentItem.Total_Collateral_Value__c) : 0);
                totalLandAreaValue += (currentItem.Valuation_Final_land_value__c != undefined ? Number(currentItem.Valuation_Final_land_value__c) : 0);
                totalBuildingAreaValue += (currentItem.Total_Floor_Value__c != undefined ? Number(currentItem.Total_Floor_Value__c) : 0);
            });
        }

        const fields = {};
        fields[APPLICATION_ID.fieldApiName] = this.applicationId;
        fields[FINAL_COLLATERAL_VALUES.fieldApiName] = totalCollateralValue;
        fields[TOTAL_LAND_AREA.fieldApiName] = totalLandAreaValue;
        fields[TOTAL_BUILDING_AREA.fieldApiName] = totalBuildingAreaValue;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('fivbbbb  Total collateral value Updated ###');
            })
            .catch(error => {
                console.log('Error in updating fivbbb total collateral value ###', error);
            });

    }
    getSectionPageContent(recId) {
        this.isSpinnerActive = true;
        getSectionContent({ recordIds: recId, metaDetaName: 'Fs_FIV_B_Collateral' })
            .then(result => {
                this.fieldsContent = result.data;
                console.log('this.fieldsContent #### ', this.fieldsContent);
                /*setTimeout(() => {
                    var _tempVar = JSON.parse(this.fieldsContent);
                    for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                        if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Title_Deed_Date__c') {
                            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Title_Deed_Date__c',''))); 
                        }
                    }    
                }, 500);
                */
                this.isSpinnerActive = false;
            })
            .catch(error => {
                console.log(error);
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

    handlePropertyDetailsValidation(evt) {

        console.log('chnage field>>>> ', evt.target.name);
        console.log('changed value>>>>>> ', evt.target.value);

        // const selectedEvent = new CustomEvent("handletabvaluechange", {
        //     detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: evt.target.name, fieldvalue: evt.target.value, recordId: this.recordIds }
        // });

        // // Dispatches the event.
        // this.dispatchEvent(selectedEvent);


        if (this.tableData) {
            if (evt.target.name == 'Nature_Of_Property__c') {
                this.natureOfProperty = evt.target.value;
                this.typeofProperty = undefined;
            }
            else if (evt.target.name == 'Type_Of_Property__c') {
                console.log('Type of Property Type ###', (evt.target.value).length);
                this.typeofProperty = evt.target.value;
            }
        }
    }

     // This Method Is Used To Handle Form Values.
     handleFormValidation(evt) {
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (this.isLandarea) {
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
        } else if (this.isValuation){
            if(fName == 'Valuation_Market_Value_Per_SqFt__c'){
                this.highestMarketValue = fValue;
            }
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
            if (this.tableData && this.tableData.strDataTableData && JSON.parse(this.tableData.strDataTableData).length) {
                JSON.parse(this.tableData.strDataTableData).forEach(element => {
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

    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.isSpinnerActive = true;
        var recordData = event.detail.recordData;
        if (event.detail.ActionName === 'edit') {
            this.isApplicantEdit = false;
            this.recordIds = recordData.Id;
            this.objectIdMap['Property__c'] = this.recordIds
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            this.showDeleteModal = true;
        }
    }
    changedFromChild(event) {
        console.log('event details #### ', JSON.stringify(event.detail));
        var tempFieldsContent = event.detail;
        if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-Customers_Residing__c') {
            var isRequired = (tempFieldsContent.previousData['Property__c-Customers_Residing__c'] == 'Yes' || tempFieldsContent.previousData['Property__c-Customers_Residing__c'] == '') ? 'isRequired-Yes' : 'isRequired-No';
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('If_No_Reason__c', isRequired)));
        }
        // if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-Land_Area_Sq_Ft__c' || tempFieldsContent.CurrentFieldAPIName === 'Property__c-Building_Area_Sq_Ft__c' || tempFieldsContent.CurrentFieldAPIName === 'Property__c-Value_per_sq_ft__c' || tempFieldsContent.CurrentFieldAPIName === 'Property__c-Building_Value_per_Sq_ft__c') {
        //     var totalArea = Number(tempFieldsContent.previousData['Property__c-Land_Area_Sq_Ft__c']) + Number(tempFieldsContent.previousData['Property__c-Building_Area_Sq_Ft__c']);
        //     this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Total_Area__c', totalArea)));
        //     var totalAreaValuation = (Number(tempFieldsContent.previousData['Property__c-Land_Area_Sq_Ft__c']) * Number(tempFieldsContent.previousData['Property__c-Value_per_sq_ft__c'])) + (Number(tempFieldsContent.previousData['Property__c-Building_Area_Sq_Ft__c']) * Number(tempFieldsContent.previousData['Property__c-Building_Value_per_Sq_ft__c']));
        //     this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Total_Value__c', totalAreaValuation)));
        // }
        if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-Title_Deed_Date__c') {
            var _val = tempFieldsContent.CurrentFieldValue;
            console.log(' _val #### ', _val);
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Title_Deed_Date__c', _val)));
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-MS_Pincode__c') {
            console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
            if (tempFieldsContent.CurrentFieldValue != true)
                this.getAllPincodeDetails(tempFieldsContent.CurrentFieldValue);
            else {
                let genericedit = this.template.querySelector('c-generic-edit-pages-l-w-c');
                this.fieldsContent = (JSON.stringify(this.setValues('City__c', null)));
                this.fieldsContent = (JSON.stringify(this.setValues('District__c', null)));
                this.fieldsContent = (JSON.stringify(this.setValues('State__c', null)));
                this.fieldsContent = (JSON.stringify(this.setValues('Taluka__c', null)));
                genericedit.refreshData((this.fieldsContent));
            }
        }
    }
    handleSave() {
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data #### ', JSON.stringify(data));
        console.log('this.natureOfProperty>>> ', this.natureOfProperty)
        if (!this.natureOfProperty) {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field, Nature Of Property');
            return;
        }
        if (!this.typeofProperty) {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field, Type Of Property');
            return;
        }
        if (data.length > 0) {
            this.isSpinnerActive = true;
            for (var i = 0; i < data.length; i++) {
                if (this.selectedApplicant === undefined) {
                    data[i].Id = this.objectIdMap[data[i].sobjectType];
                } else {
                    data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
                    data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
                    data[i].RecordTypeId = this.propertyRecordTypeId;
                    data[i].Application__c = this.applicationId;
                }
                data[i].Is_Fiv_B_Completed__c = true;
                //delete data[i].Total_Area__c;
                //delete data[i].Total_Value__c;
                //delete data[i].Title_Deed_Date__c;
                data[i].Nature_Of_Property__c = this.natureOfProperty;
                data[i].Property_Type__c = this.typeofProperty;

                console.log('data #### ', JSON.stringify(data[i]));
                saveRecord({ dataToInsert: data[i] })
                    .then(result => {
                        this.fieldsContent = undefined;
                        this.showtoastmessage('Success', 'Success', result);
                        this.tableData = undefined;
                        this.selectedApplicant = undefined;
                        this.allApplicantData = undefined;
                        this.getPropertyData();
                        this.getAllApplicantMeta();
                        this.dispatchEvent(new CustomEvent('updatedcollateralforroisummary'));
                    })
                    .catch(error => {
                        console.log(error);
                        this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                    });
            }
        } else {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
        }
    }
    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = undefined;
        this.isApplicantEdit = true;
        this.allApplicantData = undefined;
        this.getAllApplicantMeta();
    }

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

    
    showtoastmessage(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    handleDelete(event) {
        this.isSpinnerActive = true;
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            deleteRecord(this.recordIdForDelete)
                .then(() => {
                    this.tableData = undefined;
                    this.getPropertyData();
                    this.isSpinnerActive = false;
                })
                .catch(error => {
                    console.log(error);
                });
        } else if (label == 'No') {
            this.showDeleteModal = false;
            this.isSpinnerActive = false;
        }
    }
    handleRadtioButton(event) {
        this.getSectionPageContent();
        this.selectedApplicant = event.detail;
        console.log('event #### ', JSON.stringify(event.detail));
    }
    getAllApplicantMeta() {
        getAllApplicantMeta({ applicationId: this.applicationId })
            .then(result => {
                this.allApplicantData = result;
                this.isSpinnerActive = false;
            })
            .catch(error => {

            })
    }
    setValues(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName && _tempVar[0].fieldsContent[i].fieldAPIName === 'Title_Deed_Date__c') {
                _tempVar[0].fieldsContent[i].maxDate = this.todayDate();
                _tempVar[0].fieldsContent[i].value = _val;
            }
            else if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName && _tempVar[0].fieldsContent[i].fieldAPIName !== 'Title_Deed_Date__c') {
                if (_val == 'isRequired-Yes' || _val == 'isRequired-No') {
                    _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = _val == 'isRequired-No' ? true : false;
                } else {
                    if (_tempVar[0].fieldsContent[i].isCheckbox) {
                        _tempVar[0].fieldsContent[i].checkboxVal = Boolean(_val);
                    } else {
                        _tempVar[0].fieldsContent[i].value = _val;
                    }
                }

            }
        }
        console.log('_tempVar #### ', _tempVar);
        this.fieldsContent = JSON.stringify(_tempVar);
        return _tempVar;
    }
    todayDate() {
        var today = new Date();
        var dd = today.getDate() - 1;
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var todayDate = yyyy + '-' + mm + '-' + dd;
        console.log('todayDate ### ', todayDate);
        return todayDate;
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

        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Property__c', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);

        setTimeout(() => {
            this.propertyIdFIVC = propertyId;
        }, 100);
        this.handleGetFIVProperty();
    }

    updateBuildingValues(recordId) {
        this.isSpinnerActive = true;
        let tempId = this.propertyIdFIVC;
        deleteRelatedFloors({ propertyId: recordId }).then((result) => {
            console.log('deleteRelatedFloors = ', result);
            this.isSpinnerActive = false;
            this.propertyIdFIVC = tempId;
            if (result == 'success') {
                this.buildingAge = undefined;
                this.floorVal = undefined;
                this.totalFloorValue = undefined;
                this.totalAvgSqFtValue = undefined;
                this.totalFloorArea = undefined;
            }
        }).catch((err) => {
            this.isSpinnerActive = false;
            this.propertyIdFIVC = tempId;
            console.log('Error in Bulding Update = ', error);
        });
    }

    // This Method Is Used To Get Property Table Records From Server Side.
    handleGetFIVProperty() {
        this.isSpinnerActive = true;
        this.propertyData = undefined;
        getCollateralTabRecords({ appId: this.applicationId, metadataName: 'FIV_C_Property' }).then((result) => {
            console.log('handleGetFIVProperty= ', result);
            this.propertyData = JSON.parse(JSON.stringify(result));
            this.checkCollateralValidation();
            this.isSpinnerActive = false;
        }).catch((err) => {
            console.log('Error in handleGetFIVProperty= ', err);
            this.checkCollateralValidation();
            this.isSpinnerActive = false;
        });
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

    // This Method Is Used To Show Loader For Short Time.
    showTemporaryLoader() {
        this.isSpinnerActive = true;
        let ref = this;
        setTimeout(function () {
            ref.isSpinnerActive = false;
        }, 500);
    }

    // This Method Is Used To Show Toast Notification.
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
}