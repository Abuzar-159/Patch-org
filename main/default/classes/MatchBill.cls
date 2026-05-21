public with sharing class MatchBill {
    Public PO__c po { get; set; }  public MatchBill() { po = new Po__c(); }
    
    @AuraEnabled
    public static List<sobject > getStockInWardLineItems(String BillItem){
        ERP7__Bill_Line_Item__c  ItemList = (ERP7__Bill_Line_Item__c) JSON.deserialize(BillItem, ERP7__Bill_Line_Item__c.class);
        if(ItemList.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){            
            List<ERP7__Stock_Inward_Line_Item__c> SI= [SELECT Id,Name,ERP7__Remaining_Match_Quantity__c,ERP7__Purchase_Line_Items__c,ERP7__Reconciled_Quantity__c ,ERP7__Purchase_Line_Items__r.Name,ERP7__Quantity__c ,ERP7__Unit_Price__c,ERP7__Product__c , ERP7__Product__r.Name, ERP7__Serial__c, ERP7__Serial_Number__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Status__c,ERP7__Inventory_Reconciliation__c  FROM ERP7__Stock_Inward_Line_Item__c Where ERP7__Purchase_Line_Items__c =:ItemList.ERP7__Purchase_Order_Line_Items__c AND ERP7__Product__c = :ItemList.ERP7__Product__c AND ERP7__Status__c!='Awaiting Stock' and ERP7__Remaining_Match_Quantity__c>0];
            
            return [SELECT Id,Name,ERP7__Purchase_Line_Items__c,ERP7__Remaining_Match_Quantity__c,ERP7__Reconciled_Quantity__c ,ERP7__Purchase_Line_Items__r.Name,ERP7__Quantity__c ,ERP7__Unit_Price__c,ERP7__Product__c , ERP7__Product__r.Name, ERP7__Serial__c, ERP7__Serial_Number__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Status__c,ERP7__Inventory_Reconciliation__c  FROM ERP7__Stock_Inward_Line_Item__c Where ERP7__Purchase_Line_Items__c =:ItemList.ERP7__Purchase_Order_Line_Items__c AND ERP7__Product__c = :ItemList.ERP7__Product__c  AND ERP7__Status__c!='Awaiting Stock' and ERP7__Remaining_Match_Quantity__c>0];//AND  (ERP7__Quantity__c <= :ItemList.ERP7__Quantity__c OR ERP7__Unit_Price__c <= :ItemList.ERP7__Amount__c)
        }else {
            return [SELECT Id,Name,ERP7__Reconciled_Quantity__c, ERP7__Quantity__c ,ERP7__Unit_Price__c,ERP7__Product__c , ERP7__Product__r.Name  FROM ERP7__Work_Order_Line_Items__c Where  ERP7__Product__c = :ItemList.ERP7__Product__c AND ERP7__Unit_Price__c != null AND ERP7__Work_Orders__r.ERP7__Purchase_Orders__c =:ItemList.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c];
        }  
        //return null;
    }
    @AuraEnabled
    public static Boolean createIR_SR(String IRList,String SRList){
        try{
            List<ERP7__Inventory_Reconcilation__c> InventoryList = (List<ERP7__Inventory_Reconcilation__c>)JSON.deserialize(IRList, List<ERP7__Inventory_Reconcilation__c>.class);
            List<ERP7__Service_Recociliation__c> serviceList = (List<ERP7__Service_Recociliation__c>)JSON.deserialize(SRList, List<ERP7__Service_Recociliation__c>.class);
            if(InventoryList != null && InventoryList.size()>0 && Schema.SObjectType.ERP7__Inventory_Reconcilation__c.isCreateable() && Schema.SObjectType.ERP7__Inventory_Reconcilation__c.isUpdateable()){ upsert InventoryList;}
            if(serviceList != null && serviceList.size()>0 && Schema.SObjectType.ERP7__Service_Recociliation__c.isCreateable() && Schema.SObjectType.ERP7__Service_Recociliation__c.isUpdateable()){ upsert serviceList; }
            return true;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
    }
        
    @AuraEnabled 
    public static Map<Id,List<ERP7__Bill_Line_Item__c>> getBillItems(String BillId){
        Map<Id,List<ERP7__Bill_Line_Item__c>> BillItemMap = new  Map<Id,List<ERP7__Bill_Line_Item__c>>();
        String[] ids = BillId.split(','); 
        List<ERP7__Bill_Line_Item__c> test = [SELECT Id,Name,ERP7__Bill__c, ERP7__Bill__r.Name,ERP7__Service_Reconciled_Quantity__c,ERP7__Reconciled_Quantity__c, ERP7__Quantity__c, ERP7__Product__c , ERP7__Product__r.Name,ERP7__Total_Amount__c, ERP7__Product__r.ERP7__Item_Type__c ,ERP7__Amount__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Match_Type__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Debit_Line_Item_Unit_Price__c   FROM ERP7__Bill_Line_Item__c  WHERE ERP7__Bill__c IN:ids AND ERP7__Purchase_Order_Line_Items__c != null];
        for(ERP7__Bill_Line_Item__c item:[SELECT Id,Name,ERP7__Bill__c, ERP7__Bill__r.Name,ERP7__Service_Reconciled_Quantity__c,ERP7__Reconciled_Quantity__c, ERP7__Quantity__c, ERP7__Product__c , ERP7__Product__r.Name,ERP7__Total_Amount__c, ERP7__Product__r.ERP7__Item_Type__c ,ERP7__Amount__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Match_Type__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Debit_Line_Item_Unit_Price__c   FROM ERP7__Bill_Line_Item__c  WHERE ERP7__Bill__c IN:ids AND ERP7__Purchase_Order_Line_Items__c != null AND ERP7__Purchase_Order_Line_Items__r.ERP7__Match_Type__c = 'Three-Way']){
             if(item.ERP7__Product__r.ERP7__Item_Type__c !='Service')
                 item.ERP7__Quantity__c = (item.ERP7__Quantity__c > item.ERP7__Reconciled_Quantity__c)? item.ERP7__Quantity__c - item.ERP7__Reconciled_Quantity__c: 0.00 ;
             else item.ERP7__Quantity__c = (item.ERP7__Quantity__c > item.ERP7__Service_Reconciled_Quantity__c)? item.ERP7__Quantity__c - item.ERP7__Service_Reconciled_Quantity__c: 0.00 ; 
            if(item.ERP7__Quantity__c >0){
                 List<ERP7__Bill_Line_Item__c> tempList = (BillItemMap.get(item.ERP7__Bill__c) != null)? BillItemMap.get(item.ERP7__Bill__c): new List<ERP7__Bill_Line_Item__c>(); 
                 tempList.add(item);
                 BillItemMap.put(item.ERP7__Bill__c,tempList);
             }    
         }   
        return BillItemMap;
    } 
    
    
    
     @AuraEnabled
    public static Boolean processAutoMatch(String IRList){
        try{
            List< ERP7__Inventory_Reconcilation__c > InventoryList = new List< ERP7__Inventory_Reconcilation__c >();
            List<InventoryReconWrapper> InventorywrapList = (List<InventoryReconWrapper>)JSON.deserialize(IRList, List<InventoryReconWrapper>.class);
            if(InventorywrapList!=null && InventorywrapList.size()>0){
                for(InventoryReconWrapper irwrap : InventorywrapList){
                    InventoryList.add(irwrap.inventoryRecon);
                }
            }
            if(InventoryList != null && InventoryList.size()>0 && Schema.SObjectType.ERP7__Inventory_Reconcilation__c.isCreateable() && Schema.SObjectType.ERP7__Inventory_Reconcilation__c.isUpdateable()){ upsert InventoryList;}
            //if(serviceList != null && serviceList.size()>0 && Schema.SObjectType.ERP7__Service_Recociliation__c.isCreateable() && Schema.SObjectType.ERP7__Service_Recociliation__c.isUpdateable()){ upsert serviceList; }
            return true;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled 
    public static List<InventoryReconWrapper > getAutoMatchItems(String BillId){
        List< InventoryReconWrapper > invReconList = new List< InventoryReconWrapper >();
        Map<Id,List<ERP7__Bill_Line_Item__c>> BillItemMap = new  Map<Id,List<ERP7__Bill_Line_Item__c>>();
        String[] ids = BillId.split(','); 
        Set<Id> poliitemIds = new Set<Id>();
        List<ERP7__Bill_Line_Item__c> billItemList = new List<ERP7__Bill_Line_Item__c>();
        billItemList = [SELECT Id,Name,ERP7__Bill__c, ERP7__Bill__r.Name,ERP7__Service_Reconciled_Quantity__c,ERP7__Reconciled_Quantity__c, ERP7__Quantity__c, ERP7__Product__c , ERP7__Product__r.Name,ERP7__Total_Amount__c, ERP7__Product__r.ERP7__Item_Type__c ,ERP7__Amount__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Match_Type__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Debit_Line_Item_Unit_Price__c   FROM ERP7__Bill_Line_Item__c  WHERE ERP7__Bill__c IN:ids AND ERP7__Purchase_Order_Line_Items__c != null];
        if(billItemList!=null && billItemList.size()>0){
            for(ERP7__Bill_Line_Item__c billitem : billItemList){
                poliitemIds.add(billitem.ERP7__Purchase_Order_Line_Items__c);
            }
        }
        if(poliitemIds!=null && poliitemIds.size()>0){
            List<ERP7__Stock_Inward_Line_Item__c> solis= new List<ERP7__Stock_Inward_Line_Item__c>();
            Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> poStockInMap = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
            solis = [SELECT Id,Name,ERP7__Remaining_Match_Quantity__c,ERP7__Purchase_Line_Items__c,ERP7__Reconciled_Quantity__c ,ERP7__Purchase_Line_Items__r.Name,ERP7__Quantity__c ,ERP7__Unit_Price__c,ERP7__Product__c , ERP7__Product__r.Name, ERP7__Serial__c, ERP7__Serial_Number__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Status__c,ERP7__Inventory_Reconciliation__c  FROM ERP7__Stock_Inward_Line_Item__c Where ERP7__Purchase_Line_Items__c IN :poliitemIds AND ERP7__Status__c!='Awaiting Stock' and ERP7__Remaining_Match_Quantity__c>0];
            if(solis!=null && solis.size()>0){                for(ERP7__Stock_Inward_Line_Item__c siward : solis){                    if(poStockInMap.containskey(siward.ERP7__Purchase_Line_Items__c)){                        poStockInMap.get(siward.ERP7__Purchase_Line_Items__c).add(siward);                    }else{                        List<ERP7__Stock_Inward_Line_Item__c> newsolis = new List<ERP7__Stock_Inward_Line_Item__c>();                        newsolis.add(siward);                        poStockInMap.put(siward.ERP7__Purchase_Line_Items__c, newsolis);                    }                }            }    
            if(!poStockInMap.isEmpty() && poStockInMap.size()>0){                for(ERP7__Bill_Line_Item__c billitem : billItemList){                    if(poStockInMap.containskey(billitem.ERP7__Purchase_Order_Line_Items__c)){                        billitem.ERP7__Quantity__c = (billitem.ERP7__Quantity__c > billitem.ERP7__Reconciled_Quantity__c)? billitem.ERP7__Quantity__c - billitem.ERP7__Reconciled_Quantity__c: 0.00 ;                        if(billitem.ERP7__Quantity__c>0){                            decimal sumqty = 0;                            for(ERP7__Stock_Inward_Line_Item__c sinward : poStockInMap.get(billitem.ERP7__Purchase_Order_Line_Items__c)){                                sumqty = sumqty + sinward.ERP7__Remaining_Match_Quantity__c;                            }                            if(sumqty == billitem.ERP7__Quantity__c){                                for(ERP7__Stock_Inward_Line_Item__c sinward : poStockInMap.get(billitem.ERP7__Purchase_Order_Line_Items__c)){                                    InventoryReconWrapper irwarp = new InventoryReconWrapper();                                    ERP7__Inventory_Reconcilation__c ivr = new ERP7__Inventory_Reconcilation__c();                                    ivr.ERP7__Purchase_Orders__c = billitem.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c;                                    ivr.ERP7__Price__c = sinward.ERP7__Unit_Price__c;                                    ivr.ERP7__Bill_Line_Item__c = billitem.Id;                                    ivr.ERP7__Product__c = billitem.ERP7__Product__c;                                    ivr.ERP7__Stock_Inward_Line_Item__c = sinward.Id;                                    ivr.ERP7__Quantity__c = sinward.ERP7__Remaining_Match_Quantity__c;                                    ivr.Name = billitem.Name;                                    irwarp.inventoryRecon = ivr;                                    irwarp.productName = billitem.ERP7__Product__r.Name;                                    irwarp.soliName = sinward.Name;                                    irwarp.billName = billitem.Name;                                    invReconList.add(irwarp);                                }                            }                        }                    }                }            }  
        }  
        return invReconList;
    } 
    
    public class InventoryReconWrapper {
        @AuraEnabled public ERP7__Inventory_Reconcilation__c inventoryRecon { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String soliName { get; set; }
        @AuraEnabled public String billName { get; set; }
        @AuraEnabled public String poName { get; set; }
        public InventoryReconWrapper(){
            inventoryRecon = new ERP7__Inventory_Reconcilation__c();
            productName = soliName = billName = poName = '';
        }
    }
    
    @AuraEnabled
    public static List<ERP7__Bill__c> fetchBills(Integer OFF_SET,string qryFilter, String OrderBy, String Order){
        OFF_SET = Integer.valueof(OFF_SET);   
        system.debug('qryFilter : '+qryFilter);
        List<ERP7__Bill__c> billList = new List<ERP7__Bill__c> ();
        if(String.isEmpty(qryFilter)){
         //billList = [SELECT Id,Name,ERP7__Matched__c,ERP7__Posted__c ,Status__c,ERP7__Purchase_Order__r.Name,ERP7__Purchase_Order__c,ERP7__Vendor__r.Name,ERP7__Vendor__c,ERP7__Due_Date__c,ERP7__Total_Amount__c,ERP7__Approved__c FROM ERP7__Bill__c order by ERP7__Due_Date__c asc NULLS LAST limit 50 Offset :OFF_SET ]; //+' Order By '+OrderBy+' '+ Order
         String billListQuery='SELECT Id, Name, ERP7__Amount__c  , ERP7__Due_Date_Days__c, ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName  FROM ERP7__Bill__c   '+' Order By '+ String.escapeSingleQuotes(OrderBy)+' '+ String.escapeSingleQuotes(Order)+ ' NULLS LAST limit 50 Offset :OFF_SET'; 
         billList = Database.query(billListQuery);
        }    
        else{
           // system.debug('String.escapeSingleQuotes(qryFilter) : '+String.escapeSingleQuotes(qryFilter));
        //billList = Database.query('SELECT Id,Status__c,ERP7__Posted__c,Name,ERP7__Matched__c ,ERP7__Purchase_Order__r.Name,ERP7__Purchase_Order__c,ERP7__Vendor__r.Name,ERP7__Vendor__c,ERP7__Due_Date__c,ERP7__Total_Amount__c,ERP7__Approved__c FROM ERP7__Bill__c WHERE Name != NULL '+String.escapeSingleQuotes(qryFilter)+' order by ERP7__Due_Date__c asc NULLS LAST limit 50 Offset '+OFF_SET);           
        billList = Database.query('SELECT Id, Name, ERP7__Amount__c  , ERP7__Due_Date_Days__c, ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName  FROM ERP7__Bill__c WHERE Name  != Null  '+qryFilter+' Order By '+String.escapeSingleQuotes(OrderBy)+' '+ String.escapeSingleQuotes(Order)+'  NULLS LAST limit 50 Offset '+OFF_SET);    
        }
        
        Map<Id,ERP7__Bill__c> BillMap = new Map<Id,ERP7__Bill__c>(billList);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Bill__c, ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Bill__c IN: BillMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])            BillMap.remove(trans.ERP7__Bill__c); 
        return BillMap.values();
        //return billList;
    }
    @AuraEnabled
    public static List<ERP7__Bill__c> MatchBills(){
        Map<Id,ERP7__Bill__c> billMap = new Map<Id,ERP7__Bill__c>([SELECT Id,Name,ERP7__Matched__c ,ERP7__Purchase_Order__r.Name,ERP7__Purchase_Order__c,ERP7__Vendor__r.Name,ERP7__Vendor__c,ERP7__Due_Date__c,ERP7__Total_Amount__c,ERP7__Approved__c,ERP7__Posted__c FROM ERP7__Bill__c WHERE ERP7__Matched__c=false AND ERP7__Amount_Due__c > 0.00 ]);
        return billMap.values();
    }
    @AuraEnabled 
    public static void updateBillById(String recordId,Boolean fieldValue){
        if(String.isNotEmpty(recordId)){
            ERP7__Bill__c bill = new ERP7__Bill__c(Id = recordId);   if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posted__c.isUpdateable()){bill.ERP7__Posted__c = fieldValue;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Bill__c.fields.Id.isCreateable() && Schema.sObjectType.ERP7__Bill__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.isUpdateable()){ upsert bill;}else{/*not allowed to upsert*/ }
        }
        
    }
     @AuraEnabled
    public static void update_Bill(String obj){
        ERP7__Bill__c Bill = (ERP7__Bill__c) JSON.deserialize(obj, ERP7__Bill__c.class);
         
        if(Schema.SObjectType.ERP7__Bill__c.isCreateable() && Schema.SObjectType.ERP7__Bill__c.isUpdateable()) upsert Bill; else{/*not allowed to upsert*/}
    }
    
    @AuraEnabled    public static void update_Bill_to_Match(String BillId){        String[] ids = BillId.split(',');         List<ERP7__Bill__c> billList = new List<ERP7__Bill__c>();        billList = [select Id, Name, ERP7__Matched__c, ERP7__Approved__c, ERP7__Posted__c from ERP7__Bill__c where Id IN :ids];        if(billList.size()>0){            for(ERP7__Bill__c bb : billList){                if(!bb.ERP7__Matched__c){                    bb.ERP7__Matched__c = true;                              }            }            update billList;        }    }    
    
    @AuraEnabled
    public static void save_Bill(String record){
        ERP7__Bill__c Bill = (ERP7__Bill__c) JSON.deserialize(record, ERP7__Bill__c.class);
        if(Schema.SObjectType.ERP7__Bill__c.isCreateable() && Schema.SObjectType.ERP7__Bill__c.isUpdateable()) upsert Bill; else{/*not allowed to upsert*/}
    }
    
    @AuraEnabled
    public static ERP7__Bill__c saveVoucher(String voucherRecord){
        ERP7__Voucher__c voucher = (ERP7__Voucher__c) JSON.deserialize(voucherRecord, ERP7__Voucher__c.class);
        if(Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Date__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Date__c.isUpdateable()){voucher.ERP7__Date__c = system.today();}else{/*No access*/}
        if(Schema.SObjectType.ERP7__Voucher__c.isCreateable() && Schema.SObjectType.ERP7__Voucher__c.isUpdateable()){ upsert voucher;}else{/*not allowed to upsert*/}
        ERP7__Bill__c Bill = [SELECT Id, Name, ERP7__Amount__c  , ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName  FROM ERP7__Bill__c WHERE Id = :voucher.ERP7__Vendor_invoice_Bill__c];
                            //SELECT Id, Name, ERP7__Amount__c  , ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName
        return Bill;
        
    }
    
    @AuraEnabled
    public static VoucherWrap checkVoucherApex(String record){
        VoucherWrap vw = new VoucherWrap();
        ERP7__Bill__c Bill = (ERP7__Bill__c) JSON.deserialize(record, ERP7__Bill__c.class);
        Decimal amount = 0;
        Map < Id, ERP7__Voucher__c > Existing_voucher_Map = new Map < Id, ERP7__Voucher__c > ();
        List<ERP7__Voucher__c> vouchers=new List<ERP7__Voucher__c>();
        vouchers=[select Id, Name,ERP7__Vendor_invoice_Bill__c, ERP7__Vendor_invoice_Bill__r.ERP7__Vendor_Bill_Number__c, ERP7__Amount__c,CreatedDate, ERP7__Date__c from ERP7__Voucher__c where ERP7__Vendor_invoice_Bill__c=:Bill.Id];//Moin added this 30th november ERP7__Vendor_invoice_Bill__r.ERP7__Vendor_Bill_Number__c, 
        if(vouchers.size()>0) {
            for (ERP7__Voucher__c vou : vouchers){
                amount = amount + vou.ERP7__Amount__c;
            }
            if(Bill.ERP7__Total_Amount__c>amount){  vw.isValid = true;   vw.Amount = Bill.ERP7__Total_Amount__c - amount;  vw.vouchers = vouchers;  return vw;
            } 
            else {
               vw.isValid = false;
               return vw;
            }
            
        }
        if(Bill!=null && Bill.Id!=null){            ERP7__Bill__c bi = [select Id, Name, ERP7__Vendor_Bill_Number__c from ERP7__Bill__c where Id=:Bill.Id];            vw.vendorBillNumber = bi.ERP7__Vendor_Bill_Number__c;        }        vw.Amount = Bill.ERP7__Total_Amount__c;           vw.isValid = true; return vw;        
        
    }
    
    public class VoucherWrap{
        @AuraEnabled public Boolean isValid {get;set;}
        @AuraEnabled public Decimal Amount {get;set;}
        @AuraEnabled public String vendorBillNumber {get;set;}
        @AuraEnabled public List<ERP7__Voucher__c> vouchers {get;set;}
        public VoucherWrap(){
            isValid = false;
            Amount = 0.0;
            vendorBillNumber = '';
            vouchers = new List<ERP7__Voucher__c>();
        }
        
    }
    @AuraEnabled
    public static Boolean checkBillDetails(String BillId){
        try{
        Set<Id> poliIds = new Set<Id>();
        ERP7__Bill__c bill = [select id, name, ERP7__Purchase_Order__r.Id from ERP7__Bill__c where Id=:BillId];
        List<ERP7__Bill_Line_Item__c> test = new List<ERP7__Bill_Line_Item__c>();
        test = [SELECT Id,Name,ERP7__Bill__c, ERP7__Bill__r.Name,ERP7__Service_Reconciled_Quantity__c,ERP7__Reconciled_Quantity__c, ERP7__Quantity__c, ERP7__Product__c , ERP7__Product__r.Name,ERP7__Total_Amount__c, ERP7__Product__r.ERP7__Item_Type__c ,ERP7__Amount__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Match_Type__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Debit_Line_Item_Unit_Price__c   FROM ERP7__Bill_Line_Item__c  WHERE ERP7__Bill__c =:BillId AND ERP7__Purchase_Order_Line_Items__c != null];
        if(test.size()>0){
            for(ERP7__Bill_Line_Item__c billItem : test){
                poliIds.add(billItem.ERP7__Purchase_Order_Line_Items__c);
            }
        }
        List<ERP7__Purchase_Line_Items__c> polist = [select id, Name, ERP7__Match_Type__c, ERP7__Purchase_Orders__c from ERP7__Purchase_Line_Items__c where Id In :poliIds ];
        for(ERP7__Purchase_Line_Items__c poli : polist){            if(poli.ERP7__Match_Type__c == 'Three-Way') return false;            if(poli.ERP7__Match_Type__c == Null) return false;        }        return true; }Catch(Exception e){ throw new AurahandledException(e.getMessage()); }
        
    }
    
    public class ToleranceClass{
        @AuraEnabled public Decimal qtyTolerance {get;set;}
        @AuraEnabled public Decimal unitPrTolerance {get;set;}
        public ToleranceClass(){
            qtyTolerance = 0.00;
            unitPrTolerance = 0.00;
        }
    }
    
    @AuraEnabled
    public static ToleranceClass getModule(){
        ToleranceClass tc = new ToleranceClass();
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();
        if(RunModule.size() > 0){            tc.qtyTolerance = RunModule.get('Finance').ERP7__Bill_Quantity_Tolerance__c;            tc.unitPrTolerance = RunModule.get('Finance').ERP7__Bill_Unit_Price_Tolerance__c;            return tc;        }else{            return tc;        }
        
    }
}