public with sharing class CreateDebitNote {
    public decimal taxRate { get; set; }
    public Integer ItemCounter { get; set; }
    public PO__c po { get; set; }
    public Attachment newAttachment {get; set;}
    public Attachment new_Attachment;
    public List<Attachment> attach2Insert;
    public String POId {get; set;}
    public String BillID {get; set;}
    public Bill__c bill { get; set; } public List<ERP7__Debit_Note_Item__c> lineItems { get; set; }
    public List<LineItem_Wrap> LineItemWrapList { get; set; }
    public Boolean selectAll {get; set;}
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    
    public CreateDebitNote(){
        //BillID  = Apexpages.currentPage().getParameters().get('Id');
        newAttachment = new Attachment();
        attach2Insert = new List<Attachment>();
        LineItemWrapList = new List<LineItem_Wrap>();
        ItemCounter = 0;
        taxRate=0.0;
        selectAll = false;
        /*if(String.isNotEmpty(BillID)){
            Bill = [SELECT Amount__c,Vendor__c,Vendor__r.Vat__c,Vendor__r.Tax_on_Purchase__c,Vendor__r.Vat__r.Tax_Rate__c,Total_Amount__c,Purchase_Order__c,VAT_TAX_Amount__c,Received_date__c,Due_Date__c FROM BIll__c WHERE id=:BillID];
            taxRate = (Bill.Vendor__r.Vat__c!= null && Bill.Vendor__r.Tax_on_Purchase__c)?Bill.Vendor__r.Vat__r.Tax_Rate__c:0.00;
            Integer i =0;
            for(Bill_Line_Item__c li:[Select Id,Name,Amount__c,Quantity__c,Purchase_Order_Line_Items__r.Quantity__c,Purchase_Order_Line_Items__r.ERP7__Quantity_Received__c,Purchase_Order_Line_Items__c,Product__c,Item_Description__c,Total_Amount__c FROM Bill_Line_Item__c Where Bill__c =:BillID]){
                LineItem_Wrap li_wrap = new LineItem_Wrap();
                li_wrap.lineItem = li;
                li_wrap.received_Qty = li.Purchase_Order_Line_Items__r.ERP7__Quantity_Received__c;
                li_wrap.poli_Qty = li.Purchase_Order_Line_Items__r.Quantity__c;
                li_wrap.index = i;
                LineItemWrapList.add(li_wrap);i++;
            }
        }else{ 
            
            Bill = new Bill__c(Amount__c=0.00,Total_Amount__c=0.00,VAT_TAX_Amount__c=0.00,Received_date__c=System.Today(),Due_Date__c=System.Today()+30); POId = ApexPages.currentPage().getParameters().get('po'); if(String.isNotEmpty(poid)) buildBillByPO();
            
        }*/
    }
    public class LineItem_Wrap {
        public Boolean isSelect { get; set; }
        public ERP7__Debit_Note_Item__c lineItem { get; set; }
        public Integer index { get; set; }
        public decimal poli_Qty { get; set; }
        public decimal received_Qty { get; set; }
        public LineItem_Wrap (){
            index = 0;
            received_Qty = 0.00;
            poli_Qty = 0.00;
            isSelect = false;
            lineItem = new ERP7__Debit_Note_Item__c (Amount__c=0.00,Quantity__c=0.00,Total_Amount__c=0.00);
        }
    }
    
    @AuraEnabled
    public static List<String> fetch_billItems(String Id){
        List<String> returnList = new List<String>();
        if(Id!=null && Id!=''){
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> billItemIds=new Set<Id>();
        List<ERP7__Bill_Line_Item__c> updatedbillItem=new List<ERP7__Bill_Line_Item__c>();
        ERP7__Bill__c bill = [SELECT Id,Name, ERP7__Department__c, ERP7__Vendor__c , ERP7__Total_Amount__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name, ERP7__Project__c  FROM ERP7__Bill__c WHERE Id =: Id];
        returnList.add(JSON.serialize(bill)); 
        if(Id!=null && Id!=''){
            if(bill!=null){
                Decimal billAmount = 0.00;
                if(bill.ERP7__Total_Amount__c!=null) billAmount = bill.ERP7__Total_Amount__c;
                List<ERP7__Debit_Note__c> dblist = new List<ERP7__Debit_Note__c>();
                dblist = [select Id, Name, ERP7__Debit__c from ERP7__Debit_Note__c where ERP7__Vendor_Invoice_Bill__c=:Id and ERP7__Debit__c!=null];
                if(dblist.size()>0){
                    Decimal DbAmount = 0.00;
                    for(ERP7__Debit_Note__c db : dblist){
                        DbAmount = DbAmount + db.ERP7__Debit__c;
                    }
                    if(billAmount==DbAmount){
                        returnList.add(JSON.serialize(updatedbillItem)); 
        				returnList.add(JSON.serialize(billingQunaity));
                        List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
                        returnList.add(JSON.serialize(demList));
                        returnList.add('Invalid');
                        return returnList;
                    }
                }
            }
        }
        List<ERP7__Bill_Line_Item__c> billItemlist =  [SELECT Id,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Amount__c,ERP7__Total_Amount__c, ERP7__Purchase_Orders__c, ERP7__Item_Description__c,ERP7__Tax_Amount__c, ERP7__Sort_Order__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Orders__r.Name, ERP7__Purchase_Order__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.Name, ERP7__Account_Category__c, ERP7__Chart_Of_Account__c, ERP7__Debit_Note_Quantity__c  FROM ERP7__Bill_Line_Item__c Where ERP7__Bill__c =:Id];
        for(ERP7__Bill_Line_Item__c billItem:billItemlist){
            billItemIds.add(billItem.Id);
        }
        List<ERP7__Debit_Note_Item__c> existDbList = new List<ERP7__Debit_Note_Item__c>();
        Map<Id, List<ERP7__Debit_Note_Item__c>> mapBillDbItm = new Map<Id, List<ERP7__Debit_Note_Item__c>>();
        existDbList = [select Id, Name, ERP7__Quantity__c, ERP7__Bill_Line_Item__c from ERP7__Debit_Note_Item__c where ERP7__Bill_Line_Item__c IN :billItemIds];
        if(existDbList.size()>0){
            for(ERP7__Debit_Note_Item__c dbitem : existDbList){
                if(mapBillDbItm.containskey(dbitem.ERP7__Bill_Line_Item__c)){
                    mapBillDbItm.get(dbitem.ERP7__Bill_Line_Item__c).add(dbitem);
                }else{
                    List<ERP7__Debit_Note_Item__c> dblist = new List<ERP7__Debit_Note_Item__c>();
                    dblist.add(dbitem);
                    mapBillDbItm.put(dbitem.ERP7__Bill_Line_Item__c, dblist);
                }
            } 
            for(ERP7__Bill_Line_Item__c billItem:billItemlist){
                List<ERP7__Debit_Note_Item__c> dbItemsList=((mapBillDbItm.get(billItem.Id) != null) ? mapBillDbItm.get(billItem.Id) : null);  
                if(dbItemsList==null){
                    updatedbillItem.add(billItem);
                    billingQunaity.add(billItem.ERP7__Quantity__c);
                }
                else{
                    Decimal DbQuantity = 0;
                    for(ERP7__Debit_Note_Item__c dbItem : dbItemsList){
                        if(dbItem.ERP7__Quantity__c != null){
                            DbQuantity = DbQuantity + dbItem.ERP7__Quantity__c;
                        }
                    } 
                    if(DbQuantity < billItem.ERP7__Quantity__c){
                        updatedbillItem.add(billItem);
                        billingQunaity.add(billItem.ERP7__Quantity__c - DbQuantity);
                    }else{
                        updatedbillItem.add(billItem);
                        billingQunaity.add(billItem.ERP7__Quantity__c - DbQuantity);
                    }
                }
            }
            returnList.add(JSON.serialize(updatedbillItem)); 
            returnList.add(JSON.serialize(billingQunaity));
            List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
            demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c, ERP7__Bill_Line_Item__c from ERP7__Dimension__c where ERP7__Bill_Line_Item__c IN :billItemIds AND ERP7__Bill_Line_Item__c != null];
            //if(demList!=null && demList.size()>0) 
            returnList.add(JSON.serialize(demList));
            returnList.add('Consumed Quantity');
            system.debug('demList-->'+demList);
            return returnList;
        }else{
           for(ERP7__Bill_Line_Item__c billItem:billItemlist){
               updatedbillItem.add(billItem);
               billingQunaity.add(billItem.ERP7__Quantity__c);
           }
        }
        
        returnList.add(JSON.serialize(updatedbillItem)); 
        returnList.add(JSON.serialize(billingQunaity));
        
        List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
        demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c, ERP7__Bill_Line_Item__c from ERP7__Dimension__c where ERP7__Bill_Line_Item__c IN :billItemIds AND ERP7__Bill_Line_Item__c != null];
        //if(demList!=null && demList.size()>0) 
        returnList.add(JSON.serialize(demList));
        returnList.add('Consumed Quantity');
        system.debug('demList-->'+demList);
        return returnList;
        }else{
            return returnList;
        }
    }
    
    @AuraEnabled
    public static List<String> fetch_Polis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Purchase_Line_Items__c> updatedPoli=new List<ERP7__Purchase_Line_Items__c>();
        ERP7__PO__c po = [SELECT Id,Name, ERP7__Vendor__c , ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name FROM ERP7__PO__c WHERE Id =: Id];
        returnList.add(JSON.serialize(po)); 
        
        List<ERP7__Purchase_Line_Items__c> polist =  [SELECT Id,ERP7__Quantity_Received__c,ERP7__Debit_Note_Quantity__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Purchase_Orders__c, ERP7__Special_Instruction__c,ERP7__Tax__c, ERP7__Sort_Order__c,ERP7__Purchase_Orders__r.Name  FROM ERP7__Purchase_Line_Items__c Where ERP7__Purchase_Orders__c =:Id];
        //returnList.add(JSON.serialize(polist));
        for(ERP7__Purchase_Line_Items__c p:polist){
            
            if(p.ERP7__Debit_Note_Quantity__c!=null && p.ERP7__Debit_Note_Quantity__c>0 && (p.ERP7__Quantity__c-p.ERP7__Debit_Note_Quantity__c)>0){
            poliIds.add(p.Id);
            updatedPoli.add(p);
            billingQunaity.add(p.ERP7__Quantity__c-p.ERP7__Debit_Note_Quantity__c);
            }else if(p.ERP7__Debit_Note_Quantity__c==null || p.ERP7__Debit_Note_Quantity__c==0){
            poliIds.add(p.Id);
            updatedPoli.add(p);
            billingQunaity.add(p.ERP7__Quantity__c);
            }
        }
        
        
       
        /*Id RTID; RTID = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Advance_to_vendor').getRecordTypeId();
        List<ERP7__Bill_Line_Item__c> BillItems=new List<ERP7__Bill_Line_Item__c>();
        Map < Id, ERP7__Bill_Line_Item__c > Existing_billItems_Map = new Map < Id, ERP7__Bill_Line_Item__c > ();
        Map < Id, List<ERP7__Bill_Line_Item__c> > Existing_billItem_Map = new Map < Id, List<ERP7__Bill_Line_Item__c> > ();
        for(ERP7__Bill_Line_Item__c billItem:[select id,Name,ERP7__Quantity__c, ERP7__Purchase_Order_Line_Items__c,RecordTypeId,RecordType.DeveloperName from ERP7__Bill_Line_Item__c where ERP7__Purchase_Order_Line_Items__c IN :poliIds AND RecordType.DeveloperName != 'Advance_to_vendor']){
            Existing_billItems_Map.put(billItem.ERP7__Purchase_Order_Line_Items__c, billItem);
            if(Existing_billItem_Map.containskey(billItem.ERP7__Purchase_Order_Line_Items__c)){
                Existing_billItem_Map.get(billItem.ERP7__Purchase_Order_Line_Items__c).add(billItem);
            }else{
                List<ERP7__Bill_Line_Item__c> billItemList = new List<ERP7__Bill_Line_Item__c>();
                billItemList.add(billItem);
                Existing_billItem_Map.put(billItem.ERP7__Purchase_Order_Line_Items__c, billItemList);
            }
        }
        for(ERP7__Purchase_Line_Items__c p:polist){  
            List<ERP7__Bill_Line_Item__c> billItemsList=((Existing_billItem_Map.get(p.Id) != null) ? Existing_billItem_Map.get(p.Id) : null);  
            if(billItemsList==null) {
                updatedPoli.add(p);
                billingQunaity.add(p.ERP7__Quantity__c);
            }
            else{
                /*Decimal BillQuantity = 0;
                for(ERP7__Bill_Line_Item__c bi : billItemsList){
                    if(bi.ERP7__Quantity__c != null){
                        BillQuantity = BillQuantity + bi.ERP7__Quantity__c;
                    }
                } *
                //if(BillQuantity != p.ERP7__Quantity__c){
                    updatedPoli.add(p);
                    billingQunaity.add(p.ERP7__Quantity__c);
                //}
            }
        }*/
        
        returnList.add(JSON.serialize(updatedPoli)); 
        returnList.add(JSON.serialize(billingQunaity));
        List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
        demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c IN :poliIds AND ERP7__Purchase_Line_Items__c != null];
        if(demList!=null && demList.size()>0) returnList.add(JSON.serialize(demList));
        return returnList;
    }

    
    @AuraEnabled 
    public static Boolean checkTotalAmount(String Bill){
        try{
            ERP7__Debit_Note__c billObj = (ERP7__Debit_Note__c)JSON.deserialize(Bill, ERP7__Debit_Note__c.class); 
            
            if(billObj.ERP7__Tax_Amount__c != null ) billObj.ERP7__Debit__c = billObj.ERP7__Amount__c.setScale(2) + billObj.ERP7__Tax_Amount__c.setScale(2);
            else billObj.ERP7__Debit__c = billObj.ERP7__Amount__c.setScale(2);
            system.debug('Id-->'+billObj.ERP7__Vendor_Invoice_Bill__c);
            if(billObj.ERP7__Vendor_Invoice_Bill__c!=null){
                ERP7__Bill__c bill1 = [SELECT Id,Name, ERP7__Vendor__c , ERP7__Total_Amount__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name FROM ERP7__Bill__c WHERE Id =: billObj.ERP7__Vendor_Invoice_Bill__c];
                //if(billObj.ERP7__Vendor_Invoice_Bill__c!=null && billObj.ERP7__Vendor_Invoice_Bill__c!=''){
                    if(bill1!=null){
                        Decimal billAmount = 0.00;
                        if(bill1.ERP7__Total_Amount__c!=null) billAmount = bill1.ERP7__Total_Amount__c;
                        system.debug('DB Amount'+billObj.ERP7__Debit__c);
                        List<ERP7__Debit_Note__c> dblist = new List<ERP7__Debit_Note__c>();
                        dblist = [select Id, Name, ERP7__Debit__c from ERP7__Debit_Note__c where ERP7__Vendor_Invoice_Bill__c=:billObj.ERP7__Vendor_Invoice_Bill__c and ERP7__Debit__c!=null];
                        if(dblist.size()>0){
                            Decimal DbAmount = 0.00;
                            for(ERP7__Debit_Note__c db : dblist){
                                DbAmount = DbAmount + db.ERP7__Debit__c.setScale(2);
                            }
                            DbAmount = DbAmount + billObj.ERP7__Debit__c.setScale(2);
                            if(DbAmount>billAmount){
                                return true;
                            }
                        }else{
                            if(billObj.ERP7__Debit__c.setScale(2)>billAmount.setScale(2)){
                                return true;
                            } 
                        }
                    }
               // }
            }
            return false;
        }catch(Exception e){
            system.debug('Exception-->'+e+e.getLineNumber());
            return false;
        }
    }
    
    @AuraEnabled 
    public static Map<String,Object> save_Bill(String Bill, String BillItems,String RTName){
        Map<String,Object> returnval = new Map<String,Object>();
        try{
            //if(RTName != 'Advance_to_vendor'){
                List<String> returnList = new List<String>();
                //Id RTID; if(String.isNotEmpty(RTName)) RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                ERP7__Debit_Note__c billObj = (ERP7__Debit_Note__c)JSON.deserialize(Bill, ERP7__Debit_Note__c.class); 
                
                if(billObj.ERP7__Tax_Amount__c != null ) billObj.ERP7__Debit__c = billObj.ERP7__Amount__c + billObj.ERP7__Tax_Amount__c;
                else billObj.ERP7__Debit__c = billObj.ERP7__Amount__c;
                
                /*if(billObj.ERP7__Amount__c!=null){
                    if(billObj.ERP7__Amount__c<0){  
                        if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Amount__c.isUpdateable()) billObj.ERP7__Amount__c = billObj.ERP7__Amount__c * -1;  }
                }
            if(Schema.sObjectType.Bill__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Bill__c.fields.Total_Amount__c.isUpdateable()){
                if(RTName != 'Advance_to_vendor' && billObj.ERP7__VAT_TAX_Amount__c != null) {billObj.ERP7__Total_Amount__c =(billObj.ERP7__Amount__c + billObj.ERP7__VAT_TAX_Amount__c - billObj.ERP7__Discount_Amount__c);}    else {billObj.ERP7__Total_Amount__c=billObj.ERP7__Amount__c - billObj.ERP7__Discount_Amount__c; }     //- (billObj.ERP7__Discount_Amount__c )
              
            }*/
                
                
               //if(RTID != null) billObj.RecordTypeId=RTID;
              //if(Schema.sObjectType.Bill__c.fields.ERP7__Bill_Date__c.isCreateable() && Schema.sObjectType.Bill__c.fields.ERP7__Bill_Date__c.isUpdateable())  billObj.ERP7__Bill_Date__c=System.today();
               if(Schema.sObjectType.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.isUpdateable()) { upsert billObj; } else { }
                ERP7__Debit_Note__c bb=[select id,Name from ERP7__Debit_Note__c where Id=:billObj.Id];
                //Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                List<ERP7__Debit_Note_Item__c> billItemsList = (List<ERP7__Debit_Note_Item__c>)JSON.deserialize(BillItems, List<ERP7__Debit_Note_Item__c>.class);
                for(Integer i=0;i<billItemsList.size();i++){
                    if(Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Debit_Note__c.isUpdateable()) {billItemsList[i].ERP7__Debit_Note__c  = billObj.id; } 
                    //if(RTIDBLI != null) billItemsList[i].RecordTypeId = RTIDBLI; 
                    if(String.isEmpty(billItemsList[i].ERP7__Chart_Of_Account__c) && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Chart_Of_Account__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Chart_Of_Account__c.isUpdateable()){ billItemsList[i].ERP7__Chart_Of_Account__c = null;}if(billItemsList[i].ERP7__Quantity__c==null && Schema.sObjectType.Bill_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()) billItemsList[i].ERP7__Quantity__c=0; 
                    if(billItemsList[i].ERP7__Amount__c==null && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Amount__c.isUpdateable()) billItemsList[i].ERP7__Amount__c=0; 
                    if(billItemsList[i].ERP7__Tax_Amount__c==null && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Tax_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Tax_Amount__c.isUpdateable()) billItemsList[i].ERP7__Tax_Amount__c=0; 
                    //if(billItemsList[i].ERP7__Tax_Amount__c==null && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Other_Tax__c.isUpdateable())
                        billItemsList[i].ERP7__Other_Tax__c=0; 
                    //if(billItemsList[i].ERP7__Discount__c==null && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Discount__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.fields.ERP7__Discount__c.isUpdateable()) billItemsList[i].ERP7__Discount__c=0;  
                    system.debug('billItemsList[i].ERP7__Quantity__c : '+billItemsList[i].ERP7__Quantity__c);    
                    system.debug(' billItemsList[i].ERP7__Amount__c : '+billItemsList[i].ERP7__Amount__c);
                    system.debug(' billItemsList[i].ERP7__Tax_Amount__c : '+billItemsList[i].ERP7__Tax_Amount__c);
                    system.debug(' billItemsList[i].ERP7__Other_Tax__c : '+billItemsList[i].ERP7__Other_Tax__c);
                    if(Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.fields.ERP7__Total_Amount__c.isUpdateable()) billItemsList[i].ERP7__Total_Amount__c  = ((billItemsList[i].ERP7__Quantity__c  * billItemsList[i].ERP7__Amount__c)+ billItemsList[i].ERP7__Tax_Amount__c+billItemsList[i].ERP7__Other_Tax__c) - 0 ;
                }
            if(billItemsList.size()>0) {
                if(Schema.sObjectType.ERP7__Debit_Note_Item__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note_Item__c.isUpdateable()){upsert billItemsList; } else { }
            }
                returnList.add(JSON.serialize(billObj)); returnList.add(JSON.serialize(billItemsList)); //return billObj;
                returnval.put('bill',billObj);
                returnval.put('bill2',bb);
            
            
      }catch(Exception ex){   returnval.put('error',ex.getMessage()+ex.getLineNumber());   }
        return returnval;
    }
    
    
     @AuraEnabled 
    public static String save_attachment2(String parentId,String Pid){
        try{
            ERP7__Logistic__c logistics=[select id,Name from ERP7__Logistic__c where ERP7__Purchase_Order__c=:pid Limit 1];
            Attachment al=[select parentId,Body,Name,ContentType from Attachment where parentId=:logistics.Id];
            Attachment a = new Attachment(); 
            a.parentId = parentId; 
            a.Body = al.Body; 
            a.Name= al.Name; 
            a.ContentType = al.ContentType; 
            if(Schema.SObjectType.Attachment.isCreateable()){ insert a; } else{ }
            return 'Success';
        }
        catch(Exception e){ String exc=Json.serialize(e); return exc; }
        
    }
    
    
    @AuraEnabled
    public static String uploadFile(String parent, String fileName, String base64Data, String contentType) { 
        system.debug('uploadFile-->');
        try{  base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  Attachment a = new Attachment();  a.parentId = parent; a.Body = EncodingUtil.base64Decode(base64Data);  a.Name = fileName; a.ContentType = contentType; if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ } return 'Success'; } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }
               
    }
    
    @AuraEnabled
    public static ERP7__Debit_Note__c fetchDebitNoteDetails(String DId){
        if(DId!=null || DId!=''){
            ERP7__Debit_Note__c dNote = [select Id, Name, ERP7__Purchase_Orders__c, ERP7__Vendor_Invoice_Bill__c, ERP7__Account__c, ERP7__Organisation__c, ERP7__Debit__c from ERP7__Debit_Note__c where Id = :DId];
            return dNote;
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveDebitNotePayment(String payment,String PM){
         Map<String,Object> returnValue = new Map<String,Object>();
         Id RT;
         RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId(); 
         ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
         payments.RecordTypeId=RT;
         payments.ERP7__Transaction_Type__c = 'RefundPay';
         if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=PM;
         if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = PM;
         if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{returnValue.put('error', 'Not allowed to upsert payment'); }
         ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
         returnValue.put('pay', payName); 
         returnValue.put('payments',payments);
         return returnValue;
    }
       
       
    /*@AuraEnabled
    public static List<String> fetch_invlis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Invoice_Line_Item__c> invLine=new List<ERP7__Invoice_Line_Item__c>();
        ERP7__Invoice__c inv = [SELECT Id,Name, ERP7__Invoice_Amount__c, ERP7__Tax_Amount__c, ERP7__Sales_Invoice_Percentage__c, ERP7__Sales_Invoice_Tax_Percentage__c, ERP7__Shipping_Amount__c, ERP7__Shipping_Tax_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Down_Payment__c, ERP7__Total_Down_Payment_Amount__c, ERP7__Record_Type_Name__c, ERP7__Paid_Amount_Applied__c, ERP7__Order__c , ERP7__Order_S__c, ERP7__Account__r.Id, ERP7__Account__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name  FROM ERP7__Invoice__c WHERE Id =: Id];
        returnList.add(JSON.serialize(inv)); 
        system.debug('inv-->'+inv);
        invLine =  [SELECT Id,ERP7__Quantity__c,ERP7__Detailed_Description__c, Name,ERP7__Product__c,ERP7__Discount_Amount__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Invoice__c, ERP7__Total_Tax__c  FROM ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c =:Id];
        system.debug('invLine-->'+invLine.size());
        
        returnList.add(JSON.serialize(invLine)); 
        List<ERP7__Credit_Note__c> credlist = new List<ERP7__Credit_Note__c>();
        credlist = [select Id, Name, ERP7__Invoice__c, ERP7__Credit__c from ERP7__Credit_Note__c where ERP7__Invoice__c=:Id];
        if(credlist.size()>0){
            
            Decimal totalCredit = 0.00;
            for(ERP7__Credit_Note__c cred : credlist){
                if(cred.ERP7__Credit__c!=null) totalCredit = totalCredit + cred.ERP7__Credit__c;
            }
            if(inv!=null && inv.ERP7__Invoice_Amount__c!=null){
                if(totalCredit>=inv.ERP7__Invoice_Amount__c){
                    returnList.add('True'); 
                }else{
                    returnList.add('false'); 
                }
            }
            return returnList;
        }
        returnList.add('false');
        return returnList;
    }*/
    @AuraEnabled
    public static List<String> fetch_invlis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Invoice_Line_Item__c> invLine=new List<ERP7__Invoice_Line_Item__c>();
        List<ERP7__Invoice_Line_Item__c> newinvLine=new List<ERP7__Invoice_Line_Item__c>();
        ERP7__Invoice__c inv = [SELECT Id,Name, ERP7__Invoice_Amount__c, ERP7__Tax_Amount__c, ERP7__Sales_Invoice_Percentage__c, ERP7__Sales_Invoice_Tax_Percentage__c, ERP7__Shipping_Amount__c, ERP7__Shipping_Tax_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Down_Payment__c, ERP7__Total_Down_Payment_Amount__c, ERP7__Record_Type_Name__c, ERP7__Paid_Amount_Applied__c, ERP7__Order__c , ERP7__Order_S__c, ERP7__Account__r.Id, ERP7__Account__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name  FROM ERP7__Invoice__c WHERE Id =: Id];
        returnList.add(JSON.serialize(inv)); 
        system.debug('inv-->'+inv);
        invLine =  [SELECT Id,ERP7__Quantity__c,ERP7__Detailed_Description__c, Name,ERP7__Product__c,ERP7__Discount_Amount__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Invoice__c, ERP7__Total_Tax__c  FROM ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c =:Id];
        system.debug('invLine-->'+invLine.size());
        
        //returnList.add(JSON.serialize(invLine)); 
        List<ERP7__Credit_Note__c> credlist = new List<ERP7__Credit_Note__c>();
        credlist = [select Id, Name, ERP7__Invoice__c, ERP7__Credit__c from ERP7__Credit_Note__c where ERP7__Invoice__c=:Id];
        String crId='';
        if(credlist.size() > 0) crId=credlist[0].Id;
        Map<Id, Decimal> soliToInvoiceQtyMap = new Map<Id, Decimal>();
        
        if(credlist.size()>0){
            List<ERP7__Credit_Note_Item__c> CNLIs = [select Id, Name, Quantity__c,ERP7__Invoice_Line_Item__c from ERP7__Credit_Note_Item__c where ERP7__Credit_Note__c=:crId];
        for(ERP7__Credit_Note_Item__c cnli:CNLIs){
            if (!soliToInvoiceQtyMap.containsKey(cnli.ERP7__Invoice_Line_Item__c)) {
                soliToInvoiceQtyMap.put(cnli.ERP7__Invoice_Line_Item__c, 0);
            }
             soliToInvoiceQtyMap.put(cnli.ERP7__Invoice_Line_Item__c, soliToInvoiceQtyMap.get(cnli.ERP7__Invoice_Line_Item__c) + (cnli.ERP7__Quantity__c != null ? cnli.ERP7__Quantity__c : 0));
        }
            
            Decimal totalCredit = 0.00;
            for(ERP7__Credit_Note__c cred : credlist){
                if(cred.ERP7__Credit__c!=null) totalCredit = totalCredit + cred.ERP7__Credit__c;
            }
            if(inv!=null && inv.ERP7__Invoice_Amount__c!=null){
                if(totalCredit>=inv.ERP7__Invoice_Amount__c){
                    returnList.add(JSON.serialize(invLine)); 
                    returnList.add('True'); 
                }else{
                     for(ERP7__Invoice_Line_Item__c invli:invLine){
                         invli.ERP7__Quantity__c=invli.ERP7__Quantity__c-soliToInvoiceQtyMap.get(invli.Id);
                         if(invli.ERP7__Quantity__c > 0)newinvLine.add(invli);
                     }
                    returnList.add(JSON.serialize(newinvLine));
                    returnList.add('false'); 
                }
            }
            return returnList;
        }else{
          returnList.add(JSON.serialize(invLine));   
        }
        returnList.add('false');
        return returnList;
    }
    
   /* @AuraEnabled
    public static void handleAfterDelete(List<Id> invoiceLineIds) {
        List<ERP7__Invoice_Line_Item__c > invLis=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Order_Product__c,ERP7__Invoice__r.Name 
                                                  FROM ERP7__Invoice_Line_Item__c
                                                  WHERE ERP7__Invoice__c IN :invoiceLineIds];
        for(ERP7__Invoice_Line_Item__c inv:invLis){
            inv.name=inv.name+'-'+inv.ERP7__Invoice__r.Name;
            
        }
            update invLis;
         system.debug('after update handle deleting cred notes');
    }*/
    @AuraEnabled
    public static void handleAfterDelete(List<Id> invoiceIds) {
        // Step 1: Get relevant invoice line items and collect Order Product (SOLI) IDs
        List<ERP7__Invoice_Line_Item__c> invLis = [
            SELECT Id, ERP7__Quantity__c, ERP7__Order_Product__c
            FROM ERP7__Invoice_Line_Item__c
            WHERE ERP7__Invoice__c IN :invoiceIds
        ];
        
        Set<Id> soliIds = new Set<Id>();
        for (ERP7__Invoice_Line_Item__c inv : invLis) {
            if (inv.ERP7__Order_Product__c != null) {
                soliIds.add(inv.ERP7__Order_Product__c);
            }
        }
        
        if (soliIds.isEmpty()) return;
        
        // Step 2: Get all invoice line items for these SOLIs
        Map<Id, List<ERP7__Invoice_Line_Item__c>> soliToInvoiceLines = new Map<Id, List<ERP7__Invoice_Line_Item__c>>();
        Set<Id> allInvoiceLineItemIds = new Set<Id>();
        
        for (ERP7__Invoice_Line_Item__c ili : [
            SELECT Id, ERP7__Quantity__c, ERP7__Order_Product__c
            FROM ERP7__Invoice_Line_Item__c
            WHERE ERP7__Order_Product__c IN :soliIds and ERP7__Invoice__r.RecordType.Name='Sales'
        ]) {
            allInvoiceLineItemIds.add(ili.Id);
            
            if (!soliToInvoiceLines.containsKey(ili.ERP7__Order_Product__c)) {
                soliToInvoiceLines.put(ili.ERP7__Order_Product__c, new List<ERP7__Invoice_Line_Item__c>());
            }
            soliToInvoiceLines.get(ili.ERP7__Order_Product__c).add(ili);
        }
        
        // Step 3: Get Credit Note Items linked to those invoice lines
        Map<Id, Decimal> invLineToCreditQty = new Map<Id, Decimal>();
        for (Credit_Note_Item__c cni : [
            SELECT Invoice_Line_Item__c, Quantity__c
            FROM Credit_Note_Item__c
            WHERE Invoice_Line_Item__c IN :allInvoiceLineItemIds
        ]) {
            Id invLineId = cni.Invoice_Line_Item__c;
            Decimal qty = cni.Quantity__c != null ? cni.Quantity__c : 0;
            
            invLineToCreditQty.put(invLineId, 
                                   invLineToCreditQty.containsKey(invLineId) 
                                   ? invLineToCreditQty.get(invLineId) + qty 
                                   : qty
                                  );
        }
        
        // Step 4: Calculate final invoice quantity for each SOLI
        Map<Id, Decimal> soliToFinalQty = new Map<Id, Decimal>();
        for (Id soliId : soliToInvoiceLines.keySet()) {
            Decimal totalQty = 0;
            Decimal creditQty = 0;
            
            for (ERP7__Invoice_Line_Item__c ili : soliToInvoiceLines.get(soliId)) {
                totalQty += ili.ERP7__Quantity__c != null ? ili.ERP7__Quantity__c : 0;
                creditQty += invLineToCreditQty.containsKey(ili.Id) ? invLineToCreditQty.get(ili.Id) : 0;
            }
            
            soliToFinalQty.put(soliId, totalQty - creditQty);
        }
        
        // Step 5: Update SOLI (OrderItem) with final quantity
        List<OrderItem> updates = new List<OrderItem>();
        Map<Id, OrderItem> soliRecords = new Map<Id, OrderItem>(
            [SELECT Id, ERP7__Invoiced_Quantity__c FROM OrderItem WHERE Id IN :soliIds]
        );
        
        for (Id soliId : soliToFinalQty.keySet()) {
            if (!soliRecords.containsKey(soliId)) continue;
            
            OrderItem soli = soliRecords.get(soliId);
            soli.ERP7__Invoiced_Quantity__c = soliToFinalQty.get(soliId);
            updates.add(soli);
        }
        
        if (!updates.isEmpty()) {
            update updates;
            System.debug('✅ Updated OrderItem (SOLI) Invoiced Quantity');
        }
    }
    @AuraEnabled
    public static void handleOPAfterDelete(List<Id> orderIds) {
         
        // Step 2: Get all invoice line items for these SOLIs
        Map<Id, List<ERP7__Invoice_Line_Item__c>> soliToInvoiceLines = new Map<Id, List<ERP7__Invoice_Line_Item__c>>();
        Set<Id> allInvoiceLineItemIds = new Set<Id>();
        
        for (ERP7__Invoice_Line_Item__c ili : [
            SELECT Id, ERP7__Quantity__c, ERP7__Order_Product__c
            FROM ERP7__Invoice_Line_Item__c
            WHERE ERP7__Order_Product__c IN :orderIds and ERP7__Invoice__r.RecordType.Name='Sales'
        ]) {
            allInvoiceLineItemIds.add(ili.Id);
            
            if (!soliToInvoiceLines.containsKey(ili.ERP7__Order_Product__c)) {
                soliToInvoiceLines.put(ili.ERP7__Order_Product__c, new List<ERP7__Invoice_Line_Item__c>());
            }
            soliToInvoiceLines.get(ili.ERP7__Order_Product__c).add(ili);
        }
        // Step 3: Get Credit Note Items linked to those invoice lines
        Map<Id, Decimal> invLineToCreditQty = new Map<Id, Decimal>();
        for (Credit_Note_Item__c cni : [
            SELECT Invoice_Line_Item__c, Quantity__c
            FROM Credit_Note_Item__c
            WHERE Invoice_Line_Item__c IN :allInvoiceLineItemIds
        ]) {
            Id invLineId = cni.Invoice_Line_Item__c;
            Decimal qty = cni.Quantity__c != null ? cni.Quantity__c : 0;
            
            invLineToCreditQty.put(invLineId, 
                                   invLineToCreditQty.containsKey(invLineId) 
                                   ? invLineToCreditQty.get(invLineId) + qty 
                                   : qty
                                  );
        }
        
        // Step 4: Calculate final invoice quantity for each SOLI
        Map<Id, Decimal> soliToFinalQty = new Map<Id, Decimal>();
        for (Id soliId : soliToInvoiceLines.keySet()) {
            Decimal totalQty = 0;
            Decimal creditQty = 0;
            
            for (ERP7__Invoice_Line_Item__c ili : soliToInvoiceLines.get(soliId)) {
                totalQty += ili.ERP7__Quantity__c != null ? ili.ERP7__Quantity__c : 0;
                creditQty += invLineToCreditQty.containsKey(ili.Id) ? invLineToCreditQty.get(ili.Id) : 0;
            }
            
            soliToFinalQty.put(soliId, totalQty - creditQty);
        }
        
        // Step 5: Update SOLI (OrderItem) with final quantity
        List<OrderItem> updates = new List<OrderItem>();
        Map<Id, OrderItem> soliRecords = new Map<Id, OrderItem>(
            [SELECT Id, ERP7__Invoiced_Quantity__c FROM OrderItem WHERE Id IN :orderIds]
        );
        
        /*for (Id soliId : soliToFinalQty.keySet()) {
            if (!soliRecords.containsKey(soliId)) continue;
            
            OrderItem soli = soliRecords.get(soliId);
            soli.ERP7__Invoiced_Quantity__c = soliToFinalQty.get(soliId);
            updates.add(soli);
        }*/
        for (Id soliId : orderIds) {
            OrderItem soli = soliRecords.get(soliId);
            Decimal finalQty;
            
            if (soliToInvoiceLines.containsKey(soliId)) {
                // Calculate as usual
                Decimal totalQty = 0;
                Decimal creditQty = 0;
                
                for (ERP7__Invoice_Line_Item__c ili : soliToInvoiceLines.get(soliId)) {
                    totalQty += ili.ERP7__Quantity__c != null ? ili.ERP7__Quantity__c : 0;
                    creditQty += invLineToCreditQty.containsKey(ili.Id) ? invLineToCreditQty.get(ili.Id) : 0;
                }
                
                finalQty = totalQty - creditQty;
            } else {
                // No remaining line items → set to 0
                finalQty = 0;
            }
            
            soli.ERP7__Invoiced_Quantity__c = finalQty;
            updates.add(soli);
        }
        
        if (!updates.isEmpty()) {
            update updates;
            System.debug('✅ Updated OrderItem (SOLI) Invoiced Quantity');
        }
    }

    
    @future
    public static void updatePO(Set<Id> mulBillIds){
        try{
        Set<Id> mulPOIds = new Set<Id>();
        List<ERP7__Bill_Line_Item__c> billItems = new List<ERP7__Bill_Line_Item__c>();
        List<ERP7__PO__c> po2Upsert = new List<ERP7__PO__c>();
        billItems = [select Id, Name, ERP7__Purchase_Order__c, ERP7__Bill__c from ERP7__Bill_Line_Item__c where ERP7__Bill__c IN :mulBillIds];
        system.debug('billItems-->'+mulPOIds.size());
        if(billItems.size()>0){
            for(ERP7__Bill_Line_Item__c bItem : billItems){
                mulPOIds.add(bItem.ERP7__Purchase_Order__c);
            }
            system.debug('mulPOIds-->'+mulPOIds.size());
            if(mulPOIds.size()>0){
                for(ERP7__Bill__c bill : [select Id, Name, ERP7__Amount_Paid__c from ERP7__Bill__c where Id IN :mulBillIds]){
                    if(bill.ERP7__Amount_Paid__c != null && bill.ERP7__Amount_Paid__c >0){
                        Decimal billAmount = bill.ERP7__Amount_Paid__c;
                        system.debug('billAmount-->'+billAmount);
                        for(ERP7__PO__c po : [select Id, Name, ERP7__Amount_Paid__c, ERP7__Total_Due__c, ERP7__Total_Amount__c from ERP7__PO__c where Id IN :mulPOIds]){
                            system.debug('PO-->'+po);
                            if(billAmount>0){
                                //po.ERP7__Amount_Paid__c = 0;
                                po.ERP7__Amount_Paid__c = po.ERP7__Amount_Paid__c + po.ERP7__Total_Due__c;
                                system.debug('po1-->'+po.ERP7__Amount_Paid__c);
                                po2Upsert.add(po);
                            }
                            billAmount = billAmount - po.ERP7__Total_Due__c;
                        }
                    }
                }
            }
        }
        system.debug('po2Upsert--->'+po2Upsert.size());
        if(po2Upsert.size()>0){
            PreventRecursiveLedgerEntry.AwaitingStockPO = false;
            PreventRecursiveLedgerEntry.LogisticLineRollup = false;
            update po2Upsert;
        }
        }catch(Exception e){
            system.debug('Exception-->'+e.getLineNumber()+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> fetch_rmalis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__RMA_Line_Item__c> rmaLine=new List<ERP7__RMA_Line_Item__c>();
        ERP7__Return_Merchandise_Authorisation__c rma = [SELECT Id,Name, ERP7__Invoice__r.ERP7__Record_Type_Name__c, ERP7__Order__c , ERP7__Total_Refund_Amount__c, ERP7__Tax__c, ERP7__Account__r.Id, ERP7__Account__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Invoice__c,ERP7__Invoice__r.Name,ERP7__SO__c, ERP7__Restock_Fee__c, ERP7__ReStock_Tax__c, ERP7__Shipping_Amount__c, ERP7__Shipping_Tax__c,ERP7__Account__r.ERP7__Customer_Account__c,ERP7__Account__r.ERP7__Customer_Account__r.Name FROM ERP7__Return_Merchandise_Authorisation__c WHERE Id =: Id];
        returnList.add(JSON.serialize(rma)); 
        system.debug('rma-->'+rma);
        rmaLine =  [SELECT Id,ERP7__Quantity_Return__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Product__r.ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Sale_Price__c,ERP7__Total_Deduction__c, ERP7__Total_Tax__c, ERP7__Tax__c  FROM ERP7__RMA_Line_Item__c Where ERP7__Return_Merchandise_Authorisation__c =:Id];
        system.debug('rmaLine-->'+rmaLine.size());
        
        returnList.add(JSON.serialize(rmaLine)); 
        return returnList;
    }
    
     @AuraEnabled
    public static ERP7__Return_Merchandise_Authorisation__c fetch_rmalisLWC(String rmaId){
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c();
        if(String.isNotEmpty(rmaId)) rma = [SELECT Id,Name, ERP7__Order__c , ERP7__Account__r.Id, ERP7__Account__r.Name, ERP7__Organisation__c, ERP7__Invoice__c, ERP7__SO__c, ERP7__Restock_Fee__c, ERP7__ReStock_Tax__c, ERP7__Shipping_Amount__c, ERP7__Shipping_Tax__c,ERP7__Account__r.ERP7__Customer_Account__c,
                                            (SELECT Id,ERP7__Quantity_Return__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Product__r.ERP7__Description__c, ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Sale_Price__c,ERP7__Total_Deduction__c, ERP7__Total_Tax__c, ERP7__Tax__c
                                             FROM ERP7__RMA_Line_Items__r) FROM ERP7__Return_Merchandise_Authorisation__c WHERE Id =: rmaId];
        
        return rma;
    }
    
    @AuraEnabled
    public static List<String> fetch_credlis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Credit_Note_Item__c> credLine=new List<ERP7__Credit_Note_Item__c>();
        ERP7__Credit_Note__c credit = [SELECT Id,Name, ERP7__Account__c, ERP7__Active__c, ERP7__Amount__c, ERP7__Applied_Date__c, ERP7__Bill__c, ERP7__Contact__c, ERP7__Credit__c, ERP7__Date__c, ERP7__Debit__c, ERP7__Description__c, ERP7__Discount_Amount__c, ERP7__Fees__c, ERP7__Invoice__c, ERP7__Order__c, ERP7__Organisation__c, ERP7__Paid__c, ERP7__Paid_Date__c, ERP7__Payment__c, ERP7__Payment_Statements__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Purchase_Orders__c, ERP7__Reference_Number__c, ERP7__Restock_Tax__c, ERP7__Sales_Order__c, ERP7__Shipping_Amount__c, ERP7__Shipping_Tax__c, ERP7__Tax_Amount__c, ERP7__Tax_Receipt__c  FROM ERP7__Credit_Note__c WHERE Id =: Id];
        returnList.add(JSON.serialize(credit)); 
        system.debug('credit-->'+credit);
        credLine =  [SELECT Id, Name, ERP7__Account__c, ERP7__Credit_Note__c, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Description__c, ERP7__Discount__c, ERP7__Invoice_Line_Item__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Other_Tax_Rate__c, ERP7__Posted__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__RMA_Line_Item__c, ERP7__Sales_Order_Line_Item__c, ERP7__Tax_Amount__c, ERP7__Tax_Rate__c, ERP7__Total_Amount__c FROM ERP7__Credit_Note_Item__c Where ERP7__Credit_Note__c =:Id];
        system.debug('credLine-->'+credLine.size());
        
        returnList.add(JSON.serialize(credLine)); 
        return returnList;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveCreditNote(String creditNote, String credItems){
        Map<String,Object> returnval = new Map<String,Object>();
        try{
            List<String> returnList = new List<String>();
            ERP7__Credit_Note__c billObj = (ERP7__Credit_Note__c)JSON.deserialize(creditNote, ERP7__Credit_Note__c.class);
            if(billObj.ERP7__Discount_Amount__c!=null) billObj.ERP7__Amount__c = billObj.ERP7__Amount__c - billObj.ERP7__Discount_Amount__c;
            if(billObj.ERP7__Fees__c != null) billObj.ERP7__Amount__c = billObj.ERP7__Amount__c + billObj.ERP7__Fees__c;
            if(billObj.ERP7__Shipping_Amount__c != null) billObj.ERP7__Amount__c = billObj.ERP7__Amount__c + billObj.ERP7__Shipping_Amount__c;
            if(billObj.ERP7__Restock_Tax__c != null && billObj.ERP7__Tax_Amount__c != null) billObj.ERP7__Tax_Amount__c = billObj.ERP7__Tax_Amount__c + billObj.ERP7__Restock_Tax__c;
            if(billObj.ERP7__Shipping_Tax__c != null && billObj.ERP7__Tax_Amount__c != null) billObj.ERP7__Tax_Amount__c = billObj.ERP7__Tax_Amount__c + billObj.ERP7__Shipping_Tax__c;
            if(billObj.ERP7__Tax_Amount__c != null) billObj.ERP7__Credit__c = billObj.ERP7__Amount__c + billObj.ERP7__Tax_Amount__c;
            else billObj.ERP7__Credit__c = billObj.ERP7__Amount__c;            
            if(billObj.ERP7__Advance_Amount_Applied__c != null) billObj.ERP7__Credit__c = billObj.ERP7__Credit__c - billObj.ERP7__Advance_Amount_Applied__c;
            if(billObj.ERP7__Additional_Cost__c != null) billObj.ERP7__Credit__c = billObj.ERP7__Credit__c + billObj.ERP7__Additional_Cost__c;
            if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.isUpdateable()) { upsert billObj; } else { }
            ERP7__Credit_Note__c bb=[select id,Name from ERP7__Credit_Note__c where Id=:billObj.Id];
            //Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
            List<ERP7__Credit_Note_Item__c> billItemsList = (List<ERP7__Credit_Note_Item__c>)JSON.deserialize(credItems, List<ERP7__Credit_Note_Item__c>.class);
            System.debug('billItemsList'+billItemsList);
            for(Integer i=0;i<billItemsList.size();i++){
                System.debug('billItemsList[i].ERP7__Invoice_Line_Item__c'+billItemsList[i].ERP7__Invoice_Line_Item__c);
                if(billItemsList[i].ERP7__Credit_Note__c == null) billItemsList[i].ERP7__Credit_Note__c  = billObj.id; 
            }
            if(billItemsList.size()>0) {
                if(Schema.sObjectType.ERP7__Credit_Note_Item__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note_Item__c.isUpdateable()){upsert billItemsList; } else { }
            }
            returnList.add(JSON.serialize(billObj)); returnList.add(JSON.serialize(billItemsList)); //return billObj;
            returnval.put('bill',billObj);
            returnval.put('bill2',bb);
            
            
        }catch(Exception e){   
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return returnval;
    }
    
    
    @AuraEnabled
    public static List<String> fetch_deblis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Debit_Note_Item__c> dbLine=new List<ERP7__Debit_Note_Item__c>();
        ERP7__Debit_Note__c debitNote = [select Id, Name, ERP7__Account__c, ERP7__Active__c, ERP7__Amount__c, ERP7__Applied_Date__c, ERP7__Credit__c, ERP7__Credit_Account__c, ERP7__Credit_Note__c, ERP7__Credit_Note_Date__c, ERP7__Credit_Note_Number__c, ERP7__Debit__c, ERP7__Debit_Account__c, ERP7__Description__c, ERP7__Invoice__c, ERP7__Organisation__c, ERP7__Paid_Date__c, ERP7__Posted__c, ERP7__Posting_Date_Time__c, ERP7__Purchase_Orders__c, ERP7__Tax_Amount__c,ERP7__Tax_Receipt__c, ERP7__Type__c, ERP7__Vendor_Invoice_Bill__c   from ERP7__Debit_Note__c where Id =:Id];
        returnList.add(JSON.serialize(debitNote)); 
        system.debug('debitNote-->'+debitNote);
        dbLine =  [Select Id, Name, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Debit_Note__c, ERP7__Description__c, ERP7__Discount__c, ERP7__Item_Description__c, ERP7__Item_Type__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Other_Tax_Rate__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Product__c, ERP7__Purchase_Line_Items__c, ERP7__Purchase_Order__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Tax_Amount__c, ERP7__Tax_Rate__c, ERP7__TDS_Account__c, ERP7__TDS_Amount__c, ERP7__TDS_Rate__c, ERP7__Total_Amount__c, ERP7__Vendor__c, ERP7__Bill__c from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c=:Id];
        system.debug('dbLine-->'+dbLine.size());
        Set<Id> dlineIds = new Set<Id>();
        if(dbLine.size()>0){
            for(ERP7__Debit_Note_Item__c dline : dbLine)
            dlineIds.add(dline.Id);
        }
        List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
        demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c, ERP7__Debit_Note_Item__c from ERP7__Dimension__c where ERP7__Debit_Note_Item__c IN :dlineIds AND ERP7__Debit_Note_Item__c != null];
        //List<ERP7__Debit_Note_Item__c> poli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_of_Account__c from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c=:DId];
        returnList.add(JSON.serialize(dbLine)); 
        if(demList!=null && demList.size()>0){
            returnList.add(JSON.serialize(demList)); 
        }
        return returnList;
    }
    
    /*public class debitWrap{
        @AuraEnabled public ERP7__Debit_Note__c DebitNote {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note_Item__c> DBLine {get;set;}
        public debitWrap(){
            DebitNote  = new ERP7__Debit_Note__c();
            DBLine = new List<ERP7__Debit_Note_Item__c>();
        }
    }*/
    
    
    @AuraEnabled 
    public static Boolean getFunctionalityControlOrderProcess(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            return customList.ERP7__Standard_Order_Process__c;
        }
        return false;
    }
    
    @AuraEnabled 
    public static Boolean displayNameonDebitNote(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            return customList.ERP7__POLI_Name__c;
        }
        return false;
    }
    
    public class fcwrapper{
        @AuraEnabled public Boolean projectAccess {get;set;}
        @AuraEnabled public Boolean departmentAccess {get;set;}
        @AuraEnabled public Boolean allocationAccess {get;set;}
        public fcwrapper(){
            projectAccess = departmentAccess = allocationAccess = false;
        }
    }
    
    @AuraEnabled 
    public static fcwrapper getFunctionalityControlAllocation(){
        fcwrapper fcwrap = new fcwrapper();
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            fcwrap.allocationAccess = customList.ERP7__Allocation_Process__c;
            fcwrap.departmentAccess = customList.ERP7__Budget_Department_Allocation__c;
            fcwrap.projectAccess = customList.ERP7__Project_on_PO_Screen__c;
        }
        return fcwrap;
    }
    
    
    
    @AuraEnabled
    public static String uploadFileLWC(String fileName, String base64Data, String recordId) {
        // Decoding the base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = recordId;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        system.debug('cv--->'+cv);
        Insert cv;
        return 'File upload successfully!';
    }
    
    @AuraEnabled
    public static void createDimensionsList(String AA, String DId){
        try{
            system.debug('AA-->'+AA);
            system.debug('PId-->'+DId);
            String demstring = AA.replace('[[', '[');
            demstring = demstring.replace(']]', ']');
            demstring = demstring.replace('],[', ',');
            system.debug('demstring-->'+demstring);
            List<ERP7__Dimension__c> demList1 = (List<ERP7__Dimension__c>) JSON.deserialize(demstring, List<ERP7__Dimension__c>.class);
            system.debug('demList-->'+demList1);
            List<ERP7__Debit_Note_Item__c> poli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_of_Account__c, ERP7__Bill_Line_Item__c, ERP7__Bill_Line_Item__r.ERP7__Sort_Order__c from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c=:DId];
            Map<Integer, ERP7__Debit_Note_Item__c > poliMap = new Map<Integer, ERP7__Debit_Note_Item__c >();
            Map<Integer, ERP7__Debit_Note_Item__c > dbItemMap = new Map<Integer, ERP7__Debit_Note_Item__c >();
            for(ERP7__Debit_Note_Item__c pol : poli){
                if(pol.ERP7__Bill_Line_Item__c!=null) poliMap.put(Integer.valueOf(pol.ERP7__Bill_Line_Item__r.ERP7__Sort_Order__c), pol);
                //else poliMap.put(Integer.valueOf(pol.ERP7__Bill_Line_Item__r.ERP7__Sort_Order__c), pol);
                if(pol.ERP7__Sort_Order__c!=null) dbItemMap.put(Integer.valueOf(pol.ERP7__Sort_Order__c), pol);
            }
            system.debug('poliMap-->'+poliMap);
            if(demList1.size()>0){
                system.debug('demList1');
                for(ERP7__Dimension__c dem1 : demList1){
                    system.debug('Sort Order-->'+dem1.ERP7__Sort_Order__c);
                    if(dem1.ERP7__Sort_Order__c != null){
                        if(poliMap!=null && !poliMap.isEmpty()){
                            if(poliMap.containsKey(Integer.valueOf(dem1.ERP7__Sort_Order__c))){
                                dem1.ERP7__Debit_Note_Item__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Id;
                                dem1.Name = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Name;
                                dem1.ERP7__Active__c = true;
                                if(poli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = poli[0].ERP7__Organisation__c;
                                if(poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c;
                                if(poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c != null) dem1.ERP7__Chart_of_Account__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c;
                            }
                        }else{
                            if(dbItemMap.containsKey(Integer.valueOf(dem1.ERP7__Sort_Order__c))){
                                dem1.ERP7__Debit_Note_Item__c = dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Id;
                                dem1.Name = dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Name;
                                dem1.ERP7__Active__c = true;
                                if(poli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = poli[0].ERP7__Organisation__c;
                                if(dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c;
                                if(dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c != null) dem1.ERP7__Chart_of_Account__c = dbItemMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c;
                            }
                        }
                    }
                }
                system.debug('demList1-->'+demList1);
                upsert demList1;
            }
        }catch(Exception e){ system.debug('Exception~>'+e.getStackTraceString()); }
    }
    
    public class ProjectBudget{
        @AuraEnabled public Decimal projBudget                                  {get; set;}
        @AuraEnabled public Decimal projCommittedBudget                                   {get; set;}
        @AuraEnabled public Decimal projConsumedBudget                                   {get; set;}
        @AuraEnabled public Decimal projRemainingBudget                          {get; set;}
        @AuraEnabled public String budget                                  {get; set;}
        public ProjectBudget(){
            projBudget = 0.0;projCommittedBudget = 0.0; projConsumedBudget = projRemainingBudget = 0.0;
            budget = '';
        }
        
    }
    
    @AuraEnabled
    Public Static ProjectBudget getProjectBudget(String CoaId,String Project){
        ProjectBudget pwrap = new ProjectBudget();
        List< ERP7__Budget_Account__c > bacList = new List< ERP7__Budget_Account__c >();
        bacList = [select Id, Name, ERP7__Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Remaining_Amount__c  from ERP7__Budget_Account__c where ERP7__Project__c =:Project and ERP7__Chart_of_Account__c =:CoaId and ERP7__Budget_Plan__r.ERP7__Approved__c=true limit 1];
        if(bacList.size()>0){
            for(ERP7__Budget_Account__c bac : bacList){
                pwrap.projBudget = bac.ERP7__Amount__c;
                pwrap.projConsumedBudget = bac.ERP7__Consumed_Amount__c;
                pwrap.projCommittedBudget = bac.ERP7__Committed_Amount__c;
                pwrap.projRemainingBudget = bac.ERP7__Remaining_Amount__c;
                pwrap.budget = bac.Id;
            }
        }
        return pwrap;
    }
    
}