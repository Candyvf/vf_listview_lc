public class VF_QuickAction_LC_Ctrl {
    ApexPages.StandardSetController setCon;
    public List<String> leadIds {get;set;}
    
    public String recordList { get; private set; }
    
    public String warningMsg { get; set; }
    
    public Boolean validList { get; set; }
    
    public class MyWrapper {
        public String id;
    }
    
    final Set<String> notPossibleStatus = new Set<String> {'Closed - Converted', 'Closed - Not Converted'};
        
        public VF_QuickAction_LC_Ctrl(ApexPages.StandardSetController controller) {
            this.setCon = controller;
            controller.setPageSize(10);
            List<Lead> leadSelectedList = (List<Lead>) this.setCon.getSelected();
            
            if(leadSelectedList.isEmpty()){
                validList = false;
                warningMsg = 'Por favor seleccione al menos un registro para poder cerrar de forma masiva.';
            } else if(leadSelectedList.size() > 15){
                validList = false;
                warningMsg = 'Ha seleccionado demasiados registros.';
            } else {
                validList = validarLeadSelectedToClose(leadSelectedList);
                if(validList){
                    List<MyWrapper> wrapperList = new List<MyWrapper>();
                    
                    leadIds = new List<String>();
                    for(Lead leadSeleted : leadSelectedList){
                        leadIds.add((String) leadSeleted.Id);
                        MyWrapper records = new MyWrapper();
                        records.id = (String) leadSeleted.Id;
                        wrapperList.add(records);
                    }
                    System.debug(leadIds);
                    
                    recordList = JSON.serialize(wrapperList);
                    System.debug(recordList);
                }
            }
            
            System.debug(warningMsg);
            System.debug(validList);
            if(!String.isEmpty(warningMsg) && !validList){
                ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.WARNING, warningMsg);
                ApexPages.addMessage(message);
            }
            
        }
    
    public Boolean validarLeadSelectedToClose(List<Lead> leadSelectedList){
        Boolean valid = true;
        List<Lead> leadList = [SELECT Id, toLabel(Status) 
                               FROM LEAD 
                               WHERE Id IN : leadSelectedList];
        
        if(leadList.isEmpty()){
            valid = false;
            warningMsg = 'Asegurece de haber seleccionado algun Lead.';
            
        } else {
            for (Lead lead : leadList){
                if(notPossibleStatus.contains(lead.Status)) {
                    valid = false;
                    warningMsg = 'Hubo un problema, asegurece de haber seleccionado lead validos. '+ 
                        'Compruebe el estado de los lead seleccionados.';
                }
            }
        }        
        return valid;
        
    }
    
    public List<Lead> getMyRecords() {
        return (Lead[]) setCon.getSelected();
    }
    
    public integer getMySelectedSize() {
        return setCon.getSelected().size();
    }
    
    public integer getMyRecordsSize() {
        return setCon.getRecords().size();
    }
    
    public List<Object> getLeadSelected() {
        
        // return setCon.getSelected();
        List<Lead> leadSelectedList = (List<Lead>) this.setCon.getSelected();
        List<String> leadsIds = new List<String>();
        for(Lead leadSeleted : leadSelectedList){
            leadsIds.add(leadSeleted.Id);
        }
        
        System.debug(leadSelectedList);
        System.debug(leadsIds);
        return leadsIds;
    }
    
    @AuraEnabled
   	public static Map<String , Object> getLeadListSelected(Object leadsId, String myJsonString) {
        
        List<MyWrapper> myWrapper = (List<MyWrapper>)System.JSON.deserialize(myJsonString, List<MyWrapper>.class);
        List<Lead> myStringLead = (List<Lead>)System.JSON.deserialize(myJsonString, List<Lead>.class);
        System.debug('* - ' + leadsId);
        System.debug('*Strings - ' + myStringLead);
        System.debug('** - ' + myWrapper);
        System.debug('*** - ' + myJsonString);
        Set<String> leadIds = new Set<String>();
        for(MyWrapper item: myWrapper) {
            leadIds.add(item.id);
        }
        
        System.debug('*Lead*' + leadIds);
        Map<String, Object> recordMap = new Map<String, Object>();
        //System.debug('**** - ' + casesIdSelected);
        List<Lead> leadList = [SELECT Id, toLabel(Status), Name, Lead_Quality__c, Lead_Quality_Helper__c, Company
                               FROM Lead 
                               WHERE Id IN : leadIds];
        System.debug( leadList);
        recordMap.put('leadList', leadList);
        recordMap.put('leadListIds', leadIds);
        return recordMap;
    }
    
     @AuraEnabled
    public static Map<String, Object> closeSaveLeads (Lead leadResult, List<Lead> leadSelectedList, List<Id> leadSelectedIds){
        Map<String, Object> recordMap = new Map<String, Object>();
        
        recordMap.put('message', 'Registros generados, le llegara una notificación a su email.');
        return recordMap;
        
    }
}