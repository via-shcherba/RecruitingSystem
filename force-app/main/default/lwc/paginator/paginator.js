import { LightningElement, api } from 'lwc';
import firstPage from '@salesforce/label/c.First_Page';
import previous from '@salesforce/label/c.Previous';
import next from '@salesforce/label/c.Next';
import lastPage from '@salesforce/label/c.Last_Page';
/* eslint-disable no-console */

export default class Paginator extends LightningElement {
   
    @api disableButton(str) {       
        switch(str) {
            case 'falsenext':                
                this.template.querySelectorAll('lightning-button')[2].disabled = false;  
                this.template.querySelectorAll('lightning-button')[3].disabled = false;                              
            break;
            case 'truenext':
                this.template.querySelectorAll('lightning-button')[2].disabled = true;
                this.template.querySelectorAll('lightning-button')[3].disabled = true;              
            break;
            case 'falseprevious':
                this.template.querySelectorAll('lightning-button')[0].disabled = false;  
                this.template.querySelectorAll('lightning-button')[1].disabled = false;              
            break;
            case 'trueprevious':
                this.template.querySelectorAll('lightning-button')[0].disabled = true;  
                this.template.querySelectorAll('lightning-button')[1].disabled = true;              
            break;
            default:
            break;
        }       
    }

    labels = {
        firstPage,
        previous,
        next,
        lastPage
    };

    previousPage() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextPage() {                      
        this.dispatchEvent(new CustomEvent('next'));
    }

    firstPage(){
        this.dispatchEvent(new CustomEvent('first'));
    }

    lastPage(){
        this.dispatchEvent(new CustomEvent('last'));
    }

    changePageSize(event) {
        event.preventDefault();
        let value = event.target.value;
        this.dispatchEvent(new CustomEvent('select', { detail: value
        }));       
    }
}