public with sharing class ProductConfigurator { 
     
    @AuraEnabled 
    public static comWrap ConfigureMO(String RId){ 
        comWrap comW = new comWrap();   
        try{ 
            if(RId != '' && RId != Null){
                String VId = '';
                String pFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
                pFields += ', ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Address__r.ERP7__Address_Line2__c, ERP7__Address__r.ERP7__Address_Line3__c, ERP7__Address__r.ERP7__City__c, ERP7__Address__r.ERP7__State__c, ERP7__Address__r.ERP7__Country__c, ERP7__Address__r.ERP7__Postal_Code__c, ERP7__BOM_Version__r.Name, ERP7__Product__r.Name, ERP7__Process__r.Name, ERP7__Process__r.RecordType.Name, ERP7__Product__r.ERP7__MOQ__c, ERP7__Product__r.ERP7__Configure__c ';
                utilClass.FLSCheck(pFields.split(','),'ERP7__Routing__c');  
                String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Routing__c Where ERP7__Status__c = \'Certified\' ';
                query1 += ' And Id = : RId ';
                List<ERP7__Routing__c> Routings = Database.query(query1);
                if(Routings.size() > 0){
                    comW.Routing = Routings[0];
                    comW.SelectedRouting = comW.Routing.clone(false, false, false, false);
                    VId = comW.Routing.ERP7__BOM_Version__c; } else VId = RId;
               
                pFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Version__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ',ERP7__Product__r.Name from ERP7__Version__c Where ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY';
                if(VId != '' && VId != Null) query1 += ' And Id = : VId ';
                comW.Version = Database.query(query1);
                comW.SelectedVersion = comW.Version.clone(false, false, false, false);
                
                List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__Routing_Link__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, ERP7__For_Multiples__c,
                                                BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c, ERP7__Type__c, ERP7__Process_Cycle__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                                ERP7__Product_Feature__c, ERP7__Product_Feature__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Unit_of_Measure__c, ERP7__Exact_Quantity__c
                                                From ERP7__BOM__c
                                                Where ERP7__Active__c = true And
                                                ERP7__BOM_Version__c =: comW.Version.Id And
                                                ERP7__BOM_Product__c =: comW.Version.ERP7__Product__c And
                                                ERP7__Type__c = 'Primary' And
                                                BOM_Version__r.Active__c = true And
                                                BOM_Version__r.Start_Date__c <= Today And
                                                (BOM_Version__r.To_Date__c = Null Or BOM_Version__r.To_Date__c >= Today) And
                                                RecordType.Name = 'Manufacturing BOM'
                                                Order by BOM_Version__r.Default__c DESC
                                            ];
                
                List < ERP7__Variance__c > Variances = [Select Id, Name, ERP7__Bill_Of_Material__c, ERP7__BOM_Variance__c, ERP7__Product__c, ERP7__Product_Feature__c, ERP7__Product_Feature__r.Name, ERP7__Type__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,
                                                            ERP7__BOM_Variance__r.ERP7__BOM_Component__c, ERP7__BOM_Variance__r.RecordType.Name, ERP7__BOM_Variance__r.RecordTypeId, ERP7__BOM_Variance__r.ERP7__BOM_Version__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.ERP7__Picture__c,
                                                            ERP7__Active__c, ERP7__BOM_Variance__r.ERP7__Unit_of_Measure__c, ERP7__BOM_Variance__r.ERP7__Quantity__c, ERP7__BOM_Variance__r.ERP7__Cost_Price__c, ERP7__BOM_Variance__r.ERP7__Description__c, ERP7__BOM_Variance__r.ERP7__Exact_Quantity__c
                                                            From ERP7__Variance__c 
                                                            Where ERP7__Type__c = 'Alternative' And
                                                            ERP7__BOM_Variance__r.ERP7__BOM_Version__c =: comW.Version.Id And
                                                            ERP7__Bill_Of_Material__c IN :BOMS And
                                                            ERP7__Active__c = true
                                                       ];
                                         
               for(ERP7__BOM__c BOM : BOMS){
                   BOMWrapper BOMW = new BOMWrapper();
                   //BOM.ERP7__Active__c = false;
                   BOMW.BOM = BOM;
                   for(ERP7__Variance__c Variance : Variances){
                       if(Variance.ERP7__Bill_Of_Material__c == BOM.Id) {
                           Variance.ERP7__Active__c = false;
                           BOMW.Variances.add(Variance);
                       }
                   }
                   comW.BOMWrapperList.add(BOMW);
               } 
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveConfiguration(String BOMWrapperList, String RoutingId, String NewRouting, String NewVersion){   
        List<BOMWrapper> BOMWrapperLists = (List<BOMWrapper>) JSON.deserialize(BOMWrapperList, List<BOMWrapper> .class);
        ERP7__Routing__c nRouting = (ERP7__Routing__c) JSON.deserialize(NewRouting, ERP7__Routing__c .class);
        ERP7__Version__c nVersion = (ERP7__Version__c) JSON.deserialize(NewVersion, ERP7__Version__c .class);
        
        comWrap comW = new comWrap();
        try{
            if(Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) upsert nVersion;
            nRouting.ERP7__BOM_Version__c = nVersion.Id;
            if(Schema.SObjectType.ERP7__Routing__c.isCreateable() && Schema.SObjectType.ERP7__Routing__c.isUpdateable()) upsert nRouting;
            Set<Id> bomIds = new Set<Id>();
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){
                    bomIds.add(BOMW.BOM.Id);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) { bomIds.add(Variance.ERP7__BOM_Variance__c);
                        }
                    }
                }
            }
            String pFields = UtilClass.selectStarFromSObject('ERP7__BOM__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__BOM__c');  
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__BOM__c Where Id In : bomIds ';
            List<ERP7__BOM__c> BOMS = Database.query(query1);
            
            Map<Id, ERP7__BOM__c> bomMap = new Map<Id, ERP7__BOM__c>();
            for(ERP7__BOM__c BOM : BOMS) bomMap.put(BOM.Id, BOM);
            List<ERP7__BOM__c> BOMS2Upsert = new List<ERP7__BOM__c>();
            
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){
                    ERP7__BOM__c BOM = bomMap.get(BOMW.BOM.Id).clone(false, false, false, false);
                    BOM.ERP7__BOM_Version__c = nVersion.Id;
                    BOM.ERP7__Quantity__c = BOMW.BOM.ERP7__Quantity__c;
                    BOM.ERP7__Cost_Price__c = BOMW.BOM.ERP7__Cost_Price__c;
                    BOM.ERP7__Type__c='Primary';
                    BOMS2Upsert.add(BOM);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) {
                            ERP7__BOM__c BOM = bomMap.get(Variance.ERP7__BOM_Variance__c).clone(false, false, false, false);
                            BOM.ERP7__BOM_Version__c = nVersion.Id;
                            BOM.ERP7__Quantity__c = Variance.ERP7__BOM_Variance__r.ERP7__Quantity__c;
                            BOM.ERP7__Cost_Price__c = Variance.ERP7__BOM_Variance__r.ERP7__Cost_Price__c;
                            BOM.ERP7__Type__c='Primary'; BOMS2Upsert.add(BOM);
                        }
                    }
                }
            }
            if(BOMS2Upsert.size() > 0 && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Cost_Price__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Cost_Price__c.isUpdateable() && Schema.SObjectType.ERP7__BOM__c.isCreateable() && Schema.SObjectType.ERP7__BOM__c.isUpdateable()){upsert BOMS2Upsert;}else{comW.errorMsg ='not allowed to upsert BOM';}
            
            pFields = UtilClass.selectStarFromSObject('ERP7__Operation__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__Operation__c');  
            query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Operation__c Where ERP7__Routing__c = : RoutingId ';
            List< ERP7__Operation__c > Operations = Database.query(query1);
            
            List<ERP7__Operation__c> Operations2Upsert = new List<ERP7__Operation__c>();
            for(ERP7__Operation__c Operation : Operations){
                ERP7__Operation__c Oprn = Operation.clone(false, false, false, false);
                Oprn.ERP7__Routing__c = nRouting.Id;
                Operations2Upsert.add(Oprn);
            }
            if(Operations2Upsert.size() > 0 && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isUpdateable() && Schema.SObjectType.ERP7__Operation__c.isCreateable() && Schema.SObjectType.ERP7__Operation__c.isUpdateable()){upsert Operations2Upsert;}else{comW.errorMsg ='Not allowed to upsert operation';}
            comW.SelectedVersion = nVersion;
            comW.SelectedRouting = nRouting;
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveConfigurationVersion(String BOMWrapperList, String VersionId, String NewVersion){   
        List<BOMWrapper> BOMWrapperLists = (List<BOMWrapper>) JSON.deserialize(BOMWrapperList, List<BOMWrapper> .class);
        ERP7__Version__c nVersion = (ERP7__Version__c) JSON.deserialize(NewVersion, ERP7__Version__c .class);
        
        comWrap comW = new comWrap();
        try{
            if(Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) upsert nVersion;
            Set<Id> bomIds = new Set<Id>();
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){ bomIds.add(BOMW.BOM.Id);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) { bomIds.add(Variance.ERP7__BOM_Variance__c);
                        }
                    }
                }
            }
            String pFields = UtilClass.selectStarFromSObject('ERP7__BOM__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__BOM__c');  
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__BOM__c Where Id In : bomIds ';
            List<ERP7__BOM__c> BOMS = Database.query(query1);
            
            Map<Id, ERP7__BOM__c> bomMap = new Map<Id, ERP7__BOM__c>(); for(ERP7__BOM__c BOM : BOMS) bomMap.put(BOM.Id, BOM);
            List<ERP7__BOM__c> BOMS2Upsert = new List<ERP7__BOM__c>();
            
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){
                    ERP7__BOM__c BOM = bomMap.get(BOMW.BOM.Id).clone(false, false, false, false); BOM.ERP7__BOM_Version__c = nVersion.Id;
                    BOM.ERP7__Quantity__c = BOMW.BOM.ERP7__Quantity__c; BOM.ERP7__Cost_Price__c = BOMW.BOM.ERP7__Cost_Price__c;
                    BOM.ERP7__Type__c='Primary'; BOMS2Upsert.add(BOM);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) {
                            ERP7__BOM__c BOM = bomMap.get(Variance.ERP7__BOM_Variance__c).clone(false, false, false, false); BOM.ERP7__BOM_Version__c = nVersion.Id;
                            BOM.ERP7__Quantity__c = Variance.ERP7__BOM_Variance__r.ERP7__Quantity__c;
                            BOM.ERP7__Cost_Price__c = Variance.ERP7__BOM_Variance__r.ERP7__Cost_Price__c;
                            BOM.ERP7__Type__c='Primary'; BOMS2Upsert.add(BOM);
                        }
                    }
                }
            }
            if(BOMS2Upsert.size() > 0 && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Cost_Price__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Cost_Price__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()){ upsert BOMS2Upsert;}else{comW.errorMsg ='Not allowed to upsert BOM'; }
            comW.SelectedVersion = nVersion;
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    public class comWrap {
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public ERP7__Routing__c Routing                                { get ; set; }
        @AuraEnabled public ERP7__Version__c Version                                { get ; set; }
        @AuraEnabled public ERP7__Routing__c SelectedRouting                        { get ; set; }
        @AuraEnabled public ERP7__Version__c SelectedVersion                        { get ; set; }  
        @AuraEnabled public List< ERP7__BOM__c > BOMS                               { get ; set; } 
        @AuraEnabled public List< BOMWrapper > BOMWrapperList                       { get ; set; }  
       
        public comWrap() {
            errorMsg = ''; 
            BOMWrapperList = new List< BOMWrapper >();
            BOMS = new List<ERP7__BOM__c>();
            Routing = new ERP7__Routing__c();
            Version = new ERP7__Version__c();
            SelectedRouting = new ERP7__Routing__c();
            SelectedVersion = new ERP7__Version__c();                    
        }
    }  
    
    public class BOMWrapper{
        @AuraEnabled public List < ERP7__Variance__c > Variances           { get ; set; }
        @AuraEnabled public ERP7__BOM__c BOM                               { get ; set; }
        @AuraEnabled public ERP7__BOM__c SelectedBOM                       { get ; set; }
        
        public BOMWrapper(){
             Variances = new List < ERP7__Variance__c >();
             BOM = new ERP7__BOM__c(); 
             SelectedBOM = new ERP7__BOM__c();
        }
    }
  
}