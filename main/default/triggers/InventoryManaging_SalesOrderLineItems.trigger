trigger InventoryManaging_SalesOrderLineItems on Sales_Order_Line_Item__c(before insert, before update, after insert, after update, before delete, after undelete) {
    if (!PreventRecursiveLedgerEntry.testCasesTransactions) {
        if (Trigger.IsBefore) { 
            if (Trigger.IsDelete) {  OrderInventoryUtils.deleteProductPurchaseLineItems(System.Trigger.Old);
            }
            if (Trigger.IsInsert || Trigger.IsUpdate) {  
                
                /* Start ==> Calculate whether there is sufficient stock of component available for each SOLI */
                if (PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck) {
                    //Moin added this on 06th june 2023
                    PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false;
                    list < Id > soliIds2explode = new list < Id > ();
                    list < Id > proIds = new list < Id > ();
                    Map < Id, List < ERP7__BOM__c >> soliBOMS = new Map < Id, List < ERP7__BOM__c >> ();
                    Map < Id, Decimal > proStocks = new Map < Id, Decimal > ();
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                    Set < Id > productIds = new Set < Id > ();
                    Set < Id > priceBookIds = new Set < Id > ();
                    list < Id > soliBOMVersion = new List < Id > ();
                    
                    for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                        if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c) { // && soli.Order_Line_Status__c == 'In Progress' soli.Insufficient_BOM__c
                            soliIds2explode.add(soli.Id); proIds.add(soli.ERP7__Product__c);priceBookIds.add(soli.ERP7__PriceBookId__c);soliBOMVersion.add(soli.Version__c);
                        }
                    }
                    
                    if (proIds.size() > 0) {
                        List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name,
                                                      ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name,
                                                      BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c,
                                                      BOM_Version__r.Type__c, BOM_Version__r.Status__c
                                                      From ERP7__BOM__c  Where((ERP7__Active__c = true And BOM_Version__r.RecordType.Name = 'Kit' And  ERP7__BOM_Product__c In: proIds And BOM_Version__r.Active__c = true And BOM_Version__r.Start_Date__c <= Today And BOM_Version__r.To_Date__c >= Today And(BOM_Version__r.Type__c = 'Assembly' Or BOM_Version__r.Type__c = 'Sales') AND BOM_Version__r.Status__c = 'Certified') OR(Id In: soliBOMVersion AND BOM_Version__r.Status__c = 'Certified')) Order by BOM_Version__r.Default__c DESC];
                        if (BOMS != null && BOMS.size() > 0) {
                            for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                                if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c) {
                                    List < ERP7__BOM__c > myBOMS = new List < ERP7__BOM__c > ();
                                    List < ERP7__BOM__c > myAllBOMS = new List < ERP7__BOM__c > ();
                                    for (ERP7__BOM__c bom: BOMS) {
                                        if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c != Null && soli.Version__c == bom.BOM_Version__c) {
                                            productIds.add(bom.ERP7__BOM_Component__c); myBOMS.add(bom);
                                        } else if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c ==true) {
                                                       productIds.add(bom.ERP7__BOM_Component__c); myBOMS.add(bom);
                                                   }
                                        if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c == Null && bom.BOM_Version__c == Null) {
                                            productIds.add(bom.ERP7__BOM_Component__c);   myAllBOMS.add(bom);
                                        }
                                    }
                                    if (myBOMS.size() > 0) soliBOMS.put(soli.Id, myBOMS);
                                    else if (myAllBOMS.size() > 0) soliBOMS.put(soli.Id, myAllBOMS);
                                }
                            }
                        }
                    }
                    if (productIds.size() > 0) {
                        List < PricebookEntry > priceBookEntries = [Select Id, Name, Product2Id, Product2.ERP7__Track_Inventory__c from PricebookEntry where IsActive = true and Pricebook2Id In:priceBookIds and Product2Id In: productIds ];
                        Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
                        for (PricebookEntry IPE: priceBookEntries) {
                            if (IPE.Product2.ERP7__Track_Inventory__c) productPriceBookMap.put(IPE.Product2Id, IPE);
                        }
                        if (Schema.sObjectType.Inventory_Stock__c.isAccessible()) {
                            UtilClass.FlsCheck(new String[] {
                                'ERP7__Active__c',
                                    'ERP7__Organisation__c',
                                    'ERP7__Warehouse__c',
                                    'ERP7__Product__c',
                                    'ERP7__Number_of_Item_In_Stock__c',
                                    'ERP7__Number_of_Item_Purchased_In__c',
                                    'ERP7__Number_of_Items_Dispatched__c',
                                    'ERP7__No_of_Items_Sold__c',
                                    'ERP7__Checked_In_Date__c'
                                    }, 'ERP7__Inventory_Stock__c');
                            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Warehouse__c,
                                                            Product__c, Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c
                                                            From Inventory_Stock__c
                                                            Where Product__c In: productIds And
                                                            Active__c = true
                                                            //And Number_of_Item_In_Stock__c > 0 
                                                            Order By Checked_In_Date__c ASC
                                                           ];
                        }
                        for (Id pId: productIds) {
                            Decimal myStock = 0;
                            List < Inventory_Stock__c > sites = new List < Inventory_Stock__c > ();
                            for (Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                                if (pId == WIIS.Product__c) {
                                    myStock += WIIS.Number_of_Item_In_Stock__c;
                                }
                            }
                            proStocks.put(pId, myStock);
                        }
                        for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                            if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c && soliBOMS.containsKey(soli.Id) && soliBOMS.get(soli.Id) != Null) {
                                for (ERP7__BOM__c bom: soliBOMS.get(soli.Id)) {
                                    soli.Insufficient_BOM__c = false;
                                    if ((proStocks.get(bom.ERP7__BOM_Component__c) < (soli.Quantity__c * bom.Quantity__c)) && productPriceBookMap.containsKey(bom.ERP7__BOM_Component__c)) {
                                        soli.Insufficient_BOM__c = true;
                                        soli.Order_Line_Status__c = 'In Progress';
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                // END ==> Reserve the non-kit products under solis
                
                /*
                Apply Taxes Start
                */
                if (PreventRecursiveLedgerEntry.SOLI_ApplyTaxes) {
                    //Moin added this on 06th June 2023
                    PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false;
                    Map<Id, Sales_Order_Line_Item__c> currentLineItems = new Map<Id, Sales_Order_Line_Item__c>([Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c,  Inventory_Tracked__c, ERP7__Organisation__c,
                                                                                                                Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Loyalty_Program__c, Checked_Out_Process__c, Is_Back_Order__c, Is_Pre_Order__c,
                                                                                                                Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, Commission__c, Commission_Rate_Card__c,
                                                                                                                Commission_Rate_Card__r.Commission_Plan__c, Status__c, Product__r.Track_Inventory__c, Sales_Order__r.Channel__c, Sales_Order__r.Order_Status__c, Sales_Order__r.Is_Back_Order__c, Sales_Order__r.Is_Pre_Order__c,
                                                                                                                ERP7__Asset__c, Asset__r.Serial__c, ERP7__Version__c, Cost__c, ERP7__PriceBookId__c,
                                                                                                                Sales_Order__r.ERP7__Order_Profile__c, Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c, Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c, Sales_Order__r.ERP7__Order_Profile__r.ERP7__Tax_Sourcing_Rules__c, Sales_Order__r.ERP7__Bill_To_Address__c, Sales_Order__r.ERP7__Bill_To_Address__r.Country__c, Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c, Sales_Order__r.ERP7__Bill_To_Address__r.City__c, Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c,
                                                                                                                Sales_Order__r.ERP7__Ship_To_Address__c, Sales_Order__r.ERP7__Ship_To_Address__r.Country__c, Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c, Sales_Order__r.ERP7__Ship_To_Address__r.City__c, Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, Tax__c
                                                                                                                From Sales_Order_Line_Item__c 
                                                                                                                Where Id In: system.trigger.New]);
                    
                    Set<Id> accprofileIds = new Set<Id>();
                    Set<Id> prIds = new Set<Id>();
                    Set<Id> pbIds = new Set<Id>();
                    List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
                    List<ERP7__Tax__c> productprofileTax = new List<ERP7__Tax__c>();
                    Map<Id, List<ERP7__Tax__c>> profileTaxesMap = new Map<Id, List<ERP7__Tax__c>>();
                    Map<String, List<ERP7__Tax__c>> productProfileTaxesMap = new Map<String, List<ERP7__Tax__c>>();
                    
                    for(Sales_Order_Line_Item__c soli : Trigger.New){
                        if(soli.Product__c != Null) prIds.add(soli.Product__c);
                        if(soli.ERP7__PriceBookId__c != Null) pbIds.add(soli.ERP7__PriceBookId__c);
                    }   
                    
                    List < PricebookEntry > priceBookEntries = [Select Id, Name, Product2Id, Pricebook2Id, ERP7__Purchase_Price__c from PricebookEntry where IsActive = true and Pricebook2Id In: pbIds and Product2Id In: prIds];
                    Map < String, PricebookEntry > productPriceBookMap = new map < String, PricebookEntry > ();
                    for (PricebookEntry IPE: priceBookEntries) {
                        productPriceBookMap.put(String.Valueof(IPE.Product2Id).substring(0,15)+String.Valueof(IPE.Pricebook2Id).substring(0,15), IPE);
                    }
                    prIds = new Set<Id>();
                    pbIds = new Set<Id>();
                    // Moin Changes Start
                    Set<String> poSet = new Set<String>();
                    Set<String> citySet = new Set<String>();
                    Set<String> provinceSet = new Set<String>();
                    // Moin Changes End
                    for(Sales_Order_Line_Item__c soli : Trigger.New){
                        if(soli.Product__c != Null && soli.ERP7__PriceBookId__c != Null && productPriceBookMap.containsKey(String.Valueof(soli.Product__c).substring(0,15)+String.Valueof(soli.ERP7__PriceBookId__c).substring(0,15))){
                            String ik = String.Valueof(soli.Product__c).substring(0,15)+String.Valueof(soli.ERP7__PriceBookId__c).substring(0,15);
                            PricebookEntry pb = productPriceBookMap.get(ik);
                            if(pb.ERP7__Purchase_Price__c != Null && soli.ERP7__Quantity__c != Null) {
                                soli.ERP7__Price_Book_Unit_Cost__c = pb.ERP7__Purchase_Price__c;
                                if(soli.ERP7__Cost__c == Null) soli.ERP7__Cost__c = pb.ERP7__Purchase_Price__c * soli.ERP7__Quantity__c;
                            }
                        }
                        if(currentLineItems.containsKey(soli.Id)){
                            Sales_Order_Line_Item__c msoli = currentLineItems.get(soli.Id);
                            if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c != Null) { //soli.Tax__c == Null && 
                                accprofileIds.add(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c);
                                if(msoli.Product__c != Null) prIds.add(msoli.Product__c);
                                if(msoli.ERP7__PriceBookId__c != Null) pbIds.add(msoli.ERP7__PriceBookId__c);
                            }
                        }
                        // Moin Changes Start
                        if(currentLineItems.containsKey(soli.Id)){
                            Sales_Order_Line_Item__c msoli = currentLineItems.get(soli.Id);
                            if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && msoli.Sales_Order__r.ERP7__Bill_To_Address__c != Null){
                                if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != '') poSet.add(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c);
                                if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != '') citySet.add(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c);
                                if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != '') provinceSet.add(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c);
                                //if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c;
                            }
                            if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && msoli.Sales_Order__r.ERP7__Ship_To_Address__c != Null){
                                if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != '') poSet.add(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c);
                                if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != '') citySet.add(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c);
                                if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != '') provinceSet.add(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c);
                                //if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c;
                            } 
                        }
                        // Moin Changes End
                        
                    }
                    
                    
                    
                    
                      
                    
                    Date todayDate = system.today();
                    String salestax = 'Sales Tax';
                    String allFieldsTaxes = UtilClass.selectStarFromSObject('ERP7__Tax__c');
                    //String queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null Order By ERP7__Province__c Desc';
                    String queryTaxes = '';
                    system.debug('poSet-->'+poSet);
                    system.debug('citySet-->'+citySet);
                    system.debug('provinceSet-->'+provinceSet);
                     //queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null AND (ERP7__Postal_Code__c IN :poSet or ERP7__City__c IN :citySet or ERP7__Province__c IN :provinceSet)  Order By ERP7__Province__c Desc';
                    if(poSet.size()>0 || citySet.size()>0 || provinceSet.size()>0) {
                        profileTax = [select ERP7__Tax_Plan__c, ERP7__Type__c, ERP7__Total_Tax__c, ERP7__Tax_Rate__c, ERP7__Tax_COA__c, ERP7__Province__c, ERP7__Product__c, ERP7__Postal_Code__c, ERP7__Other_Tax_Type__c, ERP7__Other_Tax_COA__c, ERP7__Other_Tax_Rate__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__c, ERP7__Expiry_Date__c, ERP7__Effective_Date__c, ERP7__Country__c, ERP7__Code__c, ERP7__City__c, ERP7__Account_Profile__c, ERP7__Active__c, ERP7__Apply_Tax_On__c, id, Name from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null AND (ERP7__Postal_Code__c IN :poSet or ERP7__City__c IN :citySet or ERP7__Province__c IN :provinceSet)  Order By ERP7__Province__c Desc];//Database.query(queryTaxes);
                        system.debug('If Called');
                        if(profileTax.size()==0){
                            profileTax = [select ERP7__Tax_Plan__c, ERP7__Type__c, ERP7__Total_Tax__c, ERP7__Tax_Rate__c, ERP7__Tax_COA__c, ERP7__Province__c, ERP7__Product__c, ERP7__Postal_Code__c, ERP7__Other_Tax_Type__c, ERP7__Other_Tax_COA__c, ERP7__Other_Tax_Rate__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__c, ERP7__Expiry_Date__c, ERP7__Effective_Date__c, ERP7__Country__c, ERP7__Code__c, ERP7__City__c, ERP7__Account_Profile__c, ERP7__Active__c, ERP7__Apply_Tax_On__c, id, Name from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null Order By ERP7__Province__c Desc];
                        }
                    }else{
                       profileTax = [select ERP7__Tax_Plan__c, ERP7__Type__c, ERP7__Total_Tax__c, ERP7__Tax_Rate__c, ERP7__Tax_COA__c, ERP7__Province__c, ERP7__Product__c, ERP7__Postal_Code__c, ERP7__Other_Tax_Type__c, ERP7__Other_Tax_COA__c, ERP7__Other_Tax_Rate__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__c, ERP7__Expiry_Date__c, ERP7__Effective_Date__c, ERP7__Country__c, ERP7__Code__c, ERP7__City__c, ERP7__Account_Profile__c, ERP7__Active__c, ERP7__Apply_Tax_On__c, id, Name from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null Order By ERP7__Province__c Desc];
                       system.debug('Else Called');
                    } 
                    system.debug('profileTax-->'+profileTax);
                    queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c In :accprofileIds and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c != Null And ERP7__Product__c In : prIds Order By ERP7__Province__c Desc';
                    productprofileTax = Database.query(queryTaxes);
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
                    
                    for(ERP7__Tax__c pt : productprofileTax) {
                        String keey = String.valueof(pt.ERP7__Account_Profile__c)+String.valueof(pt.ERP7__Product__c);
                        if(productProfileTaxesMap.containsKey(keey)){
                            productProfileTaxesMap.get(keey).add(pt);
                        }
                        else {
                            List<ERP7__Tax__c> myprofileTaxes = new List<ERP7__Tax__c>();
                            myprofileTaxes.add(pt);
                            productProfileTaxesMap.put(keey,myprofileTaxes);
                        }
                    }
                    
                    for(Sales_Order_Line_Item__c soli : Trigger.New){
                        if(currentLineItems.containsKey(soli.Id)){
                            Sales_Order_Line_Item__c msoli = currentLineItems.get(soli.Id);
                            String key = String.valueof(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c)+String.valueof(msoli.ERP7__Product__c);
                            Boolean taxFound = false;
                            
                            if(productProfileTaxesMap.containsKey(key)){//soli.Tax__c == Null &&
                                List<Tax__c> taxes = productProfileTaxesMap.get(key);
                                String TaxPostalCode = '';
                                String TaxCity = '';
                                String TaxProvince = '';
                                String TaxCountry = '';
                                if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && msoli.Sales_Order__r.ERP7__Bill_To_Address__c != Null){
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != '') TaxPostalCode = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != '') TaxCity = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != '') TaxProvince = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c;
                                }
                                if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && msoli.Sales_Order__r.ERP7__Ship_To_Address__c != Null){
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != '') TaxPostalCode = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != '') TaxCity = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != '') TaxProvince = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c;
                                } 
                                
                                //Updating the tax rules to exclude city tax
                                for(Tax__c tax : taxes){
                                    if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                                        soli.Tax__c = tax.Id;
                                        soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                        if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                        taxFound = true;
                                        break;
                                    } 
                                }
                              
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        //(TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && 
                                        if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                                            soli.Tax__c = tax.Id;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        //(TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && (TaxProvince == Null || TaxProvince == '') && 
                                        if((TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && tax.ERP7__Country__c == TaxCountry)){
                                            soli.Tax__c = tax.Id;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        if((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && (tax.ERP7__Country__c == Null || tax.ERP7__Country__c == '')){
                                            soli.Tax__c = tax.Id;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            if(!taxFound  && profileTaxesMap.containsKey(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c)){//&& soli.Tax__c == Null
                                List<Tax__c> taxes = profileTaxesMap.get(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__c);
                                String TaxPostalCode = '';
                                String TaxCity = '';
                                String TaxProvince = '';
                                String TaxCountry = '';
                                if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && msoli.Sales_Order__r.ERP7__Bill_To_Address__c != Null){
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != '') TaxPostalCode = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c != '') TaxCity = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__City__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c != '') TaxProvince = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__State__c;
                                    if(msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Bill_To_Address__r.ERP7__Country__c;
                                }
                                if(msoli.Sales_Order__r.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && msoli.Sales_Order__r.ERP7__Ship_To_Address__c != Null){
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != '') TaxPostalCode = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c != '') TaxCity = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__City__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c != '') TaxProvince = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__State__c;
                                    if(msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != Null && msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c != '') TaxCountry = msoli.Sales_Order__r.ERP7__Ship_To_Address__r.ERP7__Country__c;
                                }
                                
                                for(Tax__c tax : taxes){
                                    if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                                        soli.Tax__c = tax.Id;
                                        if(tax.ERP7__Tax_Rate__c == Null) tax.ERP7__Tax_Rate__c = 0;
                                        if(soli.Base_Price__c == Null) soli.Base_Price__c = 0; 
                                        if(soli.ERP7__Discount_Amount__c == Null) soli.ERP7__Discount_Amount__c = 0;
                                        soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                        if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                        taxFound = true;
                                        break;
                                    } 
                                }
                                
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '')  && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){

                                            soli.Tax__c = tax.Id;
                                            if(tax.ERP7__Tax_Rate__c == Null) tax.ERP7__Tax_Rate__c = 0;
                                            if(soli.Base_Price__c == Null) soli.Base_Price__c = 0; 
                                            if(soli.ERP7__Discount_Amount__c == Null) soli.ERP7__Discount_Amount__c = 0;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        if((TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && tax.ERP7__Country__c == TaxCountry)){
                                            soli.Tax__c = tax.Id;
                                            if(tax.ERP7__Tax_Rate__c == Null) tax.ERP7__Tax_Rate__c = 0;
                                            if(soli.Base_Price__c == Null) soli.Base_Price__c = 0; 
                                            if(soli.ERP7__Discount_Amount__c == Null) soli.ERP7__Discount_Amount__c = 0;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                                if(!taxFound){
                                    for(Tax__c tax : taxes){
                                        if((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && (tax.ERP7__Country__c == Null || tax.ERP7__Country__c == '')){
                                            soli.Tax__c = tax.Id;
                                            if(tax.ERP7__Tax_Rate__c == Null) tax.ERP7__Tax_Rate__c = 0;
                                            if(soli.Base_Price__c == Null) soli.Base_Price__c = 0; 
                                            if(soli.ERP7__Discount_Amount__c == Null) soli.ERP7__Discount_Amount__c = 0;
                                            soli.VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            if(tax.ERP7__Other_Tax_Rate__c != Null) soli.Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.Cost__c != Null)? (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Cost__c)).setScale(2) : (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);
                                            taxFound = true;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            soli.ERP7__Total_Price__c=soli.ERP7__Base_Price__c-soli.ERP7__Discount_Amount__c+soli.ERP7__Other_Tax__c+soli.ERP7__VAT_Amount__c;
                        }
                    }  
                }
                /*
                Apply Taxes End
                */
                                
                                
                                
                /*
                FOR UPDATING LOGISTIC QUANTITY OF SOLI Starts
                */
                    // if (PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity && !System.Trigger.isInsert) {
                    //     List<ERP7__Logistic_Line_Item__c> logList = [SELECT Id, Name, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Sales_Order_Line_Item__c In :System.Trigger.New];
                    //     if(logList.size() > 0) PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false;
                    //     //  List<OrderItem> ord = System.Trigger.New ;  
                    //     if(logList.size() > 0){
                    //         for(ERP7__Sales_Order_Line_Item__c soli : System.Trigger.New){ 
                    //             if (soli.Id == null) continue;

                    //             Decimal LogQuantity = 0; 
                    //             for(ERP7__Logistic_Line_Item__c logLi : logList){
                    //                 if(logLi.ERP7__Sales_Order_Line_Item__c == soli.Id && logLi.ERP7__Quantity__c != Null) LogQuantity += logLi.ERP7__Quantity__c;                                           
                    //             }
                    //             soli.ERP7__Logistic_Quantity__c = LogQuantity; 
                    //         } 
                    //     }
                    // }   

                    if (PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity) {
                        // CASE 1: INSERT - Just set it to 0. No query needed.
                        if (System.Trigger.isInsert) {
                            for (ERP7__Sales_Order_Line_Item__c soli : (List<ERP7__Sales_Order_Line_Item__c>)System.Trigger.New) {
                                soli.ERP7__Logistic_Quantity__c = 0;
                            }
                        }
                        
                        // CASE 2: UPDATE - Run your existing logic (Calculations)
                        else if (System.Trigger.isUpdate) {
                            List<ERP7__Logistic_Line_Item__c> logList = [
                                SELECT Id, Name, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c 
                                FROM ERP7__Logistic_Line_Item__c 
                                WHERE ERP7__Sales_Order_Line_Item__c IN :System.Trigger.New
                            ];

                            // Only run logic if we found related items
                            if (logList.size() > 0) {
                                PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false;

                                for (ERP7__Sales_Order_Line_Item__c soli : (List<ERP7__Sales_Order_Line_Item__c>)System.Trigger.New) { 
                                    Decimal LogQuantity = 0; 
                                    for (ERP7__Logistic_Line_Item__c logLi : logList) {
                                        // Safe to check ID now because we are in Update context
                                        if (logLi.ERP7__Sales_Order_Line_Item__c == soli.Id && logLi.ERP7__Quantity__c != null) {
                                            LogQuantity += logLi.ERP7__Quantity__c;                                       
                                        }
                                    }
                                    soli.ERP7__Logistic_Quantity__c = LogQuantity; 
                                }
                            }
                        }
                    }
                /*
                FOR UPDATING LOGISTIC QUANTITY OF SOLI Ends
                */
                
            }
            
            if(Trigger.IsInsert){// || Trigger.IsUpdate) && PreventRecursiveLedgerEntry.SOLI_BackRun
                PreventRecursiveLedgerEntry.SOLI_BackRun = false;
                List < ERP7__Employees__c > currentEmployees = new List < ERP7__Employees__c > ();
                currentEmployees = [Select Id, ERP7__Channel__c From ERP7__Employees__c Where ERP7__Employee_User__c = : UserInfo.getUserId() And ERP7__Active__c = True Order by CreatedDate Asc Limit 1];
                if(currentEmployees.size() > 0){
                    List < Id > siteIds = new List < Id > ();
                    List < ERP7__Distribution_Channel__c > DistributionChannel = [Select Id,  ERP7__Channel__c, ERP7__Site__c From ERP7__Distribution_Channel__c Where ERP7__Channel__c = : currentEmployees[0].ERP7__Channel__c And ERP7__Active__c = true];
                    
                    for(ERP7__Distribution_Channel__c DC: DistributionChannel) siteIds.add(DC.ERP7__Site__c);
                    
                    Set < Id > nonKitProdIds = new Set < Id > ();
                    List<ERP7__Inventory_Stock__c> nonKitWarehouseItemInventoryStocks = new List<ERP7__Inventory_Stock__c>();
                    Map<Id, Product2> SOLI_prod = new Map<Id, Product2>();
                    Map<Id, Decimal> nonKitproStocks = new Map<Id, Decimal>();
                    for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                        if (soli.ERP7__Inventory_Tracked__c) {
                            nonKitProdIds.add(soli.ERP7__Product__c);
                        }
                    }
                    SOLI_prod = new Map<Id, Product2>([SELECT Id, ERP7__Allow_Back_Orders__c FROM Product2 WHERE Id IN: nonKitProdIds]);
                    nonKitWarehouseItemInventoryStocks = [SELECT Id, ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c FROM ERP7__Inventory_Stock__c WHERE  ERP7__Warehouse__c IN: siteIds AND ERP7__Product__c In: nonKitProdIds AND ERP7__Product__r.ERP7__Allow_Back_Orders__c = true AND ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Active__c = true Order By ERP7__Checked_In_Date__c ASC LIMIT 9999];
                    for (Id pId: nonKitProdIds) {
                        Decimal nonKitmyStock = 0;
                        for (ERP7__Inventory_Stock__c WIIS: nonKitWarehouseItemInventoryStocks) {
                            if (pId == WIIS.ERP7__Product__c) nonKitmyStock += WIIS.Number_of_Item_In_Stock__c;
                        }
                        nonKitproStocks.put(pId, nonKitmyStock);
                    }
                    for (Sales_Order_Line_Item__c soli: System.Trigger.New){
                        if(!soli.ERP7__Is_Back_Order__c && nonKitproStocks.containsKey(soli.ERP7__Product__c) && SOLI_prod.get(soli.ERP7__Product__c).ERP7__Allow_Back_Orders__c && (nonKitproStocks.get(soli.ERP7__Product__c) < soli.ERP7__Quantity__c || nonKitproStocks.get(soli.ERP7__Product__c) == 0 || nonKitproStocks.get(soli.ERP7__Product__c) == null ))
                            soli.ERP7__Is_Back_Order__c = true;
                        //else  soli.ERP7__Is_Back_Order__c = false;
                        
                    }
                }
            }
            
        } // End Trigger.IsBefore 
        else {
            /* Start ==> Reserve the non-kit products under solis */
            System.debug('isAfter:'+Trigger.isAfter);
            System.debug('PreventRecursiveLedgerEntry.SOLI_AllocateStock:'+PreventRecursiveLedgerEntry.SOLI_AllocateStock);
            if (PreventRecursiveLedgerEntry.SOLI_AllocateStock) {
                
                System.debug('Trigger.IsInsert:'+Trigger.IsInsert);
                if (Trigger.IsInsert || Trigger.IsUndelete || Trigger.IsUpdate) {   //Trigger.IsInsert || Trigger.IsUndelete
                    set < Id > SOLI2Update = new set < Id > ();
                    for (Sales_Order_Line_Item__c SOLI_New: System.Trigger.New){
                        if (SOLI_New.Inventory_Tracked__c && SOLI_New.ERP7__Allocate_Stock__c && SOLI_New.ERP7__Ready_To_Pick_Pack__c) SOLI2Update.add(SOLI_New.Id);                        
                    }
                    
                    if(SOLI2Update.size() > 0 && (Trigger.IsInsert || Trigger.IsUndelete)) OrderInventoryUtils.createProductPurchaseLineItems(SOLI2Update);
                    
                    if(SOLI2Update.size() > 0 && Trigger.IsUpdate){
                        List <Stock_Outward_Line_Item__c> SOutwardList = [Select Id, Name From Stock_Outward_Line_Item__c  Where Sales_Order_Line_Item__c In: SOLI2Update And ERP7__Picked_Date__c = Null And Active__c = true];
                        if(SOutwardList.size() == 0) OrderInventoryUtils.createProductPurchaseLineItems(SOLI2Update);
                    }
                }
                
                //Moin added this 06th june 2023
                PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; 
                
                System.debug('Trigger.IsUpdate:'+Trigger.IsUpdate);
                if (Trigger.IsUpdate) {
                    set < Id > SOLI2Update = new set < Id > ();
                    set < Id > SOLI2UpdateNew = new set < Id > ();
                    set < Id > lineItemIds = new set < Id > ();
                    for (Sales_Order_Line_Item__c SOLI_New: System.Trigger.New) {
                        lineItemIds.add(SOLI_New.Id);
                    }
                    
                    List < Stock_Outward_Line_Item__c > pplis2verify = [Select Id, Name, Active__c, Product__c, Quantity__c, Sales_Order_Line_Item__c,
                        Site_Product_Service_Inventory_Stock__c,ERP7__Picked_Date__c 
                        From Stock_Outward_Line_Item__c
                        Where Sales_Order_Line_Item__c In: lineItemIds And
                        ERP7__Picked_Date__c = Null And
                        Active__c = true
                    ];
                    
                    
                    for (Sales_Order_Line_Item__c SOLI_New: System.Trigger.New) {
                        Boolean IsStockAllocated = false;
                        Decimal OldQuant = 0;
                        if (SOLI_New.ERP7__Allocate_Stock__c && SOLI_New.ERP7__Product__c != Null && SOLI_New.Inventory_Tracked__c && SOLI_New.ERP7__Ready_To_Pick_Pack__c && !SOLI_New.ERP7__Is_Back_Order__c) { // && !SOLI_New.ERP7__Is_Back_Order__c
                            System.debug('Inside if 446');
                            for (Stock_Outward_Line_Item__c OutLine: pplis2verify) {
                                if (SOLI_New.Id == OutLine.Sales_Order_Line_Item__c && (SOLI_New.ERP7__Product__c == OutLine.ERP7__Product__c) && (OutLine.ERP7__Quantity__c != SOLI_New.Quantity__c)) { // || SOLI_New.ERP7__Asset__c == OutLine.ERP7__Fixed_Asset__c
                                    IsStockAllocated = true;
                                    if(OutLine.ERP7__Quantity__c == Null)  OutLine.ERP7__Quantity__c = SOLI_New.Quantity__c;
                                    else if (OutLine.ERP7__Quantity__c != Null) OldQuant += OutLine.ERP7__Quantity__c;
                                }
                            }
                            
                            if(IsStockAllocated){
                                SOLI2Update.add(SOLI_New.Id);
                            }else{
                                SOLI2UpdateNew.add(SOLI_New.Id);
                            }
                        }
                    }
                    
                    System.debug('SOLI2UpdateNew.size():'+SOLI2UpdateNew.size());
                    System.debug('SOLI2Update.size():'+SOLI2Update.size());
                    if(SOLI2UpdateNew.size() > 0) OrderInventoryUtils.createProductPurchaseLineItems(SOLI2UpdateNew);
                    if(SOLI2Update.size() > 0) OrderInventoryUtils.updateProductPurchaseLineItems(SOLI2Update); // updateProductPurchaseLineItems
                    
                }
                
            }
            
            /* End ==> Reserve the non-kit products under solis */
            
            /* Start ==> Create MRPS for SOLIs when kit is exploded based on BOM and its versions */
            if (PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode) {
                //Moin added this 06th june 2023
                PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;
                if (Trigger.IsInsert || Trigger.IsUpdate) {
                    list < Id > soliIds2explode = new list < Id > ();
                    list < Id > proIds = new list < Id > ();
                    List < ERP7__MRP__c > mrps2delete = new List < ERP7__MRP__c > ();
                    Map < Id, List < ERP7__MRP__c >> soliMrps = new Map < Id, List < ERP7__MRP__c >> ();
                    Map < Id, List < ERP7__BOM__c >> soliBOMS = new Map < Id, List < ERP7__BOM__c >> ();
                    list < Id > soliBOMVersion = new List < Id > ();
                    List < ERP7__MRP__c > MRPS2Insert = new List < ERP7__MRP__c > ();
                    Set < Id > productIds = new Set < Id > ();
                    Set < Id > priceBookIds = new Set < Id > ();
                    for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                        if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c) {
                            soliIds2explode.add(soli.Id);
                            proIds.add(soli.ERP7__Product__c);
                            soliBOMVersion.add(soli.Version__c);
                            priceBookIds.add(soli.ERP7__PriceBookId__c);
                        }
                    }
                    if (proIds.size() > 0 || soliIds2explode.size() > 0) {
                        List < ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__MRP_Product__c,
                            ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name
                            From ERP7__MRP__c
                            Where RecordType.Name = 'MRP Kit'
                            And
                            Sales_Order_Line_Item__c In: soliIds2explode
                        ];
                        List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name,
                            ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name,
                            BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c,
                            BOM_Version__r.Type__c, BOM_Version__r.Status__c
                            From ERP7__BOM__c
                            Where((ERP7__Active__c = true And BOM_Version__r.RecordType.Name = 'Kit'
                                And ERP7__BOM_Product__c In: proIds And BOM_Version__r.Active__c = true And BOM_Version__r.Start_Date__c <= Today And BOM_Version__r.To_Date__c >=
                                Today And(BOM_Version__r.Type__c = 'Assembly'
                                    Or BOM_Version__r.Type__c = 'Sales') AND BOM_Version__r.Status__c = 'Certified') OR(Id In: soliBOMVersion AND BOM_Version__r.Status__c = 'Certified'))
                            Order by BOM_Version__r.Default__c DESC
                        ];
                        for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                            if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c) {
                                List < ERP7__MRP__c > myMRPS = new List < ERP7__MRP__c > ();
                                for (ERP7__MRP__c mrp: MRPS) {
                                    if (soli.Id == mrp.Sales_Order_Line_Item__c) myMRPS.add(mrp);
                                }
                                soliMrps.put(soli.Id, myMRPS);
                                List < ERP7__BOM__c > myBOMS = new List < ERP7__BOM__c > ();
                                List < ERP7__BOM__c > myAllBOMS = new List < ERP7__BOM__c > ();
                                for (ERP7__BOM__c bom: BOMS) {
                                    if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c != Null && soli.Version__c == bom.BOM_Version__c) {
                                        myBOMS.add(bom);
                                        productIds.add(bom.ERP7__BOM_Component__c);
                                    } else if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c ==
                                        true) {
                                        myBOMS.add(bom);
                                        productIds.add(bom.ERP7__BOM_Component__c);
                                    }
                                    if (soli.Product__c == bom.ERP7__BOM_Product__c && soli.Version__c == Null && bom.BOM_Version__c == Null) {
                                        myAllBOMS.add(bom);
                                        productIds.add(bom.ERP7__BOM_Component__c);
                                    }
                                }
                                if (myBOMS.size() > 0) soliBOMS.put(soli.Id, myBOMS);
                                else if (myAllBOMS.size() > 0) soliBOMS.put(soli.Id, myAllBOMS);
                            }
                        }
                    }
                    
                    if (productIds.size() > 0) {
                        List < PricebookEntry > priceBookEntries = [Select Id, Name, Product2Id, Product2.ERP7__Track_Inventory__c from PricebookEntry where IsActive = true and Pricebook2Id In:
                            priceBookIds and Product2Id In: productIds
                        ];
                        Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
                        for (PricebookEntry IPE: priceBookEntries) {
                            if (IPE.Product2.ERP7__Track_Inventory__c) productPriceBookMap.put(IPE.Product2Id, IPE);
                        }
                        Id rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();

                        Map < Id, String > soliOldVersion = new Map < Id, String > ();
                        Map < Id, Decimal > soliOldQuantity = new Map < Id, Decimal > ();
                        if (Trigger.IsUpdate) {
                            for (Sales_Order_Line_Item__c soli: System.Trigger.Old) {
                                soliOldQuantity.put(soli.Id, soli.Quantity__c);
                                soliOldVersion.put(soli.Id, soli.Version__c);
                            }
                        }
                        for (Sales_Order_Line_Item__c soli: System.Trigger.New) {
                            /*
                                Handles the deletion of MRPs if BOM version on soli is changed..
                            */
                            Decimal oldQuantity = 0;
                            if (soliMrps != null && soliMrps.containsKey(soli.Id)) {
                                for (ERP7__MRP__c mrp: soliMrps.get(soli.Id)) {
                                    if (mrp.ERP7__Total_Amount_Required__c != Null) oldQuantity = oldQuantity + (mrp.ERP7__Total_Amount_Required__c / mrp.ERP7__BOM__r.ERP7__Quantity__c);
                                }
                            }
                            if (soli.ERP7__Inventory_Tracked__c == false && soli.Is_Kit__c == true && soli.Explode__c == true && ((soliOldVersion.containsKey(soli.Id) && String.valueof(
                                    soli.Version__c) != soliOldVersion.get(soli.Id)) || oldQuantity != soli.Quantity__c) && soliMrps.containsKey(soli.Id) && soliMrps.get(soli.Id).size() >
                                0) {
                                mrps2delete.addAll(soliMrps.get(soli.Id));
                                soliMrps.get(soli.Id).clear();
                            }
                            if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c && soliMrps.containsKey(soli.Id) && soliMrps.get(soli.Id).size() == 0 &&
                                soliBOMS.containsKey(soli.Id)) {
                                for (ERP7__BOM__c bom: soliBOMS.get(soli.Id)) {
                                    if (productPriceBookMap.containsKey(bom.ERP7__BOM_Component__c)) {
                                        ERP7__MRP__c MRP = new ERP7__MRP__c();
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = BOM.Name;} else{ /* no access */ }
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c * soli.Quantity__c;} else{ /* no access */ }
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.Id;} else{ /* no access */ }
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isUpdateable()){MRP.Version__c = soli.Version__c;} else{ /* no access */ }
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c;} else{ /* no access */ }
                                        if(Schema.sObjectType.ERP7__MRP__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Sales_Order_Line_Item__c.isUpdateable()){MRP.Sales_Order_Line_Item__c = soli.Id;} else{ /* no access */ }
                                        if (rTpe_MRPKIT != null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()) { MRP.RecordTypeId = rTpe_MRPKIT; } else{ /* no access */ }
                                        if (soli.ERP7__Insufficient_BOM__c != true && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()) { MRP.Status__c = 'Reserved'; } else{ /* no access */ }
                                        MRPS2Insert.add(MRP);
                                    }
                                }
                            }
                        }
                    }
                    if (MRPS2Insert.size() > 0 && Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){  upsert MRPS2Insert; } else { /* no access */ }
                    if (mrps2delete.size() > 0) {
                        List < Id > mrpIds = new List < Id > ();
                        for (MRP__c MRP: mrps2delete) {
                            mrpIds.add(MRP.Id);
                        }
                        if (mrpIds.size() > 0) {
                            List < Stock_Outward_Line_Item__c > SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c,
                                MRP_Material_Requirements_Planning__c,
                                Product__c, Purchase_Orders__c, Quantity__c,
                                Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c
                                From Stock_Outward_Line_Item__c
                                Where MRP_Material_Requirements_Planning__c In: mrpIds
                            ];
                            if (SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable())  { delete SDLIs; } else { /* no access */ }
                            if(MRP__c.sObjectType.getDescribe().isDeletable()){ delete mrps2delete; } else { /* no access */ }
                        }
                    }
                }
            } 
            /* End ==> Create MRPS for SOLIs when kit is exploded based on BOM and its versions ... */
        } // End Trigger.IsAfter
    }
    
}