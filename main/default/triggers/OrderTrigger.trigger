trigger OrderTrigger on Order (before insert, before update, after insert, after update, before delete) {
    try{
        system.debug('PreventRecursiveLedgerEntry.testCasesTransactions OrderTrigger :'+PreventRecursiveLedgerEntry.testCasesTransactions);
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                if(!PreventRecursiveLedgerEntry.testCasesTransactions && PreventRecursiveLedgerEntry.OrderTrigger && PreventRecursiveLedgerEntry.OrderTriggerDuringMO){//new condition here PreventRecursiveLedgerEntry.OrderTriggerDuringMO
                    PreventRecursiveLedgerEntry.OrderTrigger = false;
                    System.debug('inside OrderTrigger ');
                    set<Id> soIds = new set<Id>();
                    List<ERP7__Invoice__c> invoice2upsert = new List<ERP7__Invoice__c>();
                    Map<Id, ERP7__Invoice__c> soMapToInvoice = new Map<Id, ERP7__Invoice__c>();
                    for(ERP7__Invoice__c inv : [Select Id, ERP7__Order_S__c,ERP7__Invoice_Amount__c from ERP7__Invoice__c where ERP7__Order_S__c IN:Trigger.newMap.keyset()]) soMapToInvoice.put(inv.ERP7__Order_S__c, inv);
                    for (Order SO : System.Trigger.New){
                        if(SO.ERP7__Ready_To_Pick_Pack__c && !SO.ERP7__Is_Closed__c && SO.Status != 'Cancelled') soIds.add(SO.Id);
                        if(SO.ERP7__Issue_Invoice__c){  // && (SO.ERP7__Order_Amount__c>0) (Commenting this because we can create invoice for $0 amount also)
                            ERP7__Invoice__c invoice = new ERP7__Invoice__c();
                            if(soMapToInvoice.containsKey(So.Id) && soMapToInvoice.get(So.Id)!=null){                                invoice = soMapToInvoice.get(So.Id);
                            }
                            else{
                                invoice.ERP7__Order_S__c = SO.Id;
                                invoice.ERP7__Account__c=SO.AccountId;
                                invoice.ERP7__Active__c=true;
                                invoice.ERP7__Invoice_Date__c=System.today();
                                invoice.Organisation__c = SO.Organisation__c;
                                invoice.ERP7__Invoice_Shipping_Amount__c = SO.ERP7__Total_Shipping_Amount__c;
                                invoice.ERP7__Invoice_Amount__c = SO.ERP7__Order_Amount__c;
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Order_S__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Order_S__c.isUpdateable()){invoice.ERP7__Order_S__c = SO.Id;}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Account__c.isUpdateable()){invoice.ERP7__Account__c=SO.AccountId;}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Active__c.isUpdateable()){invoice.ERP7__Active__c=true;}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isUpdateable()){invoice.ERP7__Invoice_Date__c=System.today();}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.Organisation__c.isUpdateable()){invoice.Organisation__c = SO.Organisation__c;}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Shipping_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Shipping_Amount__c.isUpdateable()){invoice.ERP7__Invoice_Shipping_Amount__c = SO.ERP7__Total_Shipping_Amount__c;}else{/* no access*/}
                                //if( Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Amount__c.isUpdateable()){invoice.ERP7__Invoice_Amount__c = SO.ERP7__Order_Amount__c;}else{/* no access*/}
                                
                            }
                            //(soMapToInvoice.get(So.Id)!=null)? soMapToInvoice.get(So.Id):new ERP7__Invoice__c(ERP7__Order_S__c=SO.Id, ERP7__Account__c=SO.AccountId,ERP7__Active__c=true, ERP7__Invoice_Date__c=SO.ERP7__Expected_Date__c,Organisation__c = SO.Organisation__c,ERP7__Invoice_Shipping_Amount__c = SO.ERP7__Total_Shipping_Amount__c , ERP7__Invoice_Amount__c = SO.ERP7__Order_Amount__c);
                            
                            invoice2upsert.add(invoice);
                        }
                    }
                    
                    if(invoice2upsert.size()>0){
                        if(Schema.sObjectType.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.isUpdateable()) { upsert invoice2upsert; } else { /* no access */ }
                        List<OrderItem> SOLIS = [Select Id, ERP7__Sort_Order__c, ERP7__Detailed_Description__c, Description, Total_Price__c,ERP7__Invoice__c,ERP7__Invoiced_Quantity__c, OrderId, Order.ERP7__Issue_Invoice__c, Quantity,ERP7__Base_Price__c,ERP7__Discount_Amount__c,ERP7__Other_Tax__c,Product2Id,ERP7__VAT_Amount__c, UnitPrice From OrderItem Where OrderId IN: Trigger.newMap.keyset()];
                        System.debug('SOLIS : '+SOLIS.size());
                        List<ERP7__Invoice_Line_Item__c> invoiceLineItem = new List<ERP7__Invoice_Line_Item__c>();
                        Map<Id, ERP7__Invoice_Line_Item__c> soliMapToINLI = new Map<Id, ERP7__Invoice_Line_Item__c>();
                        for(ERP7__Invoice_Line_Item__c ILI:[Select Id, Name, ERP7__Sort_Order__c, ERP7__Detailed_Description__c , ERP7__Base_Price__c, ERP7__Description__c, ERP7__Discount_Amount__c,
                                                            ERP7__Other_Tax__c, ERP7__Invoice__c, ERP7__Quantity__c, ERP7__Order_Product__c,
                                                            ERP7__Shipping_Amount__c, ERP7__Sub_Total__c, ERP7__UoM__c, ERP7__VAT_Amount__c from ERP7__Invoice_Line_Item__c where ERP7__Invoice__r.ERP7__Order_S__c IN: Trigger.newMap.keyset()]){ soliMapToINLI.put(ILI.ERP7__Order_Product__c, ILI); System.debug('soliMapToINLI : '+soliMapToINLI); } 
                        for(ERP7__Invoice__c inv :invoice2upsert){
                            
                           for(Integer i=0;i<SOLIS.size();i++){    OrderItem soli = SOLIS[i];    boolean proceedToInvoice = false;    if (Trigger.isInsert && soli.Order.ERP7__Issue_Invoice__c) {        proceedToInvoice = true;    }     else if (Trigger.isUpdate && soli.Order != null && soli.Order.ERP7__Issue_Invoice__c && Trigger.newMap.get(soli.OrderId).ERP7__Issue_Invoice__c != Trigger.oldMap.get(soli.OrderId).ERP7__Issue_Invoice__c) {        proceedToInvoice = true;    }    if(proceedtoInvoice){        ERP7__Invoice_Line_Item__c INLI = new ERP7__Invoice_Line_Item__c();        system.debug('soliMapToINLI.containsKey(soli.ID) : '+soliMapToINLI.containsKey(soli.ID));        if(soliMapToINLI.get(soli.ID) != null && soliMapToINLI.containsKey(soli.ID)) INLI = soliMapToINLI.get(soli.ID);        else {            INLI.Invoice__c=inv.Id;            INLI.ERP7__Order_Product__c = soli.Id;            INLI.ERP7__Quantity__c=(soli.ERP7__Invoiced_Quantity__c >0.00)?soli.ERP7__Invoiced_Quantity__c:soli.Quantity;            INLI.ERP7__Base_Price__c =soli.ERP7__Base_Price__c;            INLI.ERP7__Unit_Price__c = soli.UnitPrice;            INLI.ERP7__Discount_Amount__c = soli.ERP7__Discount_Amount__c;            INLI.ERP7__Other_Tax__c = soli.ERP7__Other_Tax__c;            INLI.ERP7__Product__c = soli.Product2Id;            INLI.ERP7__Sub_Total__c = (soli.UnitPrice*soli.Quantity).setScale(2);            INLI.ERP7__Total_Price__c = soli.Total_Price__c;            INLI.ERP7__VAT_Amount__c = soli.ERP7__VAT_Amount__c;             INLI.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;      }        if(soli.Description != null && soli.Description != '' && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Description__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Description__c.isUpdateable()){ INLI.ERP7__Description__c = soli.Description; }else{ /* no access */ }        if(soli.ERP7__Detailed_Description__c != null && soli.ERP7__Detailed_Description__c != ''  && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Detailed_Description__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Detailed_Description__c.isUpdateable()) INLI.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;         invoiceLineItem.add(INLI);        if(soli.OrderId == inv.Order_S__c){  if(Schema.sObjectType.OrderItem.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Invoice__c.isUpdateable()){SOLIS[i].ERP7__Invoice__c = inv.id; } else{ /* no access */ } if(Schema.sObjectType.OrderItem.fields.ERP7__Invoiced_Quantity__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Invoiced_Quantity__c.isUpdateable()){SOLIS[i].ERP7__Invoiced_Quantity__c = (soli.ERP7__Invoiced_Quantity__c >0.00)?soli.ERP7__Invoiced_Quantity__c:soli.Quantity;} else{ /* no access*/ }                                          }        } }
                        }
                        system.debug('invoiceLineItem-->'+invoiceLineItem.size());
                        if (SOLIS.size() > 0) {                             if(PreventRecursiveLedgerEntry.IsFromPOS){ PreventRecursiveLedgerEntry.testCasesTransactions = true; } else { PreventRecursiveLedgerEntry.testCasesTransactions = false;                                                                                                                                         }                            if(Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()){ upsert SOLIS;   } else{ /* no aceess */ }                         }
                        
                        if(invoiceLineItem.size()>0 && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isUpdateable()) {  upsert invoiceLineItem; } else{ /* no access */ }
                        
                        
                        //===============Subscription Creation start===============
                        List<OrderItem> SOLIS1 = [Select Id, Sort_Order__c,Order.AccountId,Order.ERP7__Contact__c,Order.EffectiveDate,ServiceDate,EndDate, Description, ERP7__Total_Price__c, OrderId, Order.ERP7__Issue_Invoice__c, Quantity,UnitPrice,ERP7__Discount_Amount__c,ERP7__Discount_Percent__c,Product2Id,ERP7__VAT_Amount__c,Product2.Name,ERP7__Product_Subscription_Plan_Allocation__c,ERP7__Product_Subscription_Plan_Allocation__r.ERP7__Subscription_Plan__c,ERP7__Product_Subscription_Plan_Allocation__r.ERP7__Product__c,ERP7__Order_Delivery_Frequency__c,ERP7__Month_Duration__c,ERP7__Start_Date__c  From OrderItem Where OrderId IN: Trigger.newMap.keyset()];
                        List<ERP7__Subscription__c> subsList=[Select Id,Name,ERP7__Order_Product__c from ERP7__Subscription__c where ERP7__Order_Product__c In:SOLIS1];
                        Map<Id,String> OrdProdSubsMap=new Map<Id,String>();
                        for(ERP7__Subscription__c sub:subsList)                            OrdProdSubsMap.put(sub.ERP7__Order_Product__c,sub.Id);
                        List<ERP7__Subscription__c> subsListToUpsert=new List<ERP7__Subscription__c>();
                        for(OrderItem ordItem:SOLIS1){                            if(ordItem.ERP7__Product_Subscription_Plan_Allocation__r.ERP7__Product__c != null && ordItem.ERP7__Product_Subscription_Plan_Allocation__r.ERP7__Subscription_Plan__c != null ){                                ERP7__Subscription__c sub=new ERP7__Subscription__c();                                sub.Id=OrdProdSubsMap.get(ordItem.Id);                                sub.ERP7__Active__c=true;                                sub.ERP7__Contact__c=ordItem.Order.ERP7__Contact__c;                                sub.ERP7__Account__c=ordItem.Order.AccountId;                                sub.ERP7__Description__c=ordItem.Description;                                sub.ERP7__Discount__c=ordItem.ERP7__Discount_Percent__c;                                sub.Name=ordItem.Product2.Name;                                if(OrdProdSubsMap.get(ordItem.Id) == null && ordItem.ServiceDate != null) sub.ERP7__Start_Date__c= ordItem.ServiceDate; else sub.ERP7__Start_Date__c=system.today();                                                sub.ERP7__Order__c = ordItem.OrderId;                                sub.ERP7__Order_Product__c=ordItem.Id;                                sub.ERP7__Price__c=ordItem.UnitPrice;                                sub.ERP7__Subscription_Date__c = ordItem.ERP7__Start_Date__c;                                sub.ERP7__Product__c=ordItem.Product2Id;                                if(OrdProdSubsMap.get(ordItem.Id) == null) sub.ERP7__Purchase_Date__c= ordItem.Order.EffectiveDate;                                                    sub.ERP7__Quantity__c=ordItem.Quantity;                                sub.ERP7__Status__c='Active';                                                                if(ordItem.ERP7__Order_Delivery_Frequency__c == 'Daily')                                     sub.ERP7__Next_Order_On__c = ordItem.Order.EffectiveDate.addDays(1);                                else if(ordItem.ERP7__Order_Delivery_Frequency__c == 'Weekly')                                     sub.ERP7__Next_Order_On__c = ordItem.Order.EffectiveDate.addDays(7);                                else if(ordItem.ERP7__Order_Delivery_Frequency__c == 'Monthly')                                     sub.ERP7__Next_Order_On__c = ordItem.Order.EffectiveDate.addDays(30);                                                                if(ordItem.EndDate != null) sub.ERP7__Subscription_End_Date__c=ordItem.EndDate;                                 sub.ERP7__Subscription_Plan__c=ordItem.ERP7__Product_Subscription_Plan_Allocation__r.ERP7__Subscription_Plan__c;                                sub.ERP7__Product_Subscription_Plan_Allocation__c =ordItem.ERP7__Product_Subscription_Plan_Allocation__c;                                sub.ERP7__Month_Duration__c = ordItem.ERP7__Month_Duration__c;                                sub.ERP7__Order_Delivery_Frequency__c = ordItem.ERP7__Order_Delivery_Frequency__c;                                subsListToUpsert.add(sub);                                }                                            }                       
                        
                        if(subsListToUpsert.size() > 0) upsert subsListToUpsert;
                        //===============Subscription Creation end===============
                        
                        
                        
                    }
                    else{
                        List<OrderItem> SOLIS = [Select Id,ERP7__Invoice__c, OrderId, Order.ERP7__Issue_Invoice__c From OrderItem Where OrderId In :soIds And Inventory_Tracked__c = true And ERP7__Allocate_Stock__c = true];
                        if (SOLIS.size() > 0) {                             system.debug('OrderTrigger upserting orderItems');                            if(PreventRecursiveLedgerEntry.IsFromPOS){ PreventRecursiveLedgerEntry.testCasesTransactions = true; } else { PreventRecursiveLedgerEntry.testCasesTransactions = false; }                            if(Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()){ upsert SOLIS; }else{ /* no access */ }                        }
                        
                    }
                    
                    OrderTrigger.ManageSalesOrderWarranties(Trigger.IsInsert,Trigger.IsUpdate, Trigger.New, Trigger.Old);
                    PreventRecursiveLedgerEntry.testCasesTransactions = true;
                    
                    /*boolean uncheckIssueMO;
                    uncheckIssueMO = false;
                    ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
                    FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
                    if(FC != null){
                        uncheckIssueMO = FC.ERP7__Allow_withdraw_Order_from_MO_Scheduler__c;
                    }
                    List<OrderItem> orderItems2Update = new List<OrderItem>();
                    
                    List<OrderItem> associatedOrderItems = [Select Id, ERP7__Sort_Order__c, ERP7__Detailed_Description__c, Description, Total_Price__c,ERP7__Invoice__c,ERP7__Invoiced_Quantity__c, OrderId, Order.ERP7__Issue_Invoice__c, Quantity,ERP7__Base_Price__c,ERP7__Discount_Amount__c,ERP7__Other_Tax__c,Product2Id,ERP7__VAT_Amount__c, UnitPrice From OrderItem Where OrderId IN: Trigger.newMap.keyset()];                    
                    for (OrderItem soli : associatedOrderItems) {
                       
                        if (soli.Order != null && soli.Order.Status == 'Cancelled' && uncheckIssueMO) {
                            soli.ERP7__Issue_Manufacturing_Order__c = false;
                            orderItems2Update.add(soli);
                        }
                    }
                    if (!orderItems2Update.isEmpty()) {
                        upsert orderItems2Update;
                    }*/

                }
                //('PreventRecursiveLedgerEntry.Loged :'+PreventRecursiveLedgerEntry.Loged);
                System.debug('PreventRecursiveLedgerEntry.Loged:'+PreventRecursiveLedgerEntry.Loged);
                if(!PreventRecursiveLedgerEntry.Loged && PreventRecursiveLedgerEntry.OrderTriggerDuringMO){//new change here too
                    OrderTrigger.ManageSalesOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, Trigger.IsAfter, Trigger.New, Trigger.Old);
                }    
            }
        }else{
            if(Trigger.isDelete){
                List<ERP7__Invoice__c> inv2Delete  = [Select Id, ERP7__Order_S__c from ERP7__Invoice__c where ERP7__Order_S__c IN: Trigger.oldMap.keyset() AND Posted__c = False];
                if(inv2Delete.size()>0 && ERP7__Invoice__c.sObjectType.getDescribe().isDeletable()) { delete inv2Delete; } else{ /* no access */}
            }  
            if(Trigger.isInsert || Trigger.isUpdate){
                if(!PreventRecursiveLedgerEntry.Taxed && PreventRecursiveLedgerEntry.OrderTriggerDuringMO){//new condition here PreventRecursiveLedgerEntry.OrderTriggerDuringMO
                    system.debug('inhere PreventRecursiveLedgerEntry.Taxed');
                    Map<Id, Order> SOS = new Map<Id, Order>([Select Id, Name, ERP7__Order_Profile__c, ERP7__Order_Profile__r.ERP7__Account_Profile__c, ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c, ERP7__Order_Profile__r.ERP7__Tax_Sourcing_Rules__c, ERP7__Bill_To_Address__c, ERP7__Bill_To_Address__r.Country__c, ERP7__Bill_To_Address__r.ERP7__State__c,
                                                             ERP7__Ship_To_Address__c, ERP7__Ship_To_Address__r.Country__c, ERP7__Ship_To_Address__r.ERP7__State__c
                                                             From Order
                                                             Where Id In : Trigger.New]);
                    
                    List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
                    Map<Id, List<ERP7__Tax__c>> profileTaxesMap = new Map<Id, List<ERP7__Tax__c>>();
                    Set<Id> accprofileIds = new Set<Id>();
                    for(Order SO : System.Trigger.New){
                        //if(SO.Status == 'Activated' && SO.ERP7__Authorised__c ==false && SO.ERP7__Ready_To_Pick_Pack__c==false){SO.ERP7__Authorised__c=true;SO.ERP7__Ready_To_Pick_Pack__c=true;}
                        if(SOS.containsKey(SO.Id)){
                            Order mySO = SOS.get(SO.Id);
                            if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c != Null && SO.ERP7__Shipping_Tax__c == Null && ((mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && mySO.ERP7__Bill_To_Address__c != Null) || (mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && mySO.ERP7__Ship_To_Address__c != Null)))   accprofileIds.add(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c);
                        }
                    }
                    
                    Date todayDate = system.today();
                    String shippingtax = 'Shipping';
                    String allFieldsTaxes = UtilClass.selectStarFromSObject('ERP7__Tax__c');
                    String queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :shippingtax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null';
                    profileTax = Database.query(queryTaxes);
                    
                    for(ERP7__Tax__c pt : profileTax) {
                        if(profileTaxesMap.containsKey(pt.ERP7__Account_Profile__c)){  profileTaxesMap.get(pt.ERP7__Account_Profile__c).add(pt); }
                        else { List<ERP7__Tax__c> myprofileTaxes = new List<ERP7__Tax__c>(); myprofileTaxes.add(pt); profileTaxesMap.put(pt.ERP7__Account_Profile__c,myprofileTaxes);
                             }
                    }
                    
                    for(Order SO : System.Trigger.New){
                        if(SOS.containsKey(SO.Id)){
                            PreventRecursiveLedgerEntry.Taxed = true;
                            Order mySO = SOS.get(SO.Id);
                            if(profileTaxesMap.containsKey(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c)){                                List<Tax__c> taxes = profileTaxesMap.get(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c);                                for(Tax__c tax : taxes){                                    String TaxProvince = ''; String TaxCountry = '';                                    if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && mySO.ERP7__Bill_To_Address__c != Null){                                        if(mySO.ERP7__Bill_To_Address__r.ERP7__State__c != Null && mySO.ERP7__Bill_To_Address__r.ERP7__State__c != '') TaxProvince = mySO.ERP7__Bill_To_Address__r.ERP7__State__c; if(mySO.ERP7__Bill_To_Address__r.ERP7__Country__c != Null && mySO.ERP7__Bill_To_Address__r.ERP7__Country__c != '') TaxCountry = mySO.ERP7__Bill_To_Address__r.ERP7__Country__c;                                    }                                    if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && mySO.ERP7__Ship_To_Address__c != Null){                                        if(mySO.ERP7__Ship_To_Address__r.ERP7__State__c != Null && mySO.ERP7__Ship_To_Address__r.ERP7__State__c != '') TaxProvince = mySO.ERP7__Ship_To_Address__r.ERP7__State__c; if(mySO.ERP7__Ship_To_Address__r.ERP7__Country__c != Null && mySO.ERP7__Ship_To_Address__r.ERP7__Country__c != '') TaxCountry = mySO.ERP7__Ship_To_Address__r.ERP7__Country__c;                                    }                                    if(TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '' && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry){ if(SO.ERP7__Total_Shipping_Amount__c == Null) SO.ERP7__Total_Shipping_Amount__c = 0.00; if(SO.ERP7__Shipping_Discount__c == Null) SO.ERP7__Shipping_Discount__c = 0.00; SO.ERP7__Shipping_Tax__c = tax.Id;SO.ERP7__Shipping_VAT__c = (tax.ERP7__Tax_Rate__c / 100 * (SO.ERP7__Total_Shipping_Amount__c - SO.ERP7__Shipping_Discount__c)).setScale(2); break;                                                                                                                                                                                                        }                                }                            }                     
                        } 
                    }
                }
            }  
        }
        
    }catch(exception ex){        String exceptionError = ex.getMessage();        exceptionError += ' Line No: ' + ex.getLineNumber();        exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();         System.debug('exceptionError:'+exceptionError);    }
    
}