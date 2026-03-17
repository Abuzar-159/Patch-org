/*
 * Changes made by Shaguftha M
 * date - 06th April 2023
 * Reason - Too Many SOQL queries issue when enabling ready to pick &  paka and Issue invoice is enabled previously
 * Fix - Only onchange of issue invoice the invoice creation part to execute
 * 
*/
/* 
 Changes Made by - Syed Moin Pasha
 Date - 11th August 2021
 Reason - Invoice LineItem was not getting created for Issue Invoice from Epos/Normal 
 Fix - Removed  Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.Invoice__c.isUpdatable() - Line 67 
       as we have invoice mastered with Invoice line item 
       so it wont allow us to update 
*/

trigger SalesOrderTrigger on Sales_Order__c (before insert, before update, after insert, after update, before delete) {
    try{
        
        //Moin added this 
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();
        if(Trigger.isUpdate && Trigger.isAfter && RunModule.get('Finance').ERP7__Accounting_Period_Password__c){
            List<Date> transDateList = new List<Date>();
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }
            for(Sales_Order__c so : Trigger.new){
                system.debug('password -->'+so.ERP7__Accounting_Period_Password__c);
                if(so.ERP7__Order_Date__c!=null){
                    transDateList.add(Date.valueOf(so.ERP7__Order_Date__c));
                }
            }
            if(transDateList.size()>0){
                system.debug('transDateList-->'+transDateList.size());
                if(Trigger.new[0].ERP7__Accounting_Period_Password__c==null){
                    if(PostingPreventingHandler.checkForAccountingPeriodClosing(transDateList[0])){
                        Trigger.new[0].addError('Accounting Period is closed please enter the password from Edit Transactions');
                    }
                }else{
                    if(PostingPreventingHandler.checkForAccountingPeriodClosingPassword(transDateList[0], Trigger.new[0].ERP7__Accounting_Period_Password__c) && FC.ERP7__Closing_Period_Password_Process__c){
                        Trigger.new[0].addError('Password does not match with the Accounting Period Password');
                    }
                }
            }
        }
        //*****tax Calculation on Profile change start*****
        Set<Id> SOIdsForTax=new Set<Id>();
        if(Trigger.isAfter && Trigger.isUpdate){
            for(Sales_Order__c SO:Trigger.new){ Sales_Order__c oldSO=Trigger.oldMap.get(SO.Id); if(SO.ERP7__Order_Profile__c != oldSO.ERP7__Order_Profile__c) SOIdsForTax.add(SO.Id); }
            if(SOIdsForTax.size()> 0) SalesOrderTrigger.manageTaxUponProfileChange(SOIdsForTax);
        }
         
        //*****tax Calculation on Profile change ends*****
        
        for(Sales_Order__c SO : System.Trigger.New){ Sales_Order__c OldSO=Trigger.oldMap.get(SO.Id); Decimal oldAmtPaid=OldSO.ERP7__Amount_Paid__c; if(SO.ERP7__Amount_Paid__c != oldAmtPaid) return; }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                if(!PreventRecursiveLedgerEntry.testCasesTransactions){
                    set<Id> soIds = new set<Id>();
                    system.debug('Trigger.isUpdate : '+Trigger.isUpdate);
                    List<ERP7__Invoice__c> invoice2upsert = new List<ERP7__Invoice__c>();
                     if(Trigger.isUpdate){
                        Map<Id, ERP7__Invoice__c> soMapToInvoice = new Map<Id, ERP7__Invoice__c>();
                        for(ERP7__Invoice__c inv : [Select Id, ERP7__Order__c ,ERP7__Invoice_Amount__c from ERP7__Invoice__c where ERP7__Order__c IN:Trigger.newMap.keyset()])
                            soMapToInvoice.put(inv.ERP7__Order__c, inv);
                        for (Sales_Order__c SO : System.Trigger.New){
                            Sales_Order__c OldSO=Trigger.oldMap.get(SO.Id);
                            if(SO.ERP7__Ready_To_Pick_Pack__c && !SO.ERP7__Is_Closed__c && SO.ERP7__Status__c != 'Cancelled') soIds.add(SO.Id);
                            system.debug('OldSO.ERP7__Issue_Invoice__c : '+OldSO.ERP7__Issue_Invoice__c);
                            if((SO.ERP7__Issue_Invoice__c)&&(SO.ERP7__Sales_Order_Amount__c>0) && !OldSO.ERP7__Issue_Invoice__c){
                                ERP7__Invoice__c invoice =(soMapToInvoice.get(So.Id)!=null)? soMapToInvoice.get(So.Id):new ERP7__Invoice__c(ERP7__Order__c=SO.Id, ERP7__Account__c=SO.ERP7__Account__c,ERP7__Active__c=true, ERP7__Invoice_Date__c=system.today(),Organisation__c = SO.Organisation__c, ERP7__Invoice_Shipping_Amount__c = SO.ERP7__Total_Shipping_Amount__c, ERP7__Invoice_Amount__c = SO.ERP7__Sales_Order_Amount__c, ERP7__Tax_Amount__c=SO.ERP7__Total_Tax_Amount__c );
                               
                                    invoice2upsert.add(invoice);
                                
                            }
                        }
                    }
                    else{
                        for (Sales_Order__c SO : System.Trigger.New){
                            if(SO.ERP7__Ready_To_Pick_Pack__c && !SO.ERP7__Is_Closed__c && SO.ERP7__Status__c != 'Cancelled') soIds.add(SO.Id);
                            system.debug('SO.ERP7__Sales_Order_Amount__c : '+SO.ERP7__Sales_Order_Amount__c); 
                            if((SO.ERP7__Issue_Invoice__c)&&(SO.ERP7__Sales_Order_Amount__c>0)){
                                 ERP7__Invoice__c invoice = new ERP7__Invoice__c(ERP7__Order__c=SO.Id, ERP7__Account__c=SO.ERP7__Account__c,ERP7__Active__c=true, ERP7__Invoice_Date__c=system.today(),Organisation__c = SO.Organisation__c, ERP7__Invoice_Shipping_Amount__c = SO.ERP7__Total_Shipping_Amount__c, ERP7__Invoice_Amount__c = SO.ERP7__Sales_Order_Amount__c,  ERP7__Tax_Amount__c=SO.ERP7__Total_Tax_Amount__c);
                                 invoice2upsert.add(invoice);
                             }
                        }
                    }
                    
                   system.debug('invoice2upsert : '+invoice2upsert.size()); 
                    /*Upsert Invoice */
                    if(invoice2upsert.size()>0){
                        if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Shipping_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.Organisation__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Order__c.isUpdateable()) { upsert invoice2upsert; } else{ /* no access */ }
                        List<Sales_Order_Line_Item__c> SOLIS = [Select Id, ERP7__Sort_Order__c, ERP7__Detailed_Description__c,ERP7__Tax__c, ERP7__Description__c, Total_Price__c,Name,ERP7__Invoice__c,ERP7__Invoiced_Quantity__c, ERP7__Sales_Order__c, ERP7__Sales_Order__r.ERP7__Issue_Invoice__c, ERP7__Quantity__c,ERP7__Base_Price__c,ERP7__Discount_Amount__c,ERP7__Other_Tax__c,ERP7__Product__c,ERP7__VAT_Amount__c, ERP7__Price_Product__c  From Sales_Order_Line_Item__c Where ERP7__Sales_Order__c IN: Trigger.newMap.keyset()];
                        List<ERP7__Invoice_Line_Item__c> invoiceLineItem = new List<ERP7__Invoice_Line_Item__c>();
                        Map<Id, ERP7__Invoice_Line_Item__c> soliMapToINLI = new Map<Id, ERP7__Invoice_Line_Item__c>();
                        for(ERP7__Invoice_Line_Item__c ILI:[Select Id, Name, ERP7__Sort_Order__c, ERP7__Detailed_Description__c , ERP7__Base_Price__c, ERP7__Description__c, ERP7__Discount_Amount__c,
                                                            ERP7__Other_Tax__c, ERP7__Invoice__c, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c,
                                                            ERP7__Shipping_Amount__c, ERP7__Sub_Total__c, ERP7__UoM__c, ERP7__VAT_Amount__c from ERP7__Invoice_Line_Item__c where ERP7__Invoice__r.ERP7__Order__c IN: Trigger.newMap.keyset()]){
                                                                soliMapToINLI.put(ILI.ERP7__Sales_Order_Line_Item__c, ILI); 
                                                            } 
                        for(ERP7__Invoice__c inv :invoice2upsert){
                            
                            for(Integer i=0;i<SOLIS.size();i++){
                                Sales_Order_Line_Item__c soli = SOLIS[i];
                                if(soli.ERP7__Sales_Order__r.ERP7__Issue_Invoice__c){
                                    ERP7__Invoice_Line_Item__c INLI = (soliMapToINLI.get(soli.ID) != null)? soliMapToINLI.get(soli.ID):new ERP7__Invoice_Line_Item__c(Invoice__c=inv.Id,Sales_Order_Line_Item__c = soli.Id, ERP7__Quantity__c=(soli.ERP7__Invoiced_Quantity__c >0.00)?soli.ERP7__Invoiced_Quantity__c:soli.ERP7__Quantity__c,ERP7__Base_Price__c =soli.ERP7__Base_Price__c, ERP7__Sub_Total__c=soli.ERP7__Base_Price__c, ERP7__Unit_Price__c = soli.ERP7__Price_Product__c,ERP7__Discount_Amount__c = soli.ERP7__Discount_Amount__c,  ERP7__Tax_Rate__c = soli.ERP7__Tax__c, ERP7__Other_Tax__c = soli.ERP7__Other_Tax__c, ERP7__Product__c = soli.ERP7__Product__c,ERP7__Total_Price__c = soli.Total_Price__c, ERP7__VAT_Amount__c = soli.ERP7__VAT_Amount__c, ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c);
                                    if(soli.ERP7__Description__c != null && soli.ERP7__Description__c != '') INLI.ERP7__Description__c = soli.ERP7__Description__c;
                                    if(soli.ERP7__Detailed_Description__c != null && soli.ERP7__Detailed_Description__c != '') INLI.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;
                                    invoiceLineItem.add(INLI);
                                    if(soli.ERP7__Sales_Order__c == inv.Order__c){
                                        if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Invoice__c.isUpdateable()){SOLIS[i].ERP7__Invoice__c = inv.id;}else{/*No access*/}
                                        if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Invoiced_Quantity__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Invoiced_Quantity__c.isUpdateable()){SOLIS[i].ERP7__Invoiced_Quantity__c = (soli.ERP7__Invoiced_Quantity__c >0.00)?soli.ERP7__Invoiced_Quantity__c:soli.ERP7__Quantity__c;}else{/*No access*/}
                                    }    
                                } 
                            }
                        }
                        if (SOLIS.size() > 0) { 
                            if(PreventRecursiveLedgerEntry.IsFromPOS){
                                PreventRecursiveLedgerEntry.testCasesTransactions = true; 
                            } else {
                                PreventRecursiveLedgerEntry.testCasesTransactions = false; 
                            }
                            if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()) { upsert SOLIS;   } else{ /* no access */ } 
                        }
                        if(invoiceLineItem.size()>0) { 
                            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__VAT_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Discount_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Other_Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Base_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Base_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Description__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Description__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Detailed_Description__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Detailed_Description__c.isUpdateable()){ upsert invoiceLineItem; } else{ /* no aceess */ }
                        }
                    }else{
                        List<Sales_Order_Line_Item__c> SOLIS = [Select Id, Name,ERP7__Invoice__c, ERP7__Sales_Order__c, ERP7__Sales_Order__r.ERP7__Issue_Invoice__c From Sales_Order_Line_Item__c Where ERP7__Sales_Order__c In :soIds And Inventory_Tracked__c = true And ERP7__Allocate_Stock__c = true];
                        if (SOLIS.size() > 0) { 
                            if(PreventRecursiveLedgerEntry.IsFromPOS){
                                PreventRecursiveLedgerEntry.testCasesTransactions = true; 
                            } else {
                                PreventRecursiveLedgerEntry.testCasesTransactions = false; 
                             
                             }
                            if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()){ upsert SOLIS; } else { /* no access */ }
                        }
                    }
                    
                    //SalesOrderTrigger.ManageSalesOrderWarranties(Trigger.IsInsert,Trigger.IsUpdate, Trigger.New, Trigger.Old);
                    SalesOrderTrigger.ManageSalesOrderWarranties(Trigger.IsInsert,Trigger.IsUpdate, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
                    PreventRecursiveLedgerEntry.testCasesTransactions = true;
                }
                if(!PreventRecursiveLedgerEntry.Loged){
                    system.debug('ManageSalesOrderLogistics called');
                    //SalesOrderTrigger.ManageSalesOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, Trigger.IsAfter, Trigger.New, Trigger.Old);
                    SalesOrderTrigger.ManageSalesOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, Trigger.IsAfter, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
                }    
            }
        }else{
            if(Trigger.isDelete){
                List<ERP7__Invoice__c> inv2Delete  = [Select Id, ERP7__Order__c from ERP7__Invoice__c where ERP7__Order__c IN: Trigger.oldMap.keyset() AND Posted__c = False];
                if(inv2Delete.size()>0 && ERP7__Invoice__c.sObjectType.getDescribe().isDeletable()){  delete inv2Delete; } else{ /* no access */ }
            }  
            if(Trigger.isInsert || Trigger.isUpdate){
                if(!PreventRecursiveLedgerEntry.Taxed){
                    Map<Id, Sales_Order__c> SOS = new Map<Id, Sales_Order__c>([Select Id, Name, ERP7__Order_Profile__c, ERP7__Order_Profile__r.ERP7__Account_Profile__c, ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c, ERP7__Order_Profile__r.ERP7__Tax_Sourcing_Rules__c, ERP7__Bill_To_Address__c, ERP7__Bill_To_Address__r.Country__c, ERP7__Bill_To_Address__r.ERP7__State__c,
                                                      ERP7__Ship_To_Address__c, ERP7__Ship_To_Address__r.Country__c, ERP7__Ship_To_Address__r.ERP7__State__c
                                                      From Sales_Order__c
                                                      Where Id In : Trigger.New]);
                                               
                    List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
                    Map<Id, List<ERP7__Tax__c>> profileTaxesMap = new Map<Id, List<ERP7__Tax__c>>();
                    Set<Id> accprofileIds = new Set<Id>();
                    for(Sales_Order__c SO : System.Trigger.New){
                        if(SOS.containsKey(SO.Id)){
                            Sales_Order__c mySO = SOS.get(SO.Id);
                            if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c != Null && SO.ERP7__Shipping_Tax__c == Null && ((mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && mySO.ERP7__Bill_To_Address__c != Null) || (mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && mySO.ERP7__Ship_To_Address__c != Null))) 
                                accprofileIds.add(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c);
                        }
                    }
                    
                    Date todayDate = system.today();
                    String shippingtax = 'Shipping';
                    String allFieldsTaxes = UtilClass.selectStarFromSObject('ERP7__Tax__c');
                    String queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :shippingtax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null';
                    profileTax = Database.query(queryTaxes);
                    
                    for(ERP7__Tax__c pt : profileTax) {
                        if(profileTaxesMap.containsKey(pt.ERP7__Account_Profile__c)){
                            profileTaxesMap.get(pt.ERP7__Account_Profile__c).add(pt);
                        }
                        else {
                            List<ERP7__Tax__c> myprofileTaxes = new List<ERP7__Tax__c>();
                            myprofileTaxes.add(pt);
                            profileTaxesMap.put(pt.ERP7__Account_Profile__c,myprofileTaxes);
                        }
                    }
                    
                    for(Sales_Order__c SO : System.Trigger.New){
                        if(SOS.containsKey(SO.Id)){
                            PreventRecursiveLedgerEntry.Taxed = true;
                            Sales_Order__c mySO = SOS.get(SO.Id);
                            if(profileTaxesMap.containsKey(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c)){
                                List<Tax__c> taxes = profileTaxesMap.get(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__c);
                                for(Tax__c tax : taxes){
                                    String TaxProvince = '';
                                    String TaxCountry = '';
                                    if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && mySO.ERP7__Bill_To_Address__c != Null){
                                        if(mySO.ERP7__Bill_To_Address__r.ERP7__State__c != Null && mySO.ERP7__Bill_To_Address__r.ERP7__State__c != '') TaxProvince = mySO.ERP7__Bill_To_Address__r.ERP7__State__c;
                                        if(mySO.ERP7__Bill_To_Address__r.ERP7__Country__c != Null && mySO.ERP7__Bill_To_Address__r.ERP7__Country__c != '') TaxCountry = mySO.ERP7__Bill_To_Address__r.ERP7__Country__c;
                                    }
                                    if(mySO.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && mySO.ERP7__Ship_To_Address__c != Null){
                                        if(mySO.ERP7__Ship_To_Address__r.ERP7__State__c != Null && mySO.ERP7__Ship_To_Address__r.ERP7__State__c != '') TaxProvince = mySO.ERP7__Ship_To_Address__r.ERP7__State__c;
                                        if(mySO.ERP7__Ship_To_Address__r.ERP7__Country__c != Null && mySO.ERP7__Ship_To_Address__r.ERP7__Country__c != '') TaxCountry = mySO.ERP7__Ship_To_Address__r.ERP7__Country__c;
                                    }
                                    if(TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '' && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry){
                                        if(SO.ERP7__Total_Shipping_Amount__c == Null) SO.ERP7__Total_Shipping_Amount__c = 0.00;
                                        if(SO.ERP7__Shipping_Discount__c == Null) SO.ERP7__Shipping_Discount__c = 0.00;
                                        SO.ERP7__Shipping_Tax__c = tax.Id;
                                        SO.ERP7__Shipping_VAT__c = (tax.ERP7__Tax_Rate__c / 100 * (SO.ERP7__Total_Shipping_Amount__c - SO.ERP7__Shipping_Discount__c)).setScale(2);
                                        break;
                                    }
                                }
                            }
                        } 
                    }
                }
            }  
        }
    } catch(exception ex){
        String exceptionError = ex.getMessage();
        exceptionError += ' Line No: ' + ex.getLineNumber();
        exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();
    } 
}