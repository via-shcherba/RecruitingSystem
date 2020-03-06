import LightningDatatable from 'lightning/datatable';

import DatatablePicklistTemplate from './customDataTable.html';

export default class CustomDataTable extends LightningDatatable {   
	static customTypes = {
		picklist: {
			template: DatatablePicklistTemplate,
			typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'type']
		},	   
	};	
}