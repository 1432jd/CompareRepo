import { LightningElement, api, track, wire } from 'lwc';
import getProperties from '@salesforce/apex/fsPcAcController.getProperties';
import getDocumentPublicList from '@salesforce/apex/fsPcAcController.getDocumentPublicList';
import getApplicantList from '@salesforce/apex/fsPcAcController.getApplicantList';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DOCUMENT_OBJECT from '@salesforce/schema/Document_Set_Code__c';
import ConVerTYPE_FIELD from '@salesforce/schema/ContentVersion.Type__c'

export default class PcCompareDocs extends LightningElement {

    @api applicationId;
    @track documentTypeOption;
    @track selectedDocumentOption;
    @track isAsset = false;
    @track isApplicant = false;
    @track prpertyOptions = [];
    @track customerOptions = [];
    @track customerValue;
    @track propertyValue;

    @track fivBdocList = [];
    @track fivCdocList = [];
    @track fivbDocs = false;
    @track fivcDocs = false;
    @track carousalSpinner = false;
    @track selectedPropertyName;
    @track selectedApplicantName;
    @track selectedOption;
    @track supportedExtensions = ['bmp','gif','jpeg','jpg','png','tif','tiff','vsd'];

    @track conVerTypePicklistOption = [];
    selectedConVerType = '';
    @track allDocuments = [];


    //importing the document type  field from document set code Object
    @wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: 'Document_Set_Code__c.Type__c' })
    orgtype({ data, error }) {
        if (data) {
            this.carousalSpinner = true;
            this.documentTypeOption = data.values;
            this.getExistingApplicants();
            console.log('type options>>>> ', this.documentTypeOption);
            this.getExistingProperties();
            this.carousalSpinner = false;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ConVerTYPE_FIELD })
    picklistTypeValue({ error, data }) {
        if (data) {
            data.values.forEach(item => {
                this.conVerTypePicklistOption.push({ label: item.label, value: item.value });
            });
        } else if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        //code
        this.searchFiles();
    }

    handleConVerChnage(event)
    {
        var val = event.target.value
        this.selectedConVerType = val; 

        var allDocuments = this.allDocuments;
        var fivBdocList = [];
        var fivCdocList = [];
        
        for(var i in allDocuments)
        {
            if (allDocuments[i].Type__c ==  val && allDocuments[i].File_Type__c == 'FIV - C Photo' && this.supportedExtensions.includes(allDocuments[i].FileExtension)) {                         
                fivCdocList.push({ link: '/sfc/servlet.shepherd/document/download/' + allDocuments[i].ContentDocumentId, id: allDocuments[i].ContentDocumentId });
                this.fivcDocs = true;
            }
            if (allDocuments[i].Type__c ==  val &&  allDocuments[i].File_Type__c == 'FIV - B Photo' && this.supportedExtensions.includes(allDocuments[i].FileExtension)) {
                fivBdocList.push({ link: '/sfc/servlet.shepherd/document/download/' + allDocuments[i].ContentDocumentId, id: allDocuments[i].ContentDocumentId });
                this.fivbDocs = true;
            }
        }
        this.fivBdocList = fivBdocList;
        this.fivCdocList = fivCdocList;
    }
    
    handleInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log(name);
        console.log(value);
        if (name == "Type Of Document") {
            this.selectedDocumentOption = value;
            if (this.selectedDocumentOption == 'Applicant') {
                this.selectedOption = event.target.value;
                this.isAsset = false;
                this.isApplicant = true;
            }
            else if (this.selectedDocumentOption == 'Asset') {
                this.selectedOption = event.target.value;
                this.isApplicant = false;
                this.isAsset = true;
            }
            else {
                this.selectedOption = event.target.value;
                this.isApplicant = false;
                this.isAsset = false;
            }
        }
        else if (name == "Prperty Info") {
            this.selectedPropertyName = event.target.value;
        }
        else if (name == "Customer Info") {
            this.selectedApplicantName = event.target.value;
        }

    }

    // method used to get all the properties under the application
    getExistingProperties() {
        getProperties({ appId: this.applicationId }).then(result => {
            let options = [];
            console.log('get properties in compare docs####', result)
            if (result && result.length) {
                result.forEach(Element => {
                    options.push({ label: Element.Name, value: Element.Id });
                });
                this.prpertyOptions = options;
            }
        })
            .catch(err => {
                console.log('ERR in compare docs Property options', err);
            })

    }


    getExistingApplicants() {
        getApplicantList({ appId: this.applicationId })
            .then(result => {
                let options = [];
                console.log('get applicants in compare docs####', result)
                if (result) {
                    for (var key in result) {
                        options.push({ label: result[key].Customer_Information__r.Name, value: result[key].Customer_Information__c });
                    }
                    this.customerOptions = options;
                }
            })
            .catch(error => {
                console.log('ERR in compare docs Applicant options', error);
            })
    }


    // method used to search the files which had been captured at FIV-B and FIV-C Stage
        searchFiles(event) {
        console.log('this property name>>> ', this.selectedPropertyName);
        console.log('this acc name >>>> ', this.selectedApplicantName);
        console.log('this app name >>>> ', this.applicationId);
        this.carousalSpinner = true;
        this.fivCdocList = [];
        this.fivBdocList = [];
        getDocumentPublicList({ appId: this.applicationId, propertyId: this.selectedPropertyName, applicantId: this.selectedApplicantName, type: this.selectedOption }).then((result) => {
            console.log('getDocumentPublicList= ', result);
            if (result && result.length) {
                this.allDocuments = result;
                result.forEach(currentFile => {
                    if (currentFile.File_Type__c == 'FIV - C Photo' && this.supportedExtensions.includes(currentFile.FileExtension)) {                         
                        this.fivCdocList.push({ link: '/sfc/servlet.shepherd/document/download/' + currentFile.ContentDocumentId, id: currentFile.ContentDocumentId });
                        this.fivcDocs = true;
                    }
                    if (currentFile.File_Type__c == 'FIV - B Photo' && this.supportedExtensions.includes(currentFile.FileExtension)) {
                        this.fivBdocList.push({ link: '/sfc/servlet.shepherd/document/download/' + currentFile.ContentDocumentId, id: currentFile.ContentDocumentId });
                        this.fivbDocs = true;
                    }
                });
                console.log('this.fivCdocList= ', this.fivCdocList);
                this.carousalSpinner = false;
            } else {
                this.fivbDocs = false;
                this.fivcDocs = false;
                this.fivBdocList = [];
                this.fivCdocList = [];
                this.carousalSpinner = false;
            }
        }).catch((err) => {
            console.log('error in getDocumentPublicList= ', err);
            this.carousalSpinner = false;
        });
    }

}