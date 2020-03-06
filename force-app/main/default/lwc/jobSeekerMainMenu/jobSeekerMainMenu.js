import { LightningElement, wire, track } from 'lwc';
import userId from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/jobSeekerMainMenuController.getUserInfo';
import helloLbl from '@salesforce/label/c.Hello';
import logoutLbl from '@salesforce/label/c.Logout';
import notExistLbl from '@salesforce/label/c.Such_user_does_not_exist';

export default class JobSeekerMainMenu extends LightningElement {

    currentUserId = userId;
    @track userInfo;
    @track error;

    labels = {
        helloLbl,
        logoutLbl,
        notExistLbl
    };
    
    @wire(getUserInfo, {
        userId: '$currentUserId'
    })
    wiredUser({data, error}) {       
        if (data) {
            this.userInfo = data;
        } else if (error) { 
            this.error = error; 
        }
    }

    logout() {       
        let domain = window.location.hostname;              
        window.location.replace('https://' + domain + '/secur/logout.jsp');
    }

}