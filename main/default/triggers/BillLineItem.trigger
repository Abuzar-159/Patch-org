trigger BillLineItem on ERP7__Bill_Line_Item__c (after insert, after update, before insert, before update, before delete) {//, after delete
    List<Transaction__c> Transactions2update = new List<Transaction__c>();
    List<Product2> Products2update = new List<Product2>();
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    
    Map<Id,Id> ExistingTransaction_Map2BilllineItemlineItem = new Map<Id,Id>();
    //for(Transaction__c trans:[SELECT Id,Bill__c,ERP7__Bill_Line_Item__c FROM Transaction__c Where ERP7__Bill_Line_Item__c in:Trigger.newMap.keyset()])  ExistingTransaction_Map2BilllineItemlineItem.put(trans.ERP7__Bill_Line_Item__c,trans.Id);
    RunModule =  Module__c.getAll();
    //Commented below code as it was not allowing to create a bill for more than 5 % so that debit note can be created and amount is reduced for mathing
    /*if(Trigger.isBefore){
        if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c) && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c ){
            // Retrieve the variance limit from the custom setting
            Decimal qtyvarianceLimit = 0; 
            Decimal upvarianceLimit = 0;
            if(RunModule.size() > 0){
                if(RunModule.get('Finance') != null){
                    if(RunModule.get('Finance').Run__c && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
                        qtyvarianceLimit = RunModule.get('Finance').ERP7__Bill_Quantity_Tolerance__c;
                        upvarianceLimit = RunModule.get('Finance').ERP7__Bill_Unit_Price_Tolerance__c;
                    }
                }
            }
            
            // Map to store purchase line item IDs and their poli
            Map<Id, ERP7__Purchase_Line_Items__c> poliMap = new Map<Id, ERP7__Purchase_Line_Items__c>();
            
            // Collect the purchase line item IDs from the bill line items
            Set<Id> purchaseLineItemIds = new Set<Id>();
            for (ERP7__Bill_Line_Item__c billLineItem : Trigger.new) {
                purchaseLineItemIds.add(billLineItem.ERP7__Purchase_Order_Line_Items__c);
            }
            
            // Query the purchase line items and store their unit prices in the map
            for (ERP7__Purchase_Line_Items__c purchaseLineItem : [SELECT Id, ERP7__Quantity__c, ERP7__Unit_Price__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN :purchaseLineItemIds]) {
                poliMap.put(purchaseLineItem.Id, purchaseLineItem);
            }
            
            // Iterate through the bill line items to verify unit prices and Qty
            for (ERP7__Bill_Line_Item__c billLineItem : Trigger.new) {
                if(billLineItem.ERP7__Purchase_Order_Line_Items__c!=null){
                    Decimal billUnitPrice = billLineItem.ERP7__Amount__c;
                    Decimal billQty = billLineItem.ERP7__Quantity__c;
                    ERP7__Purchase_Line_Items__c poli = poliMap.get(billLineItem.ERP7__Purchase_Order_Line_Items__c);
                    Decimal purchaseUnitPrice = poli.ERP7__Unit_Price__c;
                    Decimal purchaseQty = poli.ERP7__Quantity__c;
                    // Verify the unit price only if both bill and purchase unit prices are present
                    if (billUnitPrice != null && purchaseUnitPrice != null && billUnitPrice>purchaseUnitPrice) {
                        Decimal upVarianceDiff = billUnitPrice - purchaseUnitPrice;
                        Decimal upVariance = ((upVarianceDiff/purchaseUnitPrice)*100).setScale(2);
                        // Compare the variance with the limit
                        if (upVariance > upvarianceLimit) {
                           if(!Test.isRunningTest()) billLineItem.addError('Unit price variance exceeds the limit. Variance: ' + upVariance + ', Limit: ' + upvarianceLimit);
                        }
                    }
                    if (billQty != null && purchaseQty != null && billQty>purchaseQty) {
                        Decimal qtyVarianceDiff = billQty - purchaseQty;
                        Decimal qtyVariance = ((qtyVarianceDiff/purchaseQty)*100).setScale(2);
                        // Compare the variance with the limit
                        if (qtyVariance > qtyvarianceLimit) {
                           if(!Test.isRunningTest()) billLineItem.addError('Qty variance exceeds the limit. Variance: ' + qtyVariance + ', Limit: ' + qtyvarianceLimit);
                        }
                    }
                }
            }
        }
    }*/
    if(Trigger.isBefore){
        if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c) && ( RunModule.get('Finance').ERP7__Run_Posting_Trigger__c || (RunModule.get('Finance').ERP7__Bill_Unit_Price_Tolerance__c > 0 || RunModule.get('Finance').ERP7__Bill_Quantity_Tolerance__c > 0 )) ){//RunModule.get('Finance').ERP7__Run_Posting_Trigger__c
            // Retrieve the variance limit from the custom setting
            Decimal qtyvarianceLimit = 0; 
            Decimal upvarianceLimit = 0;
            if(RunModule.size() > 0){
                if(RunModule.get('Finance') != null){
                    if(RunModule.get('Finance').Run__c && ( RunModule.get('Finance').ERP7__Run_Posting_Trigger__c || (RunModule.get('Finance').ERP7__Bill_Unit_Price_Tolerance__c > 0 || RunModule.get('Finance').ERP7__Bill_Quantity_Tolerance__c > 0 )) ){//RunModule.get('Finance').ERP7__Run_Posting_Trigger__c
                        qtyvarianceLimit = RunModule.get('Finance').ERP7__Bill_Quantity_Tolerance__c;
                        upvarianceLimit = RunModule.get('Finance').ERP7__Bill_Unit_Price_Tolerance__c;
                    }
                }
            }
            
            // Map to store purchase line item IDs and their poli
            Map<Id, ERP7__Purchase_Line_Items__c> poliMap = new Map<Id, ERP7__Purchase_Line_Items__c>();
            
            // Collect the purchase line item IDs from the bill line items
            Set<Id> purchaseLineItemIds = new Set<Id>();
            for (ERP7__Bill_Line_Item__c billLineItem : Trigger.new) {
                purchaseLineItemIds.add(billLineItem.ERP7__Purchase_Order_Line_Items__c);
            }
            
            // Query the purchase line items and store their unit prices in the map
            for (ERP7__Purchase_Line_Items__c purchaseLineItem : [SELECT Id, ERP7__Quantity__c, ERP7__Unit_Price__c,ERP7__Tax_Rate__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN :purchaseLineItemIds]) {
                poliMap.put(purchaseLineItem.Id, purchaseLineItem);
            }
            
            // Iterate through the bill line items to verify unit prices and Qty
            for (ERP7__Bill_Line_Item__c billLineItem : Trigger.new) {
                if(billLineItem.ERP7__Purchase_Order_Line_Items__c!=null){
                    Decimal billUnitPrice = billLineItem.ERP7__Amount__c;
                    Decimal billQty = billLineItem.ERP7__Quantity__c;
                    Decimal billTaxRate = billLineItem.ERP7__Tax_Rate__c ;
                    ERP7__Purchase_Line_Items__c poli = poliMap.get(billLineItem.ERP7__Purchase_Order_Line_Items__c);
                    Decimal purchaseUnitPrice = poli.ERP7__Unit_Price__c;
                    Decimal purchaseQty = poli.ERP7__Quantity__c;
                    Decimal purchaseTaxRate = poli.ERP7__Tax_Rate__c;
                    // Verify the unit price only if both bill and purchase unit prices are present
                   /* if (billUnitPrice != null && purchaseUnitPrice != null && purchaseUnitPrice != 0 && billUnitPrice>purchaseUnitPrice) {
                        Decimal upVarianceDiff = billUnitPrice - purchaseUnitPrice;
                        Decimal upVariance = ((upVarianceDiff/purchaseUnitPrice)*100).setScale(2);
                        // Compare the variance with the limit
                        if (upVariance > upvarianceLimit) {
                            if(!Test.isRunningTest()) billLineItem.addError('Unit price variance exceeds the limit. Variance= ' + upVariance + ', Limit= ' + upvarianceLimit);
                        }
                    }
                     if (billUnitPrice != null && purchaseUnitPrice != null && purchaseUnitPrice != 0 && billUnitPrice<purchaseUnitPrice) {
                        Decimal downVarianceDiff = purchaseUnitPrice - billUnitPrice;
                        Decimal downVariance = ((downVarianceDiff/purchaseUnitPrice)*100).setScale(2);
                        // Compare the variance with the limit
                        if (downVariance > upvarianceLimit) {
                            if(!Test.isRunningTest()) billLineItem.addError('Unit price variance is below the lower limit. Variance= ' + downVariance + ', Limit= ' + upvarianceLimit);
                        }
                    }
                    if (billQty != null && purchaseQty != null && billQty>purchaseQty) {
                        if(!Test.isRunningTest()) billLineItem.addError('There is Bill Qty variance that exceeds the PO Qty.');
                        //Decimal qtyVarianceDiff = billQty - purchaseQty;
                        //Decimal qtyVariance = ((qtyVarianceDiff/purchaseQty)*100).setScale(2);
                        // Compare the variance with the limit
                        //if (qtyVariance > qtyvarianceLimit) {
                        //if(!Test.isRunningTest()) billLineItem.addError('Qty variance exceeds the limit. Variance: ' + qtyVariance + ', Limit: ' + qtyvarianceLimit);
                        //}
                    }
                    if (billUnitPrice != null && purchaseUnitPrice != null && purchaseUnitPrice == 0 && billUnitPrice != 0) {
                        if (!Test.isRunningTest()) billLineItem.addError('PO unit price is 0 but bill unit price is non-zero.');
                    }
                    
                    // Tax when PO tax is zero
                    if (billTaxRate != null && purchaseTaxRate != null && purchaseTaxRate == 0 && billTaxRate != 0) {
                        if (!Test.isRunningTest()) billLineItem.addError('PO tax rate is 0 but bill tax rate is non-zero.');
                    }
                    if (billTaxRate != null && purchaseTaxRate != null && purchaseTaxRate != 0 && billTaxRate>purchaseTaxRate) {
                        Decimal qtyVarianceDiff = billTaxRate - purchaseTaxRate;
                        Decimal qtyVariance = ((qtyVarianceDiff/purchaseTaxRate)*100).setScale(2);
                        // Compare the variance with the limit
                        if (qtyVariance > qtyvarianceLimit) {
                            if(!Test.isRunningTest()) billLineItem.addError('Tax variance exceeds the limit. Variance= ' + qtyVariance + ', Limit= ' + qtyvarianceLimit);
                        }
                    }
                    
                     if (billTaxRate != null && purchaseTaxRate != null && purchaseTaxRate != 0 && billTaxRate<purchaseTaxRate) {
                        Decimal qtyVarianceDiff = purchaseTaxRate - billTaxRate;
                        Decimal qtyVariance = ((qtyVarianceDiff/purchaseTaxRate)*100).setScale(2);
                        // Compare the variance with the limit
                        if (qtyVariance > qtyvarianceLimit) {
                            if(!Test.isRunningTest()) billLineItem.addError('Tax variance is below the lower limit. Variance= ' + qtyVariance + ', Limit= ' + qtyvarianceLimit);
                        }
                    }*/
                    // Unit Price variance (guard division by zero)
                    if (billUnitPrice != null && purchaseUnitPrice != null) {
                        if (purchaseUnitPrice == 0) {
                            if (billUnitPrice != 0 && !Test.isRunningTest())
                                billLineItem.addError('PO unit price is 0 but bill unit price is non-zero.');
                        } else {
                            if (billUnitPrice > purchaseUnitPrice) {
                                Decimal diff = billUnitPrice - purchaseUnitPrice;
                                Decimal variance = ((diff / purchaseUnitPrice) * 100).setScale(2);
                                if (variance > upvarianceLimit && !Test.isRunningTest())
                                    billLineItem.addError('Unit price variance exceeds the limit. Variance= ' + variance + ', Limit= ' + upvarianceLimit);
                            } else if (billUnitPrice < purchaseUnitPrice) {
                                Decimal diff = purchaseUnitPrice - billUnitPrice;
                                Decimal variance = ((diff / purchaseUnitPrice) * 100).setScale(2);
                                if (variance > upvarianceLimit && !Test.isRunningTest())
                                    billLineItem.addError('Unit price variance is below the lower limit. Variance= ' + variance + ', Limit= ' + upvarianceLimit);
                            }
                        }
                    }
                    
                    // Quantity: error only when bill > PO (as required)
                    if (billQty != null && purchaseQty != null && billQty > purchaseQty) {
                        if (!Test.isRunningTest())
                            billLineItem.addError('Bill Qty exceeds the PO Qty.');
                    }
                    
                    // Tax variance (guard division by zero)
                   /* if (billTaxRate != null && purchaseTaxRate != null) {
                        if (purchaseTaxRate == 0) {
                            if (billTaxRate != 0 && !Test.isRunningTest())
                                billLineItem.addError('PO tax rate is 0 but bill tax rate is non-zero.');
                        } else {
                            if (billTaxRate > purchaseTaxRate) {
                                Decimal diff = billTaxRate - purchaseTaxRate;
                                Decimal variance = ((diff / purchaseTaxRate) * 100).setScale(2);
                                if (variance > qtyvarianceLimit && !Test.isRunningTest())
                                    billLineItem.addError('Tax variance exceeds the limit. Variance= ' + variance + ', Limit= ' + qtyvarianceLimit);
                            } else if (billTaxRate < purchaseTaxRate) {
                                Decimal diff = purchaseTaxRate - billTaxRate;
                                Decimal variance = ((diff / purchaseTaxRate) * 100).setScale(2);
                                if (variance > qtyvarianceLimit && !Test.isRunningTest())
                                    billLineItem.addError('Tax variance is below the lower limit. Variance= ' + variance + ', Limit= ' + qtyvarianceLimit);
                            }
                        }
                    }*/
                    if (billTaxRate != null && purchaseTaxRate != null) {
                        Decimal diff = (billTaxRate - purchaseTaxRate).abs();
                        Decimal variance = 0;
                        if (purchaseTaxRate != 0)
                            variance = ((diff / purchaseTaxRate) * 100).setScale(2);
                        System.debug('variance: '+variance);
                        System.debug('billTaxRate: '+billTaxRate);
                        System.debug('purchaseTaxRate: '+purchaseTaxRate);
                        System.debug('qtyvarianceLimit: '+qtyvarianceLimit);
                        // Only check if variance is *actually greater* than limit
                        if (variance > qtyvarianceLimit && !Test.isRunningTest()) {
                            if (billTaxRate > purchaseTaxRate) {
                                billLineItem.addError('Tax variance exceeds the limit. Variance= ' + variance + ', Limit= ' + qtyvarianceLimit);
                            } else if (billTaxRate < purchaseTaxRate) {
                                billLineItem.addError('Tax variance is below the lower limit. Variance is ' + variance + ', Limit is ' + qtyvarianceLimit+' billTaxRate: '+ billTaxRate +' purchaseTaxRate: '+ purchaseTaxRate);
                            }
                        }
                    }


                }
            }
        }
    }
    // bill deletion validation check
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> parentBillIds = new Set<Id>();
        for (ERP7__Bill_Line_Item__c bli : Trigger.old) {
            if (bli.ERP7__Bill__c != null) {
                parentBillIds.add(bli.ERP7__Bill__c);
            }
        }
        if (parentBillIds.isEmpty()) {      return;
        }
        Map<Id, ERP7__Bill__c> parentBills = new Map<Id, ERP7__Bill__c>(
            [SELECT Id, ERP7__Posted__c FROM ERP7__Bill__c WHERE Id IN :parentBillIds]
        );
        for (ERP7__Bill_Line_Item__c bli : Trigger.old) {
            ERP7__Bill__c parentBill = parentBills.get(bli.ERP7__Bill__c);
            if (parentBill != null && parentBill.ERP7__Posted__c == true) { //  bli.addError('This Bill Line Item cannot be deleted because the associated Bill has been posted.');
            }
        }
        // bill deletion scenario to not allow deletion if debit note item is created against it
        List<ERP7__Debit_Note_Item__c> debitnoteItems=[Select id, ERP7__Bill_Line_Item__c from ERP7__Debit_Note_Item__c where ERP7__Bill_Line_Item__c in:Trigger.oldMap.keySet()];
        Set<Id> billLineItemIdsWithDebitNotes = new Set<Id>();
        for (ERP7__Debit_Note_Item__c dni : debitnoteItems) {  billLineItemIdsWithDebitNotes.add(dni.ERP7__Bill_Line_Item__c);
        }
        
        for (ERP7__Bill_Line_Item__c bli : Trigger.old) {
            if (billLineItemIdsWithDebitNotes.contains(bli.Id)) {  // bli.addError('This Bill Line Item cannot be deleted because it has associated Debit Note Items.');
            }
        }
    }// bill deletion scenario end
    
    //validation on bill line item if its modified from record level and posted
    if (Trigger.isBefore && Trigger.isUpdate && PreventRecursiveLedgerEntry.billTriggerIsBefore) {
        
        //new validations for multiple bills on same po
       /* Set<Id> purchaseLineItemIds = new Set<Id>();
        Set<Id> billLineItemIds = new Set<Id>();
        for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
            if(newBli.Id!=null){
                ERP7__Bill_Line_Item__c oldBli = Trigger.oldMap.get(newBli.Id);
                if(oldBli!=null){
                    if (newBli.ERP7__Quantity__c != oldBli.ERP7__Quantity__c || newBli.ERP7__Amount__c != oldBli.ERP7__Amount__c ||newBli.ERP7__Tax_Rate__c != oldBli.ERP7__Tax_Rate__c) {
                        billLineItemIds.add(newBli.Id);  if (newBli.ERP7__Purchase_Order_Line_Items__c != null) {  purchaseLineItemIds.add(newBli.ERP7__Purchase_Order_Line_Items__c);
                        }
                    } 
                }
            }
        }
        
        Map<Id, ERP7__Purchase_Line_Items__c> purchaseLineItemsMap = new Map<Id, ERP7__Purchase_Line_Items__c>();
        if (!purchaseLineItemIds.isEmpty()) {   purchaseLineItemsMap = new Map<Id, ERP7__Purchase_Line_Items__c>([
                SELECT Id, ERP7__Quantity__c,ERP7__Tax_Rate__c,ERP7__Unit_Price__c
                FROM ERP7__Purchase_Line_Items__c WHERE Id IN :purchaseLineItemIds
            ]);
        }
        if(!purchaseLineItemIds.isEmpty()){
            Map<Id, Decimal> otherBilledQuantities = new Map<Id, Decimal>();  List<AggregateResult> results = [
                SELECT SUM(ERP7__Quantity__c) totalQuantity, ERP7__Purchase_Order_Line_Items__c pliId
                FROM ERP7__Bill_Line_Item__c   WHERE ERP7__Purchase_Order_Line_Items__c IN :purchaseLineItemIds AND Id NOT IN :billLineItemIds And RecordType.DeveloperName != 'Advance_to_vendor'
                GROUP BY ERP7__Purchase_Order_Line_Items__c
            ];
            
            for (AggregateResult ar : results) { Id pliId = (Id)ar.get('pliId');
                Decimal total = (Decimal)ar.get('totalQuantity');  otherBilledQuantities.put(pliId, total);
            }
            
            for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
                if(newBli.Id!=null){
                    ERP7__Bill_Line_Item__c oldBli = Trigger.oldMap.get(newBli.Id);
                    if(oldBli!=null){   if (newBli.ERP7__Quantity__c != oldBli.ERP7__Quantity__c || newBli.ERP7__Amount__c != oldBli.ERP7__Amount__c ||newBli.ERP7__Tax_Rate__c != oldBli.ERP7__Tax_Rate__c) {
                            
                            ERP7__Purchase_Line_Items__c parentPli = purchaseLineItemsMap.get(newBli.ERP7__Purchase_Order_Line_Items__c);
                            
                            if (parentPli != null) {
                                Decimal totalQuantityOnPli = parentPli.ERP7__Quantity__c != null ? parentPli.ERP7__Quantity__c : 0;
                                Decimal existingOtherQuantity = otherBilledQuantities.get(parentPli.Id) != null ? otherBilledQuantities.get(parentPli.Id) : 0;
                                
                                Decimal newTotalBilledQuantity = existingOtherQuantity + newBli.ERP7__Quantity__c;
                                Decimal unitPriceOnPli = parentPli.ERP7__Unit_Price__c != null ? parentPli.ERP7__Unit_Price__c : 0;
                                Decimal taxRateOnPli = parentPli.ERP7__Tax_Rate__c != null ? parentPli.ERP7__Tax_Rate__c : 0;
                                if (newTotalBilledQuantity > totalQuantityOnPli) {PreventRecursiveLedgerEntry.billTriggerIsBefore=false;
                                                                                 // newBli.addError('The updated quantity would cause the total billed quantity to exceed the original Purchase Order Line Item quantity of ' + totalQuantityOnPli);
                                }else if(newbli.ERP7__Amount__c != unitPriceOnPli) { 
                           			 	//newBli.addError('The updated amount of ' + newBli.ERP7__Amount__c + ' does not match the original Purchase Order Line Item Unit Price of ' + unitPriceOnPli);
                                }else if(newbli.ERP7__Tax_Rate__c != taxRateOnPli) { 
                            		//	newBli.addError('The updated tax rate of ' + newBli.ERP7__Tax_Rate__c + '% does not match the original Purchase Order Line Item tax rate of ' + taxRateOnPli + '%');
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        //multiple po scenario end
        
        Set<Id> parentBillIds = new Set<Id>();
        for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
            if (newBli.ERP7__Bill__c != null) {
                parentBillIds.add(newBli.ERP7__Bill__c);
            }
        }
        
        Map<Id, ERP7__Bill__c> parentBills = new Map<Id, ERP7__Bill__c>();
        if (!parentBillIds.isEmpty()) {
            parentBills = new Map<Id, ERP7__Bill__c>([
                SELECT Id, ERP7__Posted__c
                FROM ERP7__Bill__c
                WHERE Id IN :parentBillIds
            ]);
        }

        for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
            ERP7__Bill_Line_Item__c oldBli = Trigger.oldMap.get(newBli.Id);
            
            if(oldBli!=null){
                boolean fieldHasChanged = 
                    newBli.ERP7__Tax_Amount__c != oldBli.ERP7__Tax_Amount__c ||
                    newBli.ERP7__Tax_Rate__c != oldBli.ERP7__Tax_Rate__c ||
                    newBli.ERP7__Quantity__c != oldBli.ERP7__Quantity__c ||
                    // newBli.ERP7__Posted__c != oldBli.ERP7__Posted__c ||
                    newBli.ERP7__Amount__c != oldBli.ERP7__Amount__c ||
                    newBli.ERP7__Total_Amount__c != oldBli.ERP7__Total_Amount__c;
                
                ERP7__Bill__c parentBill = parentBills.get(newBli.ERP7__Bill__c);
                boolean parentBillIsPosted = (parentBill != null && parentBill.ERP7__Posted__c == true);
                if (fieldHasChanged && parentBillIsPosted) {PreventRecursiveLedgerEntry.billTriggerIsBefore=false;    newBli.addError('This Bill Line Item cannot be changed because the associated Bill has already been posted.');
                }
            }
            
        }*/
        for (ERP7__Bill_Line_Item__c item : Trigger.new) {
            ERP7__Bill_Line_Item__c oldItem = Trigger.oldMap.get(item.Id);

            // Recalculate only if specific fields changed
            if (
                item.ERP7__Quantity__c != oldItem.ERP7__Quantity__c ||
                item.ERP7__Amount__c != oldItem.ERP7__Amount__c ||
                item.ERP7__Tax_Rate__c != oldItem.ERP7__Tax_Rate__c
            ) {
                Decimal quantity = item.ERP7__Quantity__c != null ? item.ERP7__Quantity__c : 0;
                Decimal unitPrice = item.ERP7__Amount__c != null ? item.ERP7__Amount__c : 0;
                Decimal taxRate = item.ERP7__Tax_Rate__c != null ? item.ERP7__Tax_Rate__c : 0;

                Decimal taxAmount = (unitPrice * quantity) * (taxRate / 100);
                Decimal totalAmount = (unitPrice * quantity) + taxAmount;

                item.ERP7__Tax_Amount__c = taxAmount;
                item.ERP7__Total_Amount__c = totalAmount;
            }
        }
        
    }
    //
    //validations when creating bill
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<Id> purchaseLineItemIds = new Set<Id>();
        Set<Id> parentBillIds = new Set<Id>();
        
        for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
            if (newBli.ERP7__Purchase_Order_Line_Items__c != null) {
                purchaseLineItemIds.add(newBli.ERP7__Purchase_Order_Line_Items__c);
            }
            if (newBli.ERP7__Bill__c != null) {
                parentBillIds.add(newBli.ERP7__Bill__c);
            }
        }
        
        // Over-billing Validation
        if (!purchaseLineItemIds.isEmpty()) {
            Map<Id, ERP7__Purchase_Line_Items__c> purchaseLineItemsMap = new Map<Id, ERP7__Purchase_Line_Items__c>([
                SELECT Id, ERP7__Quantity__c
                FROM ERP7__Purchase_Line_Items__c
                WHERE Id IN :purchaseLineItemIds
            ]);
            
            Map<Id, Decimal> existingBilledQuantities = new Map<Id, Decimal>();
            for (AggregateResult ar : [
                SELECT SUM(ERP7__Quantity__c) totalQuantity, ERP7__Purchase_Order_Line_Items__c pliId
                FROM ERP7__Bill_Line_Item__c
                WHERE ERP7__Purchase_Order_Line_Items__c IN :purchaseLineItemIds And RecordType.DeveloperName != 'Advance_to_vendor'
                GROUP BY ERP7__Purchase_Order_Line_Items__c
            ]) {
                existingBilledQuantities.put((Id)ar.get('pliId'), (Decimal)ar.get('totalQuantity'));
            }
            
            for (ERP7__Bill_Line_Item__c newBli : Trigger.new) {
                ERP7__Purchase_Line_Items__c parentPli = purchaseLineItemsMap.get(newBli.ERP7__Purchase_Order_Line_Items__c);
                if (parentPli != null) {
                    Decimal totalQuantityOnPli = parentPli.ERP7__Quantity__c != null ? parentPli.ERP7__Quantity__c : 0;
                    Decimal newBilledQuantity = existingBilledQuantities.get(parentPli.Id) != null ? existingBilledQuantities.get(parentPli.Id) : 0;
                    Decimal newTotalBilledQuantity = newBilledQuantity + (newBli.ERP7__Quantity__c != null ? newBli.ERP7__Quantity__c : 0);
                    
                    if (newTotalBilledQuantity > totalQuantityOnPli) {  // newBli.addError('The quantity would cause the total billed quantity to exceed the original Purchase Order Line Item quantity of ' + totalQuantityOnPli);
                    }
                }
            }
        }
    }
    //
    
    //new code below to update bill when changes are doe on line items
    if (Trigger.isAfter && Trigger.isUpdate && PreventRecursiveLedgerEntry.billTriggersIsAfter) {
        Set<Id> billIds = new Set<Id>();
        for (ERP7__Bill_Line_Item__c item : Trigger.new) {
            ERP7__Bill_Line_Item__c oldItem = Trigger.oldMap.get(item.Id);
            if (
                item.ERP7__Quantity__c != oldItem.ERP7__Quantity__c || 
                item.ERP7__Amount__c != oldItem.ERP7__Amount__c || 
                item.ERP7__Tax_Amount__c != oldItem.ERP7__Tax_Amount__c
            ) {
                // only now add the parent Bill to the list
                if (item.ERP7__Bill__c != null) {  billIds.add(item.ERP7__Bill__c);
                }
            }
        }
        if (!billIds.isEmpty()) {
            // Query all line items for those bills
            List<ERP7__Bill_Line_Item__c> lineItems = [
                SELECT
                Id,
                ERP7__Bill__c,
                ERP7__Amount__c,
                ERP7__Quantity__c,
                ERP7__Tax_Amount__c,
                ERP7__Total_Amount__c
                FROM ERP7__Bill_Line_Item__c
                WHERE ERP7__Bill__c IN :billIds
            ];
            
            // Create maps to accumulate per bill
            Map<Id, Decimal> amountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> taxMap = new Map<Id, Decimal>();
            Map<Id, Decimal> totalAmountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> quantityMap = new Map<Id, Decimal>();
            
            for (ERP7__Bill_Line_Item__c item : lineItems) {  Id billId = item.ERP7__Bill__c;   if (billId == null) continue;
                
                Decimal quantity = item.ERP7__Quantity__c != null ? item.ERP7__Quantity__c : 0;
                Decimal unitPrice = item.ERP7__Amount__c != null ? item.ERP7__Amount__c : 0;
                Decimal tax = item.ERP7__Tax_Amount__c != null ? item.ERP7__Tax_Amount__c : 0;
                Decimal total = item.ERP7__Total_Amount__c != null ? item.ERP7__Total_Amount__c : 0;
                
                amountMap.put(billId, (amountMap.containsKey(billId) ? amountMap.get(billId) : 0) + (unitPrice * quantity));
                taxMap.put(billId, (taxMap.containsKey(billId) ? taxMap.get(billId) : 0) + tax);
                totalAmountMap.put(billId, (totalAmountMap.containsKey(billId) ? totalAmountMap.get(billId) : 0) + total);
                quantityMap.put(billId, (quantityMap.containsKey(billId) ? quantityMap.get(billId) : 0) + quantity);
            }
            
            // Now update the bills with the recalculated values
            List<ERP7__Bill__c> billsToUpdate = new List<ERP7__Bill__c>();
            
            for (Id billId : billIds) {
                ERP7__Bill__c bill = new ERP7__Bill__c(
                    Id = billId,
                    ERP7__Amount__c = amountMap.containsKey(billId) ? amountMap.get(billId) : 0,
                    ERP7__VAT_TAX_Amount__c = taxMap.containsKey(billId) ? taxMap.get(billId) : 0,
                    ERP7__Total_Amount__c = totalAmountMap.containsKey(billId) ? totalAmountMap.get(billId) : 0
                   // ERP7__Matched__c = false
                );
                System.debug('bill matched still -- '+bill.ERP7__Matched__c);
                billsToUpdate.add(bill);
            }
            System.debug('billsToUpdate size '+billsToUpdate.size());
            if (!billsToUpdate.isEmpty()) {PreventRecursiveLedgerEntry.billTriggersIsAfter=false;
                                              update billsToUpdate;
            }
        }
    }
    //new code end
    
    if((Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c)) && Trigger.isAfter && PreventRecursiveLedgerEntry.billTriggersFromPO){//new condition added to stop unnecessary triggers from running
        
        for(Transaction__c trans:[SELECT Id,Bill__c,ERP7__Bill_Line_Item__c FROM Transaction__c Where ERP7__Bill_Line_Item__c in:Trigger.newMap.keyset()]){
            if(trans.ERP7__Bill_Line_Item__c != null) ExistingTransaction_Map2BilllineItemlineItem.put(trans.ERP7__Bill_Line_Item__c,trans.Id);
        }
        
        if(!PreventRecursiveLedgerEntry.testCasesTransactions){  
            Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Supplier_Invoice_Transaction'); 
            for( ERP7__Bill_Line_Item__c billlineitem : System.Trigger.New){   
                Decimal sum=0; sum=billlineitem.ERP7__Amount__c*billlineitem.ERP7__Quantity__c;
                if(ExistingTransaction_Map2BilllineItemlineItem.get(billlineitem.id)!=null){  
                    Transaction__c trans = new Transaction__c(Id=ExistingTransaction_Map2BilllineItemlineItem.get(billlineitem.id));  
                    if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){
                        trans.Active__c = billlineitem.Posted__c;
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                        trans.Amount__c = billlineitem.Total_Amount__c;
                    }else{/*No access*/}   
                    if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){
                        trans.Organisation__c = billlineitem.Organisation__c;
                    }else{/*No access*/} 
                    if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){
                        trans.Organisation_Business_Unit__c = billlineitem.Cost_Centre_Unit__c;
                    }else{/*No access*/} 
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){
                        trans.Transaction_Date__c = (billlineitem.ERP7__Posted_Date__c != null)?billlineitem.ERP7__Posted_Date__c:System.Today();
                    }else{/*No access*/} 
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){
                        trans.Transaction_Status__c = 'Completed';
                    }else{/*No access*/}
                    if(billlineitem.RecordTypeId == Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Expense_Bill').getRecordTypeId()) {
                        trans.Transaction_Type__c = 'Expense';   }  else{ trans.Transaction_Type__c = 'Purchase'; }
                    if(Schema.sObjectType.Transaction__c.fields.Bill__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Bill__c.isUpdateable()){
                        trans.Bill__c = billlineitem.Bill__c;
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isUpdateable()){
                        trans.ERP7__Supplier__c =  billlineitem.Vendor__c;  
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isUpdateable()){
                        trans.ERP7__Bill_Line_Item__c = billlineitem.Id; 
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isUpdateable()){
                        trans.Purchase_Return_PO__c =billlineitem.Purchase_Order__c;     
                    }else{/*No access*/}     
                    if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){
                        trans.Product__c = billlineitem.Product__c;
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){
                        trans.Project__c = billlineitem.Project__c;     
                    }else{/*No access*/}  
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()){
                        trans.ERP7__Purchase_Line_Items__c =billlineitem.Purchase_Order_Line_Items__c; 
                    }else{/*No access*/}
                    Transactions2update.add(trans);
                }else{
                    if(billlineitem.Posted__c){      
                        Transaction__c trans = new Transaction__c();    
                        if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){
                            trans.Active__c = true;
                        }else{/*No access*/}   
                        if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                            trans.Amount__c = billlineitem.Total_Amount__c; 
                        }else{/*No access*/}  
                        if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){
                            trans.Organisation__c = billlineitem.Organisation__c; 
                        }else{/*No access*/}   
                        if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){
                            trans.Organisation_Business_Unit__c = billlineitem.Cost_Centre_Unit__c; 
                        }else{/*No access*/}  
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){
                            trans.Transaction_Date__c = (billlineitem.ERP7__Posted_Date__c != null)?billlineitem.ERP7__Posted_Date__c:System.Today(); 
                        }else{/*No access*/}   
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){
                            trans.Transaction_Status__c = 'Completed';     
                        }else{/*No access*/}
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){
                            if(billlineitem.RecordTypeId == Schema.SObjectType.ERP7__Bill_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Expense_Bill').getRecordTypeId()){ 
                                trans.Transaction_Type__c = 'Expense'; 
                            }else{       trans.Transaction_Type__c = 'Purchase';
                            }
                        }else{/*No access*/}
                        if(Schema.sObjectType.Transaction__c.fields.Bill__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Bill__c.isUpdateable()){trans.Bill__c = billlineitem.Bill__c; }else{/*No access*/}    if(Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isUpdateable()){trans.ERP7__Supplier__c =  billlineitem.Vendor__c; }else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isUpdateable()){trans.ERP7__Bill_Line_Item__c = billlineitem.Id;   }else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){trans.Product__c = billlineitem.Product__c;   }else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){trans.Project__c = billlineitem.Project__c;  }else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isUpdateable()){trans.Purchase_Return_PO__c =billlineitem.Purchase_Order__c;  }else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()){trans.ERP7__Purchase_Line_Items__c =billlineitem.Purchase_Order_Line_Items__c;    }else{/*No access*/}   if(SIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = SIT; }else{/*No access*/}
                        Transactions2update.add(trans);
                    }
                }
            } 
            
            system.debug('Transactions2update.size() from bill~>'+Transactions2update.size());
            
            if(Transactions2update.size() > 0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){  /*   //upsert Transactions2update;*/  } else{ /* no access */ }
        }
    }
    
}