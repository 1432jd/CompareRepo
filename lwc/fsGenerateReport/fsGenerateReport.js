import { LightningElement, track, api, wire } from 'lwc';
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import getData from '@salesforce/apex/fsReportPDFController.getData';
import createDataForVF from '@salesforce/apex/fsReportPDFController.createDataForVF';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import BusinessDate from '@salesforce/label/c.Business_Date';


export default class FsGenerateReport extends NavigationMixin(LightningElement) {

    @api applicationNo = 'App-101';
    @track isSpinner = false;
    @track applicationName;
    @track showerrorApp = true;
    @track value = '--None--';
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track getDataArr = ["Login", "Verification", "Lead Detail", "Process Credit", "Approval Credit", "MOD Registration", "Agreement Execution", "Disbursal Maker", "Disbursal Author", "File Inward","VDC Maker","VDC Checker","Vendor Handoff"];
    @track getStagesData = [];



    connectedCallback() {
        this.handleGetLastLoginDate();
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }



    get options() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Login', value: 'Login' },
            { label: 'Verification', value: 'Verification' },
            { label: 'Lead Detail', value: 'Lead Detail' },
            { label: 'Process Credit', value: 'Process Credit' },
            { label: 'Approval Credit', value: 'Approval Credit' },
            { label: 'Post Approval', value: 'Post Approval' },
            { label: 'MOD Registration', value: 'MOD Registration' },
            { label: 'Agreement Execution', value: 'Agreement Execution' },
            { label: 'Disbursal Maker', value: 'Disbursal Maker' },
            { label: 'Disbursal Author', value: 'Disbursal Author' },
            { label: 'File Inward', value: 'File Inward' },
            { label: 'VDC Maker', value: 'VDC Maker' },
            { label: 'VDC Checker', value: 'VDC Checker' },
            { label: 'Vendor Handoff', value: 'Vendor Handoff' },

        ];
    }


    async handleSave() {
        this.isSpinner=true;
        let allValid = this.handleCheckValidity();
        if (!allValid) {
            return;
        }
        this.getStagesData = [];
        var selectedValue = this.getStageValue;
        console.log('MS 1 = ', selectedValue);
        if (selectedValue == 'All') {
            for (let i = 0; i < this.getDataArr.length; i++) {
                var rslt = await this.getDataCall(this.getDataArr[i]);
                this.getStagesData.push((rslt));
            }
            console.log(JSON.stringify(this.getStagesData));
            this.callVF();

            /** WORKING CODE
            let totalLength = this.getDataArr.length; 
            for(let i = 0;i < this.getDataArr.length; i++){
                getData({ appId: this.recordId,selectedStage:this.getDataArr[i]})
                .then((result) => {
                    if (result) {
                        this.getStagesData.push(result);
                        
                    }
                }).catch((err) => {
                    this.isloaded = true;
                    console.log('Error in getExistingRecord= ', err);
                }).finally(() => {
                    console.log('stages lenghyh is >>>',this.getStagesData.length);
                    console.log('array length is >>>>',this.getDataArr.length);
                    if(this.getStagesData.length == totalLength){
                        console.log('INSIDE FINALLY CONDITION');
                        console.log(JSON.stringify(this.getStagesData));
                        console.log('INSIDE FINALLY CONDITION');
                        createDataForVF({jsonData : this.getStagesData})
                        .then((result) => {
                            if (result) {
                                console.log('OPEN VF HERE');
                            }
                        }).catch((err) => {
                            this.isloaded = true;
                            console.log('Error in getExistingRecord= ', err);
                        });
                    }
                    
                });
                if(this.getStagesData.length == totalLength){
                    break;
                }
            }
            **/
        } else {
            this.isSpinner=true;
            var rslt = await this.getDataCall(selectedValue);
            this.getStagesData.push(rslt);
            this.callVF();
            
        }

        /***********
        if (this.showerrorApp == false) {
          //  this.isSpinner=true;
          //  this.getDataArr[0]='All';
            //for(let i=0; i<this.getDataArr.length; i++){
        if(this.getStageValue=='All'){
            for(let i=0; i<this.getDataArr.length; i++){

                getData({ appId: this.recordId,selectedStage:this.getDataArr[i]}).then((result) => {
                        if (result) {
                              this.getStagesData.push(result);
                              console.log('length is >>>>>',(this.getStagesData.length));
                                console.log('result id sgdy>>',JSON.stringify(this.getStagesData));
                                if(i==(this.getDataArr.length-1)){
                                    this.callfun();
                                }
                                                      
                        }
                }).catch((err) => {
                    this.isloaded = true;
                    console.log('Error in getExistingRecord= ', err);
                });
               
                

            }

            
        }
        }
        */
    }



    /*
    callfun(){
          console.log('inside callfun');
          console.log('aplication id is >>>',this.applicationName);
          console.log('stage value  id is >>>',this.getDataArr[0]);
          var str='All';

         setData({ allStagesData: this.getStagesData}).then((result) => {

                                  
                                            if (result) {

                                                try{
                                                console.log('inside result of data');
                                                this[NavigationMixin.GenerateUrl]({
                                                    type: 'standard__webPage',
                                                    attributes: {
                                                        url: '/apex/fsReportsPDF?Id=' + this.applicationName+'&StageValue='+str
                                                    }
                                                    }).then(generatedUrl => {
                                                        window.open(generatedUrl);
                                                    });
                                                }catch(e){
                                                    console.log('message is >>>>',e.message);
                                                }

                                               
                                            }
                                            }).catch((err) => {
                                                console.log('Error in Record= ', err);
                                            });

                                   






    }
    */
    handleOnChangeApp(event) {
        this.applicationName = event.detail;
        this.showerrorApp = false;
    }

    removehandleOnChangeApp() {
        this.showerrorApp = true;
    }

    handleFormValues(event) {
        this.getStageValue = event.target.value;
    }

    handleCheckValidity() {
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return (allValid2);
    }

    getDataCall(selectedStg) {

        console.log('record id in promise is >>>>',this.recordId);
         console.log('this.applicationName id in promise is >>>>',this.applicationName);
          console.log('selectedStg in promise is >>>>',selectedStg);


        return new Promise((resolve, reject) => {
            getData({ appId: this.applicationName, selectedStage: selectedStg })
                .then(result => {
                    resolve(result);
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });
        });
    }

    callVF() {

        console.log('stages data in callvf uis >>>>', this.getStagesData);
        console.log('this.applicationName is  >>>>', this.applicationName);

      //  var str = this.getStageValue;

       //var encodedData = encodeURIComponent(this.getStagesData);
        createDataForVF({ jsonData: this.getStagesData,appId:this.applicationName })
            .then((result) => {
                console.log('result = ', result)
                if (result) {
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            // url: '/apex/fsReportsPDF?Id=' + this.applicationName+'&StageValue='+str
                            url: '/apex/fsReportsPDF?Id=' + this.applicationName
                            // url: '/apex/fsReportsPDF'
                           // url: '/apex/fsReportsPDF?val=' + this.getStagesData
                        }
                    }).then(generatedUrl => {
                        window.open(generatedUrl);
                    });

                    this.isSpinner=false;
                }

            }).catch((err) => {
                this.isSpinner=false;
                this.isloaded = true;
                console.log('Error in getExistingRecord= ', err);
            });
    }
}