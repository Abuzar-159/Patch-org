trigger InventoryManaging_OrderProduct on OrderItem (before insert, before update, after insert, after update, before delete, after undelete) {
    
    if (!PreventRecursiveLedgerEntry.testCasesTransactions && PreventRecursiveLedgerEntry.OrderTriggerDuringMO) {
        System.debug('inside InventoryManaging_OrderProduct Trigger before');
        if (Trigger.IsBefore) {
            system.debug('isdelete~>' + Trigger.IsDelete);
            if (Trigger.IsDelete) { 
                system.debug('5');
                for (OrderItem ord : System.Trigger.Old) {
                    if (ord.ERP7__Ready_To_Pick_Pack__c && (ord.ERP7__Logistic_Quantity__c != 0.0 || ord.ERP7__Logistic_Quantity__c != null)) {
                        ord.addError('Logistic is created, you cannot delete order product');
                        System.debug('yes i did');
                    }
                }
                OrderProductInventoryUtils.deleteProductPurchaseLineItems(System.Trigger.Old);
            } 
            if (Trigger.IsInsert || Trigger.IsUpdate) { 
                // New Validation: Prevent setting Explode__c to true if manual logistics exist for the OrderItem
                if (Trigger.IsUpdate) {
                    // Collect OrderItem IDs
                    Set<Id> orderItemIds = new Set<Id>();
                    for (OrderItem soli : Trigger.New) {
                        orderItemIds.add(soli.Id);
                    }
                    // Query Logistic Line Items for the OrderItems
                    List<ERP7__Logistic_Line_Item__c> existingLogistics = [
                        SELECT Id, ERP7__Order_Product__c 
                        FROM ERP7__Logistic_Line_Item__c 
                        WHERE ERP7__Order_Product__c IN :orderItemIds
                    ];
                    // Map OrderItems to their Logistic Line Items
                    Map<Id, List<ERP7__Logistic_Line_Item__c>> orderItemToLogisticsMap = new Map<Id, List<ERP7__Logistic_Line_Item__c>>();
                    for (ERP7__Logistic_Line_Item__c logItem : existingLogistics) {
                        if (!orderItemToLogisticsMap.containsKey(logItem.ERP7__Order_Product__c)) {
                            orderItemToLogisticsMap.put(logItem.ERP7__Order_Product__c, new List<ERP7__Logistic_Line_Item__c>());
                        }
                        orderItemToLogisticsMap.get(logItem.ERP7__Order_Product__c).add(logItem);
                    }

                    // Check each OrderItem for Explode__c change
                    for (OrderItem newSoli : Trigger.New) {
                        OrderItem oldSoli = Trigger.OldMap.get(newSoli.Id);
                        // Check if Explode__c is being set to true and was previously false
                  /*      if (newSoli.ERP7__Explode__c && !oldSoli.ERP7__Explode__c && orderItemToLogisticsMap.containsKey(newSoli.Id)) {
                            newSoli.addError('You cannot explode since manual logistic is already created');
                        }*/
                        if (newSoli.ERP7__Explode__c 
    && !oldSoli.ERP7__Explode__c 
    && orderItemToLogisticsMap.containsKey(newSoli.Id)) {
    
    String lang = UserInfo.getLocale(); // or UserInfo.getLanguage() for UI lang
    String errorMsg;

    if (lang.startsWith('fr')) {
        errorMsg = 'Vous ne pouvez pas exploser car une logistique manuelle est déjà créée';
    } else {
        errorMsg = 'You cannot explode since manual logistic is already created';
    }

    newSoli.addError(errorMsg);
}

                    }
                }

                /* Start ==> Calculate whether there is sufficient stock of component available for each SOLI */ 
                if (PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck) {
                    PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false;
                    List<Id> soliIds2explode = new List<Id>();  
                    List<Id> proIds = new List<Id>(); 
                    Map<Id, List<ERP7__BOM__c>> soliBOMS = new Map<Id, List<ERP7__BOM__c>>(); 
                    Map<Id, Decimal> proStocks = new Map<Id, Decimal>(); 
                    List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStocks = new List<ERP7__Inventory_Stock__c>(); 
                    Set<Id> productIds = new Set<Id>();
                    Set<Id> priceBookIds = new Set<Id>();    
                    List<Id> soliBOMVersion = new List<Id>(); 
                    for (OrderItem soli : System.Trigger.New) { 
                        if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.ERP7__Explode__c) {
                            soliIds2explode.add(soli.Id); 
                            proIds.add(soli.Product2Id); 
                            priceBookIds.add(soli.ERP7__PriceBookId__c); 
                            if (soli.ERP7__Version__c != null) soliBOMVersion.add(soli.ERP7__Version__c);
                        }
                    } 
                    system.debug('soliIds2explode : ' + soliIds2explode.size());
                    system.debug('proIds : ' + proIds.size());
                    system.debug('priceBookIds : ' + priceBookIds.size());
                    system.debug('soliBOMVersion : ' + soliBOMVersion.size());
                    Set<Id> alternateBOMs = new Set<Id>();
                    Set<Id> alternateBOMProds = new Set<Id>();
                    if (proIds.size() > 0) { 
                        List<ERP7__BOM__c> BOMS = [
                            SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.ERP7__Type__c, 
                                   ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c, ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c, 
                                   ERP7__BOM_Product__c, ERP7__BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, 
                                   ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, 
                                   RecordType.Name, ERP7__BOM_Version__r.Active__c, ERP7__BOM_Version__r.Category__c, 
                                   ERP7__BOM_Version__r.Default__c, ERP7__BOM_Version__r.Start_Date__c, ERP7__BOM_Version__r.To_Date__c, 
                                   ERP7__BOM_Version__r.Type__c, ERP7__BOM_Version__r.Status__c 
                            FROM ERP7__BOM__c  
                            WHERE ((ERP7__Active__c = true AND ERP7__Type__c != 'Alternate' AND ERP7__BOM_Version__r.RecordType.Name = 'Kit' 
                                    AND ERP7__BOM_Product__c IN :proIds AND ERP7__BOM_Version__r.Active__c = true 
                                    AND ERP7__BOM_Version__r.Start_Date__c <= TODAY AND ERP7__BOM_Version__r.To_Date__c >= TODAY 
                                    AND (ERP7__BOM_Version__r.Type__c = 'Assembly' OR ERP7__BOM_Version__r.Type__c = 'Sales') 
                                    AND ERP7__BOM_Version__r.Status__c = 'Certified') 
                                   OR (Id IN :soliBOMVersion AND ERP7__BOM_Version__r.Status__c = 'Certified'))    
                            ORDER BY ERP7__BOM_Version__r.Default__c DESC
                        ];  
                        if (BOMS != null && BOMS.size() > 0) { 
                            for (OrderItem soli : System.Trigger.New) { 
                                if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.ERP7__Explode__c) { 
                                    List<ERP7__BOM__c> myBOMS = new List<ERP7__BOM__c>(); 
                                    List<ERP7__BOM__c> myAllBOMS = new List<ERP7__BOM__c>();    
                                    for (ERP7__BOM__c bom : BOMS) {
                                        if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c != null && soli.ERP7__Version__c == bom.ERP7__BOM_Version__c) {
                                            productIds.add(bom.ERP7__BOM_Component__c);  
                                            myBOMS.add(bom);
                                        } else if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c == null && bom.ERP7__BOM_Version__c != null && bom.ERP7__BOM_Version__r.Default__c == true) {
                                            productIds.add(bom.ERP7__BOM_Component__c);  
                                            myBOMS.add(bom); 
                                        } else if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c == null && bom.ERP7__BOM_Version__c == null) {
                                            productIds.add(bom.ERP7__BOM_Component__c);  
                                            myAllBOMS.add(bom); 
                                        }
                                        if (soli.Product2Id == bom.ERP7__BOM_Product__c && bom.ERP7__BOM_Alternate_Of__c != null) {
                                            alternateBOMs.add(bom.ERP7__BOM_Alternate_Of__c);
                                            alternateBOMProds.add(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c);
                                        }
                                    }  
                                    if (myBOMS.size() > 0) { 
                                        soliBOMS.put(soli.Id, myBOMS); 
                                    } else if (myAllBOMS.size() > 0) {
                                        soliBOMS.put(soli.Id, myAllBOMS); 
                                    }
                                }
                            }
                        }
                    }  
                    if (productIds.size() > 0) { 
                        List<PricebookEntry> priceBookEntries = [
                            SELECT Id, Name, Product2Id, Product2.ERP7__Track_Inventory__c 
                            FROM PricebookEntry 
                            WHERE IsActive = true AND Pricebook2Id IN :priceBookIds AND (Product2Id IN :productIds OR Product2Id IN :alternateBOMProds)
                        ]; 
                        Map<Id, PricebookEntry> productPriceBookMap = new Map<Id, PricebookEntry>(); 
                        for (PricebookEntry IPE : priceBookEntries) { 
                            if (IPE.Product2.ERP7__Track_Inventory__c) {
                                productPriceBookMap.put(IPE.Product2Id, IPE); 
                            }
                        }  
                        if (Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) { 
                            UtilClass.FlsCheck(new String[] { 
                                'ERP7__Active__c', 'ERP7__Organisation__c', 'ERP7__Warehouse__c', 'ERP7__Product__c', 
                                'ERP7__Number_of_Item_In_Stock__c', 'ERP7__Number_of_Item_Purchased_In__c', 
                                'ERP7__Number_of_Items_Dispatched__c', 'ERP7__No_of_Items_Sold__c', 'ERP7__Checked_In_Date__c'
                            }, 'ERP7__Inventory_Stock__c');  
                            WarehouseItemInventoryStocks = [
                                SELECT Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Warehouse__c, ERP7__Product__c, 
                                       ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, 
                                       ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  
                                FROM ERP7__Inventory_Stock__c  
                                WHERE (ERP7__Product__c IN :productIds OR ERP7__Product__c IN :alternateBOMProds) 
                                AND ERP7__Active__c = true AND ERP7__Number_of_Item_In_Stock__c > 0 
                                ORDER BY ERP7__Checked_In_Date__c ASC 
                            ]; 
                        } 
                        for (Id pId : productIds) { 
                            Decimal myStock = 0; 
                            List<ERP7__Inventory_Stock__c> sites = new List<ERP7__Inventory_Stock__c>(); 
                            for (ERP7__Inventory_Stock__c WIIS : WarehouseItemInventoryStocks) { 
                                if (pId == WIIS.ERP7__Product__c) { 
                                    myStock += WIIS.ERP7__Number_of_Item_In_Stock__c;   
                                }
                            } 
                            proStocks.put(pId, myStock); 
                        } 
                        for (Id alternatedProdId : alternateBOMProds) {
                            Decimal myStock = 0; 
                            List<ERP7__Inventory_Stock__c> sites = new List<ERP7__Inventory_Stock__c>(); 
                            for (ERP7__Inventory_Stock__c WIIS : WarehouseItemInventoryStocks) { 
                                if (alternatedProdId == WIIS.ERP7__Product__c) { 
                                    myStock += WIIS.ERP7__Number_of_Item_In_Stock__c;   
                                }
                            } 
                            proStocks.put(alternatedProdId, myStock); 
                        }
                        for (OrderItem soli : System.Trigger.New) { 
                            if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.ERP7__Explode__c && soliBOMS.containsKey(soli.Id) && soliBOMS.get(soli.Id) != null && soli.ERP7__Logistic_Quantity__c == 0) {  
                                for (ERP7__BOM__c bom : soliBOMS.get(soli.Id)) { 
                                    soli.ERP7__Insufficient_BOM__c = false; 
                                    if (bom.ERP7__BOM_Alternate_Of__c != null) {
                                        if (((proStocks.get(bom.ERP7__BOM_Component__c) < (soli.Quantity * bom.ERP7__Quantity__c)) && 
                                             (proStocks.get(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c) < (soli.Quantity * bom.ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c))) && 
                                            productPriceBookMap.containsKey(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c)) { 
                                            system.debug('if alternate');
                                            soli.ERP7__Insufficient_BOM__c = true;    
                                            soli.Order_Line_Status__c = 'In Progress'; 
                                            break; 
                                        }   
                                    } else if ((proStocks.get(bom.ERP7__BOM_Component__c) < (soli.Quantity * bom.ERP7__Quantity__c)) && 
                                               productPriceBookMap.containsKey(bom.ERP7__BOM_Component__c)) { 
                                        system.debug('else');
                                        soli.ERP7__Insufficient_BOM__c = true;    
                                        soli.Order_Line_Status__c = 'In Progress'; 
                                        break; 
                                    } 
                                } 
                                system.debug('soli.Insufficient_BOM__c : ' + soli.ERP7__Insufficient_BOM__c);
                            } 
                        }  
                    }
                }
                /* END ==> Reserve the non-kit products under solis */
                /* Apply Taxes Start */  
                if (PreventRecursiveLedgerEntry.SOLI_ApplyTaxes) {
                    system.debug('inhere PreventRecursiveLedgerEntry.SOLI_ApplyTaxes');
                    Map<Id, OrderItem> currentLineItems = new Map<Id, OrderItem>([
                        SELECT Id, ERP7__Base_Price__c, ERP7__Discount_Amount__c, ERP7__Invoice__c, UnitPrice, ERP7__Total_Price__c, 
                               TotalPrice, ERP7__VAT_Amount__c, ERP7__Inventory_Tracked__c, ERP7__Organisation__c, Product2Id, 
                               Product2.Name, Product2.ERP7__SKU__c, Quantity, OrderId, ERP7__Loyalty_Points__c, ERP7__Loyalty_Program__c, 
                               ERP7__Checked_Out_Process__c, ERP7__Is_Back_Order__c, ERP7__Is_Pre_Order__c, Order.Name, 
                               Order.ERP7__Sub_Total__c, Order.ERP7__Total_Discount__c, Order.ERP7__Total_Due__c, 
                               Order.ERP7__Total_Tax_Amount__c, ERP7__Commission__c, ERP7__Commission_Rate_Card__c, 
                               ERP7__Commission_Rate_Card__r.ERP7__Commission_Plan__c, ERP7__Status__c, Product2.ERP7__Track_Inventory__c, 
                               Order.ERP7__Channel__c, Order.ERP7__Stage__c, Order.ERP7__Is_Back_Order__c, Order.ERP7__Is_Pre_Order__c, 
                               ERP7__Asset__c, ERP7__Asset__r.ERP7__Serial__c, ERP7__Version__c, ERP7__Cost__c, ERP7__PriceBookId__c, 
                               Order.ERP7__Order_Profile__c, Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c, 
                               Order.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c, 
                               Order.ERP7__Order_Profile__r.ERP7__Tax_Sourcing_Rules__c, Order.ERP7__Bill_To_Address__c, 
                               Order.ERP7__Bill_To_Address__r.ERP7__Country__c, Order.ERP7__Bill_To_Address__r.ERP7__State__c, 
                               Order.ERP7__Bill_To_Address__r.ERP7__City__c, Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, 
                               Order.ERP7__Ship_To_Address__c, Order.ERP7__Ship_To_Address__r.ERP7__Country__c, 
                               Order.ERP7__Ship_To_Address__r.ERP7__State__c, Order.ERP7__Ship_To_Address__r.ERP7__City__c, 
                               Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Tax__c, Order.ERP7__Tax_Exempted__c 
                        FROM OrderItem 
                        WHERE Id IN :Trigger.New
                    ]);
                    Set<Id> accprofileIds = new Set<Id>();  
                    Set<Id> prIds = new Set<Id>(); 
                    Set<Id> pbIds = new Set<Id>(); 
                    List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>(); 
                    List<ERP7__Tax__c> productprofileTax = new List<ERP7__Tax__c>(); 
                    Map<Id, List<ERP7__Tax__c>> profileTaxesMap = new Map<Id, List<ERP7__Tax__c>>(); 
                    Map<String, List<ERP7__Tax__c>> productProfileTaxesMap = new Map<String, List<ERP7__Tax__c>>(); 
                    for (OrderItem soli : Trigger.New) { 
                        if (soli.Product2Id != null) prIds.add(soli.Product2Id); 
                        if (soli.ERP7__PriceBookId__c != null) pbIds.add(soli.ERP7__PriceBookId__c); 
                    }     
                    List<PricebookEntry> priceBookEntries = [
                        SELECT Id, Name, Product2Id, Pricebook2Id, ERP7__Purchase_Price__c 
                        FROM PricebookEntry 
                        WHERE IsActive = true AND Pricebook2Id IN :pbIds AND Product2Id IN :prIds
                    ]; 
                    Map<String, PricebookEntry> productPriceBookMap = new Map<String, PricebookEntry>();
                    for (PricebookEntry IPE : priceBookEntries) {
                        productPriceBookMap.put(String.valueOf(IPE.Product2Id).substring(0, 15) + String.valueOf(IPE.Pricebook2Id).substring(0, 15), IPE);
                    } 
                    for (OrderItem soli : Trigger.New) { 
                        if (soli.Product2Id != null && soli.ERP7__PriceBookId__c != null && 
                            productPriceBookMap.containsKey(String.valueOf(soli.Product2Id).substring(0, 15) + String.valueOf(soli.ERP7__PriceBookId__c).substring(0, 15))) { 
                            String ik = String.valueOf(soli.Product2Id).substring(0, 15) + String.valueOf(soli.ERP7__PriceBookId__c).substring(0, 15); 
                            PricebookEntry pb = productPriceBookMap.get(ik); 
                            if (pb.ERP7__Purchase_Price__c != null && soli.Quantity != null) { 
                                soli.ERP7__Price_Book_Unit_Cost__c = pb.ERP7__Purchase_Price__c; 
                                if (soli.ERP7__Cost__c == null) soli.ERP7__Cost__c = pb.ERP7__Purchase_Price__c * soli.Quantity; 
                            }  
                        } 
                    }
                    prIds = new Set<Id>();  
                    pbIds = new Set<Id>();  
                    for (OrderItem soli : Trigger.New) {                            
                        if (currentLineItems.containsKey(soli.Id)) {    
                            OrderItem msoli = currentLineItems.get(soli.Id);
                            if (soli.ERP7__Tax__c == null && msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c != null) {
                                accprofileIds.add(msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c); 
                                if (msoli.Product2Id != null) prIds.add(msoli.Product2Id); 
                                if (msoli.ERP7__PriceBookId__c != null) pbIds.add(msoli.ERP7__PriceBookId__c);  
                            }  
                        } 
                    }     
                    Date todayDate = System.today(); 
                    String salestax = 'Sales Tax'; 
                    String allFieldsTaxes = UtilClass.selectStarFromSObject('ERP7__Tax__c'); 
                    String queryTaxes = 'SELECT ' + String.escapeSingleQuotes(allFieldsTaxes) + ' FROM ERP7__Tax__c WHERE ERP7__Account_Profile__c IN :accprofileIds AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :salestax AND ERP7__Tax_Rate__c != null AND ERP7__Product__c = null ORDER BY ERP7__Province__c DESC'; 
                    profileTax = Database.query(queryTaxes); 
                    queryTaxes = 'SELECT ' + String.escapeSingleQuotes(allFieldsTaxes) + ' FROM ERP7__Tax__c WHERE ERP7__Account_Profile__c IN :accprofileIds AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :salestax AND ERP7__Tax_Rate__c != null AND ERP7__Product__c != null AND ERP7__Product__c IN :prIds ORDER BY ERP7__Province__c DESC';
                    productprofileTax = Database.query(queryTaxes);
                    system.debug('profileTax-->' + profileTax);
                    for (ERP7__Tax__c pt : profileTax) {   
                        if (profileTaxesMap.containsKey(pt.ERP7__Account_Profile__c)) {
                            profileTaxesMap.get(pt.ERP7__Account_Profile__c).add(pt);
                        } else { 
                            List<ERP7__Tax__c> myprofileTaxes = new List<ERP7__Tax__c>();  
                            myprofileTaxes.add(pt); 
                            profileTaxesMap.put(pt.ERP7__Account_Profile__c, myprofileTaxes);
                        } 
                    } 
                    system.debug('productprofileTax-->' + productprofileTax);
                    for (ERP7__Tax__c pt : productprofileTax) {   
                        String keey = String.valueOf(pt.ERP7__Account_Profile__c) + String.valueOf(pt.ERP7__Product__c);                            
                        if (productProfileTaxesMap.containsKey(keey)) { 
                            productProfileTaxesMap.get(keey).add(pt); 
                        } else {
                            List<ERP7__Tax__c> myprofileTaxes = new List<ERP7__Tax__c>();   
                            myprofileTaxes.add(pt); 
                            productProfileTaxesMap.put(keey, myprofileTaxes); 
                        } 
                    } 
                    for (OrderItem soli : Trigger.New) {   
                        if (currentLineItems.containsKey(soli.Id)) { 
                            OrderItem msoli = currentLineItems.get(soli.Id);         
                            String key = String.valueOf(msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c) + String.valueOf(msoli.Product2Id); 
                            Boolean taxFound = false; 
                            if (!msoli.Order.ERP7__Tax_Exempted__c) {
                                if (soli.ERP7__Tax__c == null && productProfileTaxesMap.containsKey(key)) {  
                                    List<ERP7__Tax__c> taxes = productProfileTaxesMap.get(key);            
                                    String TaxPostalCode = '';  
                                    String TaxCity = ''; 
                                    String TaxProvince = ''; 
                                    String TaxCountry = ''; 
                                    if (msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && msoli.Order.ERP7__Bill_To_Address__c != null) {    
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != '') 
                                            TaxPostalCode = msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;    
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c != '') 
                                            TaxCity = msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c;      
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c != '') 
                                            TaxProvince = msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c;                                        
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c != '') 
                                            TaxCountry = msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c;  
                                    } 
                                    if (msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && msoli.Order.ERP7__Ship_To_Address__c != null) {    
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != '') 
                                            TaxPostalCode = msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c;      
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c != '') 
                                            TaxCity = msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c;       
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c != '') 
                                            TaxProvince = msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c;     
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c != '') 
                                            TaxCountry = msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c; 
                                    } 
                                    for (ERP7__Tax__c tax : taxes) {       
                                        if ((TaxPostalCode != null && TaxPostalCode != '' && TaxProvince != null && TaxProvince != '' && TaxCountry != null && TaxCountry != '') && 
                                            (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)) {     
                                            soli.ERP7__Tax__c = tax.Id; 
                                            soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                       (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                       (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                            if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                          (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                          (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);     
                                            taxFound = true;  
                                            break; 
                                        }  
                                    } 
                                    if (!taxFound) {     
                                        for (ERP7__Tax__c tax : taxes) { 
                                            if ((TaxProvince != null && TaxProvince != '' && TaxCountry != null && TaxCountry != '') && 
                                                ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                 tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)) {   
                                                soli.ERP7__Tax__c = tax.Id; 
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                taxFound = true;  
                                                break;   
                                            } 
                                        } 
                                    } 
                                    if (!taxFound) {      
                                        for (ERP7__Tax__c tax : taxes) {          
                                            if ((TaxCountry != null && TaxCountry != '') && 
                                                ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                 (tax.ERP7__City__c == null || tax.ERP7__City__c == '') && 
                                                 (tax.ERP7__Province__c == null || tax.ERP7__Province__c == '') && 
                                                 tax.ERP7__Country__c == TaxCountry)) {     
                                                soli.ERP7__Tax__c = tax.Id; 
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);                                                
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                taxFound = true; 
                                                break; 
                                            } 
                                        } 
                                    } 
                                    if (!taxFound) {    
                                        for (ERP7__Tax__c tax : taxes) {    
                                            if ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                (tax.ERP7__City__c == null || tax.ERP7__City__c == '') && 
                                                (tax.ERP7__Province__c == null || tax.ERP7__Province__c == '') && 
                                                (tax.ERP7__Country__c == null || tax.ERP7__Country__c == '')) {      
                                                soli.ERP7__Tax__c = tax.Id; 
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);       
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);        
                                                taxFound = true;   
                                                break;  
                                            } 
                                        } 
                                    } 
                                } 
                                if (!taxFound && soli.ERP7__Tax__c == null && profileTaxesMap.containsKey(msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c)) {  
                                    List<ERP7__Tax__c> taxes = profileTaxesMap.get(msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__c);  
                                    String TaxPostalCode = '';     
                                    String TaxCity = '';   
                                    String TaxProvince = '';    
                                    String TaxCountry = '';   
                                    if (msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && msoli.Order.ERP7__Bill_To_Address__c != null) {  
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c != '') 
                                            TaxPostalCode = msoli.Order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;  
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c != '') 
                                            TaxCity = msoli.Order.ERP7__Bill_To_Address__r.ERP7__City__c;   
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c != '') 
                                            TaxProvince = msoli.Order.ERP7__Bill_To_Address__r.ERP7__State__c;    
                                        if (msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c != null && msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c != '') 
                                            TaxCountry = msoli.Order.ERP7__Bill_To_Address__r.ERP7__Country__c;  
                                    }  
                                    if (msoli.Order.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && msoli.Order.ERP7__Ship_To_Address__c != null) {     
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != '') 
                                            TaxPostalCode = msoli.Order.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c;      
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c != '') 
                                            TaxCity = msoli.Order.ERP7__Ship_To_Address__r.ERP7__City__c;     
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c != '') 
                                            TaxProvince = msoli.Order.ERP7__Ship_To_Address__r.ERP7__State__c;    
                                        if (msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c != null && msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c != '') 
                                            TaxCountry = msoli.Order.ERP7__Ship_To_Address__r.ERP7__Country__c; 
                                    }
                                    for (ERP7__Tax__c tax : taxes) {  
                                        if ((TaxPostalCode != null && TaxPostalCode != '' && TaxProvince != null && TaxProvince != '' && TaxCountry != null && TaxCountry != '') && 
                                            (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)) {
                                            soli.ERP7__Tax__c = tax.Id;   
                                            if (tax.ERP7__Tax_Rate__c == null) tax.ERP7__Tax_Rate__c = 0;   
                                            if (soli.ERP7__Base_Price__c == null) soli.UnitPrice = 0;   
                                            if (soli.ERP7__Discount_Amount__c == null) soli.ERP7__Discount_Amount__c = 0;  
                                            soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                       (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                       (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                            if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                          (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                          (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                            taxFound = true;    
                                            break;  
                                        }  
                                    }
                                    if (!taxFound) {  
                                        for (ERP7__Tax__c tax : taxes) {  
                                            if ((TaxProvince != null && TaxProvince != '' && TaxCountry != null && TaxCountry != '') && 
                                                ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                 tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)) { 
                                                soli.ERP7__Tax__c = tax.Id;   
                                                if (tax.ERP7__Tax_Rate__c == null) tax.ERP7__Tax_Rate__c = 0;  
                                                if (soli.ERP7__Base_Price__c == null) soli.UnitPrice = 0;    
                                                if (soli.ERP7__Discount_Amount__c == null) soli.ERP7__Discount_Amount__c = 0;   
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);     
                                                taxFound = true;  
                                                break; 
                                            } 
                                        } 
                                    } 
                                    if (!taxFound) {  
                                        for (ERP7__Tax__c tax : taxes) {  
                                            if ((TaxCountry != null && TaxCountry != '') && 
                                                ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                 (tax.ERP7__City__c == null || tax.ERP7__City__c == '') && 
                                                 (tax.ERP7__Province__c == null || tax.ERP7__Province__c == '') && 
                                                 tax.ERP7__Country__c == TaxCountry)) {
                                                soli.ERP7__Tax__c = tax.Id;  
                                                if (tax.ERP7__Tax_Rate__c == null) tax.ERP7__Tax_Rate__c = 0;  
                                                if (soli.ERP7__Base_Price__c == null) soli.UnitPrice = 0;   
                                                if (soli.ERP7__Discount_Amount__c == null) soli.ERP7__Discount_Amount__c = 0;  
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);  
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                taxFound = true; 
                                                break; 
                                            } 
                                        } 
                                    }  
                                    if (!taxFound) { 
                                        for (ERP7__Tax__c tax : taxes) {  
                                            if ((tax.ERP7__Postal_Code__c == null || tax.ERP7__Postal_Code__c == '') && 
                                                (tax.ERP7__City__c == null || tax.ERP7__City__c == '') && 
                                                (tax.ERP7__Province__c == null || tax.ERP7__Province__c == '') && 
                                                (tax.ERP7__Country__c == null || tax.ERP7__Country__c == '')) {  
                                                soli.ERP7__Tax__c = tax.Id;  
                                                if (tax.ERP7__Tax_Rate__c == null) tax.ERP7__Tax_Rate__c = 0;  
                                                if (soli.ERP7__Base_Price__c == null) soli.UnitPrice = 0;   
                                                if (soli.ERP7__Discount_Amount__c == null) soli.ERP7__Discount_Amount__c = 0; 
                                                soli.ERP7__VAT_Amount__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                           (tax.ERP7__Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);  
                                                if (tax.ERP7__Other_Tax_Rate__c != null) 
                                                    soli.ERP7__Other_Tax__c = (tax.ERP7__Apply_Tax_On__c == 'Cost Price' && soli.ERP7__Cost__c != null) ? 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Cost__c)).setScale(2) : 
                                                                              (tax.ERP7__Other_Tax_Rate__c / 100 * (soli.ERP7__Base_Price__c - soli.ERP7__Discount_Amount__c)).setScale(2);    
                                                taxFound = true;  
                                                break;   
                                            } 
                                        } 
                                    } 
                              /*  } else {
                                    
                                    soli.ERP7__Tax__c = null;   
                                    soli.ERP7__VAT_Amount__c = 0.00;    
                                    soli.ERP7__Other_Tax__c = 0.00;  
                                    
                             
                                }*/
                                    //Added fix by Saqlain for Tax getting updated and setting the value to null , which was causing issue 
                                    } else {
                                        if (Trigger.isInsert) {
                                            // keep legacy behavior for brand new lines
                                            soli.ERP7__Tax__c        = null;
                                            soli.ERP7__VAT_Amount__c = 0.00;
                                            soli.ERP7__Other_Tax__c  = 0.00;
                                        } else { // Trigger.isUpdate
                                            // preserve existing values when editing and no new match is found
                                            OrderItem oldRec = Trigger.oldMap.get(soli.Id);
                                            soli.ERP7__Tax__c        = oldRec.ERP7__Tax__c;
                                            soli.ERP7__VAT_Amount__c = oldRec.ERP7__VAT_Amount__c;
                                            soli.ERP7__Other_Tax__c  = oldRec.ERP7__Other_Tax__c;
                                        }
                                    }

                            }
                        } 
                    } 
                }  
                /* Apply Taxes End */   
                
                /* FOR UPDATING LOGISTIC QUANTITY OF SOLI Starts */ 
                if (PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity) {  
                    system.debug('inhere PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity');
                    List<ERP7__Logistic_Line_Item__c> logList = [
                        SELECT Id, Name, ERP7__Quantity__c, ERP7__Order_Product__c 
                        FROM ERP7__Logistic_Line_Item__c 
                        WHERE ERP7__Order_Product__c IN :System.Trigger.New
                    ];   
                    for (OrderItem soli : System.Trigger.New) {  
                        Decimal LogQuantity = 0; 
                        for (ERP7__Logistic_Line_Item__c logLi : logList) {  
                            if (soli.Id != null && logLi.ERP7__Order_Product__c == soli.Id && logLi.ERP7__Quantity__c != null) 
                                LogQuantity += logLi.ERP7__Quantity__c;     
                        }      
                        soli.ERP7__Logistic_Quantity__c = LogQuantity;    
                    }   
                } 
                /* FOR UPDATING LOGISTIC QUANTITY OF SOLI Ends */ 
            }  
            if (Trigger.IsInsert) {  
                PreventRecursiveLedgerEntry.SOLI_BackRun = false;  
                List<ERP7__Employees__c> currentEmployees = [
                    SELECT Id, ERP7__Channel__c 
                    FROM ERP7__Employees__c 
                    WHERE ERP7__Employee_User__c = :UserInfo.getUserId() AND ERP7__Active__c = true 
                    ORDER BY CreatedDate ASC LIMIT 1
                ];  
                if (currentEmployees.size() > 0) { 
                    List<Id> siteIds = new List<Id>(); 
                    List<ERP7__Distribution_Channel__c> DistributionChannel = [
                        SELECT Id, ERP7__Channel__c, ERP7__Site__c 
                        FROM ERP7__Distribution_Channel__c 
                        WHERE ERP7__Channel__c = :currentEmployees[0].ERP7__Channel__c AND ERP7__Active__c = true
                    ];    
                    for (ERP7__Distribution_Channel__c DC : DistributionChannel) siteIds.add(DC.ERP7__Site__c);   
                    Set<Id> nonKitProdIds = new Set<Id>(); 
                    List<ERP7__Inventory_Stock__c> nonKitWarehouseItemInventoryStocks = new List<ERP7__Inventory_Stock__c>();
                    Map<Id, Product2> SOLI_prod = new Map<Id, Product2>();   
                    Map<Id, Decimal> nonKitproStocks = new Map<Id, Decimal>();   
                    for (OrderItem soli : System.Trigger.New) {  
                        if (soli.ERP7__Inventory_Tracked__c) { 
                            nonKitProdIds.add(soli.Product2Id); 
                        } 
                    } 
                    SOLI_prod = new Map<Id, Product2>([
                        SELECT Id, ERP7__Allow_Back_Orders__c 
                        FROM Product2 
                        WHERE Id IN :nonKitProdIds
                    ]); 
                    nonKitWarehouseItemInventoryStocks = [
                        SELECT Id, ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c 
                        FROM ERP7__Inventory_Stock__c 
                        WHERE ERP7__Warehouse__c IN :siteIds AND ERP7__Product__c IN :nonKitProdIds 
                        AND ERP7__Product__r.ERP7__Allow_Back_Orders__c = true AND ERP7__Number_of_Item_In_Stock__c > 0 
                        AND ERP7__Active__c = true 
                        ORDER BY ERP7__Checked_In_Date__c ASC LIMIT 9999
                    ];  
                    for (Id pId : nonKitProdIds) {
                        Decimal nonKitmyStock = 0;    
                        for (ERP7__Inventory_Stock__c WIIS : nonKitWarehouseItemInventoryStocks) {
                            if (pId == WIIS.ERP7__Product__c) nonKitmyStock += WIIS.ERP7__Number_of_Item_In_Stock__c;    
                        }   
                        nonKitproStocks.put(pId, nonKitmyStock);  
                    } 
                    for (OrderItem soli : System.Trigger.New) {   
                        if (!soli.ERP7__Is_Back_Order__c && soli.ERP7__Track_Inventory__c && nonKitproStocks.containsKey(soli.Product2Id) && 
                            SOLI_prod.get(soli.Product2Id).ERP7__Allow_Back_Orders__c && 
                            (nonKitproStocks.get(soli.Product2Id) < soli.Quantity || nonKitproStocks.get(soli.Product2Id) == 0 || nonKitproStocks.get(soli.Product2Id) == null)) 
                            soli.ERP7__Is_Back_Order__c = true; 
                    } 
                } 
            } 
        } else {
            if (PreventRecursiveLedgerEntry.OrderItemTrigger) {
                PreventRecursiveLedgerEntry.OrderItemTrigger = false;
                System.debug('inside InventoryManaging_OrderProduct Trigger after');
                /* Start ==> Reserve the non-kit products under solis */ 
                System.debug('After PreventRecursiveLedgerEntry.SOLI_AllocateStock:' + PreventRecursiveLedgerEntry.SOLI_AllocateStock);
                if (PreventRecursiveLedgerEntry.SOLI_AllocateStock) {  
                    if (Trigger.IsInsert || Trigger.IsUndelete || Trigger.IsUpdate) {
                        Set<Id> SOLI2Update = new Set<Id>();  
                        for (OrderItem SOLI_New : System.Trigger.New) {   
                            if (SOLI_New.ERP7__Inventory_Tracked__c && SOLI_New.ERP7__Allocate_Stock__c && 
                                SOLI_New.ERP7__Ready_To_Pick_Pack__c && SOLI_New.ERP7__Track_Inventory__c && 
                                SOLI_New.Quantity != SOLI_New.ERP7__Logistic_Quantity__c) 
                                SOLI2Update.add(SOLI_New.Id);   
                        }
                        system.debug('SOLI2Update : ' + SOLI2Update.size());
                        system.debug('Trigger.IsInsert  : ' + Trigger.IsInsert);
                        system.debug('Trigger.IsUpdate  : ' + Trigger.IsUpdate);
                        system.debug('Trigger.IsUndelete  : ' + Trigger.IsUndelete);
                        if (SOLI2Update.size() > 0 && (Trigger.IsInsert || Trigger.IsUndelete)) { 
                            OrderProductInventoryUtils.createProductPurchaseLineItems(SOLI2Update); 
                            system.debug('1'); 
                        }
                        if (SOLI2Update.size() > 0 && Trigger.IsUpdate) {
                            system.debug('2'); 
                            List<ERP7__Stock_Outward_Line_Item__c> SOutwardList = [
                                SELECT Id, Name 
                                FROM ERP7__Stock_Outward_Line_Item__c  
                                WHERE ERP7__Order_Product__c IN :SOLI2Update AND ERP7__Picked_Date__c = null AND ERP7__Active__c = true
                            ];  
                            system.debug('SOutwardList.size() : ' + SOutwardList.size()); 
                            if (SOutwardList.size() == 0) 
                                OrderProductInventoryUtils.createProductPurchaseLineItems(SOLI2Update); 
                        }
                    } 
                    if (Trigger.IsUpdate) {                        
                        Set<Id> SOLI2Update = new Set<Id>();    
                        Set<Id> SOLI2UpdateNew = new Set<Id>(); 
                        Set<Id> lineItemIds = new Set<Id>();  
                        for (OrderItem SOLI_New : System.Trigger.New) {  
                            lineItemIds.add(SOLI_New.Id); 
                        }  
                        List<ERP7__Stock_Outward_Line_Item__c> pplis2verify = [
                            SELECT Id, Name, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Quantity__c, 
                                   ERP7__Order_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Picked_Date__c 
                            FROM ERP7__Stock_Outward_Line_Item__c 
                            WHERE ERP7__Order_Product__c IN :lineItemIds AND ERP7__Picked_Date__c = null AND ERP7__Active__c = true
                        ];  
                        for (OrderItem SOLI_New : System.Trigger.New) {   
                            Boolean IsStockAllocated = false; 
                            Decimal OldQuant = 0; 
                            if (SOLI_New.ERP7__Allocate_Stock__c && SOLI_New.Product2Id != null && SOLI_New.ERP7__Inventory_Tracked__c && 
                                SOLI_New.ERP7__Ready_To_Pick_Pack__c && !SOLI_New.ERP7__Is_Back_Order__c && SOLI_New.ERP7__Track_Inventory__c && 
                                SOLI_New.Quantity != SOLI_New.ERP7__Logistic_Quantity__c) {   
                                for (ERP7__Stock_Outward_Line_Item__c OutLine : pplis2verify) {                                                                                                 
                                    if (SOLI_New.Id == OutLine.ERP7__Order_Product__c && (SOLI_New.Product2Id == OutLine.ERP7__Product__c) && 
                                        ((OutLine.ERP7__Quantity__c != SOLI_New.Quantity))) {   
                                        IsStockAllocated = true;  
                                        if (OutLine.ERP7__Quantity__c == null) 
                                            OutLine.ERP7__Quantity__c = SOLI_New.Quantity;  
                                        else if (OutLine.ERP7__Quantity__c != null) 
                                            OldQuant += OutLine.ERP7__Quantity__c;  
                                    }  
                                    if (SOLI_New.Id == OutLine.ERP7__Order_Product__c && SOLI_New.Product2Id == OutLine.ERP7__Product__c && 
                                        OutLine.ERP7__Product__r.ERP7__Serialise__c) 
                                        IsStockAllocated = false;
                                } 
                                if (IsStockAllocated) { 
                                    SOLI2Update.add(SOLI_New.Id); 
                                } else { 
                                    SOLI2UpdateNew.add(SOLI_New.Id); 
                                } 
                            }  
                        }  
                        System.debug('SOLI2UpdateNew:' + SOLI2UpdateNew.size());
                        System.debug('SOLI2Update:' + SOLI2Update.size());
                        if (SOLI2UpdateNew.size() > 0) { 
                            system.debug('3'); 
                            OrderProductInventoryUtils.createProductPurchaseLineItems(SOLI2UpdateNew);  
                        }  
                        if (SOLI2Update.size() > 0) { 
                            system.debug('4'); 
                            OrderProductInventoryUtils.updateProductPurchaseLineItems(SOLI2Update);   
                        } 
                    } 
                }  
                /* End ==> Reserve the non-kit products under solis */ 
                /* Start ==> Create MRPS for SOLIs when kit is exploded based on BOM and its versions */  
                system.debug('PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode : ' + PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode);
                if (PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode) {
                    if (Trigger.IsInsert || Trigger.IsUpdate) { 
                        List<Id> soliIds2explode = new List<Id>(); 
                        List<Id> proIds = new List<Id>(); 
                        List<ERP7__MRP__c> mrps2delete = new List<ERP7__MRP__c>();  
                        Map<Id, List<ERP7__MRP__c>> soliMrps = new Map<Id, List<ERP7__MRP__c>>(); 
                        Map<Id, List<ERP7__BOM__c>> soliBOMS = new Map<Id, List<ERP7__BOM__c>>(); 
                        List<Id> soliBOMVersion = new List<Id>(); 
                        List<ERP7__MRP__c> MRPS2Insert = new List<ERP7__MRP__c>(); 
                        Set<Id> productIds = new Set<Id>(); 
                        Set<Id> priceBookIds = new Set<Id>();  
                        Set<Id> alternateBOM = new Set<Id>();
                        Set<Id> alternateBOMProd = new Set<Id>();
                        for (OrderItem soli : System.Trigger.New) {   
                            if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.ERP7__Explode__c) { 
                                soliIds2explode.add(soli.Id); 
                                proIds.add(soli.Product2Id); 
                                soliBOMVersion.add(soli.ERP7__Version__c); 
                                priceBookIds.add(soli.ERP7__PriceBookId__c); 
                            }  
                        }  
                        if (proIds.size() > 0 || soliIds2explode.size() > 0) {   
                            List<ERP7__MRP__c> MRPS = [
                                SELECT Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Quantity__c, 
                                       ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, 
                                       ERP7__MRP_Product__r.Preview_Image__c, ERP7__Order_Product__c, RecordType.Name 
                                FROM ERP7__MRP__c       
                                WHERE RecordType.Name = 'MRP Kit' AND ERP7__Order_Product__c IN :soliIds2explode 
                            ];   
                            List<ERP7__BOM__c> BOMS = [
                                SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, 
                                       ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c, ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c, 
                                       ERP7__BOM_Product__c, ERP7__BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, 
                                       ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, 
                                       RecordType.Name, ERP7__BOM_Version__r.Active__c, ERP7__BOM_Version__r.Category__c, 
                                       ERP7__BOM_Version__r.Default__c, ERP7__BOM_Version__r.Start_Date__c, ERP7__BOM_Version__r.To_Date__c, 
                                       ERP7__BOM_Version__r.Type__c, ERP7__BOM_Version__r.Status__c 
                                FROM ERP7__BOM__c  
                                WHERE ((ERP7__Active__c = true AND ERP7__Type__c != 'Alternate' AND ERP7__BOM_Version__r.RecordType.Name = 'Kit' 
                                        AND ERP7__BOM_Product__c IN :proIds AND ERP7__BOM_Version__r.Active__c = true 
                                        AND ERP7__BOM_Version__r.Start_Date__c <= TODAY AND ERP7__BOM_Version__r.To_Date__c >= TODAY 
                                        AND (ERP7__BOM_Version__r.Type__c = 'Assembly' OR ERP7__BOM_Version__r.Type__c = 'Sales') 
                                        AND ERP7__BOM_Version__r.Status__c = 'Certified') 
                                       OR (Id IN :soliBOMVersion AND ERP7__BOM_Version__r.Status__c = 'Certified'))   
                                ORDER BY ERP7__BOM_Version__r.Default__c DESC
                            ];  
                            for (OrderItem soli : System.Trigger.New) {   
                                if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.ERP7__Explode__c) {
                                    List<ERP7__MRP__c> myMRPS = new List<ERP7__MRP__c>();  
                                    for (ERP7__MRP__c mrp : MRPS) { 
                                        if (soli.Id == mrp.ERP7__Order_Product__c) myMRPS.add(mrp); 
                                    }   
                                    soliMrps.put(soli.Id, myMRPS);   
                                    List<ERP7__BOM__c> myBOMS = new List<ERP7__BOM__c>(); 
                                    List<ERP7__BOM__c> myAllBOMS = new List<ERP7__BOM__c>();    
                                    for (ERP7__BOM__c bom : BOMS) {  
                                        if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c != null && soli.ERP7__Version__c == bom.ERP7__BOM_Version__c) { 
                                            myBOMS.add(bom); 
                                            productIds.add(bom.ERP7__BOM_Component__c);       
                                        } else if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c == null && bom.ERP7__BOM_Version__c != null && bom.ERP7__BOM_Version__r.Default__c == true) {    
                                            myBOMS.add(bom); 
                                            productIds.add(bom.ERP7__BOM_Component__c);   
                                        } else if (soli.Product2Id == bom.ERP7__BOM_Product__c && soli.ERP7__Version__c == null && bom.ERP7__BOM_Version__c == null) {
                                            myAllBOMS.add(bom); 
                                            productIds.add(bom.ERP7__BOM_Component__c); 
                                        }
                                        if (soli.Product2Id == bom.ERP7__BOM_Product__c && bom.ERP7__BOM_Alternate_Of__c != null) {
                                            alternateBOM.add(bom.ERP7__BOM_Alternate_Of__c);
                                            alternateBOMProd.add(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c);
                                        }
                                    }  
                                    if (myBOMS.size() > 0) soliBOMS.put(soli.Id, myBOMS);   
                                    else if (myAllBOMS.size() > 0) soliBOMS.put(soli.Id, myAllBOMS);
                                } 
                            }
                        } 
                        system.debug('alternateBOMProd : ' + alternateBOMProd.size());
                        if (productIds.size() > 0) { 
                            List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStocks = new List<ERP7__Inventory_Stock__c>();
                            Map<Id, Decimal> proStocks = new Map<Id, Decimal>();
                            List<PricebookEntry> priceBookEntries = [
                                SELECT Id, Name, Product2Id, Product2.ERP7__Track_Inventory__c 
                                FROM PricebookEntry 
                                WHERE IsActive = true AND Pricebook2Id IN :priceBookIds AND (Product2Id IN :productIds OR Product2Id IN :alternateBOMProd)
                            ]; 
                            Map<Id, PricebookEntry> productPriceBookMap = new Map<Id, PricebookEntry>();   
                            if (Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) { 
                                UtilClass.FlsCheck(new String[] { 
                                    'ERP7__Active__c', 'ERP7__Organisation__c', 'ERP7__Warehouse__c', 'ERP7__Product__c', 
                                    'ERP7__Number_of_Item_In_Stock__c', 'ERP7__Number_of_Item_Purchased_In__c', 
                                    'ERP7__Number_of_Items_Dispatched__c', 'ERP7__No_of_Items_Sold__c', 'ERP7__Checked_In_Date__c'
                                }, 'ERP7__Inventory_Stock__c');  
                                WarehouseItemInventoryStocks = [
                                    SELECT Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Warehouse__c, ERP7__Product__c, 
                                           ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, 
                                           ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  
                                    FROM ERP7__Inventory_Stock__c  
                                    WHERE (ERP7__Product__c IN :productIds OR ERP7__Product__c IN :alternateBOMProd) 
                                    AND ERP7__Active__c = true 
                                    ORDER BY ERP7__Checked_In_Date__c ASC 
                                ]; 
                            } 
                            for (Id pId : productIds) { 
                                Decimal myStock = 0; 
                                List<ERP7__Inventory_Stock__c> sites = new List<ERP7__Inventory_Stock__c>(); 
                                for (ERP7__Inventory_Stock__c WIIS : WarehouseItemInventoryStocks) { 
                                    if (pId == WIIS.ERP7__Product__c) { 
                                        myStock += WIIS.ERP7__Number_of_Item_In_Stock__c;   
                                    } 
                                } 
                                proStocks.put(pId, myStock); 
                            } 
                            for (Id alternatedProdId : alternateBOMProd) {
                                Decimal myStock = 0; 
                                List<ERP7__Inventory_Stock__c> sites = new List<ERP7__Inventory_Stock__c>(); 
                                for (ERP7__Inventory_Stock__c WIIS : WarehouseItemInventoryStocks) { 
                                    if (alternatedProdId == WIIS.ERP7__Product__c) { 
                                        myStock += WIIS.ERP7__Number_of_Item_In_Stock__c;  
                                        system.debug('alternateBOMProd myStock: ' + myStock); 
                                    } 
                                } 
                                proStocks.put(alternatedProdId, myStock); 
                            }
                            for (PricebookEntry IPE : priceBookEntries) { 
                                if (IPE.Product2.ERP7__Track_Inventory__c) productPriceBookMap.put(IPE.Product2Id, IPE);
                            } 
                            Id rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
                            Map<Id, String> soliOldVersion = new Map<Id, String>(); 
                            Map<Id, Decimal> soliOldQuantity = new Map<Id, Decimal>();
                            if (Trigger.IsUpdate) {                                
                                for (OrderItem soli : System.Trigger.Old) { 
                                    soliOldQuantity.put(soli.Id, soli.Quantity); 
                                    soliOldVersion.put(soli.Id, soli.ERP7__Version__c); 
                                } 
                            } 
                       
                            for (OrderItem soli: System.Trigger.New) {
                                Decimal oldQuantity = 0;  
                                /* Handles the deletion of MRPs if BOM version on soli is changed.. */ 
                                if (soliMrps != null && soliMrps.containsKey(soli.Id)) {    
                                    for (ERP7__MRP__c mrp: soliMrps.get(soli.Id)) 
                                    { 
                                        /*system.debug('oldQuantity : '+oldQuantity);
system.debug('mrp.ERP7__Total_Amount_Required__c : '+mrp.ERP7__Total_Amount_Required__c);
system.debug('mrp.ERP7__BOM__r.ERP7__Quantity__c : '+mrp.ERP7__BOM__r.ERP7__Quantity__c);*/
                                        if (mrp.ERP7__Total_Amount_Required__c != Null) oldQuantity = oldQuantity + (mrp.ERP7__Total_Amount_Required__c / mrp.ERP7__BOM__r.ERP7__Quantity__c); 
                                        if (soli.ERP7__Insufficient_BOM__c != true &&  Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()) {mrp.Status__c = 'Reserved'; } else {/* no access*/}
                                    }
                                } 
                                /* system.debug('soliMrps.containsKey(soli.Id) : '+soliMrps.containsKey(soli.Id));
system.debug('soliOldVersion.containsKey(soli.Id) : '+soliOldVersion.containsKey(soli.Id));
system.debug('String.valueof(soli.Version__c) : '+String.valueof(soli.Version__c));
system.debug('soliOldVersion.get(soli.Id) : '+soliOldVersion.get(soli.Id));
system.debug('oldQuantity : '+oldQuantity);
system.debug('soli.Quantity : '+soli.Quantity);
system.debug('soliMrps.containsKey(soli.Id : '+soliMrps.containsKey(soli.Id));
system.debug('soliMrps.get(soli.Id).size() : '+soliMrps.get(soli.Id).size());
system.debug('soliBOMS.containsKey(soli.Id) : '+soliBOMS.containsKey(soli.Id));*/
                                if (soli.ERP7__Inventory_Tracked__c == false && soli.Is_Kit__c == true && soli.Explode__c == true && ((soliOldVersion.containsKey(soli.Id) && String.valueof(soli.Version__c) != soliOldVersion.get(soli.Id)) || (soliOldQuantity.containsKey(soli.Id) && soliOldQuantity.get(soli.Id) != soli.Quantity)) && soliMrps.containsKey(soli.Id) && soliMrps.get(soli.Id).size() >0) {mrps2delete.addAll(soliMrps.get(soli.Id));soliMrps.get(soli.Id).clear(); system.debug('clear');} // || oldQuantity != soli.Quantity removed from if condition because it should check the qty of order item not MRP
                                if (!soli.ERP7__Inventory_Tracked__c && soli.Is_Kit__c && soli.Explode__c && soliMrps.containsKey(soli.Id) && soliMrps.get(soli.Id).size() == 0 &&   soliBOMS.containsKey(soli.Id)) {   
                                    system.debug('BOM');
                                    for (ERP7__BOM__c bom: soliBOMS.get(soli.Id)) 
                                    {  
                                        
                                        if (productPriceBookMap.containsKey(bom.ERP7__BOM_Component__c)) 
                                        {    
                                            system.debug('BOM 2');
                                            /*system.debug('(proStocks.get(bom.ERP7__BOM_Component__c) : '+proStocks.get(bom.ERP7__BOM_Component__c));
system.debug('soli.Quantity : '+soli.Quantity);
system.debug('bom.Quantity__c : '+bom.Quantity__c);
system.debug('bom.ERP7__BOM_Alternate_Of__c : '+bom.ERP7__BOM_Alternate_Of__c);
system.debug('proStocks.get(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c) : '+proStocks.get(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c));
system.debug('ERP7__BOM_Alternate_Of__r.Quantity__c : '+bom.ERP7__BOM_Alternate_Of__r.Quantity__c);
system.debug('productPriceBookMap.containsKey(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c) : '+productPriceBookMap.containsKey(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c));*/
                                            if((proStocks.get(bom.ERP7__BOM_Component__c) < (soli.Quantity * bom.Quantity__c)) && bom.ERP7__BOM_Alternate_Of__c != null && ((proStocks.get(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c) >= (soli.Quantity * bom.ERP7__BOM_Alternate_Of__r.Quantity__c)) && productPriceBookMap.containsKey(bom.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c))){
                                                system.debug('BOM alternate creation');
                                                ERP7__MRP__c MRP = new ERP7__MRP__c(); 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = BOM.ERP7__BOM_Alternate_Of__r.Name;} else{/* no access*/} 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = BOM.ERP7__BOM_Alternate_Of__r.Quantity__c * soli.Quantity; } else{ /* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.ERP7__BOM_Alternate_Of__c;} else {/* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isUpdateable()){MRP.Version__c = soli.Version__c; } else{ /* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c; } else{/* no access*/ }  
                                                if( Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isUpdateable()){MRP.ERP7__Order_Product__c = soli.Id;} else { /* no access*/ }   
                                                if (rTpe_MRPKIT != null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()){ MRP.RecordTypeId = rTpe_MRPKIT; } else{/* no access*/ }  
                                                if (soli.ERP7__Insufficient_BOM__c != true &&  Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()) {MRP.Status__c = 'Reserved'; } else {/* no access*/}   
                                                MRPS2Insert.add(MRP); 
                                            }
                                            else{
                                                ERP7__MRP__c MRP = new ERP7__MRP__c(); 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = BOM.Name;} else{/* no access*/} 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c * soli.Quantity; } else{ /* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.Id;} else {/* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isUpdateable()){MRP.Version__c = soli.Version__c; } else{ /* no access*/ } 
                                                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c; } else{/* no access*/ }  
                                                if( Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isUpdateable()){MRP.ERP7__Order_Product__c = soli.Id;} else { /* no access*/ }   
                                                if (rTpe_MRPKIT != null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()){ MRP.RecordTypeId = rTpe_MRPKIT; } else{/* no access*/ }  
                                                if (soli.ERP7__Insufficient_BOM__c != true &&  Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()) {MRP.Status__c = 'Reserved'; } else {/* no access*/}   
                                                MRPS2Insert.add(MRP);   
                                            }
                                            
                                        } 
                                    } 
                                }
                                else if(soliMrps.containskey(soli.Id) && soliMrps.get(soli.Id) != null) { system.debug('else part of MRP update'); MRPS2Insert.addAll(soliMrps.get(soli.Id)); }
                            } 
                        } 
                        system.debug('MRPS2Insert : '+MRPS2Insert.size());
                        if (MRPS2Insert.size() > 0 && Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { upsert MRPS2Insert; } else{ /* no access */ }   
                        system.debug('mrps2delete : '+mrps2delete.size());
                        if (mrps2delete.size() > 0) {      
                            List < Id > mrpIds = new List < Id > ();  
                            for (MRP__c MRP: mrps2delete) { mrpIds.add(MRP.Id);    } 
                            if (mrpIds.size() > 0) {    
                                List < Stock_Outward_Line_Item__c > SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c,MRP_Material_Requirements_Planning__c, Product__c, Purchase_Orders__c, Quantity__c, Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c From Stock_Outward_Line_Item__c Where MRP_Material_Requirements_Planning__c In: mrpIds];   
                                system.debug('SDLIs : '+SDLIs.size());
                                if (SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()){ delete SDLIs;    } 
                                
                                if(ERP7__MRP__c.sObjectType.getDescribe().isDeletable()){ delete mrps2delete; }  
                            }  
                        } 
                    }  
                }  
                /* End ==> Create MRPS for SOLIs when kit is exploded based on BOM and its versions ... */
            }
        }  
    }      
}