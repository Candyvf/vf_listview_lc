({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Lead', fieldName: 'Name', type: 'text', sortable: 'true' },
            { label: 'Status', fieldName: 'Status', type: 'text', sortable: 'true' },
            { label: 'Company', fieldName: 'Company', type: 'text', sortable: 'true' },
            { label: 'Quality', fieldName: 'Lead_Quality_Helper__c', type: 'number', sortable: 'true' }
        ]);
        var validSelected = component.get("v.showActions");
        if (validSelected == 'true') {
            helper.getLeadSelected(component, event, helper);
        }
    },
    
    generateCloseMasive : function(component, event, helper){
           helper.sendLeadListToClose(component, event, helper);
	}
})