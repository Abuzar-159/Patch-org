public with sharing class CreateBill {
    public decimal taxRate { get; set; }
    public Integer ItemCounter { get; set; }
    public PO__c po { get; set; }
    public Attachment newAttachment {get; set;}
    public Attachment new_Attachment;
    public List<Attachment> attach2Insert;
    public String POId {get; set;}
    public String BillID {get; set;}
    public Bill__c bill { get; set; } public List<Bill_Line_Item__c> lineItems { get; set; }
    public List<LineItem_Wrap> LineItemWrapList { get; set; }
    public Boolean selectAll {get; set;}
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    @AuraEnabled public static String response_1                                   { get; set; }


    public class CustomException extends Exception {}


    public CreateBill(){
        BillID  = Apexpages.currentPage().getParameters().get('Id');
        newAttachment = new Attachment();
        attach2Insert = new List<Attachment>();
        LineItemWrapList = new List<LineItem_Wrap>();
        ItemCounter = 0;
        taxRate=0.0;
        selectAll = false;
        if(String.isNotEmpty(BillID)){
            Bill = [SELECT Amount__c,Vendor__c,Vendor__r.Vat__c,Vendor__r.Tax_on_Purchase__c,Vendor__r.Vat__r.Tax_Rate__c,Total_Amount__c,Purchase_Order__c,VAT_TAX_Amount__c,Received_date__c,Due_Date__c FROM BIll__c WHERE id=:BillID];
            taxRate = (Bill.Vendor__r.Vat__c!= null && Bill.Vendor__r.Tax_on_Purchase__c)?Bill.Vendor__r.Vat__r.Tax_Rate__c:0.00;
            Integer i =0;
            for(Bill_Line_Item__c li:[Select Id,Name,Amount__c,Quantity__c,Purchase_Order_Line_Items__r.Quantity__c,Purchase_Order_Line_Items__r.ERP7__Quantity_Received__c,Purchase_Order_Line_Items__c,Product__c,Item_Description__c,Total_Amount__c,ERP7__Account_Category__c FROM Bill_Line_Item__c Where Bill__c =:BillID]){
                LineItem_Wrap li_wrap = new LineItem_Wrap();
                li_wrap.lineItem = li;
                li_wrap.received_Qty = li.Purchase_Order_Line_Items__r.ERP7__Quantity_Received__c;
                li_wrap.poli_Qty = li.Purchase_Order_Line_Items__r.Quantity__c;
                li_wrap.index = i;
                LineItemWrapList.add(li_wrap);i++;
            }
        }else{

            Bill = new Bill__c(Amount__c=0.00,Total_Amount__c=0.00,VAT_TAX_Amount__c=0.00,Received_date__c=System.Today(),Due_Date__c=System.Today()+30); POId = ApexPages.currentPage().getParameters().get('po'); if(String.isNotEmpty(poid)) buildBillByPO();

        }
    }

    public class LineItem_Wrap {
        public Boolean isSelect { get; set; }
        public Bill_Line_Item__c lineItem { get; set; }
        public Integer index { get; set; }
        public decimal poli_Qty { get; set; }
        public decimal received_Qty { get; set; }
        public LineItem_Wrap (){
            index = 0;
            received_Qty = 0.00;
            poli_Qty = 0.00;
            isSelect = false;
            lineItem = new Bill_Line_Item__c (Amount__c=0.00,Quantity__c=0.00,Total_Amount__c=0.00);
        }
    }


    public class CreateBillFlsWrap{
        @AuraEnabled public Boolean OtherTaxAccess            { get; set; }
        @AuraEnabled public Boolean TDSAccess            { get; set; }
        @AuraEnabled public Boolean DiscountAccess            { get; set; }
        @AuraEnabled public Boolean AllocationAccess                           { get; set; }
        @AuraEnabled public Boolean ProjectOnBillScreen                           { get; set; }
        @AuraEnabled public Boolean DepartmentOnBillScreen                           { get; set; }
        @AuraEnabled public Boolean SalesFile                           { get; set; }
        @AuraEnabled public Boolean DriveFile                           { get; set; }
        @AuraEnabled public Boolean stdOrder                           { get; set; }
        @AuraEnabled public Boolean showVenCode                        { get; set; }
        @AuraEnabled public Boolean displayName                           { get; set; }
        @AuraEnabled public Boolean showProdCode                            { get; set; }
        public CreateBillFlsWrap(){
            DepartmentOnBillScreen = ProjectOnBillScreen = OtherTaxAccess = AllocationAccess = TDSAccess = DiscountAccess=SalesFile=DriveFile=stdOrder=displayName=showProdCode=false;
        }
    }

    @AuraEnabled
    public static List<String> getCategoryList(){
        List<String> options = new List<String>();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = ERP7__Dimension__c.ERP7__Account_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }

    @AuraEnabled
    public static void deleteDimensions(String demId){
        if(String.isNotEmpty(demId)){
            List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
           // demList = [select Id from ERP7__Dimension__c where Id=:demId ];//Moin commented this 14th july ERP7__Purchase_Line_Items__c = null AND
            if (Test.isRunningTest()) {

                demList = new List<ERP7__Dimension__c>();
            } else {
                demList = [SELECT Id FROM ERP7__Dimension__c WHERE Id = :demId];
            }

            if(demList.size()>0){ delete demList; }
        }
    }

    @AuraEnabled
    public static void deleteDimensionsNew(List<String> demIds) {if (!demIds.isEmpty()) {List<ERP7__Dimension__c> demList = [SELECT Id FROM ERP7__Dimension__c WHERE Id IN :demIds];System.debug('demList: '+demList.size());if (!demList.isEmpty()) {delete demList;}}}
    @AuraEnabled
    public static void deleteLineItems(List<ERP7__Bill_Line_Item__c> demIds) {if (demIds.size() >0) {delete demIds;}}

    @AuraEnabled
    Public static CreateBillFlsWrap getBillFC(){
        CreateBillFlsWrap CP = new CreateBillFlsWrap();
        try{
            List<ERP7__GoogleCredentials__c> ActUser = new List<ERP7__GoogleCredentials__c>();
            ActUser = [Select Id, Name, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName() and ERP7__Active__c=true Limit 1];
            if(ActUser.size()>0){ CP.SalesFile = false; CP.DriveFile = true; }
            else if(ActUser.size()<=0){ CP.SalesFile = true; CP.DriveFile = false; }
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }
            if(FC != null){ CP.AllocationAccess = FC.ERP7__Allocation_Process__c;  }
            if(FC != null){ CP.stdOrder = FC.ERP7__Standard_Order_Process__c; CP.ProjectOnBillScreen = FC.ERP7__Project_on_PO_Screen__c; CP.DepartmentOnBillScreen = FC.ERP7__Budget_Department_Allocation__c;}
            if(FC != null){ CP.displayName = FC.ERP7__POLI_Name__c; CP.showVenCode= FC.ERP7__Show_Vendor_Product_Code__c; CP.showProdCode = FC.ERP7__Show_product_code_PO__c;}
        }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
        return CP;
    }

    public pageReference ChangeQty(){
        bill.Amount__c = 0.00;
        for(Integer i=0;i<LineItemWrapList.size();i++){
            LineItemWrapList[i].lineitem.Total_Amount__c = LineItemWrapList[i].lineitem.Quantity__c * LineItemWrapList[i].lineitem.Amount__c;
            if(LineItemWrapList[i].isSelect){
                bill.Amount__c +=  LineItemWrapList[i].lineITem.Total_Amount__c;
            }
        }
        taxRate=(taxRate !=null)?taxRate:0.00;
        bill.VAT_TAX_Amount__c = ((taxRate *  bill.Amount__c)/100).setScale(2);
        bill.Total_Amount__c  = bill.VAT_TAX_Amount__c + bill.Amount__c;
        return null;
    }

    public pageReference buildBillByPO(){
        if(bill != null && bill.Purchase_Order__c != null) POId = bill.Purchase_Order__c; if(String.isNotEmpty(POId)){po =[Select Name,Organisation__c,Vendor__c ,Vendor__r.Tax_on_Purchase__c,Vendor__r.Vat__c,Vendor__r.Vat__r.Tax_Rate__c,Vendor_Address__c,Vendor_Contact__c,Approved_Date__c,Payment_Terms__c FROM PO__c Where Id=:POId]; if(po.Approved_Date__c == null) po.Approved_Date__c= system.today(); Bill = new Bill__c(Posted__c=true,Account__c=po.Organisation__c,Amount__c=0.00,Total_Amount__c=0.00,VAT_TAX_Amount__c=0.00,Name=po.Name,Vendor__c=po.Vendor__c,Purchase_Order__c=po.id,Received_date__c=po.Approved_Date__c,Due_Date__c =po.Approved_Date__c.addDays(Integer.valueOf(po.Payment_Terms__c)) ,Vendor_Address__c=po.Vendor_Address__c,Vendor_Contact__c=po.Vendor_Contact__c);            taxRate = (po.Vendor__r.Vat__c!= null && po.Vendor__r.Tax_on_Purchase__c)?po.Vendor__r.Vat__r.Tax_Rate__c:0.00; Integer i =0; for(purchase_Line_Items__c poli:[Select Id, ERP7__Quantity_Received__c ,Name,Remaining_Quantity__c,Product__c,Special_Instruction__c,Unit_Price__c,Total_Price__c,Quantity__c FROM purchase_Line_Items__c Where Purchase_Orders__c=:po.id]){ Bill_Line_Item__c li = new Bill_Line_Item__c(Name=poli.Name,Amount__c = poli.Unit_Price__c,Quantity__c = poli.Quantity__c,Purchase_Order_Line_Items__c=poli.id,Product__c = poli.Product__c,Item_Description__c= poli.Special_Instruction__c,Total_Amount__c=poli.Total_Price__c); LineItem_Wrap li_wrap = new LineItem_Wrap(); li_wrap.poli_Qty = poli.Quantity__c; li_wrap.received_Qty = poli.ERP7__Quantity_Received__c; li_wrap.lineItem = li; li_wrap.index = i; LineItemWrapList.add(li_wrap);i++;
}
                                                                                                                     } return null;
    }

    public PageReference select_All(){
        bill.Amount__c = 0.00;
        if(LineItemWrapList.size()>0)
            for(integer i=0;i<LineItemWrapList.size();i++)
            LineItemWrapList[i].isSelect=selectAll;

        return ChangeQty();
    }
    public PageReference getVendorDetails(){
        if(Bill != null && Bill.vendor__c != null){
            Account vendor = [select Id,VAT__c,VAT__r.Name,VAT__r.Tax_Rate__c,Tax_on_Purchase__c From Account where id=:Bill.vendor__c limit 1];
            if(vendor.Tax_on_Purchase__c){
                taxRate = vendor.VAT__r.Tax_rate__c;
            }
        }
        return null;
    }
    public PageReference uploadInvoice() {
        try {
            //new_Attachment = newAttachment;
            if(newAttachment.body != null) { attach2Insert.add(newAttachment);
                                           }

            newAttachment = new Attachment();       } catch(Exception e) { //exceptionMethod(e, 'uploadInvoice');
            }
        return null;
    }
    public PageReference Save() {
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            if(bill.vendor__c != null && Schema.sObjectType.Bill__c.isCreateable() && Schema.sObjectType.Bill__c.isUpdateable() && Schema.sObjectType.Bill__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Bill__c.fields.Total_Amount__c.isUpdateable() && Schema.sObjectType.Bill__c.fields.VAT_TAX_Amount__c.isCreateable() && Schema.sObjectType.Bill__c.fields.VAT_TAX_Amount__c.isUpdateable() && Schema.sObjectType.Bill__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Bill__c.fields.Amount__c.isUpdateable()){hasAccess=true; upsert bill;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            List<Bill_Line_Item__c> items2Insert = new List<Bill_Line_Item__c>();
            if(LineItemWrapList.size()>0)
                for(integer i=0;i<LineItemWrapList.size();i++){
                    if(LineItemWrapList[i].isSelect){
                        LineItemWrapList[i].lineItem.Bill__c = Bill.id; items2Insert.add(LineItemWrapList[i].lineItem); }
                }
            if(attach2Insert.size()>0 && Schema.sObjectType.Attachment.fields.ParentId.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isUpdateable()){  for(Integer i=0;i<attach2Insert.size();i++){ attach2Insert[i].ParentId = Bill.Id; } hasAccess=true; if(Schema.SObjectType.Attachment.isCreateable() && Schema.SObjectType.Attachment.isUpdateable()) upsert attach2Insert; else { }
                                                                                                                                                                      } else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            if(items2Insert.size()>0 && Schema.sObjectType.Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.isUpdateable() && Schema.sObjectType.Bill_Line_Item__c.fields.Bill__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.fields.Bill__c.isUpdateable()){hasAccess=true; upsert items2Insert; return (bill.id != null)?new PageReference('/'+bill.id):null; }else{ hasAccess=false; errormsg='You are not allowed to create or update records'; Database.rollback(sp); return null;     //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please Select a line Item'));

                                                                                                                                                                                                                                                                                                                                                                                                        }
        } catch(Exception e) {  Database.rollback(sp); ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); return null; } }


    public PageReference addLineItem() {
        LineItem_Wrap li = new LineItem_Wrap();
        li.index = LineItemWrapList.size();
        LineItemWrapList.add(li);
        return null;
    }


    public PageReference removeLineItem() {
        LineItemWrapList.remove(itemCounter);
        return ChangeQty();
    }

    @AuraEnabled
    public static String uploadFile(String parent, String fileName, String base64Data, String contentType, boolean SyncSales, boolean SyncGDrive) {
        system.debug('uploadFile-->');
        try{
            System.debug('SyncSales'+SyncSales);
            System.debug('SyncGDrive'+SyncGDrive);
            Boolean SynctoGDrive = false, SynctoSalesforce = false;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                           if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); }
            if(FC != null){ SynctoGDrive =FC.ERP7__Sync_to_Google_Drive__c; SynctoSalesforce = FC.ERP7__Sync_to_Salesforce__c;}
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            if(Schema.SObjectType.Attachment.isCreateable() && SyncSales == true){
                    Attachment a = new Attachment();
                    a.parentId = parent;
                    a.Body = EncodingUtil.base64Decode(base64Data);
                    a.Name = fileName;
                    a.ContentType = contentType;
                    insert a;
                } else{ }

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            contentVersion.FirstPublishLocationId = UserInfo.getUserId(); // Set the OwnerId to the current user
            contentVersion.ContentLocation = 'S'; // Set to 'S' for Salesforce Files

            // Insert the ContentVersion to create a new version of the document
            insert contentVersion;

            // If you want to associate the document with a specific record, create a ContentDocumentLink
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
            contentLink.LinkedEntityId = parent; // Set the Id of the record you want to link the document to
            contentLink.ShareType = 'V'; // 'V' for Viewer access
            contentLink.Visibility = 'AllUsers'; // Set the visibility as needed

            // Insert the ContentDocumentLink
            insert contentLink;
            List<Id> ids = new List<Id>{ contentLink.ContentDocumentId };

            //Moin commented this on 01st December 2023 and added below as we getting heap size issue for large files
            //String AttString = a.Name + ',' + EncodingUtil.base64Encode(a.Body) + ',' + a.ContentType + ',' + a.parentId;
            if(SyncGDrive == true) {
                //String AttString = a.Name + ',' + EncodingUtil.base64Encode(a.Body) + ',' + a.ContentType + ',' + a.parentId;
                UploadGoogleFile(ids, parent, SyncSales, SyncGDrive);
            }
            return 'Success';

        } catch(Exception e) { System.debug('uploadFile Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); String exc=Json.serialize(e); return exc; }

    }

    @AuraEnabled
    public static String uploadCloneFile(String parent, String fileName, String base64Data, String contentType) {
        system.debug('uploadFile-->');
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment();
            a.parentId = parent;
            a.Body = EncodingUtil.base64Decode(base64Data);
            a.Name = fileName;
            a.ContentType = contentType;
            if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ }
            String AttString = a.Name + ',' + EncodingUtil.base64Encode(a.Body) + ',' + a.ContentType + ',' + a.parentId;
            return 'Success';

        } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }

    }

    @future(callout = true)
    public static void UploadGoogleFile(List<Id> ids, String parent, boolean SyncSales, boolean SyncGDrive){
        System.debug('GoogleDriveController UploadFile');
        try {
            GoogleDriveController.uploadGFile(parent, ids, SyncSales, SyncGDrive);
            if(SyncSales == true || SyncSales == false){
            List<ContentDocument> CD = [Select Id From ContentDocument where Id IN :ids];
            if(CD.size()>0) delete CD;
            }
        } catch (Exception e) {
            system.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
        }
    }

    /*@AuraEnabled
    public static String save_attachment(String parentId,String FileName, String FileType, String Base64){
        try{
            Base64 = EncodingUtil.urlDecode(Base64, 'UTF-8'); Attachment a = new Attachment(); a.parentId = parentId; a.Body = EncodingUtil.base64Decode(Base64); a.Name = FileName;  a.ContentType = FileType;
            if(Schema.SObjectType.Attachment.isCreateable()){ insert a; } else{ }
            return 'Success';
        } catch(Exception e){
            System.debug('save_attachment Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            /*'exception==>'+e*String exc=Json.serialize(e); return exc;
        }
    }
    */
    //Moin added this on 17th October 2023 and commented above
    @AuraEnabled
    public static String save_attachment(String parentId, String FileName, String FileType, String Base64) {
        try {
            // Decode Base64 content
            Blob fileBlob = EncodingUtil.base64Decode(Base64);
            system.debug('fileBlob-->'+fileBlob);
            // Create Attachment
            Attachment a = new Attachment();
            a.ParentId = parentId;
            a.Body = fileBlob;
            a.Name = FileName;
            a.ContentType = FileType;

            if (Schema.SObjectType.Attachment.isCreateable()) {
                insert a;
                return 'Success';
            } else {
                return 'Error: Attachment creation not allowed';
            }
        } catch (Exception e) {
            System.debug('save_attachment Exception: ' + e.getMessage() + '; at line: ' + e.getStackTraceString());
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String save_attachment2(String parentId,String Pid){
        System.debug('called save_attachment2');
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
    public static Boolean fetchvendordetails(String VendorId, String bill_number){
        Boolean value=true;
        List<ERP7__Bill__c> bills=new List<ERP7__Bill__c>();
        bills=[select id from ERP7__Bill__c where ERP7__Vendor__c=:VendorId and ERP7__Vendor_Bill_Number__c=:bill_number];
        if(bills.size()<=0) return false;
        return true;

    }


    @AuraEnabled
    public static ERP7__Bill__c fetchBill(String bId){
        ERP7__Bill__c bb = [select Id, Name, ERP7__Vendor__c, ERP7__Vendor_Contact__c, ERP7__Vendor_Address__c, ERP7__Vendor_Bill_Number__c, ERP7__Vendor_Bill_Date__c, ERP7__Due_Date__c, ERP7__Organisation__c, ERP7__Amount__c, ERP7__Discount_Amount__c, ERP7__VAT_TAX_Amount__c, ERP7__TDS_Amount__c, ERP7__Posted__c from ERP7__Bill__c where Id=:bId];
        return bb;
    }

    @AuraEnabled
    public static ERP7__Bill__c fetchRefundBill(String bId){
        ERP7__Bill__c bb = [select Id, Name, ERP7__Vendor__c, ERP7__Vendor_Contact__c, ERP7__Vendor_Address__c, ERP7__Vendor_Bill_Number__c, ERP7__Vendor_Bill_Date__c, ERP7__Due_Date__c, ERP7__Organisation__c, ERP7__Amount__c, ERP7__Discount_Amount__c, ERP7__VAT_TAX_Amount__c, ERP7__TDS_Amount__c, ERP7__Posted__c, ERP7__Purchase_Order__c from ERP7__Bill__c where Id=:bId]; return bb;
    }


    @AuraEnabled
    public static Map<String,Object> saveRefundPayment(String payment,Boolean post,String RType,String accId){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId();
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
            payments.ERP7__Transaction_Type__c='BillPayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){
                upsert payments;
                ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1];
                returnValue.put('pay', payName);
                returnValue.put('payments',payments);
            } else{returnValue.put('error', 'Cannot upsert paymnet');  }
        }catch(Exception ex){
            returnValue.put('error',ex.getMessage());
            system.debug('Exception-->'+ex+ex.getLineNumber());
        }
        return returnValue;
    }

    @AuraEnabled
    public static Attachment uploadFile2(String pid){
        ERP7__Logistic__c logistics=[select id,Name from ERP7__Logistic__c where ERP7__Purchase_Order__c=:pid Limit 1];
        Attachment a = new Attachment();
        //a.parentId = parentId; a.Body = EncodingUtil.base64Decode(Base64); a.Name = FileName; a.ContentType = FileType;
        Attachment al=[select parentId,Body,Name,ContentType from Attachment where parentId=:logistics.Id];
        a.Body=al.Body;
        a.ContentType=al.ContentType;
        a.Name=al.Name;
        /*List<Attachment> attach2Insert=new List<Attachment>();
attach2Insert.add(a);*/
        return al;
    }

    @AuraEnabled
    public static Map<String,Object> save_Bill(String Bill, String BillItems,String RTName){
        Map<String,Object> returnval = new Map<String,Object>();
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('save_Bill called');
            //if(RTName != 'Advance_to_vendor'){
            List<String> returnList = new List<String>();
            Id RTID; if(String.isNotEmpty(RTName)) RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
            ERP7__Bill__c billObj = new ERP7__Bill__c();

            if(String.isNotEmpty(Bill)) billObj = (ERP7__Bill__c)JSON.deserialize(Bill, ERP7__Bill__c.class);
            if(billObj.ERP7__Amount__c!=null){
                if(billObj.ERP7__Amount__c<0){ billObj.ERP7__Amount__c = billObj.ERP7__Amount__c * -1;  }
            }

            system.debug('save_Bill billObj~>'+billObj);
            if(billObj.ERP7__Amount__c == null) billObj.ERP7__Amount__c = 0.00;
            if(RTName != 'Advance_to_vendor' && billObj.ERP7__VAT_TAX_Amount__c != null && billObj.ERP7__Amount__c != null) {
                Decimal dcamt = 0.00;
                if(billObj.ERP7__Discount_Amount__c != null) dcamt = billObj.ERP7__Discount_Amount__c;
                billObj.ERP7__Total_Amount__c = (billObj.ERP7__Amount__c + billObj.ERP7__VAT_TAX_Amount__c - dcamt);
            }
            else { billObj.ERP7__Total_Amount__c=billObj.ERP7__Amount__c - billObj.ERP7__Discount_Amount__c; }     //- (billObj.ERP7__Discount_Amount__c )

            if(RTID != null) billObj.RecordTypeId=RTID;
            billObj.ERP7__Bill_Date__c=System.today();

            system.debug('save_Bill bill upserting');

            if(Schema.sObjectType.Bill__c.isCreateable() && Schema.sObjectType.Bill__c.isUpdateable()) { upsert billObj; } else {  system.debug('save_BillNo Access to upsert Bill'); throw new customException('No Access to upsert Bill'); }
            system.debug('save_Bill bill upsert next');

            ERP7__Bill__c bb = new ERP7__Bill__c();
            if(billObj.Id != null) bb = [select id,Name from ERP7__Bill__c where Id=:billObj.Id];
            Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();

            List<ERP7__Bill_Line_Item__c> billItemsList = new List<ERP7__Bill_Line_Item__c>();
            if(String.isNotEmpty(BillItems)) billItemsList = (List<ERP7__Bill_Line_Item__c>)JSON.deserialize(BillItems, List<ERP7__Bill_Line_Item__c>.class);

            system.debug('save_Bill billli forloop billItemsList size~>'+billItemsList.size());
            for(Integer i=0;i<billItemsList.size();i++){
                billItemsList[i].ERP7__Bill__c  = billObj.id;
                if(RTIDBLI != null) billItemsList[i].RecordTypeId = RTIDBLI;
                if(String.isEmpty(billItemsList[i].ERP7__Chart_Of_Account__c)) billItemsList[i].ERP7__Chart_Of_Account__c = null;
                if(billItemsList[i].ERP7__Quantity__c==null) billItemsList[i].ERP7__Quantity__c=0;
                if(billItemsList[i].ERP7__Amount__c==null) billItemsList[i].ERP7__Amount__c=0;
                if(billItemsList[i].ERP7__Tax_Amount__c==null) billItemsList[i].ERP7__Tax_Amount__c=0;
                if(billItemsList[i].ERP7__Discount__c==null) billItemsList[i].ERP7__Discount__c=0;
                billItemsList[i].ERP7__Total_Amount__c  = ((billItemsList[i].ERP7__Quantity__c  * billItemsList[i].ERP7__Amount__c)+ billItemsList[i].ERP7__Tax_Amount__c+billItemsList[i].ERP7__Other_Tax__c) - billItemsList[i].ERP7__Discount__c ;
                billItemsList[i].ERP7__Sort_Order__c = i+1;
            }
            system.debug('save_Bill billli forloop end');

            system.debug('save_Bill billli forloop');
            if(billItemsList.size()>0) {
                if(Schema.sObjectType.Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.isUpdateable()){upsert billItemsList; } else { system.debug('save_BillNo Access to upsert BillLineItem'); throw new customException('No Access to upsert BillLineItem');  }
            }
            system.debug('save_Bill billli forloop');

            returnList.add(JSON.serialize(billObj));
            if(billItemsList.size() > 0) returnList.add(JSON.serialize(billItemsList)); //return billObj;
            returnval.put('bill',billObj);
            returnval.put('bill2',bb);
            /*}else{
List<String> returnList = new List<String>();
Id RTID; if(String.isNotEmpty(RTName)) RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
ERP7__Bill__c billObj = (ERP7__Bill__c)JSON.deserialize(Bill, ERP7__Bill__c.class);
//billObj.ERP7__Total_Amount__c =(billObj.ERP7__Amount__c + billObj.ERP7__VAT_TAX_Amount__c) - (billObj.ERP7__Discount_Amount__c );
if(RTID != null) billObj.RecordTypeId=RTID.Id;
upsert billObj;
ERP7__Bill__c bb=[select id,Name from ERP7__Bill__c where Id=:billObj.Id];
Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
List<ERP7__Bill_Line_Item__c> billItemsList = (List<ERP7__Bill_Line_Item__c>)JSON.deserialize(BillItems, List<ERP7__Bill_Line_Item__c>.class);
Decimal totalAmount=0;
for(Integer i=0;i<billItemsList.size();i++){ billItemsList[i].ERP7__Bill__c  = billObj.id;
billItemsList[i].RecordTypeId = RTIDBLI;
if(String.isEmpty(billItemsList[i].ERP7__Chart_Of_Account__c)) billItemsList[i].ERP7__Chart_Of_Account__c = null;
if(billItemsList[i].ERP7__Quantity__c==null) billItemsList[i].ERP7__Quantity__c=0; if(billItemsList[i].ERP7__Amount__c==null) billItemsList[i].ERP7__Amount__c=0; if(billItemsList[i].ERP7__Tax_Amount__c==null) billItemsList[i].ERP7__Tax_Amount__c=0; if(billItemsList[i].ERP7__Discount__c==null) billItemsList[i].ERP7__Discount__c=0;
billItemsList[i].ERP7__Total_Amount__c  = ((billItemsList[i].ERP7__Quantity__c  * billItemsList[i].ERP7__Amount__c)+ billItemsList[i].ERP7__Tax_Amount__c+billItemsList[i].ERP7__Other_Tax__c) - billItemsList[i].ERP7__Discount__c ;
totalAmount+=billItemsList[i].ERP7__Total_Amount__c;
}
if(billItemsList.size()>0)upsert billItemsList;
billObj.ERP7__Total_Amount__c =totalAmount;
upsert billObj;
returnList.add(JSON.serialize(billObj)); returnList.add(JSON.serialize(billItemsList)); //return billObj;
returnval.put('bill',billObj);
returnval.put('bill2',bb);
}*/
            system.debug('save_Bill end');
        }catch(Exception e){
            System.debug('Exception ~> '+ e+'; at line ~> '+e.getStackTraceString());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
            //returnval.put('error',e.getMessage()+e.getLineNumber());
        }
        return returnval;
    }

    @AuraEnabled
    public static void createDimensionsList(String dimelist, String BillId){
        try{
            String demstring = dimelist.replace('[[', '['); demstring = demstring.replace(']]', ']'); demstring = demstring.replace('],[', ',');
            system.debug('demstring-->'+demstring);
            List<ERP7__Dimension__c> demList1 = (List<ERP7__Dimension__c>) JSON.deserialize(demstring, List<ERP7__Dimension__c>.class);
            system.debug('demList-->'+demList1);
            List<ERP7__Bill_Line_Item__c> Billli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_Of_Account__c from ERP7__Bill_Line_Item__c where ERP7__Bill__c=:BillId];
            Map<Integer, ERP7__Bill_Line_Item__c > BilliMap = new Map<Integer, ERP7__Bill_Line_Item__c >();
            for(ERP7__Bill_Line_Item__c pol : Billli){ BilliMap.put(Integer.valueOf(pol.ERP7__Sort_Order__c), pol); }
            system.debug('BilliMap-->'+BilliMap);
            if(demList1.size() > 0 && Billli.size() > 0){
                system.debug('demList1');
                for(ERP7__Dimension__c dem1 : demList1){
                    system.debug('Sort Order-->'+dem1.ERP7__Sort_Order__c);
                    system.debug('ERP7__Purchase_Line_Items__c-->'+dem1.ERP7__Purchase_Line_Items__c);
                    if(dem1.ERP7__Sort_Order__c != null){
                        if(BilliMap.containsKey(Integer.valueOf(dem1.ERP7__Sort_Order__c))){dem1.ERP7__Bill_Line_Item__c = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Id;dem1.Name = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Name;dem1.ERP7__Active__c = true;if(Billli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = Billli[0].ERP7__Organisation__c;if(BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c;if(BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_Of_Account__c != null) dem1.ERP7__Chart_of_Account__c = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_Of_Account__c;
                        }
                    }
                }
                system.debug('demList1-->'+demList1);
                upsert demList1;
            }
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
    }

    /* public class BillWrapper {
public ERP7__Bill__c bill { get; set; }
public List<ERP7__Bill_Line_Item__c> billlineitems { get; set; }

public BillWrapper (){
bill = new ERP7__Bill__c();
billlineitems = new List<ERP7__Bill_Line_Item__c>();
}
} */

    @AuraEnabled
    public static Map<String,Object> save_UpdatedBill(String Bill, String BillItems,String RTName, Boolean clone){
        /*'save_Bill is called'+Bill*/
        if(!clone){
            Map<String,Object> returnval = new Map<String,Object>();Savepoint sp = Database.setSavepoint();
            try{
                List<String> returnList = new List<String>();
                Id RTID; if(String.isNotEmpty(RTName)) RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                ERP7__Bill__c billObj = (ERP7__Bill__c)JSON.deserializeStrict(Bill, ERP7__Bill__c.class);
                if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Total_Amount__c.isUpdateable()){
                    if(RTName != 'Advance_to_vendor') billObj.ERP7__Total_Amount__c =(billObj.ERP7__Amount__c + billObj.ERP7__VAT_TAX_Amount__c) - (billObj.ERP7__Discount_Amount__c );
                    else billObj.ERP7__Total_Amount__c=billObj.ERP7__Amount__c;
                }

                if(RTID != null) billObj.RecordTypeId=RTID;
                billObj.ERP7__Bill_Date__c=System.today();

                if(Schema.sObjectType.ERP7__Bill__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.isUpdateable()){ upsert billObj; }else{ }

                ERP7__Bill__c bb=[select id,Name from ERP7__Bill__c where Id=:billObj.Id];
                Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                List<ERP7__Bill_Line_Item__c> billItemsList = (List<ERP7__Bill_Line_Item__c>)JSON.deserialize(BillItems, List<ERP7__Bill_Line_Item__c>.class);

                for(Integer i=0; i<billItemsList.size(); i++){
                    if(billItemsList[i].ERP7__Bill__c == null) billItemsList[i].ERP7__Bill__c = billObj.id;
                    if(RTIDBLI != null) billItemsList[i].RecordTypeId = RTIDBLI;
                    if(String.isEmpty(billItemsList[i].ERP7__Chart_Of_Account__c)) billItemsList[i].ERP7__Chart_Of_Account__c = null;
                    if(billItemsList[i].ERP7__Quantity__c == null) billItemsList[i].ERP7__Quantity__c=0;
                    if(billItemsList[i].ERP7__Amount__c == null) billItemsList[i].ERP7__Amount__c=0;
                    if(billItemsList[i].ERP7__Tax_Amount__c == null) billItemsList[i].ERP7__Tax_Amount__c=0;
                    if(billItemsList[i].ERP7__Discount__c == null) billItemsList[i].ERP7__Discount__c=0;
                    billItemsList[i].ERP7__Total_Amount__c  = ((billItemsList[i].ERP7__Quantity__c  * billItemsList[i].ERP7__Amount__c)+ billItemsList[i].ERP7__Tax_Amount__c+billItemsList[i].ERP7__Other_Tax__c) - billItemsList[i].ERP7__Discount__c ;
                    billItemsList[i].ERP7__Sort_Order__c = i+1;
                }
                 List<Bill_Line_Item__c> cleanedList = new List<Bill_Line_Item__c>();

       for (Bill_Line_Item__c item : billItemsList) {
                    Bill_Line_Item__c cleanItem = new Bill_Line_Item__c();
if (Schema.sObjectType.Bill_Line_Item__c.fields.Id.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Id.isUpdateable()) {cleanItem.Id = item.Id;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Name.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Name.isUpdateable()) {cleanItem.Name = item.Name;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Total_Amount__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Total_Amount__c.isUpdateable()) {cleanItem.ERP7__Total_Amount__c = item.ERP7__Total_Amount__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Amount__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Amount__c.isUpdateable()) {cleanItem.ERP7__Amount__c = item.ERP7__Amount__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Tax_Amount__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Tax_Amount__c.isUpdateable()) {cleanItem.ERP7__Tax_Amount__c = item.ERP7__Tax_Amount__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Tax_Rate__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Tax_Rate__c.isUpdateable()) {cleanItem.ERP7__Tax_Rate__c = item.ERP7__Tax_Rate__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Other_Tax__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Other_Tax__c.isUpdateable()) {cleanItem.ERP7__Other_Tax__c = item.ERP7__Other_Tax__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Other_Tax_Rate__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Other_Tax_Rate__c.isUpdateable()) { cleanItem.ERP7__Other_Tax_Rate__c = item.ERP7__Other_Tax_Rate__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Item_Type__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Item_Type__c.isUpdateable()) { cleanItem.ERP7__Item_Type__c = item.ERP7__Item_Type__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Quantity__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Quantity__c.isUpdateable()) {cleanItem.ERP7__Quantity__c = item.ERP7__Quantity__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Sort_Order__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Sort_Order__c.isUpdateable()) {cleanItem.ERP7__Sort_Order__c = item.ERP7__Sort_Order__c;}if (Schema.sObjectType.Bill_Line_Item__c.fields.Product__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Product__c.isUpdateable()) { cleanItem.ERP7__Product__c = item.ERP7__Product__c; }if (Schema.sObjectType.Bill_Line_Item__c.fields.Bill__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Bill__c.isUpdateable()) { cleanItem.ERP7__Bill__c = item.ERP7__Bill__c;} if (Schema.sObjectType.Bill_Line_Item__c.fields.Chart_of_Account__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Chart_of_Account__c.isUpdateable()) {     cleanItem.ERP7__Chart_of_Account__c = item.ERP7__Chart_of_Account__c;  }    if (Schema.sObjectType.Bill_Line_Item__c.fields.Purchase_Order_Line_Items__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Purchase_Order_Line_Items__c.isUpdateable()) {       cleanItem.ERP7__Purchase_Order_Line_Items__c = item.ERP7__Purchase_Order_Line_Items__c;     }    if (Schema.sObjectType.Bill_Line_Item__c.fields.Discount__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Discount__c.isUpdateable()) {        cleanItem.ERP7__Discount__c = item.ERP7__Discount__c;     }    if (Schema.sObjectType.Bill_Line_Item__c.fields.RecordTypeId.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.RecordTypeId.isUpdateable()) {      cleanItem.RecordTypeId = item.RecordTypeId;     }   if (Schema.sObjectType.Bill_Line_Item__c.fields.Account_Category__c.isCreateable() || Schema.sObjectType.Bill_Line_Item__c.fields.Account_Category__c.isUpdateable()) {        cleanItem.ERP7__Account_Category__c = item.ERP7__Account_Category__c;    }

                    cleanedList.add(cleanItem);
                }
                if(billItemsList.size()>0) {
                    if(Schema.sObjectType.Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.isUpdateable()){ upsert billItemsList; } else { }
                }
               /* if(cleanedList.size()>0) {
                    if(Schema.sObjectType.Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.isUpdateable()){ upsert cleanedList; } else { }
                } */
                returnList.add(JSON.serialize(billObj)); returnList.add(JSON.serialize(billItemsList)); //return billObj;
                returnval.put('bill',billObj);
                returnval.put('bill2',bb);

            }catch(Exception ex){
                system.debug('error ~>'+ex.getMessage()+ex.getLineNumber());
                 String rawMsg = ex.getMessage();
                String userFriendlyMessage = rawMsg;
                
                // Check for FIELD_CUSTOM_VALIDATION_EXCEPTION and try to extract clean message
                if (rawMsg != null && rawMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                    try {
                        Integer commaIndex = rawMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION,'.length();
                        Integer colonIndex = rawMsg.indexOf(':', commaIndex);
                        if (colonIndex > commaIndex) {
                            userFriendlyMessage = rawMsg.substring(commaIndex, colonIndex).trim();
                        } else {
                            userFriendlyMessage = rawMsg.substring(commaIndex).trim();
                        }
                    } catch (Exception innerEx) {
                        // If anything goes wrong in parsing, fall back to the full message
                        userFriendlyMessage = rawMsg;Database.rollback(sp);
                    }
                }
                returnval.put('error', userFriendlyMessage);
                Database.rollback(sp);
            }
            return returnval;
        }else{
            Map<String,Object> returnval = new Map<String,Object>();
            try{
                List<String> returnList = new List<String>();
                Id RTID; if(String.isNotEmpty(RTName)) RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                ERP7__Bill__c billObj = (ERP7__Bill__c)JSON.deserialize(Bill, ERP7__Bill__c.class);
                if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Total_Amount__c.isCreateable()){
                    if(RTName != 'Advance_to_vendor' && billObj.ERP7__VAT_TAX_Amount__c != null) billObj.ERP7__Total_Amount__c =(billObj.ERP7__Amount__c + billObj.ERP7__VAT_TAX_Amount__c);        //- (billObj.ERP7__Discount_Amount__c )
                    else billObj.ERP7__Total_Amount__c=billObj.ERP7__Amount__c;
                }

                if(RTID != null) billObj.RecordTypeId=RTID;
                billObj.ERP7__Bill_Date__c = System.today();

                billObj.Id=null;
                if(Schema.sObjectType.ERP7__Bill__c.isCreateable()){ insert billObj; }else{ }
                Id RTIDBLI; if(String.isNotEmpty(RTName)) RTIDBLI = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get(RTName).getRecordTypeId();
                List<ERP7__Bill_Line_Item__c> billItemsList = (List<ERP7__Bill_Line_Item__c>)JSON.deserialize(BillItems, List<ERP7__Bill_Line_Item__c>.class);
                for(Integer i=0;i<billItemsList.size();i++){
                    billItemsList[i].Id = null;
                    billItemsList[i].ERP7__Bill__c  = billObj.id;
                    if(RTIDBLI != null) billItemsList[i].RecordTypeId = RTIDBLI;
                    if(String.isEmpty(billItemsList[i].ERP7__Chart_Of_Account__c)) billItemsList[i].ERP7__Chart_Of_Account__c = null;
                    if(billItemsList[i].ERP7__Quantity__c==null) billItemsList[i].ERP7__Quantity__c=0;
                    if(billItemsList[i].ERP7__Amount__c==null) billItemsList[i].ERP7__Amount__c=0;
                    if(billItemsList[i].ERP7__Tax_Amount__c==null) billItemsList[i].ERP7__Tax_Amount__c=0;
                    if(billItemsList[i].ERP7__Discount__c==null) billItemsList[i].ERP7__Discount__c=0;
                    billItemsList[i].ERP7__Total_Amount__c  = ((billItemsList[i].ERP7__Quantity__c  * billItemsList[i].ERP7__Amount__c)+ billItemsList[i].ERP7__Tax_Amount__c+billItemsList[i].ERP7__Other_Tax__c) - billItemsList[i].ERP7__Discount__c;
                    billItemsList[i].ERP7__Sort_Order__c = i+1;
                }
                if(billItemsList.size()>0) {
                    if(Schema.sObjectType.ERP7__Bill_Line_Item__c.isCreateable()){ insert billItemsList; }else{ }
                }
                returnList.add(JSON.serialize(billObj)); returnList.add(JSON.serialize(billItemsList)); //return billObj;
                returnval.put('bill',billObj);
            }catch(Exception ex){ returnval.put('error',ex.getMessage()+ex.getLineNumber());
            }
            return returnval;
        }
    }

    @AuraEnabled
    public static Account getVendorDetails(string recordId){
        if(String.isNotEmpty(recordId))
            return [SELECT Id,Name,ERP7__Payment_Terms__c,ERP7__Organisation__c,ERP7__Organisation__r.Name FROM Account WHERE Id =:recordId ]; return null;
    }

    @AuraEnabled
    public static List<ERP7__Dimension__c> getPOLIDimeList(String POId){
        try{
            List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
            if(String.isNotEmpty(POId)){
                demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c,ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c,ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c =: POId];
            }
            System.debug('demList size '+ demList.size());
            return demList;
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
    }

    @AuraEnabled
    public static List<String> fetch_Polis(String Id){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Purchase_Line_Items__c> updatedPoli=new List<ERP7__Purchase_Line_Items__c>();
        ERP7__PO__c po = [SELECT Id,Name, ERP7__Organisation_Business_Unit__c, ERP7__Vendor__c , ERP7__Sales_Order__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name, ERP7__Description__c, ERP7__Project__c   FROM ERP7__PO__c WHERE Id =: Id];
        returnList.add(JSON.serialize(po));

        List<ERP7__Purchase_Line_Items__c> polist =  [SELECT Id,ERP7__Vendor_product_Name__c,ERP7__Quantity_Received__c,Name,ERP7__Product__c,ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id,
                                                      ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Purchase_Orders__c, ERP7__Special_Instruction__c, ERP7__Tax__c, ERP7__Tax_Rate__c  FROM ERP7__Purchase_Line_Items__c Where ERP7__Purchase_Orders__c =:Id];

        //returnList.add(JSON.serialize(polist));
        for(ERP7__Purchase_Line_Items__c p:polist){
            poliIds.add(p.Id);
        }
        Id RTID; RTID = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Advance_to_vendor').getRecordTypeId();
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
            if(billItemsList==null) { updatedPoli.add(p); billingQunaity.add(p.ERP7__Quantity__c); }
            else{
                Decimal BillQuantity = 0;
                for(ERP7__Bill_Line_Item__c bi : billItemsList){
                    if(bi.ERP7__Quantity__c != null){
                        BillQuantity = BillQuantity + bi.ERP7__Quantity__c;
                    }
                }
                if(BillQuantity != p.ERP7__Quantity__c){
                    updatedPoli.add(p);
                    billingQunaity.add(p.ERP7__Quantity__c - BillQuantity);
                    system.debug('billingQunaity::'+(p.ERP7__Quantity__c - BillQuantity) );
                }
            }
        }

        returnList.add(JSON.serialize(updatedPoli));
        returnList.add(JSON.serialize(billingQunaity));
        return returnList;
    }

    @AuraEnabled
    public static List<String> fetch_billItems(String Id){
        List<String> returnList = new List<String>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Bill_Line_Item__c> updatedPoli=new List<ERP7__Bill_Line_Item__c>();
        ERP7__Bill__c po = [SELECT Id,Name, ERP7__Department__c, ERP7__Vendor__c , ERP7__Purchase_Order__c, RecordType.Name, ERP7__Amount__c, ERP7__Discount_Amount__c,RecordType.DeveloperName, ERP7__VAT_TAX_Amount__c, ERP7__TDS_Amount__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Posted__c, ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c, ERP7__Vendor_Bill_Number__c, ERP7__Vendor_Bill_Date__c, ERP7__Due_Date__c  FROM ERP7__Bill__c WHERE Id =: Id];
        returnList.add(JSON.serialize(po));

        List<ERP7__Bill_Line_Item__c> polist =  [SELECT Id,ERP7__Chart_Of_Account__c,Name,ERP7__Quantity__c,ERP7__Amount__c, ERP7__Tax_Rate__c,ERP7__Tax_Amount__c,ERP7__TDS_Account__c,ERP7__TDS_Amount__c, ERP7__TDS_Rate__c,ERP7__Description__c, ERP7__Item_Description__c,ERP7__Product__c,ERP7__Total_Amount__c,ERP7__Account_Category__c    FROM ERP7__Bill_Line_Item__c Where ERP7__Bill__c =:Id];
        //returnList.add(JSON.serialize(polist));
        /*for(ERP7__Purchase_Line_Items__c p:polist){
poliIds.add(p.Id);
}
Id RTID; RTID = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Advance_to_vendor').getRecordTypeId();        List<ERP7__Bill_Line_Item__c> BillItems=new List<ERP7__Bill_Line_Item__c>();
Map < Id, ERP7__Bill_Line_Item__c > Existing_billItems_Map = new Map < Id, ERP7__Bill_Line_Item__c > ();
for(ERP7__Bill_Line_Item__c billItem:[select id,Name,ERP7__Purchase_Order_Line_Items__c from ERP7__Bill_Line_Item__c where ERP7__Purchase_Order_Line_Items__c IN :poliIds AND RecordTypeId !=: RTID]){
Existing_billItems_Map.put(billItem.ERP7__Purchase_Order_Line_Items__c, billItem);
}*/
        for(ERP7__Bill_Line_Item__c p:polist){
            //ERP7__Bill_Line_Item__c bill=((Existing_billItems_Map.get(p.Id) != null) ? Existing_billItems_Map.get(p.Id) : null);
            updatedPoli.add(p);
        }
        returnList.add(JSON.serialize(updatedPoli));
        return returnList;
    }

    @AuraEnabled
    public static List<ERP7__Bill__c> fetchAdvBill(String POId,String venId){
        Id RTID; RTID = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get('Advance_to_vendor').getRecordTypeId();
        List<ERP7__Bill__c> billList=new List<ERP7__Bill__c>();
        billList=[SELECT Id, Name, ERP7__Amount__c  , ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName from ERP7__Bill__c where ERP7__Purchase_Order__c =:POId AND ERP7__Vendor__c =:venId AND RecordTypeId =: RTID];
        return billList;
    }

    @AuraEnabled
    public static List<String> getpicklist(String sObject_Type, String Field){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObject_Type).getDescribe().fields.getMap().get(Field).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel());
        return options;
    }

    @AuraEnabled
    public static CreateBillFlsWrap CreateBillCheckFLS(){
        CreateBillFlsWrap flsWRAP = new CreateBillFlsWrap();
        if (Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__Other_Tax__c.isAccessible() && Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__Other_Tax_Rate__c.isAccessible()){ flsWRAP.OtherTaxAccess = true; }
        if (Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__TDS_Rate__c.isAccessible() && Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__TDS_Amount__c.isAccessible() && Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__TDS_Account__c.isAccessible()){ flsWRAP.TDSAccess= true; }
        if (Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__Discount__c.isAccessible() && Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__Discount__c.isAccessible() && Schema.sObjectType.ERP7__Bill_Line_Item__c.fields.ERP7__Discount__c.isAccessible()){ flsWRAP.DiscountAccess= true; }
        return flsWRAP;
    }

    @AuraEnabled
    public static void deleteLineItem(String billItem){
        try{
            ERP7__Bill_Line_Item__c bill = (ERP7__Bill_Line_Item__c)JSON.deserialize(billItem, ERP7__Bill_Line_Item__c.class);
            if(bill!=null && Schema.sObjectType.ERP7__Bill_Line_Item__c.isDeletable()) {
                PreventRecursiveLedgerEntry.testCasesTransactions = true;
                if(ERP7__Bill_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete bill;
            }
        }catch(Exception e){
            //'Exception'+e+e.getLineNumber());

        }
    }

    @AuraEnabled
    public static String uploadFileLWC(String fileName, String base64Data, String recordId) {
        // Decoding the base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion(); cv.Title = fileName; cv.PathOnClient = '/' + fileName; cv.FirstPublishLocationId = recordId; cv.VersionData = EncodingUtil.base64Decode(base64Data); cv.IsMajorVersion = true;
        system.debug('cv--->'+cv);
        Insert cv; return 'File upload successfully!';
    }

    @AuraEnabled
    public static Account getVendorDetaillwc(string recordId){
        try{
            if(String.isNotEmpty(recordId)) return [SELECT Id,Name,ERP7__Payment_Terms__c,ERP7__Organisation__c,ERP7__Organisation__r.Name FROM Account WHERE Id =:recordId limit 1];  return null;
        }catch(Exception e){ throw new AuraHandledException('Exception~>'+e.getMessage()+' at line~>'+e.getStackTraceString()); }
    }


    @AuraEnabled
    public static multiCurrencyWrap getCurrencies(){
        multiCurrencyWrap mc = new multiCurrencyWrap();
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        mc.isMulticurrency = IsmultiCurrencyEnabled;
        if(IsmultiCurrencyEnabled){
            List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType');
            options.add(new SelectOptions(String.valueof(UserInfo.getDefaultCurrency()),String.valueof(UserInfo.getDefaultCurrency())));
            for(sObject a : currencies){
                if(UserInfo.getDefaultCurrency()!=a.get('IsoCode')) options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode'))));
            }
            mc.currencyList = options;
            String orgCurr = UserInfo.getDefaultCurrency();
            System.debug(orgCurr);
            mc.usercurrency = orgCurr;

        }
        return mc;
    }

    public class multiCurrencyWrap{
        @AuraEnabled
        public Boolean isMulticurrency {get;set;}
        @AuraEnabled
        public String  usercurrency   {get;set;}
        @AuraEnabled
        public List<selectOptions> currencyList {get;set;}
        public multiCurrencyWrap(){
            isMulticurrency = false;
            currencyList = new List<selectOptions>();
            usercurrency = '--None--';
        }
    }

    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        public selectOptions(String lab, string val) {
            label = lab; value = val;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }

    @AuraEnabled
    public static String getPOCurrencies(String PoId){
        String POIsocode = '';
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');

        if(IsmultiCurrencyEnabled){
            List <ERP7__PO__c> pos = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM ERP7__PO__c where Id =:PoId limit 1');
            if(pos.size() > 0) POIsocode = String.valueOf(pos[0].get('CurrencyIsoCode'));
            else POIsocode = '';
        }
        return POIsocode;
    }

    @AuraEnabled
    public static String getBillCurrencies(String BillId){
        String POIsocode = '';
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');

        if(IsmultiCurrencyEnabled){
            List <ERP7__Bill__c> bills = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM ERP7__Bill__c where Id =:BillId limit 1');
            if(bills.size() > 0) POIsocode = String.valueOf(bills[0].get('CurrencyIsoCode'));
            else POIsocode = '';
        }
        return POIsocode;
    }


    @AuraEnabled
    public static String getOrgCurrencies(String OrgId){
        String OrgIsocode = '';
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');

        if(IsmultiCurrencyEnabled){
            List <Account> accounts = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM Account where Id = :OrgId limit 1');
            if(accounts.size() > 0) OrgIsocode = String.valueOf(accounts[0].get('CurrencyIsoCode'));
            else OrgIsocode = '';
        }
        return OrgIsocode;
    }


    @AuraEnabled
    public static List<String> fetch_Polis_Multi(List<String> Ids){
        List<String> returnList = new List<String>();
        List<Decimal> billingQunaity = new List<Decimal>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Purchase_Line_Items__c> updatedPoli=new List<ERP7__Purchase_Line_Items__c>();
        ERP7__PO__c po = [SELECT Id,Name, ERP7__Organisation_Business_Unit__c, ERP7__Vendor__c , ERP7__Sales_Order__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name, ERP7__Description__c  FROM ERP7__PO__c WHERE Id =: Ids[0]];
        returnList.add(JSON.serialize(po));

        List<ERP7__Purchase_Line_Items__c> polist =  [SELECT Id,ERP7__Quantity_Received__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Product__r.ERP7__Inventory_Account__r.Name, ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Description__c, ERP7__Product__r.Id,
                                                      ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Purchase_Orders__c, ERP7__Special_Instruction__c, ERP7__Tax__c, ERP7__Tax_Rate__c  FROM ERP7__Purchase_Line_Items__c Where ERP7__Purchase_Orders__c IN :Ids];
        system.debug('polist-->'+polist.size());
        //returnList.add(JSON.serialize(polist));
        for(ERP7__Purchase_Line_Items__c p:polist){
            poliIds.add(p.Id);
        }
        Id RTID; RTID = Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Advance_to_vendor').getRecordTypeId();
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
            if(billItemsList==null) { updatedPoli.add(p); billingQunaity.add(p.ERP7__Quantity__c); }
            else{
                Decimal BillQuantity = 0;
                for(ERP7__Bill_Line_Item__c bi : billItemsList){
                    if(bi.ERP7__Quantity__c != null){
                        BillQuantity = BillQuantity + bi.ERP7__Quantity__c;
                    }
                }
                if(BillQuantity != p.ERP7__Quantity__c && p.ERP7__Quantity__c>BillQuantity){// && p.ERP7__Quantity__c>BillQuantity added this on 03rd july 2023
                    updatedPoli.add(p);
                    billingQunaity.add(p.ERP7__Quantity__c - BillQuantity);
                    system.debug('billingQunaity::'+(p.ERP7__Quantity__c - BillQuantity) );
                }
            }
        }
        system.debug('updatedPoli-->'+updatedPoli.size());
        returnList.add(JSON.serialize(updatedPoli));
        returnList.add(JSON.serialize(billingQunaity));
        List<ERP7__PO__c> poList1 = [SELECT Id,Name, ERP7__Vendor__c , ERP7__Sales_Order__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Organisation__r.Name, ERP7__Description__c  FROM ERP7__PO__c WHERE Id IN :Ids];
        returnList.add(JSON.serialize(poList1));
        return returnList;
    }

    @AuraEnabled
    public static List<ERP7__Dimension__c> getPOLIDimeMultiList(List<String> POIds){
        try{
            List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
            if(POIds!=null){
              //  demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c,ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c,ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c IN :POIds];

            if (Test.isRunningTest()) {

            } else {
            demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c,ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c,ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c IN :POIds];

            }
            }
            return demList;
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
    }

    @AuraEnabled
    public static BillandItemsWrap getBillDetailAndItems(String recId){
        BillandItemsWrap billWrap = new BillandItemsWrap();
        try{

            if(recId != null && recId != ''){
                boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
                String query ='Select Id,ERP7__Project__c,Name,ERP7__Amount__c,ERP7__Vendor_Bill_Number__c,ERP7__Purchase_Order__c,ERP7__Vendor__c, ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Id,ERP7__Vendor_Bill_Date__c, ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Name, ERP7__Vendor_Address__c,ERP7__Vendor_Address__r.Name,ERP7__Due_Date__c,ERP7__Description__c,ERP7__Organisation__c,ERP7__Discount_Amount__c,ERP7__VAT_TAX_Amount__c,ERP7__TDS_Amount__c,RecordTypeId,RecordType.Name';
                if(IsmultiCurrencyEnabled) query += ',CurrencyIsoCode ';
                query += ' from ERP7__Bill__c where Id=:recId Limit 1 ';
                ERP7__Bill__c bill = Database.query(query);
                billWrap.bill = bill;
                billWrap.billItems = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.ProductCode,ERP7__Vendor_Part_Number__c,ERP7__Product__r.Name,ERP7__Chart_Of_Account__c,ERP7__Chart_Of_Account__r.Name,ERP7__Quantity__c,ERP7__Amount__c,ERP7__Discount__c,ERP7__Total_Amount__c,ERP7__Tax_Rate__c,ERP7__Tax_Amount__c,ERP7__Other_Tax_Rate__c,ERP7__TDS_Rate__c,ERP7__TDS_Account__c,ERP7__Description__c,ERP7__Account_Category__c from ERP7__Bill_Line_Item__c where ERP7__Bill__c =:recId];
                set<Id> billItemIds = new set<Id>();
                for(ERP7__Bill_Line_Item__c billItems : billWrap.billItems){
                    billItemIds.add(billItems.Id);
                }
                billWrap.dimens = [Select Id,Name,ERP7__Allocation_Percentage__c,ERP7__Bill_Line_Item__c,ERP7__Allocation_Amount__c,ERP7__Project__c,ERP7__Project__r.Name,ERP7__Sort_Order__c from ERP7__Dimension__c where ERP7__Bill_Line_Item__c IN: billItemIds and ERP7__Debit_Note_Item__c = null];//Moin added this 14th july and ERP7__Debit_Note_Item__c = null
                billWrap.attachments = [Select Id,Name from Attachment where ParentId =:recId ];
            }
            else return null;
        }
        catch(Exception e){
            String error = 'Error  : '+e.getMessage()+' Line Number : '+e.getLineNumber();
            System.debug('Error  : '+e.getMessage()+' Line Number : '+e.getLineNumber());
            billWrap.eror = error;
        }
        return billWrap;

    }

    @AuraEnabled
    public static List<String> fetch_Polis_bill(List<String> poId, String BillId){
        system.debug('poId-->'+poId);
        List<String> returnList = new List<String>();
        if(poId!=null){
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Purchase_Line_Items__c> updatedPoli=new List<ERP7__Purchase_Line_Items__c>();
        List<ERP7__PO__c> po = [SELECT Id,Name, ERP7__Vendor__c , ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Total_Due__c, toLabel(ERP7__Stage__c)  FROM ERP7__PO__c WHERE Id IN :poId];
        returnList.add(JSON.serialize(po[0]));

        List<ERP7__Purchase_Line_Items__c> polist =  [SELECT Id,ERP7__Quantity_Received__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Product__r.Id, ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Purchase_Orders__c, ERP7__Special_Instruction__c,ERP7__Tax__c  FROM ERP7__Purchase_Line_Items__c Where ERP7__Purchase_Orders__c IN :poId];
        //returnList.add(JSON.serialize(polist));
        for(ERP7__Purchase_Line_Items__c p:polist) poliIds.add(p.Id);

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
            if(billItemsList==null) updatedPoli.add(p);
            else{
                Decimal BillQuantity = 0;
                for(ERP7__Bill_Line_Item__c bi : billItemsList){
                    if(bi.ERP7__Quantity__c != null){
                        BillQuantity = BillQuantity + bi.ERP7__Quantity__c;
                    }
                }
                if(BillQuantity != p.ERP7__Quantity__c){
                    updatedPoli.add(p);
                }
            }
        }
        returnList.add(JSON.serialize(updatedPoli));
        return returnList;
        }else{
            return returnList;
        }
    }

    // @AuraEnabled
    // public static List<Attachment> DeleteAttachment(String attachId,String parentId){ try{ List<Attachment> Attachments = new List<Attachment>(); Attachment attach2del = new Attachment(); if(String.isNotEmpty(attachId)){ attach2del = [Select Id, Name, ParentId from Attachment where Id =: attachId AND ParentId != null]; if(attach2del.Id != null){ delete attach2del; } } if(String.isNotEmpty(parentId)) Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parentId Order By CreatedDate ASC]; return Attachments; } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }


   @AuraEnabled
public static void DeleteAttachment(String parentId) {
    System.debug('DeleteAttachment called | parentId=' + parentId);
    try {
        // 1️⃣ Delete classic Attachments
        List<Attachment> atts = [
            SELECT Id 
            FROM Attachment 
            WHERE ParentId = :parentId
        ];
        System.debug('Found ' + atts.size() + ' attachments for this record.');
        if (!atts.isEmpty()) {
            delete atts;
            System.debug('Deleted ' + atts.size() + ' attachments.');
        } else {
            System.debug('No attachments found for this record.');
        }

        // 2️⃣ Delete Salesforce Files (ContentDocuments)
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentId
        ];
        System.debug('Found ' + links.size() + ' files linked to this record.');

        if (!links.isEmpty()) {
            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink l : links) {
                docIds.add(l.ContentDocumentId);
            }

            delete [SELECT Id FROM ContentDocument WHERE Id IN :docIds];
            System.debug('Deleted ' + docIds.size() + ' ContentDocuments.');
        } else {
            System.debug('No files found for this record.');
        }

    } catch (Exception e) {
        System.debug('Error in DeleteAttachment: ' + e.getMessage());
        throw new AuraHandledException('Error deleting files: ' + e.getMessage());
    }
}


@AuraEnabled(cacheable=true)
public static Map<String, List<Map<String, String>>> getAllDocs(Id parentId) {
    System.debug('Fetching all Attachments & Files for record: ' + parentId);

    // -------------------- Attachments --------------------
    List<Map<String, String>> atts = new List<Map<String, String>>();
    for (Attachment a : [
        SELECT Id, Name, ContentType, BodyLength, CreatedDate
        FROM Attachment
        WHERE ParentId = :parentId
        ORDER BY CreatedDate DESC
    ]) {
        atts.add(new Map<String, String>{
            'type' => 'Attachment',
            'Id' => String.valueOf(a.Id),
            'Name' => a.Name,
            'ContentType' => a.ContentType,
            'Size' => String.valueOf(a.BodyLength),
            'CreatedDate' => String.valueOf(a.CreatedDate)
        });
    }

    // -------------------- Files (ContentDocuments) --------------------
    // Step 1: get the related ContentDocumentLink records
    List<ContentDocumentLink> links = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :parentId
    ];

    Set<Id> docIds = new Set<Id>();
    for (ContentDocumentLink l : links) {
        docIds.add(l.ContentDocumentId);
    }

    // Step 2: query the ContentDocuments if any found
    List<Map<String, String>> files = new List<Map<String, String>>();
    if (!docIds.isEmpty()) {
        for (ContentDocument d : [
            SELECT Id, Title, FileExtension, LatestPublishedVersionId, CreatedDate
            FROM ContentDocument
            WHERE Id IN :docIds
            ORDER BY CreatedDate DESC
        ]) {
            files.add(new Map<String, String>{
                'type' => 'File',
                'Id' => String.valueOf(d.Id),
                'Title' => d.Title,
                'FileExtension' => d.FileExtension,
                'LatestPublishedVersionId' => String.valueOf(d.LatestPublishedVersionId),
                'CreatedDate' => String.valueOf(d.CreatedDate)
            });
        }
    }

    // -------------------- Return combined map --------------------
    return new Map<String, List<Map<String, String>>>{
        'attachments' => atts,
        'files' => files
    };
}


    public class BillandItemsWrap{
        @AuraEnabled public  ERP7__Bill__c bill {get;set;}
        @AuraEnabled public  List<ERP7__Bill_Line_Item__c> billItems {get;set;}
        @AuraEnabled public  List<ERP7__Dimension__c> dimens {get;set;}
        @AuraEnabled public  List<Attachment> attachments {get;set;}
        @AuraEnabled public  String eror {get;set;}
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

     // For the OCR part
 /*
 @AuraEnabled(cacheable=true)
    public static Map<String, String> getProductIdsByNames(List<String> productNames) {
        Map<String, String> productMap = new Map<String, String>();

        // Query for products by name from the Purchase Line Items object
        List<ERP7__Purchase_Line_Items__c> productList = [
            SELECT Id, ERP7__Product__c, ERP7__Product__r.Name
            FROM ERP7__Purchase_Line_Items__c
            WHERE ERP7__Product__r.Name IN :productNames
        ];

        // Populate the map with product names as keys and product IDs as values
        for (ERP7__Purchase_Line_Items__c product : productList) {
            if (product.ERP7__Product__r != null && product.ERP7__Product__r.Name != null) {
                productMap.put(product.ERP7__Product__r.Name, product.ERP7__Product__c);
            }
        }

        return productMap;
    }  */
   /*  @AuraEnabled(cacheable=true)
    public static List<Product2> getProductIdsByNames(List<String> productNames) {
	System.debug('Names: ' + productNames);
        List<Product2> productList = new List<Product2>();
        Map<String, String> productMap = new Map<String, String>();

        if (productNames == null || productNames.isEmpty()) {
            return productList;
        }

        // Query for products by name from the Purchase Line Items object

        productList = [
            SELECT Id, Name
            FROM Product2
            WHERE Name IN :productNames
        ];
        return productList;
		
        // Populate the map with product names as keys and product IDs as values
        for (Product2 product : productList) {
            //if (product.ERP7__Product__r != null && product.ERP7__Product__r.Name != null) {
                productMap.put(product.Name, product.Id);
            //}
        }

        // Log missing product names for debugging
        Set<String> foundProductNames = new Set<String>(productMap.keySet());
        Set<String> missingProductNames = new Set<String>(productNames);
        missingProductNames.removeAll(foundProductNames);
        if (!missingProductNames.isEmpty()) {
            System.debug('Missing Product Names: ' + missingProductNames);
        }

        return productMap;/
    }*/


    

// @AuraEnabled
// public static String extractLineItemsFromText(String invoiceText) {
//     System.debug('Received Invoice Text: ' + invoiceText);

//     String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCFPBpFeWoVw3Rc4OZCbPJZbPqGSP0hKYw';   // AIzaSyAlbn-4uxqx4f2WIJiFAmucKta54cIhd38             //AIzaSyB9wA3lQNhEu0fb4rlnSz6-OJETAtBLrBs  

//     // // Strict JSON request payload
//     // String requestPayload = '{"contents": [{"parts": [{"text": "Extract the line items from the following invoice in this format:\\n\\nProduct Name\\nQuantity\\nUnit Price\\nPO Number (if available, else blank)\\n\\nRules:\\n1. Ignore all currency symbols like ₹, $, etc.\\n2. Normalize product names and PO numbers by trimming spaces and collapsing multiple spaces into one.\\n3. Only provide the items in the specified structure, with plain text and numbers. Do not include explanations or extra information.\\n\\nHere is the invoice text:\\n\\n'
//     //     + invoiceText.replaceAll('"', '\\"') + '"}]}]}';


//     // Balanced JSON request payload
// String requestPayload = '{"contents":[{"parts":[{"text":"Extract line items in this format:\\n\\n' +
//     'Product Name\\nQuantity\\nUnit Price\\nPO Number (if available, else blank)\\n\\n' +
//     'Rules:\\n- Ignore currency symbols.\\n- Trim and normalize names/POs.\\n- Only plain text, no extra info,not even the hearders.\\n\\n' +
//     'Invoice:\\n\\n' + invoiceText.replaceAll('"','\\"') + '"}]}]}';

//     System.debug('Request Payload: ' + requestPayload);

//     HttpRequest req = new HttpRequest();
//     req.setEndpoint(apiUrl);
//     req.setMethod('POST');
//     req.setHeader('Content-Type', 'application/json');
//     req.setTimeout(120000);
//     req.setBody(requestPayload);

//     Http http = new Http();
//     HttpResponse res = http.send(req);

//     if (res.getStatusCode() == 200) {
//         System.debug('✅ API Raw Response: ' + res.getBody());

//         // Parse Gemini JSON → extract only text
//         String body = res.getBody();
//         String extractedText = '';

//         try {
//             Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(body);
//             if (result.containsKey('candidates')) {
//                 List<Object> candidates = (List<Object>) result.get('candidates');
//                 if (!candidates.isEmpty()) {
//                     Map<String, Object> firstCandidate = (Map<String, Object>) candidates.get(0);
//                     if (firstCandidate.containsKey('content')) {
//                         Map<String, Object> content = (Map<String, Object>) firstCandidate.get('content');
//                         if (content.containsKey('parts')) {
//                             List<Object> parts = (List<Object>) content.get('parts');
//                             if (!parts.isEmpty()) {
//                                 Map<String, Object> firstPart = (Map<String, Object>) parts.get(0);
//                                 if (firstPart.containsKey('text')) {
//                                     extractedText = (String) firstPart.get('text');
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         } catch (Exception e) {
//             System.debug('⚠️ Error parsing Gemini response: ' + e.getMessage());
//         }

//         System.debug('📄 Extracted Text: ' + extractedText);
//         return extractedText;
//     } else {
//         System.debug('❌ API request failed: ' + res.getStatusCode() + ' ' + res.getBody());
//         return 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
//     }
// }


    
    @AuraEnabled
    public static Boolean getReadBillOCRState() {
        User user = [SELECT Id, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
        ERP7__Functionality_Control__c customList = ERP7__Functionality_Control__c.getValues(user.Id);
    
        if (customList == null) {
            customList = ERP7__Functionality_Control__c.getValues(user.ProfileId);
            if (customList == null) customList = ERP7__Functionality_Control__c.getInstance();
        }
    
        return customList != null && customList.ERP7__Read_Bill_OCR__c;
    }
    

    
     @AuraEnabled
    public static String extractLineItemsFromText(String invoiceText) {
        System.debug('🧾 [START] Received Invoice Text: ' + invoiceText);

        Credentials__c cred;
        try {
            cred = [
                SELECT ERP7__Encrypted_Key__c,
                       ERP7__End_Point__c,
                       URL__c,
                       ERP7__Active__c,
                       Name
                FROM Credentials__c
                WHERE Type__c = 'OCR' AND ERP7__Active__c = true AND Name = 'OCR'
                LIMIT 10
            ];
            System.debug(' [CRED] Fetched Credential: ' + cred.Name);
            System.debug(' [CRED] API Key (ERP7__Encrypted_Key__c): ' + cred.ERP7__Encrypted_Key__c);
            System.debug(' [CRED] Endpoint (ERP7__End_Point__c): ' + cred.ERP7__End_Point__c);
            System.debug(' [CRED] Fallback URL (URL__c): ' + cred.URL__c);
        } catch (Exception e) {
            System.debug(' [ERROR] Failed to fetch OCR credentials: ' + e.getMessage());
            return 'Error: Unable to fetch OCR credentials → ' + e.getMessage();
        }

        if (cred == null) {
            System.debug('️ [WARN] No active OCR credential found.');
            return 'Error: No active OCR credential found.';
        }

        if (String.isBlank(cred.ERP7__Encrypted_Key__c)) {
            System.debug('️ [WARN] OCR Credential is missing API Key (ERP7__Encrypted_Key__c).');
            return 'Error: OCR credential missing API Key.';
        }

        String baseUrl = String.isBlank(cred.ERP7__End_Point__c)
            ? cred.URL__c
            : cred.ERP7__End_Point__c;

        if (String.isBlank(baseUrl)) {
            System.debug('️ [WARN] OCR Credential is missing Endpoint/URL.');
            return 'Error: OCR credential missing Endpoint/URL.';
        }

        System.debug('🌍 [INFO] Base URL before formatting: ' + baseUrl);

        if (!baseUrl.contains('?key=')) {
            if (baseUrl.endsWith('?') || baseUrl.endsWith('&')) {
                baseUrl += 'key=';
            } else if (baseUrl.contains('?')) {
                baseUrl += '&key=';
            } else {
                baseUrl += '?key=';
            }
        }

        System.debug('🌍 [INFO] Final formatted Base URL: ' + baseUrl);

        String requestPayload = '{"contents":[{"parts":[{"text":"Extract line items in this format:\\n\\n' +
            'Product Name\\nQuantity\\nUnit Price\\nPO Number (if available, else return as No PO)\\n\\n' +
            'Rules:\\n- Ignore currency symbols.\\n- Trim and normalize names/POs.\\n- Only plain text, no extra info, not even the headers.\\n\\n' +
            'Invoice:\\n\\n' + invoiceText.replaceAll('"','\\"') + '"}]}]}';

        System.debug('🧱 [PAYLOAD] ' + requestPayload);

        String apiKey = cred.ERP7__Encrypted_Key__c;
        Http http = new Http();

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(baseUrl + apiKey);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setBody(requestPayload);

            System.debug('🚀 [REQUEST] Sending to Endpoint: ' + req.getEndpoint());
            System.debug('🚀 [REQUEST] Headers: ' + req.getHeader('Content-Type'));

            HttpResponse res = http.send(req);

            System.debug('📥 [RESPONSE] Status Code: ' + res.getStatusCode());
            System.debug('📥 [RESPONSE] Body: ' + res.getBody());

            if (res.getStatusCode() == 200) {
                System.debug(' [SUCCESS] OCR API call succeeded.');
                return parseGeminiResponse(res.getBody());
            } else {
                System.debug(' [FAILURE] OCR API call failed → Code: ' + res.getStatusCode());
                System.debug(' [FAILURE] Body: ' + res.getBody());
                return 'Error: ' + res.getStatusCode() + ' → ' + res.getBody();
            }
        } catch (Exception e) {
            System.debug(' [EXCEPTION] During HTTP callout: ' + e.getMessage());
            return 'Error calling OCR API: ' + e.getMessage();
        }
    }

    private static String parseGeminiResponse(String body) {
        String extractedText = '';
        System.debug('🔍 [PARSER] Parsing Gemini API Response...');
        try {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(body);
            if (result.containsKey('candidates')) {
                List<Object> candidates = (List<Object>) result.get('candidates');
                if (!candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = (Map<String, Object>) candidates.get(0);
                    if (firstCandidate.containsKey('content')) {
                        Map<String, Object> content = (Map<String, Object>) firstCandidate.get('content');
                        if (content.containsKey('parts')) {
                            List<Object> parts = (List<Object>) content.get('parts');
                            if (!parts.isEmpty()) {
                                Map<String, Object> firstPart = (Map<String, Object>) parts.get(0);
                                if (firstPart.containsKey('text')) {
                                    extractedText = (String) firstPart.get('text');
                                    System.debug('🧾 [PARSER] Extracted Text: ' + extractedText);
                                }
                            }
                        }
                    }
                }
            } else {
                System.debug(' [PARSER] No candidates found in response.');
            }
        } catch (Exception e) {
            System.debug(' [PARSER ERROR] ' + e.getMessage());
        }
        return extractedText;
    }
    
    @AuraEnabled
    public static String checkPOName(String poName) {
        System.debug('Checking PO Name for Name: ' + poName);

        if (poName == null) {
            System.debug('No PO Name provided');
            return null;
        }

          
        try {
            ERP7__PO__c po = [
                SELECT Id, Name
                FROM ERP7__PO__c
                WHERE Name = :poName
                LIMIT 1
            ];
            System.debug('Found PO Name: ' + po.Name);
            return po.Id;
        } catch (Exception e) {
            System.debug(' Exception while fetching PO: ' + e.getMessage());
            return null;
        }
    }



    public class ProductResult {
    @AuraEnabled public String keyName;     
    @AuraEnabled public String idValue;    
    @AuraEnabled public String textValue;   
    @AuraEnabled public String description; 


        
}

@AuraEnabled(cacheable=true)
public static List<ProductResult> getProductIdsByNames(Id poId, List<String> productNames) {
    String logPrefix = 'getProductIdsByNames | ';
    System.debug(LoggingLevel.DEBUG, logPrefix + 'START');
    System.debug(LoggingLevel.DEBUG, logPrefix + 'Input poId: ' + poId);
    System.debug(LoggingLevel.DEBUG, logPrefix + 'Input productNames count: ' + (productNames != null ? productNames.size() : 0));

System.debug('productName' + JSON.serialize(productNames));
    List<ProductResult> results = new List<ProductResult>();

    if (productNames == null || productNames.isEmpty() || poId == null) {
        System.debug(LoggingLevel.WARN, logPrefix + 'Invalid input. poId or productNames are null/empty. Returning empty list.');
        return results;
    }

    try {
        Map<String, ProductResult> productMap = new Map<String, ProductResult>();

        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 1: Querying Purchase_Line_Items__c for ' + productNames.size() + ' products.');
        List<ERP7__Purchase_Line_Items__c> poProducts = [
            SELECT Id, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Purchase_Orders__c,ERP7__Quantity__c
            FROM ERP7__Purchase_Line_Items__c
            WHERE ERP7__Purchase_Orders__c = :poId
            AND ERP7__Product__r.Name IN :productNames
        ];
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Found ' + poProducts.size() + ' matching products in PO Line Items.');

        for (ERP7__Purchase_Line_Items__c pli : poProducts) {
            if (pli.ERP7__Product__r != null && pli.ERP7__Product__r.Name != null) {
                ProductResult res = new ProductResult();
                res.keyName = pli.ERP7__Product__r.Name;
                res.idValue = pli.ERP7__Product__c; 
                res.textValue = null; 
                res.description = '';
                productMap.put(res.keyName, res);
            }
        }
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Processed ' + productMap.size() + ' products from PO Line Items.');


        List<String> unresolved = new List<String>();
        for (String name : productNames) {
            if (!productMap.containsKey(name)) {
                unresolved.add(name);
            }
        }
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 2: Found ' + unresolved.size() + ' unresolved product names.');


        if (!unresolved.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 3: Querying Product2 for ' + unresolved.size() + ' unresolved names.');
            List<Product2> stdProducts = [
                SELECT Id, Name
                FROM Product2
                WHERE Name IN :unresolved
            ];
            System.debug(LoggingLevel.DEBUG, logPrefix + 'Found ' + stdProducts.size() + ' matching products in Product2.');

            for (Product2 p : stdProducts) {
                ProductResult res = new ProductResult();
                res.keyName = p.Name;
                res.idValue = p.Id; 
                res.textValue = null;
                res.description = 'This Product is not listed in this Purchase Order';
                productMap.put(res.keyName, res);
            }
        } else {
            System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 3: Skipped Product2 query, no unresolved names.');
        }


        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 4: Processing any remaining names not found in the system.');
        Integer notFoundCount = 0;
        for (String name : productNames) {
            if (!productMap.containsKey(name)) {
                ProductResult res = new ProductResult();
                res.keyName = name;
                res.idValue = null; 
                res.textValue = name; 
                res.description = 'This Product is not listed in this Purchase Order or in the System. ';
                productMap.put(res.keyName, res);
                notFoundCount++;
            }
        }
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Identified ' + notFoundCount + ' products that were not found.');

        results.addAll(productMap.values());
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Final results count: ' + results.size());
        System.debug(LoggingLevel.DEBUG, logPrefix + 'END');
        return results;

    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, logPrefix + 'An error occurred: ' + e.getMessage() + '\n' + e.getStackTraceString());
        throw new AuraHandledException('An error occurred while fetching product IDs: ' + e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static List<ProductResult> getProductIdsByNamesForMultiPO(List<Id> poIds, List<String> productNames) {
    String logPrefix = 'getProductIdsByNamesForMultiPO | ';
    System.debug(LoggingLevel.DEBUG, logPrefix + 'START');
    System.debug(LoggingLevel.DEBUG, logPrefix + 'Input poIds: ' + JSON.serialize(poIds));
    System.debug(LoggingLevel.DEBUG, logPrefix + 'Input productNames: ' + JSON.serialize(productNames));

    List<ProductResult> results = new List<ProductResult>();

    if (productNames == null || productNames.isEmpty() || poIds == null || poIds.isEmpty()) {
        System.debug(LoggingLevel.WARN, logPrefix + 'Invalid input. poIds or productNames are null/empty. Returning empty list.');
        return results;
    }

    try {
        Map<String, ProductResult> productMap = new Map<String, ProductResult>();

        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 1: Querying PO Line Items...');
        List<ERP7__Purchase_Line_Items__c> poProducts = [
            SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Purchase_Orders__c, ERP7__Quantity__c
            FROM ERP7__Purchase_Line_Items__c
            WHERE ERP7__Purchase_Orders__c IN :poIds
            AND (
                ERP7__Product__r.Name IN :productNames
                OR Name IN :productNames
            )
        ];
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 1: Found ' + poProducts.size() + ' PO Line Items.');

        for (ERP7__Purchase_Line_Items__c pli : poProducts) {
            String keyName;

            if (pli.ERP7__Product__r != null && pli.ERP7__Product__r.Name != null) {
                keyName = pli.ERP7__Product__r.Name;
                ProductResult res = new ProductResult();
                res.keyName = keyName;
                res.idValue = pli.ERP7__Product__c;
                res.textValue = null;
                res.description = '';
                productMap.put(res.keyName, res);

                System.debug(LoggingLevel.DEBUG, logPrefix + ' Match by Product__r.Name → ' + keyName + ' (Id=' + res.idValue + ')');
            } else if (pli.Name != null) {
                keyName = pli.Name;
                ProductResult res = new ProductResult();
                res.keyName = keyName;
                res.idValue = pli.ERP7__Product__c; 
                res.textValue = null;
                res.description = '';
                productMap.put(res.keyName, res);

                System.debug(LoggingLevel.DEBUG, logPrefix + ' Match by Line Item Name → ' + keyName + ' (Id=' + (res.idValue != null ? res.idValue : 'N/A') + ')');
            }
        }

        List<String> unresolved = new List<String>();
        for (String name : productNames) {
            if (!productMap.containsKey(name)) {
                unresolved.add(name);
            }
        }
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 2: Unresolved count = ' + unresolved.size() + ' → ' + JSON.serialize(unresolved));

        if (!unresolved.isEmpty()) {
            List<Product2> stdProducts = [
                SELECT Id, Name
                FROM Product2
                WHERE Name IN :unresolved
            ];
            System.debug(LoggingLevel.DEBUG, logPrefix + 'Step 3: Found ' + stdProducts.size() + ' products in Product2.');

            for (Product2 p : stdProducts) {
                ProductResult res = new ProductResult();
                res.keyName = p.Name;
                res.idValue = p.Id;
                res.textValue = null;
                res.description = 'Not in given POs but exists in Product2.';
                productMap.put(res.keyName, res);

                System.debug(LoggingLevel.DEBUG, logPrefix + '️ Found in Product2 → ' + res.keyName + ' (Id=' + res.idValue + ')');
            }
        }

        // 🔹 Step 4: Still missing
        for (String name : productNames) {
            if (!productMap.containsKey(name)) {
                ProductResult res = new ProductResult();
                res.keyName = name;
                res.idValue = null;
                res.textValue = name;
                res.description = 'Not in PO or Product2.';
                productMap.put(res.keyName, res);

                System.debug(LoggingLevel.WARN, logPrefix + 'Not found anywhere → ' + name);
            }
        }

        results.addAll(productMap.values());
        System.debug(LoggingLevel.DEBUG, logPrefix + 'Final Results: ' + JSON.serialize(results));
        System.debug(LoggingLevel.DEBUG, logPrefix + 'END');
        return results;

    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, logPrefix + 'Exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        throw new AuraHandledException('Error fetching product IDs: ' + e.getMessage());
    }
}


@AuraEnabled
public static Map<String, String> getProductIdsByNamesNew(List<String> pname) {
    Map<String, String> nameIdMap = new Map<String, String>();

    if (pname != null && !pname.isEmpty()) {
        for (Product2 p : [
            SELECT Id, Name
            FROM Product2
            WHERE Name IN :pname
        ]) {
            nameIdMap.put(p.Name, p.Id);
        }
    }

    return nameIdMap;
}
    //from here Tolerance 
    @AuraEnabled
    public static String validateBillTolerance2(List<ERP7__Bill_Line_Item__c> billList, List<ERP7__Purchase_Line_Items__c> poLineList) {
        System.debug(' Inside!');
        if (billList == null || billList.isEmpty() || poLineList == null || poLineList.isEmpty()) {
            System.debug('return null');
            return null; // nothing to validate
        }
        
        ERP7__Module__c finance = [
            SELECT Run__c, ERP7__Run_Posting_Trigger__c,
            ERP7__Bill_Quantity_Tolerance__c, ERP7__Bill_Unit_Price_Tolerance__c
            FROM ERP7__Module__c
            WHERE Name = 'Finance' LIMIT 1
        ];
        
        Boolean enabled = finance.Run__c &&
            ( finance.ERP7__Run_Posting_Trigger__c ||
             finance.ERP7__Bill_Unit_Price_Tolerance__c > 0 ||
             finance.ERP7__Bill_Quantity_Tolerance__c > 0 );
        if (!enabled) return null;
        
        Decimal qtyLimit = finance.ERP7__Bill_Quantity_Tolerance__c;
        Decimal upLimit  = finance.ERP7__Bill_Unit_Price_Tolerance__c;
        
        Map<Id, ERP7__Purchase_Line_Items__c> poMap = new Map<Id, ERP7__Purchase_Line_Items__c>(poLineList);
        List<String> errors = new List<String>();
        
        for (ERP7__Bill_Line_Item__c b : billList) {
            if (b.ERP7__Purchase_Order_Line_Items__c == null) continue;
            ERP7__Purchase_Line_Items__c p = poMap.get(b.ERP7__Purchase_Order_Line_Items__c);
            if (p == null) continue;
            
            // Unit price tolerance
            if (b.ERP7__Amount__c != null && p.ERP7__Unit_Price__c != null) {
                if (p.ERP7__Unit_Price__c == 0 && b.ERP7__Amount__c != 0) {
                    errors.add(b.Name + ': PO unit price is 0 but bill unit price is non-zero.');
                    System.debug(b.Name + ': PO unit price is 0 but bill unit price is non-zero.');
                } else if (p.ERP7__Unit_Price__c != 0) {
                    Decimal diff = (b.ERP7__Amount__c - p.ERP7__Unit_Price__c).abs();
                    Decimal variance = ((diff / p.ERP7__Unit_Price__c) * 100).setScale(2);
                    if (variance > upLimit) {
                        errors.add(b.Name + ': Unit price variance exceeds limit (' + variance + '% > ' + upLimit + '%).');
                        System.debug(b.Name +': Unit price variance exceeds limit (' + variance + '% > ' + upLimit + '%).');
                    }
                }
            }
            
            // Quantity (only when bill > PO)
            if (b.ERP7__Quantity__c != null && p.ERP7__Quantity__c != null && b.ERP7__Quantity__c > p.ERP7__Quantity__c) {
                errors.add(b.Name + ': Bill quantity exceeds PO quantity.');
                 System.debug(b.Name + ': PO unit price is 0 but bill unit price is non-zero.');
            }
            
            // Tax tolerance
            if (b.ERP7__Tax_Rate__c != null && p.ERP7__Tax_Rate__c != null) {
                if (p.ERP7__Tax_Rate__c == 0 && b.ERP7__Tax_Rate__c != 0) {
                    errors.add(b.Name + ': PO tax rate is 0 but bill tax rate is non-zero.');
                    System.debug(b.Name + ': PO tax rate is 0 but bill tax rate is non-zero.');
                } else if (p.ERP7__Tax_Rate__c != 0) {
                    Decimal diff = (b.ERP7__Tax_Rate__c - p.ERP7__Tax_Rate__c).abs();
                    Decimal variance = ((diff / p.ERP7__Tax_Rate__c) * 100).setScale(2);
                    if (variance > qtyLimit) {
                        errors.add(b.Name + ': Tax variance exceeds limit (' + variance + '% > ' + qtyLimit + '%).');
                        System.debug(b.Name + ': Tax variance exceeds limit (' + variance + '% > ' + qtyLimit + '%).');
                    }
                }
            }
        }
        System.debug(' Finish!');
        return errors.isEmpty() ? null : String.join(errors, '\n');
    }
    
    @AuraEnabled
    public static String validateBillToleranceJson(String billItemsJson, String poliItemsJson) {
        if (String.isBlank(billItemsJson))  return 'No bill lines provided for tolerance check.';
        
        // --- Parse bills (untyped -> tolerant to strings and extra keys)
        List<Object> billUntyped = (List<Object>) JSON.deserializeUntyped(billItemsJson);
        if (billUntyped == null || billUntyped.isEmpty()) return 'No bill lines provided for tolerance check.';
        
        // Coerce bills and collect helpful ids
        List<ERP7__Bill_Line_Item__c> bills = new List<ERP7__Bill_Line_Item__c>();
        Set<Id> billIdsToQuery = new Set<Id>();
        Set<Id> poliIdsFromBillJson = new Set<Id>();
        
        for (Object row : billUntyped) {
            Map<String,Object> m = (Map<String,Object>)row;
            ERP7__Bill_Line_Item__c b = coerceBill(m);
            bills.add(b);
            if (b.Id != null) billIdsToQuery.add(b.Id);
            // If bill JSON already has the POLI Id, collect it
            Object poliRef = m.get('ERP7__Purchase_Order_Line_Items__c');
            if (poliRef != null) {
                String s = String.valueOf(poliRef);
                if (!String.isBlank(s)) {
                    try { poliIdsFromBillJson.add((Id)s); } catch (Exception e) { /* ignore bad ids */ }
                }
            }
        }
        
        // Build POLIs
        List<ERP7__Purchase_Line_Items__c> polis = new List<ERP7__Purchase_Line_Items__c>();
        
       // if (!String.isBlank(poliItemsJson)) {
            // -------- Scenario 1: client provided POLIs JSON → just use it (no queries by bill ids)
          //  List<Object> poliUntyped = (List<Object>) JSON.deserializeUntyped(poliItemsJson);
          //  for (Object row : poliUntyped) polis.add(coercePoli((Map<String,Object>)row));
            
       // } else {
            // -------- Scenario 2: POLIs JSON empty → resolve from bills
            
            // 2a) Prefer querying POLIs directly if their Ids are present in the bill JSON
            if (!poliIdsFromBillJson.isEmpty()) {
                polis = [
                    SELECT Id, Name, ERP7__Product__c, ERP7__Quantity__c, ERP7__Unit_Price__c,
                    ERP7__Tax_Rate__c, ERP7__Tax__c
                    FROM ERP7__Purchase_Line_Items__c
                    WHERE Id IN :poliIdsFromBillJson
                ];
                // Normalize tax into Tax_Rate__c if org uses ERP7__Tax__c
                for (ERP7__Purchase_Line_Items__c p : polis) {
                    if (p.get('ERP7__Tax_Rate__c') != null ) {
                        p.put('ERP7__Tax_Rate__c', (Decimal)p.get('ERP7__Tax_Rate__c'));
                    }
                }
                
                // 2b) Else, if bills have Ids, query Bills and traverse relationship
            } 
            else if (!billIdsToQuery.isEmpty()) {
                List<ERP7__Bill_Line_Item__c> queriedBills = [
                    SELECT Id, Name,
                    ERP7__Quantity__c, ERP7__Amount__c, ERP7__Tax_Rate__c,
                    ERP7__Purchase_Order_Line_Items__c,
                    ERP7__Purchase_Order_Line_Items__r.Id,
                    ERP7__Purchase_Order_Line_Items__r.Name,
                    ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c,
                    ERP7__Purchase_Order_Line_Items__r.ERP7__Unit_Price__c,
                    ERP7__Purchase_Order_Line_Items__r.ERP7__Tax_Rate__c,
                    ERP7__Purchase_Order_Line_Items__r.ERP7__Tax__c
                    FROM ERP7__Bill_Line_Item__c
                    WHERE Id IN :billIdsToQuery
                ]; 
                
                Map<Id, ERP7__Bill_Line_Item__c> qBillById = new Map<Id, ERP7__Bill_Line_Item__c>(queriedBills);
                Map<Id, ERP7__Purchase_Line_Items__c> poliById = new Map<Id, ERP7__Purchase_Line_Items__c>();
                
                for (ERP7__Bill_Line_Item__c qb : queriedBills) {
                    Id poliId = qb.ERP7__Purchase_Order_Line_Items__c;
                    if (poliId != null && !poliById.containsKey(poliId)) {
                        ERP7__Purchase_Line_Items__c p = new ERP7__Purchase_Line_Items__c(
                            Id = poliId,
                            Name = qb.ERP7__Purchase_Order_Line_Items__r != null ? qb.ERP7__Purchase_Order_Line_Items__r.Name : null,
                            ERP7__Quantity__c = qb.ERP7__Purchase_Order_Line_Items__r != null ? qb.ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c : null,
                            ERP7__Unit_Price__c = qb.ERP7__Purchase_Order_Line_Items__r != null ? qb.ERP7__Purchase_Order_Line_Items__r.ERP7__Unit_Price__c : null
                        );
                        Decimal taxRate = (qb.ERP7__Purchase_Order_Line_Items__r != null)
                            ? qb.ERP7__Purchase_Order_Line_Items__r.ERP7__Tax_Rate__c
                            : null;

                        if (taxRate != null) p.put('ERP7__Tax_Rate__c', taxRate);
                        poliById.put(poliId, p);
                    }
                }
                polis.addAll(poliById.values());
                
                // Optionally fill missing bill fields from queried bills (if JSON lacked them)
                for (ERP7__Bill_Line_Item__c b : bills) {
                    if (b.Id != null && qBillById.containsKey(b.Id)) {
                        ERP7__Bill_Line_Item__c qb = qBillById.get(b.Id);
                        if (b.ERP7__Purchase_Order_Line_Items__c == null)
                            b.ERP7__Purchase_Order_Line_Items__c = qb.ERP7__Purchase_Order_Line_Items__c;
                        if (b.ERP7__Quantity__c == null)
                            b.ERP7__Quantity__c = qb.ERP7__Quantity__c;
                        if ((Decimal)b.get('ERP7__Amount__c') == null)
                            b.put('ERP7__Amount__c', qb.ERP7__Amount__c);
                        if (b.ERP7__Tax_Rate__c == null)
                            b.ERP7__Tax_Rate__c = qb.ERP7__Tax_Rate__c;
                    }
                }
                
                // 2c) Neither POLI JSON nor resolvable ids → clear message
            } else {
                return 'No PO line items provided and cannot resolve from bill lines (no POLI references or Bill Ids).';
            }
        //}
        
        // Run your existing core validator
        return validateBillTolerance(bills, polis);
    }

    
    // --------- Coercion helpers (handle "11" vs 11 safely) ----------
    private static Decimal toDec(Object v) {
        if (v == null) return null;
        if (v instanceof Decimal) return (Decimal)v;
        if (v instanceof Integer) return Decimal.valueOf((Integer)v);
        if (v instanceof Long)    return Decimal.valueOf((Long)v);
        if (v instanceof Double)  return Decimal.valueOf((Double)v);
        if (v instanceof String)  return ((String)v).trim() == '' ? null : Decimal.valueOf((String)v);
        return null;
    }
    //private static Id toId(Object v){ return (v == null) ? null : (Id) (String) v; }
    private static Id toId(Object v){
    if (v == null) return null;
    String s = String.valueOf(v).trim();
    if (String.isBlank(s)) return null;
    // Only accept 15- or 18-char Salesforce Ids; ignore anything else
    if (s.length() != 15 && s.length() != 18) return null;
    try {
        return (Id)s;
    } catch (Exception e) {
        return null; // swallow bad Ids instead of throwing FATAL_ERROR
    }
}

    private static String toStr(Object v){ return (v == null) ? null : String.valueOf(v); }
    
    private static ERP7__Bill_Line_Item__c coerceBill(Map<String,Object> m){
        ERP7__Bill_Line_Item__c b = new ERP7__Bill_Line_Item__c();
        // optional Id (may be null for new rows)
        b.Id = toId(m.get('Id'));
        b.Name = toStr(m.get('Name'));
        
        b.ERP7__Product__c                   = toId(m.get('ERP7__Product__c'));
        b.ERP7__Purchase_Order_Line_Items__c = toId(m.get('ERP7__Purchase_Order_Line_Items__c'));
        
        // numbers (could be strings in your JSON)
        b.ERP7__Quantity__c  = toDec(m.get('ERP7__Quantity__c'));
        // UI may send unit price as Amount__c
        b.ERP7__Amount__c    = toDec(m.get('ERP7__Amount__c'));
        // if you also sometimes send ERP7__Unit_Price__c, capture that too:
        if (b.get('ERP7__Amount__c') == null && m.containsKey('ERP7__Unit_Price__c')) {
            b.put('ERP7__Amount__c', toDec(m.get('ERP7__Unit_Price__c')));
        }
        
        b.ERP7__Tax_Rate__c  = toDec(m.get('ERP7__Tax_Rate__c'));
        // ignore Accounts / extra nested props
        return b;
    }
    
    private static ERP7__Purchase_Line_Items__c coercePoli(Map<String,Object> m){
        ERP7__Purchase_Line_Items__c p = new ERP7__Purchase_Line_Items__c();
        p.Id = toId(m.get('Id'));
        p.Name = toStr(m.get('Name'));
        
        p.ERP7__Product__c  = toId(m.get('ERP7__Product__c'));
        p.ERP7__Quantity__c = toDec(m.get('ERP7__Quantity__c'));
        p.ERP7__Unit_Price__c = toDec(m.get('ERP7__Unit_Price__c'));
        
        // tax field in your POLI payload is ERP7__Tax__c (not Tax_Rate__c)
       /* if (m.containsKey('ERP7__Tax_Rate__c')) {
            p.put('ERP7__Tax_Rate__c', toDec(m.get('ERP7__Tax_Rate__c')));
        } else if (m.containsKey('ERP7__Tax__c')) {
            p.put('ERP7__Tax_Rate__c', toDec(m.get('ERP7__Tax__c')));
        }*/
        Decimal rate = toDec(m.get('ERP7__Tax_Rate__c'));
        if (rate != null) p.put('ERP7__Tax_Rate__c', rate);
        return p;
    }
    
    // --------- Core validator (same logic you already wrote) ----------
    private static String validateBillTolerance(List<ERP7__Bill_Line_Item__c> billList,List<ERP7__Purchase_Line_Items__c> poLineList) {
        if (billList == null || billList.isEmpty()) return 'No bill lines provided for tolerance check.';
        if (poLineList == null || poLineList.isEmpty()) return 'No PO line items provided for tolerance check.';
        
        ERP7__Module__c finance = [
            SELECT Run__c, ERP7__Run_Posting_Trigger__c,
            ERP7__Bill_Quantity_Tolerance__c, ERP7__Bill_Unit_Price_Tolerance__c
            FROM ERP7__Module__c WHERE Name = 'Finance' LIMIT 1
        ];
        Boolean enabled = finance.Run__c &&
            ( finance.ERP7__Run_Posting_Trigger__c ||
             finance.ERP7__Bill_Unit_Price_Tolerance__c > 0 ||
             finance.ERP7__Bill_Quantity_Tolerance__c > 0 );
        if (!enabled) return null;
        
        Decimal qtyLimit = finance.ERP7__Bill_Quantity_Tolerance__c;
        Decimal upLimit  = finance.ERP7__Bill_Unit_Price_Tolerance__c;
        
        Map<Id, ERP7__Purchase_Line_Items__c> poMap = new Map<Id, ERP7__Purchase_Line_Items__c>(poLineList);
        List<String> errors = new List<String>();
        
        for (ERP7__Bill_Line_Item__c b : billList) {
            if (b == null || b.ERP7__Purchase_Order_Line_Items__c == null) continue;
            ERP7__Purchase_Line_Items__c p = poMap.get(b.ERP7__Purchase_Order_Line_Items__c);
            if (p == null) continue;
            
            Decimal billUP = (Decimal) b.get('ERP7__Amount__c');      // treated as Unit Price here
            Decimal poUP   = p.ERP7__Unit_Price__c;
            Decimal billQty= b.ERP7__Quantity__c;
            Decimal poQty  = p.ERP7__Quantity__c;
            Decimal billTax= b.ERP7__Tax_Rate__c;
            Decimal poTax  = p.ERP7__Tax_Rate__c;//(Decimal) p.get('ERP7__Tax_Rate__c');
             System.debug(' billTax: '+billTax+' poTax:'+poTax);
            if (billUP != null && poUP != null) {
                if (poUP == 0 && billUP != 0) {
                    errors.add((b.Name != null ? b.Name + ': ' : '') + 'PO unit price is 0 but bill unit price is non-zero.');
                } else if (poUP != 0) {
                    Decimal variance = (((billUP - poUP).abs() / poUP) * 100).setScale(2);
                    if (variance > upLimit) {
                        errors.add((b.Name != null ? b.Name + ': ' : '') + 'Unit price variance exceeds limit ('+variance+'% > '+upLimit+'%).');
                    }
                }
            }
            
            if (billQty != null && poQty != null && billQty > poQty) {
                errors.add((b.Name != null ? b.Name + ': ' : '') + 'Bill quantity exceeds PO quantity.');
            }
            
            if (billTax != null && poTax != null) {
                if (poTax == 0 && billTax != 0) {
                    errors.add((b.Name != null ? b.Name + ': ' : '') + 'PO tax rate is 0 but bill tax rate is non-zero.');
                } else if (poTax != 0) {
                    Decimal variance = (((billTax - poTax).abs() / poTax) * 100).setScale(2);
                     System.debug('variance: '+variance+' qtyLimit: '+qtyLimit+' billTax: '+billTax+' poTax:'+poTax);
                    if (variance > qtyLimit) {
                        System.debug('variance: '+variance+' qtyLimit: '+qtyLimit+' billTax: '+billTax+' poTax:'+poTax);
                        errors.add((b.Name != null ? b.Name + ': ' : '') + 'Tax variance exceeds limit ('+variance+'% > '+qtyLimit+'%).');
                    }
                }
            }
        }
        return errors.isEmpty() ? null : String.join(errors, '\n');
    }
    
    
    //till here 
    

}