import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getJobSeekers from '@salesforce/apex/HRConsoleController.getJobSeekers';
import getStatusFieldValues from '@salesforce/apex/HRConsoleController.getStatusFieldValues';
import getSpecializations from '@salesforce/apex/HRConsoleController.getSpecializations';
import updateJobSeekers from '@salesforce/apex/HRConsoleController.updateJobSeekers';
import deleteJobSeekers from '@salesforce/apex/HRConsoleController.deleteJobSeekers';
import searchJobSeekers from '@salesforce/apex/HRConsoleController.searchJobSeekers';
import invitePersons from '@salesforce/apex/HRConsoleController.invitePersons';
import sendInterview from '@salesforce/apex/HRConsoleController.sendInterview';
import changeStatusInApex from '@salesforce/apex/HRConsoleController.changeStatus';
import changeSpecialization from '@salesforce/apex/HRConsoleController.changeSpecialization';
import { loadStyle } from 'lightning/platformResourceLoader';
import hRStule from '@salesforce/resourceUrl/hRStule';
import { refreshApex } from '@salesforce/apex'; 
import { customLabels } from './CustomLabels.js';

export default class HRConsole extends LightningElement {
    
    @track data;
    @track error;
    @track columns;
    @track sortedBy;
    @track sortedDirection;    
    @api jobSeekerBackground;   
    @track addRowWindow;
    @track selectedRows;
    @track handleSelectedRows;
    @track draftValues;   
    @track paginationList;
    @track numberPages;
    @track totalRecords;
    @track pageSize;
    @track pageNumber;

    _result;

    @track labels = customLabels;
      
    ownerName = { label: this.labels.ownerNameLbl, fieldName: 'OwnerName', type: 'text', sortable: true };
    firstName = { label: this.labels.firstNameLbl, fieldName: 'FirstName', type: 'text', editable: true, sortable: true };
    lastName = { label: this.labels.lastNameLbl, fieldName: 'LastName', type: 'text', editable: true, sortable: true };
    email = { label: this.labels.emailLbl, fieldName: 'Email', type: 'text', editable: true, sortable: true };
    phone = { label: this.labels.phoneLbl, fieldName: 'Phone', type: 'phone', editable: true, sortable: true };
    background = { label: this.labels.backgroundLbl, fieldName: 'Background', type: 'text', editable: true, sortable: true };
    createdDate = { label: this.labels.createdDateLbl, fieldName: 'CreatedDate', type: 'date', sortable: true };
    toInvateBtn = {
        label: this.labels.invLbl,
        type: 'button-icon', 
        initialWidth: 50,       
        typeAttributes: {
            iconName: 'action:email',
            label: this.labels.invitedLbl,
            title: this.labels.toInviteLbl,
            variant: 'border-filled',
            alternativeText: this.labels.toInviteLbl
        }
    };

    toSendBtn = {
        label: this.labels.sndLbl,
        type: 'button-icon', 
        initialWidth: 50,       
        typeAttributes: {
            iconName: 'action:new_task',
            label: this.labels.sentLbl,
            title: this.labels.toInterviewLbl,
            variant: 'border-filled',
            alternativeText: this.labels.sendLbl
        }
    };

    deleteBtn = {
        label: this.labels.delLbl,
        type: 'button-icon', 
        initialWidth: 50,       
        typeAttributes: {
            iconName: 'action:delete',
            label: this.labels.deleteLbl,
            title: this.labels.deleteLbl,
            variant: 'border-filled',
            alternativeText: this.labels.delLbl
        }
    };

    status = {
        label: this.labels.statusLbl, fieldName: 'Status', type: 'picklist',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {           
            value: { fieldName: 'Status' },       
            context: { fieldName: 'Id' },
            type: 'Status'            
        }                     
    };

    specialization = {
        label: this.labels.specializationLbl, fieldName: 'SpecializationId', type: 'picklist',
        sortable: true,
        initialWidth: 120,
        typeAttributes: {           
            value: { fieldName: 'SpecializationId' },       
            context: { fieldName: 'Id' },
            type: 'Specialization'            
        }                     
    };

    constructor() {
        super();         
        this.getColomsDataTogether();          
        this.pageNumber = 1;  
        this.pageSize = 5;  
        this.addRowWindow = false; 
        this.selectedRows = [];
        this.handleSelectedRows = [];
        this.draftValues = [];              
    }

    async getColomsDataTogether() {
        let statusResult = await getStatusFieldValues();
        if (statusResult) {
            let statuses = [];
            statusResult.forEach(value => {
                let status = {};
                status.label = value;
                status.value = value;
                statuses.push(status);
            });
            this.status.typeAttributes.options = statuses;          
        }
        let specializationResult = await getSpecializations();
        if (specializationResult) {
            let specializations = [];
            specializationResult.forEach(value => {
                let specialization = {};
                specialization.label = value.Name;
                specialization.value = value.Id;
                specializations.push(specialization);
            });
            this.specialization.typeAttributes.options = specializations;           
        }
        await this.collectColomns();
    }

    collectColomns() {       
        let allFields = [];
        allFields.push(this.ownerName);
        allFields.push(this.firstName);
        allFields.push(this.lastName);
        allFields.push(this.specialization);
        allFields.push(this.email);
        allFields.push(this.phone);
        allFields.push(this.background);
        allFields.push(this.createdDate);
        allFields.push(this.status);
        allFields.push(this.toInvateBtn);
        allFields.push(this.toSendBtn);
        allFields.push(this.deleteBtn);
        this.columns = allFields; 
        return null;
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, hRStule)
        ]);
    }
                      
    @wire(getJobSeekers) wiredJobSeekers(wiredData) {
        this._result = wiredData;              
        if (this._result.data) {
            let preparedJobSeekers = [];
            this._result.data.forEach(jobSeeker => {               
                let preparedJobSeeker = {};
                preparedJobSeeker.OwnerName = jobSeeker.Owner.Name;
                preparedJobSeeker.SpecializationId = jobSeeker.Specialization__c;
                preparedJobSeeker.FirstName = jobSeeker.FirstName__c;
                preparedJobSeeker.LastName = jobSeeker.LastName__c;
                preparedJobSeeker.Email = jobSeeker.Email__c;
                preparedJobSeeker.Phone = jobSeeker.Phone__c;
                preparedJobSeeker.Background = jobSeeker.Background__c;
                preparedJobSeeker.Id = jobSeeker.Id;
                preparedJobSeeker.CreatedDate = jobSeeker.CreatedDate;
                preparedJobSeeker.Status = jobSeeker.Status__c;
                preparedJobSeekers.push(preparedJobSeeker);
            });
            this.data = preparedJobSeekers;                   
            this.rewriteData();
            this.countPages();
            this.setPageNumber();           
        }
        if (this._result.error) {
            this.error = this._result.error;
        }
    }
    
    refreshData() {       
        return refreshApex(this._result);             
    }

    showWindow() {
        this.addRowWindow = true;
    }

    hideWindow() {
        this.addRowWindow = false;
    }

    successCreatedRow() {
        this.handleSuccess(this.labels.recordCreatedLbl + '!');        
        this.addRowWindow = false;
        this.refreshData();  
        this.countPages();
        this.setPageNumber();
    }
   
    getBackground(event) {        
        this.jobSeekerBackground = event.target.value;         
    }

    handleRowAction(event) {                 
        let row = event.detail.row;
        let label = event.detail.action.label; 
        let idRows = [];
        let arrayIds = [];             
        switch (label) {
            case this.labels.invitedLbl:                       
                idRows.push(row.Id);                      
                this.invitateJobSeekers(idRows);
                break;
            case this.labels.sentLbl: 
                idRows.push(row.Id);                                   
                this.sendInterviewToJobSeeker(idRows);
                break;
            case this.labels.deleteLbl:                                  
                arrayIds.push(row.Id);                                                
                this.deleteRows(arrayIds);
                break;           
            default:
        }    
        this.handleSelectedRows = [];           
    }

    invitateJobSeekers(idRows) {
        let label = this.labels.invitedLbl;
        let jsonData = JSON.stringify(idRows);
        invitePersons({ jsonData: jsonData })
        .then(result => {
            if (result) {                             
                this.handleSuccess(this.labels.invitedLbl + '!');
                changeStatusInApex({ jsonData: jsonData, status: label });
                this.changeStatusInTable(idRows, label);                 
                this.rewriteData();                                                         
            } else {
                this.handleError(this.labels.notInvitedLbl + '!');
            }
        });
    }

    changeStatusInTable(rows, status) {
        rows.forEach(row => {
            let index = this.getElementNumber(row);
            this.data[index].Status = status;
        });
    }

    sendInterviewToJobSeeker(idRows) {
        let label = this.labels.sentLbl;
        let jsonData = JSON.stringify(idRows);
        sendInterview({ jsonData: jsonData })
        .then(result => {
            if (result) {                             
                this.handleSuccess(this.labels.interviewSentLbl + '!');
                changeStatusInApex({ jsonData: jsonData, status: label });
                this.changeStatusInTable(idRows, label);                 
                this.rewriteData();                                                         
            } else {
                this.handleError(this.labels.interviewNotSentLbl + '!');
            }
        });
    }

    invateAll() {        
        this.invitateJobSeekers(this.selectedRows);
        this.handleSelectedRows = [];            
    }

    sendAll() {
        this.sendInterviewToJobSeeker(this.selectedRows);
        this.handleSelectedRows = [];      
    }

    rewriteData() {
        let newData = [];
        this.data.forEach(jobSeeker => {                                                          
            newData.push(jobSeeker);
        });
        this.data = newData;  
        this.setPageNumber();           
    }

    getSelectedRows(event) {
        let selectedRows = event.detail.selectedRows;
        let rows = [];
        for (let i = 0; i < selectedRows.length; i++){
            rows.push(selectedRows[i].Id);                     
        }       
        this.selectedRows = rows;
    }

    deleteAll() {                               
        this.deleteRows(this.selectedRows);
        this.handleSelectedRows = [];                    
    }

    async deleteRows(selectedRows) {        
        let result = await deleteJobSeekers({ jsonData: JSON.stringify(selectedRows) }); 
        if (result) {                       
            selectedRows.forEach(row => {                                                                       
                let rowNumber = this.getElementNumber(row);                
                this.data.splice(rowNumber, 1);  
            });       
            this.handleSuccess(this.labels.rowsDeletedLbl + '!');         
            this.rewriteData();                     
            this.setPageNumber();                                        
        } else {
            this.handleError(this.labels.rowsNotDeletedLbl + '!');
        }                
    }

    searchData(event) {       
        let value = event.target.value;        
        searchJobSeekers({searchKey: value})
        .then(result => {
            if (result) {                             
                let preparedJobSeekers = [];
                result.forEach(jobSeeker => {                               
                    let preparedJobSeeker = {};
                    preparedJobSeeker.OwnerName = jobSeeker.Owner.Name;
                    preparedJobSeeker.SpecializationId = jobSeeker.Specialization__c;
                    preparedJobSeeker.FirstName = jobSeeker.FirstName__c;
                    preparedJobSeeker.LastName = jobSeeker.LastName__c;
                    preparedJobSeeker.Email = jobSeeker.Email__c;
                    preparedJobSeeker.Phone = jobSeeker.Phone__c;
                    preparedJobSeeker.Background = jobSeeker.Background__c;
                    preparedJobSeeker.Id = jobSeeker.Id;
                    preparedJobSeeker.CreatedDate = jobSeeker.CreatedDate;
                    preparedJobSeeker.Status = jobSeeker.Status__c;
                    preparedJobSeekers.push(preparedJobSeeker);
                });
                this.data = preparedJobSeekers;   
                this.countPages();
                this.setPageNumber();                                          
            } 
        });       
    }

    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;        
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
        this.setPageNumber();
    }

    sortData(fieldName, sortDirection) {   
        let sortedData = JSON.parse(JSON.stringify(this.data));
        let key =(a) => a[fieldName]; 
        let reverse = sortDirection === 'asc' ? 1: -1;      
        sortedData.sort((a,b) => {
            let valueA = key(a) ? key(a).toLowerCase() : '';
            let valueB = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((valueA > valueB) - (valueB > valueA));                       
        });       
        this.data = sortedData;
    }
     
    saveData(event) {
        let draftValues = event.detail.draftValues;
        let updateRows = [];
        draftValues.forEach((elem) => {
            let row = {};
            let index = +elem.id.split('-')[1];         
            this.data[index].Id = row.Id = this.data[index].Id;                 
            this.data[index].FirstName = row.FirstName__c = (elem.FirstName !== undefined) ? elem.FirstName : this.data[index].FirstName;            
            this.data[index].LastName = row.LastName__c = (elem.LastName !== undefined) ? elem.LastName : this.data[index].LastName;
            this.data[index].Email = row.Email__c = (elem.Email !== undefined) ? elem.Email : this.data[index].Email;
            this.data[index].Phone = row.Phone__c = (elem.Phone !== undefined) ? elem.Phone : this.data[index].Phone;
            this.data[index].Background = row.Background__c = (elem.Background !== undefined) ? elem.Background : this.data[index].Background;
            this.data[index].CreatedDate = this.data[index].CreatedDate;
            this.data[index].OwnerName = this.data[index].OwnerName;
            this.data[index].Status = this.data[index].Status;
            this.data[index].SpecializationId = this.data[index].SpecializationId;           
            updateRows.push(row); 
        });         
        updateJobSeekers({jsonData: JSON.stringify(updateRows)})
        .then(result => {
            if (result) {
                this.draftValues = [];
                this.handleSuccess(this.labels.rowsUpdatedLbl + '!');               
            }
        })
        .catch(error => {
            this.error = error;
            this.handleError(this.labels.errorLbl + '!');
        });      
    }
    
    getElementNumber(id) {
       let number;       
        this.data.forEach((item, index) => {
            if(id === item.Id) {
                number = index;                                            
            }
        });
        return number;
    }

    picklistChanged(event) {   
        event.stopPropagation();
        let value = event.detail.data.value;
        let recordId = event.detail.data.context;
        let type = event.detail.data.type;        
        let rowNumber = this.getElementNumber(recordId); 
        let rows = [];               
        switch(type) {
            case this.labels.statusLbl:
            rows.push(recordId);   
            changeStatusInApex({ jsonData: JSON.stringify(rows), status: value })
            .then(result => {
                if (result) {               
                    this.handleSuccess(this.labels.statusChangedToLbl + ' ' + value + '!');                    
                    this.data[rowNumber].Status = value;  
                    this.rewriteData();      
                } else {
                    this.handleError(this.labels.errorLbl + '!');
                }
            })
            .catch(error => {
                this.error = error;
                this.handleError(this.labels.errorLbl + '!');
            });
            break;
            case this.labels.specializationLbl:            
            changeSpecialization({recordId: recordId, value: value})
            .then(result => {                            
                if (result) {                                                                      
                    this.data[rowNumber].SpecializationId = value;                                        
                    this.data[rowNumber].OwnerName = result;                     
                    this.rewriteData();   
                    this.setPageNumber();   
                    this.handleSuccess(this.labels.specializationLbl + '!');                                 
                } else {
                    this.handleError(this.labels.errorLbl + '!');
                }
            })
            .catch(error => {
                this.error = error;
                this.handleError(this.labels.errorLbl + '!');
            });
            break;
            default:
            break;
        }
    }

    handleSuccess(text) {
        let showSuccess = new ShowToastEvent({
            title: this.labels.successLbl + '!',
            message: text,
            variant: 'Success',
        });
        dispatchEvent(showSuccess);
    }
    
    handleError(text) {
        let showError = new ShowToastEvent({
            title: this.labels.errorLbl + '!',
            message: text,
            variant: 'error',
        });
        dispatchEvent(showError);
    }

    countPages() {
        let numberRecords = this.data.length;
        if (this.pageSize > numberRecords) {
            this.numberPages = 1;
        } else {
            this.numberPages = Math.ceil(numberRecords / + this.pageSize);            
        }
        this.checkAlailableButtons();              
    }

    setPageNumber() {   
        let totalSize = this.data.length;    
        let recordFrom = (this.pageNumber - 1) * this.pageSize;        
        let recordTo;
        if((recordFrom + this.pageSize) <= totalSize) {           
            recordTo = recordFrom + this.pageSize;
        } else {
            recordTo = (totalSize - recordFrom) + recordFrom;
        }          
        this.paginationList = [];
        for(let i = recordFrom; i < recordTo; i++) {
            if(totalSize > i) {
                this.paginationList.push(this.data[i]);
            }
        }      
    }

    checkAlailableButtons() {
        if (this.pageNumber > 1) {
            this.template.querySelector('c-paginator').disableButton('falseprevious');
        }
        if (this.pageNumber === 1) {
            this.template.querySelector('c-paginator').disableButton('trueprevious');
        }
        if (this.pageNumber < this.numberPages) {
            this.template.querySelector('c-paginator').disableButton('falsenext');
        } else {
            this.template.querySelector('c-paginator').disableButton('truenext');
        }
    }

    previousPage(event) {
        event.stopPropagation();
        if (this.pageNumber > 1) {
            this.pageNumber--;          
        } 
        this.countPages();
        this.setPageNumber();       
    }

    nextPage(event) {
        event.stopPropagation();
        if(this.pageNumber < this.numberPages) {
            this.pageNumber++;            
        }  
        this.countPages();   
        this.setPageNumber();          
    }
    
    changePageSize(event) {              
        this.pageSize = + event.detail;
        this.countPages();
        this.pageNumber = 1;
        this.setPageNumber();       
    }

    firstPage(event) {
        event.stopPropagation();
        this.pageNumber = 1;
        this.countPages();
        this.setPageNumber();
    }

    lastPage(event) {
        event.stopPropagation();
        this.pageNumber = this.numberPages;
        this.countPages();
        this.setPageNumber();
    }

}