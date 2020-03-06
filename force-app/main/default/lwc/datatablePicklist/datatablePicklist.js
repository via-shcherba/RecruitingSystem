import { LightningElement, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {     
    @api value;
    @api context;
    @api type;
    @api options;
        
    handleChange(event) {
        this.value = event.detail.value;                                 
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value, type: this.type }
            }
        }));
    }
    
}