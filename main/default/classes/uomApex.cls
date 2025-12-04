public with sharing class uomApex {
    @AuraEnabled(cacheable=true)
    public static List<ERP7__UOM_Conversion__mdt> getAllUOMConversions() {
        Map<String, ERP7__UOM_Conversion__mdt> uomsMap = ERP7__UOM_Conversion__mdt.getAll();
        List<ERP7__UOM_Conversion__mdt> uomsList = [Select Id, MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt ORDER BY MasterLabel ASC limit 999];
        return uomsList;
    }
    @AuraEnabled(cacheable=true)
    public static List<ERP7__UOM_Conversion__mdt> searchMethod(String searchItem) {
        List<ERP7__UOM_Conversion__mdt> uomsList = new List<ERP7__UOM_Conversion__mdt>();
        if(String.isNotEmpty(searchItem)){//if(searchItem != null || searchItem != ''){
            String query = 'SELECT Id, MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt WHERE MasterLabel LIKE \'%' + String.escapeSingleQuotes(searchItem) + '%\'';  
            uomsList = Database.query(query);
        }else if(String.isEmpty(searchItem)){
            String query = 'SELECT Id, MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt ORDER BY MasterLabel ASC';
            uomsList = Database.query(query);
        }
        return uomsList;
    }

    @AuraEnabled(cacheable=true)
    public static void createUOMConv(String label, Decimal fromValue, Decimal toValue, String fromUOM, String toUOM) {
        List<ERP7__UOM_Conversion__mdt> uomsList = new List<ERP7__UOM_Conversion__mdt>();
        try{
            String modifiedlabel = '';
            modifiedlabel = label.replace('-', '');
            modifiedlabel = modifiedlabel.replaceAll('_', '');
            modifiedlabel = modifiedlabel.replaceAll(' ', '_');
            modifiedlabel = 'X'+modifiedlabel;
            Decimal tvalue = toValue;
            Decimal fvalue = fromValue;
            System.debug('modifiedlabel' + modifiedlabel);
            Metadata.DeployContainer container = new Metadata.DeployContainer();//container
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();//custom metadata instance
            String namespaceLabel = System.Label.namespaceLabel;
            customMetadata.fullName= namespaceLabel +'UOM_Conversion.'+ modifiedlabel; //'Api name without __mdt(.)'+'DeveloperName';
            customMetadata.label=label;//Label
            System.debug('namespaceLabel: '+ namespaceLabel +'UOM_Conversion.'+ modifiedlabel); 
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'ERP7__From_Value__c';
            customField1.value = fvalue;
            customMetadata.values.add(customField1);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField2= new Metadata.CustomMetadataValue();
            customField2.field = 'ERP7__To_Value__c';
            customField2.value = tvalue;
            customMetadata.values.add(customField2);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customField3.field = 'ERP7__From_UOM__c';
            customField3.value = fromUOM;
            customMetadata.values.add(customField3);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
            customField4.field = 'ERP7__To_UOM__c';
            customField4.value = toUOM;
            customMetadata.values.add(customField4);
            container.addMetadata(customMetadata);
            
            Id asyncResultId = Metadata.Operations.enqueueDeployment(container, null);
        }
        catch(exception e){
           System.debug('Error: '+ e);
        }
    }
    @AuraEnabled(cacheable=true)
    public static void updateUoM(String id, String Label, Decimal fromValue, Decimal toValue, String fromUOM, String toUOM) {
        List<ERP7__UOM_Conversion__mdt> uomsList = new List<ERP7__UOM_Conversion__mdt>();
        try{
            Map<String, ERP7__UOM_Conversion__mdt> uomsMap = ERP7__UOM_Conversion__mdt.getAll();
            ERP7__UOM_Conversion__mdt uom = new ERP7__UOM_Conversion__mdt();
            uomsList = uomsMap.values();
            for(ERP7__UOM_Conversion__mdt um:uomsList){
                if(um.DeveloperName==id)uom=um;
            }   
            Metadata.DeployContainer container = new Metadata.DeployContainer();//container
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();//custom metadata instance
            
            String namespaceLabel = System.Label.namespaceLabel;
            customMetadata.fullName = namespaceLabel +'UOM_Conversion.'+ uom.DeveloperName; //'Api name without __mdt(.)'+'DeveloperName';
            customMetadata.label=Label;
			System.debug('namespaceLabel: '+ namespaceLabel +'UOM_Conversion.'+ uom.DeveloperName);            
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'ERP7__From_Value__c';
            customField1.value = fromValue;
            customMetadata.values.add(customField1);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField2= new Metadata.CustomMetadataValue();
            customField2.field = 'ERP7__To_Value__c';
            customField2.value = toValue;
            customMetadata.values.add(customField2);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customField3.field = 'ERP7__From_UOM__c';
            customField3.value = fromUOM;
            customMetadata.values.add(customField3);
            container.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
            customField4.field = 'ERP7__To_UOM__c';
            customField4.value = toUOM;
            customMetadata.values.add(customField4);
            container.addMetadata(customMetadata);
            Id asyncResultId = Metadata.Operations.enqueueDeployment(container, null);
            
        }catch(exception e){
            System.debug('Caught exception: '+ e); 
        }
    }
}