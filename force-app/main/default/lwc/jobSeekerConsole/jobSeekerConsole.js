import { LightningElement, track } from 'lwc';
import userId from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/jobSeekerMainMenuController.getUserInfo';
import getJobSeeker from '@salesforce/apex/JobSeekerConsoleController.getJobSeeker';
import deleteJobSeeker from '@salesforce/apex/JobSeekerConsoleController.deleteJobSeeker';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { customLabels } from './customLabels.js';

export default class JobSeekerConsole extends LightningElement {

    currentUserId = userId;
    @track data;
    @track error;
    @track firstName;
    @track lastName;
    @track email;
    @track phone;
    @track specialization;
    @track jobSeekerBackground;

    labels = customLabels;

    constructor() {
        super();
        this.getData();
    }

    async getData() {       
        let userInfo = await getUserInfo({userId: this.currentUserId});
        if (userInfo) {
            this.firstName = userInfo.FirstName;
            this.lastName = userInfo.LastName;
            this.email = userInfo.Email;                   
        }    
        let jobSeeker = await getJobSeeker({userId: this.currentUserId})
        if (jobSeeker) {
            this.data = jobSeeker;
            this.jobSeekerBackground = this.data.Background__c;         
        }       
    }

    getPhone(event) {
        this.phone = event.target.value; 
    }

    getSpecialization(event) {
        this.specialization = event.target.value; 
    }

    getBackground(event) {        
        this.jobSeekerBackground = event.target.value;         
    }

    changeBackground(event) {      
        this.jobSeekerBackground = event.target.value;
    }

    deleteRow() {        
        deleteJobSeeker({jobSeekerId: this.data.Id})
        .then(result => {
            if (result) {    
                this.handleSuccess(this.labels.deletedSumLbl + '!');   
            } else {
                this.handleError(this.labels.deleteErrorLbl + '!');                
            }
        })
        .catch(error => {           
            this.handleError(this.labels.deleteErrorLbl + ': ' + error);
        });
        this.data = null;
    }

    setSuccessCreated(event) {
        this.handleSuccess(this.labels.createdSumLbl + '!');
        this.data = {};
        this.data.Id = event.detail.id;
        this.data.Phone__c = this.phone;
        this.data.Specialization__c = this.specialization;
        this.data.Background__c = this.jobSeekerBackground;       
    }

    setSuccessUpdated() {
        this.handleSuccess(this.labels.updatedSumLbl + '!');
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

}