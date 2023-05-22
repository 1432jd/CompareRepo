import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypeId from '@salesforce/apex/fsPcAcController.getRecordTypeId';
import getACCollateralTabRecords from '@salesforce/apex/fsPcAcController.getACCollateralTabRecords';
import { getRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import deleteRelatedFloors from '@salesforce/apex/FS_BuildingFloorController.deleteRelatedFloors';
import getHighestPropertyValueMap from '@salesforce/apex/fsPcAcController.getHighestPropertyValueMap';

const Property_FIELDS = [
    'Property__c.Building_Area_Sq_Ft__c',
    'Property__c.Building_Value_per_Sq_ft__c',
    'Property__c.Land_Area_Sq_Ft__c',
    'Property__c.Valuation_Market_Value_Per_SqFt__c',
    'Property__c.Month__c',
    'Property__c.Title_Deed_Year__c',
    'Property__c.Type_Of_Property__c',
    'Property__c.Living_property_Distance_from_Branch__c',
    'Property__c.Mortgage_property_distance_from_branch__c',
    'Property__c.Mortgage_property_Living_property_are__c',
    'Property__c.Person_residing_at_Mortgage_property__c',
    'Property__c.Is_living_property_is_own_property__c',
    'Property__c.Living_property_Pincode__c',
    'Property__c.Pathway_Available__c',
    'Property__c.Boundaries_As_Per_Inspection_Are_Same__c',
    'Property__c.Property_Type__c',
    'Property__c.Nature_Of_Property__c',
    'Property__c.Title_Deed_Number__c',
    'Property__c.Pincode__c',
    'Property__c.Building_Age__c'
];

export default class PcProperty extends LightningElement {
    
    @api objName;
    @api sectiontitle;
    @api propertyRecordId;
    @api isGeneralDetails;
    @api isLandAreaAndValuation;
    @api isBuildingAreaAndValuation;
    @api applicationId;
    @api loginId;
    @api parentPropertyId;
    @api recordId;
    @api relationshipId;
    @api typeofProperty;
    @api titleDeedNumber;
    @track deedMonth;
    @track deedYear;
    @track distanceFromBranch;
    @track buildingAge;
    @track pathValue;
    @track showThis = false;
    @track showpathRemarks = false;
    @track showBoundaries = false;
    @track mortgageRemarks;
    @track finalLandValue;
    @track propertyRecordTypeId;
    @track pchasBuildingValue = false;
    @track pchasLandValue = false;
    @track isCollateralData = false;
    @track collateralTable = [];
    @track showCollateralForm = false;
    @track isAc = false;
    @track pcLandArea;
    @track pcLandValue;
    @track pcbuildingArea;
    @track pcbuildingValue;
    @track disabledAll = false;
    @track propSpinner = false;
    @track natureOfProperty;
    @track propertyMarketValueMap;
    @track highestMarketValue;

    @track totalFloorValue;
    @track totalFloorArea;
    @track totalAvgSqFtValue;
    @track isUnsaved = false;

    get showForm() {
        return (this.recordId);
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


    //track variables
    @api fivCAutoPopFields = {
        'mortgage_property_distance': '', 'mortagage_and_living_property': '', 'person_at_mortgage': '', 'living_property_distance': '',
        'living_pincode': '', 'is_living_is_own': ''
    };
    @track fivCAutoPopFieldsInternal = {
        'mortgage_property_distance': '', 'mortagage_and_living_property': '', 'person_at_mortgage': '', 'living_property_distance': '',
        'living_pincode': '', 'is_living_is_own': ''
    };
    @api landValues = { Land_Area: undefined, Market_Value: undefined, FinalLandValue: undefined };

    // @api buildingValues = { Building_Area: undefined, Building_Value: undefined, Total_Building_Value: undefined };

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
        }
    ];


    @wire(getRecord, { recordId: '$recordId', fields: Property_FIELDS })
    property({ error, data }) {
        if (data) {
            console.log('Data >>>', data);
            console.log('land values ', this.landValues);
            console.log('in if ', data.fields.Building_Area_Sq_Ft__c.value);
            this.pcbuildingArea = data.fields.Building_Area_Sq_Ft__c.value;
            this.pcbuildingValue = data.fields.Building_Value_per_Sq_ft__c.value;
            this.pcLandArea = data.fields.Land_Area_Sq_Ft__c.value;
            this.pcLandValue = data.fields.Valuation_Market_Value_Per_SqFt__c.value;
            console.log('pc land area  ', this.pcLandArea, 'pcLandValue  ', this.pcLandValue);
            console.log('land values ', this.landValues);

            // Land Area and Valuation Object...
            let tempObj1 = JSON.parse(JSON.stringify(this.landValues));
            this.landValues = JSON.parse(JSON.stringify(tempObj1));

            if ((this.pcLandArea != null && this.pcLandArea != undefined && this.pcLandArea != '') && (this.pcLandValue != null &&
                this.pcLandValue != undefined && this.pcLandValue != '')) {
                this.pchasLandValue = true;
                console.log('pc has values');
                this.landValues.Land_Area = parseInt(this.pcLandArea);
                this.landValues.Market_Value = parseInt(this.pcLandValue);
                this.landValues.FinalLandValue = this.pcLandArea * this.pcLandValue;
            }
            else {
                this.landValues.Land_Area = parseInt(this.pcLandArea);
                this.landValues.Market_Value = parseInt(this.pcLandValue);
                this.landValues.FinalLandValue = this.pcLandArea * this.pcLandValue;
            }
            console.log('data.fields.Month__c>>>>', data.fields.Month__c);
            console.log('mortgage distance ', data.fields.Mortgage_property_distance_from_branch__c.value);
            if (data.fields.Title_Deed_Number__c.value != undefined && data.fields.Title_Deed_Number__c.value != null)
                this.titleDeedNumber = data.fields.Title_Deed_Number__c.value;

            if (data.fields.Month__c.value != undefined && data.fields.Month__c.value != null)
                this.deedMonth = data.fields.Month__c.value;
            if (data.fields.Title_Deed_Year__c.value != undefined && data.fields.Title_Deed_Year__c.value != null)
                this.deedYear = data.fields.Title_Deed_Year__c.value;
            else
                this.deedYear = null;
            if (data.fields.Living_property_Distance_from_Branch__c.value != undefined && data.fields.Living_property_Distance_from_Branch__c.value != null)
                this.distanceFromBranch = data.fields.Living_property_Distance_from_Branch__c.value;
            else
                this.distanceFromBranch = this.fivCAutoPopFields.living_property_distance;
            if (data.fields.Mortgage_property_distance_from_branch__c.value != undefined && data.fields.Mortgage_property_distance_from_branch__c.value != null)
                this.fivCAutoPopFieldsInternal.mortgage_property_distance = data.fields.Mortgage_property_distance_from_branch__c.value;
            else
                this.fivCAutoPopFieldsInternal.mortgage_property_distance = this.fivCAutoPopFields.mortgage_property_distance;

            if (data.fields.Mortgage_property_Living_property_are__c.value != undefined && data.fields.Mortgage_property_Living_property_are__c.value != null)
                this.fivCAutoPopFieldsInternal.mortagage_and_living_property = data.fields.Mortgage_property_Living_property_are__c.value;
            else
                this.fivCAutoPopFieldsInternal.mortagage_and_living_property = this.fivCAutoPopFields.mortagage_and_living_property

            if (data.fields.Person_residing_at_Mortgage_property__c.value != undefined && data.fields.Person_residing_at_Mortgage_property__c.value != null)
                this.fivCAutoPopFieldsInternal.person_at_mortgage = data.fields.Person_residing_at_Mortgage_property__c.value;
            else
                this.fivCAutoPopFieldsInternal.person_at_mortgage = this.fivCAutoPopFields.person_at_mortgage;

            if (data.fields.Is_living_property_is_own_property__c.value != undefined && data.fields.Is_living_property_is_own_property__c.value != null)
                this.fivCAutoPopFieldsInternal.is_living_is_own = data.fields.Is_living_property_is_own_property__c.value;
            else
                this.fivCAutoPopFieldsInternal.is_living_is_own = this.fivCAutoPopFields.is_living_is_own;

            if (data.fields.Pincode__c.value != undefined && data.fields.Pincode__c.value != null)
                this.fivCAutoPopFieldsInternal.living_pincode = data.fields.Pincode__c.value;
            else
                this.fivCAutoPopFieldsInternal.living_pincode = this.fivCAutoPopFields.living_pincode;

            if (data.fields.Mortgage_property_Living_property_are__c.value != undefined && data.fields.Mortgage_property_Living_property_are__c.value != null) {
                if (data.fields.Mortgage_property_Living_property_are__c.value == 'No')
                    this.showThis = true;
                else
                    this.showThis = false;
            }
            if (data.fields.Pathway_Available__c.value != undefined && data.fields.Pathway_Available__c.value != null &&
                data.fields.Pathway_Available__c.value != '') {
                if (data.fields.Pathway_Available__c.value == 'No')
                    this.showpathRemarks = true;
                else
                    this.showpathRemarks = false;
            }
            if (data.fields.Boundaries_As_Per_Inspection_Are_Same__c.value != undefined && data.fields.Boundaries_As_Per_Inspection_Are_Same__c.value != null &&
                data.fields.Boundaries_As_Per_Inspection_Are_Same__c.value != '') {
                if (data.fields.Boundaries_As_Per_Inspection_Are_Same__c.value == 'No')
                    this.showBoundaries = true;
                else
                    this.showBoundaries = false;
            }
            if (data.fields.Nature_Of_Property__c.value != undefined && data.fields.Nature_Of_Property__c.value != null &&
                data.fields.Nature_Of_Property__c.value != '') {
                this.natureOfProperty = data.fields.Nature_Of_Property__c.value;
            }
            if (data.fields.Property_Type__c.value != undefined && data.fields.Property_Type__c.value != null &&
                data.fields.Property_Type__c.value != '') {
                this.typeofProperty = data.fields.Property_Type__c.value;
                if (this.typeofProperty == 'Vacant Land') {
                    if (this.isBuildingAreaAndValuation) {
                        this.disabledAll = true;
                    }
                    else
                        this.disabledAll = false;
                }
                else {
                    this.disabledAll = false;

                }
            }
            if (data.fields.Building_Age__c.value != undefined && data.fields.Building_Age__c.value != null &&
                data.fields.Building_Age__c.value != '') {
                this.buildingAge = data.fields.Building_Age__c.value;
            }
            else
                this.buildingAge = undefined;
        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }





    connectedCallback() {
        console.log('section>>>>>> ', this.sectiontitle);
        console.log('autopop_fields', JSON.stringify(this.fivCAutoPopFields));
        console.log('recordId>>>>>> ', this.recordId);
        console.log('parentPropertyId>>>>>> ', this.parentPropertyId);
        console.log('///////////////// Property Componenet////////////');
        console.log(this.applicationId);
        console.log(this.loginId);
        console.log('deed year', this.deedYear, 'deed Month', this.deedMonth);
        this.getpropertyRecordTypeId();
        if (this.fivCAutoPopFields.mortagage_and_living_property == 'No')
            this.showThis = true;
        else
            this.showThis = false;
        if (this.sectiontitle == 'AC') {
            this.getAllCollateralRecords();
        }
        else {
            this.getAllCollateralRecords();
            this.showCollateralForm = true;
        }
        this.handleGetHighestPropertyValueMap();
    }
    renderedCallback() {
        if (this.sectiontitle == 'PC') {
            if (this.typeofProperty == 'Vacant Land') {
                if (this.isBuildingAreaAndValuation)
                    this.disabledAll = true;
                else
                    this.disabledAll = false;
            }
            else
                this.disabledAll = false;
        }
    }

    getAllCollateralRecords() {
        let rcType;
        if (this.sectiontitle == 'PC')
            rcType = 'PC Property Detail';
        else if (this.sectiontitle == 'AC')
            rcType = 'AC Property Detail';
        if (this.sectiontitle == 'PC') {
            this.isCollateralData = false;
            this.collateralTable = undefined;
        }
        getACCollateralTabRecords({ appId: this.applicationId, recordTypeName: rcType }).then(result => {
            if (result) {
                console.log('data refreshed ', result);
                this.collateralTable = JSON.parse(JSON.stringify(result));
                if (this.collateralTable && this.collateralTable.strDataTableData && JSON.parse(this.collateralTable.strDataTableData).length) {
                    JSON.parse(result.strDataTableData).forEach(element => {
                        for (let keyValue of Object.keys(element)) {
                            if (keyValue != 'Id') {
                                const selectedEvent = new CustomEvent("handletabvaluechange", {
                                    detail: { tabname: 'Collateral', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                                });
                                this.dispatchEvent(selectedEvent);
                            }
                        }
                    });
                }
                if (this.sectiontitle == 'AC') {
                    setTimeout(() => {
                        this.isAc = true;
                        this.isCollateralData = true;
                    }, 200);
                    this.propSpinner = false;
                }
            }
        })
            .catch(error => {
                console.log(error);
                this.collateralTable = undefined;
                this.propSpinner = false;
            })
    }

    handleSelectedPropertyRow(event) {
        var data = event.detail;
        console.log('TYpe Of Property', data.recordData.Type_Of_Property__c);

        if (data && data.ActionName == 'edit') {
            console.log('data.recordData ', data.recordData);
            console.log('Id ', this.recordId);
            console.log('this.isBuildingAreaAndValuation ', this.isBuildingAreaAndValuation);
            this.showCollateralForm = false;
            this.recordId = undefined;
            setTimeout(() => {
                this.recordId = data.recordData.Id;
                this.showCollateralForm = true;
            }, 400);
            if (this.isBuildingAreaAndValuation) {
                console.log('Vacant Ac Property');
                if (data.recordData.Type_Of_Property__c == 'Vacant Land') {
                    //this.updateBuildingValues(this.recordId);
                    console.log('disabled all', this.disabledAll);
                    this.disabledAll = true;
                }
                else
                    this.disabledAll = false;
            }
            console.log('disabled all', this.disabledAll);
        }
    }




    handlepropertySubmit(event) {
        console.log('property submit called', this.recordId);
        let allValid = this.handleCheckValidity();
        console.log('all valid', allValid, 'isgeneral details', this.isGeneralDetails);
        if ((this.isGeneralDetails || this.isBuildingAreaAndValuation || this.isLandAreaAndValuation) && !allValid) {
            event.preventDefault();
            if (this.isLandAreaAndValuation && (this.landValues.Land_Area == 0 || this.landValues.Market_Value == 0)) {
                event.preventDefault();
                this.showToast('', 'error', 'Land Area and Market Value should be greater than 0');
            }
        }
        else if (this.isBuildingAreaAndValuation && !this.isUnsaved) {
            console.log('INSIDE FLOOR UPDATE')
            this.isUnsaved = true;
            this.template.querySelector('c-fs-building-floor-cmp').handleSave();
            event.preventDefault();
            return;
        }
    }




    handlepropertySuccess(event) {
        this.isUnsaved = false;
        console.log('success property called', event.detail.id);
        this.showToast('Success', 'success', 'Record Updated Successfully');
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Collateral', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);
        if (this.isBuildingAreaAndValuation) {
            const selectEvent = new CustomEvent('changetotalvalue', {
                detail: true
            });
            this.dispatchEvent(selectEvent);
        }
        if (this.sectiontitle == 'PC' || this.sectiontitle == 'AC') {
            const checkEvent = new CustomEvent('checkpropertyvalidation', { detail: true });
            this.dispatchEvent(checkEvent);
            if (this.isGeneralDetails && this.typeofProperty == 'Vacant Land') {
                this.propSpinner = true;
                this.updateBuildingValues(this.recordId);
            }

        }
        if (this.sectiontitle == 'AC') {
            this.propSpinner = true;
            this.showCollateralForm = false;
        }
        this.collateralTable = undefined;
        this.getAllCollateralRecords();
    }



    handleerror(event) {
        console.log('errro>>>>>> ', JSON.stringify(event.detail));
    }


    // Method used to handle form Validations
    handleFormValidation(evt) {
        console.log('chnage field>>>> ', evt.target.fieldName);
        console.log('changed value>>>>>> ', evt.target.value);
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (this.isGeneralDetails) {
            if (evt.target.name == 'Month__c') {
                this.deedMonth = evt.target.value;
            }
            else if (evt.target.fieldName == 'Mortgage_property_Living_property_are__c') {
                if (evt.target.value == 'No')
                    this.showThis = true;
                else
                    this.showThis = false;
            }
            else if (evt.target.name == 'Title_Deed_Year__c') {
                this.deedYear = evt.target.value;
            } else if (evt.target.name == 'Living_property_Distance_from_Branch__c') {
                this.distanceFromBranch = evt.target.value;
            }
            else if (evt.target.fieldName == 'Nature_Of_Property__c') {
                this.natureOfProperty = evt.target.value;
                this.typeofProperty = undefined;
            }
            else if (evt.target.name == 'Type_Of_Property__c') {
                console.log('Type of Property Type ###', (evt.target.value).length);
                this.typeofProperty = evt.target.value;
            }
        }
        else if (this.isLandAreaAndValuation) {
            let tempObj = JSON.parse(JSON.stringify(this.landValues));
            this.landValues = JSON.parse(JSON.stringify(tempObj));
            let land_value = this.landValues.Land_Area;
            let market_value = this.landValues.Market_Value;
            if (evt.target.fieldName == 'Pathway_Available__c') {
                if (evt.target.value == 'No')
                    this.showpathRemarks = true;
                else
                    this.showpathRemarks = false;
            }
            else if (evt.target.fieldName == 'Boundaries_As_Per_Inspection_Are_Same__c') {
                if (evt.target.value == 'No')
                    this.showBoundaries = true;
                else
                    this.showBoundaries = false;
            }
            else if (evt.target.fieldName == 'Mortgage_Property_Area__c') {
                if (evt.target.value == 'Negative')
                    this.mortgageRemarks = true;
                else
                    this.mortgageRemarks = false;
            }
            else if (evt.target.name == 'Land_Area_Sq_Ft__c') {
                land_value = this.template.querySelector('[data-id="land_Area"]').value !== undefined ? this.template.querySelector('[data-id="land_Area"]').value : 0;
                console.log('type 1 :', typeof (this.landValues.Land_Area));
                console.log('type 2:', typeof (land_value));
                this.landValues.Land_Area = Number(land_value);
            }
            else if (evt.target.name == 'Valuation_Market_Value_Per_SqFt__c') {
                market_value = this.template.querySelector('[data-id="market_Value"]').value !== undefined ? this.template.querySelector('[data-id="market_Value"]').value : 0;
                console.log('market_value>>> ', market_value);
                this.landValues.Market_Value = Number(market_value);
            }
            this.landValues.FinalLandValue = land_value * market_value;
            console.log(' this.finalLandValue>>> ', this.finalLandValue);
        }
        else if (this.isBuildingAreaAndValuation) {
            if (evt.target.name == 'Building_Age__c') {
                this.buildingAge = evt.target.value;
            }
        }
        let rcId = this.recordId ? this.recordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Collateral', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);

    }



    // get the Property recordTypeId
    getpropertyRecordTypeId() {
        let rcType;
        if (this.sectiontitle == 'PC')
            rcType = 'PC Property Detail';
        else if (this.sectiontitle == 'AC')
            rcType = 'AC Property Detail';
        getRecordTypeId({ objName: 'Property__c', recordTypeName: rcType })
            .then(res => {
                if (res)
                    this.propertyRecordTypeId = res;
                console.log('Property record type id >>>> ', JSON.stringify(res));
            })
            .catch(err => {
                console.log('errr occured in getting record type id for property', err);
            })
    }

    // method used to check the Validation 
    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1 && allValid2) {
            return true;
        }
        else {
            return false;
        }
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


    handleCancel() {
        this.showCollateralForm = false;
    }

    // update Building Values when property type is changed to Vacant Land
    updateBuildingValues(recordId) {
        this.propSpinner = true;
        let tempId = this.recordId;
        deleteRelatedFloors({ propertyId: recordId }).then((result) => {
            console.log('deleteRelatedFloors = ', result);
            this.propSpinner = false;
            this.recordId = tempId;
            if (result == 'success') {
                this.totalFloorValue = undefined;
                this.totalAvgSqFtValue = undefined;
                this.totalFloorArea = undefined;
                this.buildingValue = undefined;
                this.buildingAge = undefined;
                getRecordNotifyChange([{ recordId: this.recordId }]);
            }
        }).catch((err) => {
            this.propSpinner = false;
            this.recordId = tempId;
            console.log('Error in Bulding Update = ', error);
        });
    }

    // show toast Method
    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    handleGetHighestPropertyValueMap(){
        getHighestPropertyValueMap({appId : this.applicationId}).then((result) => {
            console.log('HandleGetHighestPropertyValueMap= ',result)
            console.log('HandleGetHighestPropertyValueMap= ',this.parentPropertyId)
            if(result){
                this.propertyMarketValueMap = JSON.parse(JSON.stringify(result))
                if(this.propertyMarketValueMap[this.parentPropertyId]){
                    this.highestMarketValue = this.propertyMarketValueMap[this.parentPropertyId];
                }
                console.log('Highest Property Map>>',this.propertyMarketValueMap);
            }            
        }).catch((err) => {
            console.log('Error in handleGetHighestPropertyValueMap= ',err)
        });
    }

}