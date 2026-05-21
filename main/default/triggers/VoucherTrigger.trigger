/*
* Changes made by - Syed Moin Pasha
* Date - 26th july 2023
* Reason - Was getting exception RollUpSummaryUtility exp~>Update failed. First exception on row 0 with id a1J06000009lvv5EAA; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ERP7.BillTrigger: execution of AfterUpdate
* Fix Applied : Added PreventRecursiveLedgerEntry.proceedVoucherCreation = false; on line 62
* 
*/

trigger VoucherTrigger on Voucher__c (after insert, after update, before update, before delete){
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c) ){
        system.debug('PreventRecursiveLedgerEntry.testCasesTransactions-->'+PreventRecursiveLedgerEntry.testCasesTransactions);
        if(!PreventRecursiveLedgerEntry.testCasesTransactions){
                if(Trigger.isBefore && Trigger.isUpdate){
                    //new code is to validate the correct voucher amounts. the amounts should not be greater than the bill amount
                    Set<Id> billIds = new Set<Id>();
        			for (Voucher__c vou : Trigger.new) {
            			if (vou.ERP7__Vendor_invoice_Bill__c != null) {
                			billIds.add(vou.ERP7__Vendor_invoice_Bill__c);
            			}
        			}
    				Map<Id, Decimal> existingVoucherAmounts = new Map<Id, Decimal>();
    				for(AggregateResult ar : [SELECT SUM(ERP7__Amount__c) totalAmount, ERP7__Vendor_invoice_Bill__c FROM Voucher__c WHERE ERP7__Vendor_invoice_Bill__c IN :billIds GROUP BY ERP7__Vendor_invoice_Bill__c]) {
        				existingVoucherAmounts.put((Id)ar.get('ERP7__Vendor_invoice_Bill__c'), (Decimal)ar.get('totalAmount'));
    				}
        			Map<Id, ERP7__Bill__c> billMap = new Map<Id, ERP7__Bill__c>(
            			[SELECT Id, ERP7__Total_Amount__c FROM ERP7__Bill__c WHERE Id IN :billIds]
        			);
                	for(Voucher__c vou : Trigger.new){
                    	Voucher__c oldVoucher = Trigger.oldMap.get(vou.Id);
                    	if (vou.ERP7__Amount__c != oldVoucher.ERP7__Amount__c && (oldVoucher.ERP7__Approved__c == true || oldVoucher.ERP7__Paid__c==true)) {
                        	//vou.addError('You cannot change the Amount field on a voucher that has already been approved or paid.');
                        }else if(vou.ERP7__Amount__c != oldVoucher.ERP7__Amount__c && oldVoucher.ERP7__Approved__c == false){
                        	ERP7__Bill__c parentBill = billMap.get(vou.ERP7__Vendor_invoice_Bill__c);
                			if (parentBill != null) {
                    			Decimal totalOtherVouchersAmount = existingVoucherAmounts.get(parentBill.Id) != null ? existingVoucherAmounts.get(parentBill.Id) : 0;
                    			totalOtherVouchersAmount -= oldVoucher.ERP7__Amount__c;
                    			Decimal newTotalVouchersAmount = totalOtherVouchersAmount + vou.ERP7__Amount__c;
                    			if (newTotalVouchersAmount > parentBill.ERP7__Total_Amount__c) {
                        			//vou.addError('The total amount for all vouchers on this bill (' + newTotalVouchersAmount + ') cannot exceed the bill\'s total amount (' + parentBill.ERP7__Total_Amount__c + ').');
                    			}
                			}
                        }//new code end
                    	if(vou.ERP7__Credit_Applied__c!=null) vou.ERP7__Amount_Paid__c = vou.ERP7__Amount_Paid_Rollup__c + vou.ERP7__Credit_Applied__c;
                    	else vou.ERP7__Amount_Paid__c = vou.ERP7__Amount_Paid_Rollup__c;
                    	system.debug('Credit-->'+vou.ERP7__Credit_Applied__c);
                    	system.debug('Amount Paid-->'+vou.ERP7__Amount_Paid__c);
                	}
            }
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                system.debug('Here');
                PreventRecursiveLedgerEntry.proceedVoucherCreation = false;System.debug('set the ERP7__Amount_Paid__c on Bill from voucher ');System.debug(trigger.new);
                list<RollUpSummaryUtility.fieldDefinition> MPSfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
                    new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount_Paid__c', 'ERP7__Amount_Paid__c')
                        };
                            RollUpSummaryUtility.rollUpTrigger(MPSfieldDefinitions, trigger.new, 'ERP7__Voucher__c','ERP7__Vendor_invoice_Bill__c', 'ERP7__Bill__c', '');
                PreventRecursiveLedgerEntry.testCasesTransactions = true;
                
            }
        }
        //validation to not allow deletion of voucher if payment is made
        if (Trigger.isBefore && Trigger.isDelete) {
    		for (Voucher__c voucher : Trigger.old) {
        		if (voucher.ERP7__Paid__c == true) {
            		//voucher.addError('This voucher cannot be deleted because it has already been paid.');
        		}
    		}
		}
        //
    }  
}