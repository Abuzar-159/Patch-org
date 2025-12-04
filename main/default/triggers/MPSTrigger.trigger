trigger MPSTrigger on MPS__c (after insert) {
    if(!PreventRecursiveLedgerEntry.preventMPsTrigger){
        Set<Id> ProductIds = new Set<Id>();
        Map<Id,List<ERP7__BOM__c>> proBOMS = new Map<Id,List<ERP7__BOM__c>>();
        List<MPS__c> MPS2upsert = new List<MPS__c>();
        
        for(MPS__c MPS : System.Trigger.New){
            if(MPS.ERP7__Product__c != Null) ProductIds.add(MPS.ERP7__Product__c);
        }
        List<ERP7__BOM__c> BOMS = [Select Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__BOM_Version__c
                                   From ERP7__BOM__c
                                   Where ERP7__BOM_Product__c In :ProductIds And
                                   ERP7__Active__c = true];
        for(Id pId : ProductIds){
            List<ERP7__BOM__c> myBOMS = new List<ERP7__BOM__c>();
            for(ERP7__BOM__c bom : BOMS){
                if(pId == bom.ERP7__BOM_Product__c) myBOMS.add(bom);
            }
            proBOMS.put(pId,myBOMS);
        }
        
        for(MPS__c MPS : System.Trigger.New){
            if(proBOMS.containsKey(MPS.ERP7__Product__c)){
                List<ERP7__BOM__c> myBOMS = proBOMS.get(MPS.ERP7__Product__c);
                for(ERP7__BOM__c bom : myBOMS){
                    if(bom.ERP7__BOM_Version__c == MPS.ERP7__Version__c) {
                        MPS__c newMPS = new MPS__c();
                        if(Schema.sObjectType.MPS__c.fields.Name.isCreateable() && Schema.sObjectType.MPS__c.fields.Name.isUpdateable()) newMPS.Name = bom.Name;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Bill_Of_Material__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Bill_Of_Material__c.isUpdateable()) newMPS.ERP7__Bill_Of_Material__c = bom.Id;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Start_Date__c.isUpdateable()) newMPS.ERP7__Start_Date__c = MPS.ERP7__Start_Date__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__End_Date__c.isUpdateable()) newMPS.ERP7__End_Date__c = MPS.ERP7__End_Date__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Lot_Size__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Lot_Size__c.isUpdateable()) newMPS.ERP7__Lot_Size__c = MPS.ERP7__Lot_Size__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Default_Demand_Forecast__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Default_Demand_Forecast__c.isUpdateable()) newMPS.ERP7__Default_Demand_Forecast__c = MPS.ERP7__Default_Demand_Forecast__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Master_Production_Schedule__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Master_Production_Schedule__c.isUpdateable()) newMPS.ERP7__Master_Production_Schedule__c = MPS.Id;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Minimum_Inventory_Level__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Minimum_Inventory_Level__c.isUpdateable()) newMPS.ERP7__Minimum_Inventory_Level__c = MPS.ERP7__Minimum_Inventory_Level__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Product__c.isUpdateable()) newMPS.ERP7__Product__c = bom.ERP7__BOM_Component__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Schedule_Period__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Schedule_Period__c.isUpdateable()) newMPS.ERP7__Schedule_Period__c = MPS.ERP7__Schedule_Period__c;
                        if(Schema.sObjectType.MPS__c.fields.ERP7__Starting_Inventory__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Starting_Inventory__c.isUpdateable()) newMPS.ERP7__Starting_Inventory__c = MPS.ERP7__Starting_Inventory__c;
                        if(bom.ERP7__BOM_Version__c != Null && Schema.sObjectType.MPS__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.MPS__c.fields.ERP7__Version__c.isUpdateable()) newMPS.ERP7__Version__c = bom.ERP7__BOM_Version__c;
                        MPS2upsert.add(newMPS);
                    }
                }
            }
        }   
        if(MPS2upsert.size() > 0 && Schema.SObjectType.MPS__c.isCreateable() && Schema.SObjectType.MPS__c.isUpdateable()) upsert MPS2upsert;  else{ }                    
        
    }
}