({
    getInvoiceRecord  : function(cmp,event,helper) {
        let str = cmp.get("v.InvoiceId");
        str = str.replace('}', '');
        
        cmp.set("v.InvoiceId",str);
        var action = cmp.get("c.fetchRecord");
        action.setParams({
            InvId:cmp.get("v.InvoiceId")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState(); 
            var result = response.getReturnValue();
            if(state ==='SUCCESS'){
                cmp.set('v.Rec',response.getReturnValue());
                cmp.set('v.Name',result.Name);
                cmp.set('v.Type',result.ERP7__Record_Type_Name__c );
                cmp.set('v.OrdId',result.ERP7__Order_S__c);
                let tempId = result.ERP7__Order_S__c;
                console.log('tempId::',tempId);
                cmp.set("v.StandardOrdId",tempId);
                
                cmp.set('v.SoId',result.ERP7__Order__c);
                cmp.set('v.recordId',result.Id);
                cmp.set('v.InvAmt', result.ERP7__Invoice_Amount__c);
                cmp.set('v.TaxAmt', result.ERP7__Tax_Amount__c);
                cmp.set('v.Discount', result.ERP7__Discount__c);
                console.log('-->'+ cmp.get('v.recordId'));
                if(!$A.util.isEmpty(cmp.get("v.SoId")))
                    helper.getFieldsSetApiNameHandler(cmp,'ERP7__Invoice__c','erp7__createinvoice');
                if(!$A.util.isEmpty(cmp.get("v.OrdId")))
                    helper.getFieldsSetApiNameHandler(cmp,'ERP7__Invoice__c','ERP7__Create_Order_Invoice');
                var type=cmp.get('v.Type');
                //console.log("type-->"+ type);
                //console.log("bfr"+cmp.get('v.allowEdit'));
                if(type==="Sale")
                    //cmp.set('v.allowEdit',false);
                //console.log("aft"+cmp.get('v.allowEdit'));
                console.log("sales order id"+cmp.get('v.SoId'));
                console.log("order id"+cmp.get('v.OrdId'));
                helper.setDefaultValues(cmp,event,helper);
            }
            else{
                console.log('Error:',response.getError());
            } 
        });
        $A.enqueueAction(action);
        
    },
        setDefaultValues: function(component, event, helper){
        if(!$A.util.isEmpty(component.get("v.InvoiceId"))){  
            //helper.fetchOrderInfo(component);
            //helper.getInvoiceLineItem(component);
            
            if(!$A.util.isEmpty(component.get("v.OrdId"))){
                let ordId = component.get("v.StandardOrdId");
                console.log('StandardOrdId::'+ ordId);
                console.log('SOrdId::'+ component.get("v.SoId"));
                var action = component.get("c.getInvoicesofOrder");
                
                action.setParams({
                    OrdId:component.get("v.StandardOrdId"),
                    InvId:component.get("v.InvoiceId")
                }); 
                action.setCallback(this,function(response){
                    var state = response.getState(); 
                    var PaidAmount =0.00;
                    var invid= component.get("v.InvoiceId");
                    var res = response.getReturnValue();
                    
                    if(state ==='SUCCESS'){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log(" Invoice result::"+ JSON.stringify(res));
                        
                        for(var i in res){  
                            if(!$A.util.isEmpty(res[i].ERP7__Paid_Amount_Applied__c))
                            {
                                PaidAmount = Number(PaidAmount) +  Number(JSON.stringify(res[i].ERP7__Paid_Amount_Applied__c));
                                component.set("v.TotalPaidAdvance", PaidAmount);
                                console.log("not inv id "+ res[i].Id);
                            }
                        }
                        console.log("inv id "+ component.get("v.InvoiceId"));  
                        
                        console.log(" PaidAmount: "+ component.get("v.TotalPaidAdvance"));
                        
                        
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log('Error?',response.getError());
                    } 
                });
                
                $A.enqueueAction(action);
            } 
            else{
                let ordId = component.get("v.StandardOrdId");
                console.log('StandardOrdId::'+ ordId);
                console.log('SOrdId::'+ component.get("v.SoId"));
                var action = component.get("c.getInvoicesofSales");
                
                action.setParams({
                    OrdId:component.get("v.SoId"),
                    InvId:component.get("v.InvoiceId")
                }); 
                action.setCallback(this,function(response){
                    var state = response.getState(); 
                    var PaidAmount =0.00;
                    var invid= component.get("v.InvoiceId");
                    var res = response.getReturnValue();
                    
                    if(state ==='SUCCESS'){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log(" Invoice result::"+ JSON.stringify(res));
                        
                        for(var i in res){  
                            if(!$A.util.isEmpty(res[i].ERP7__Paid_Amount_Applied__c))
                            {
                                PaidAmount = Number(PaidAmount) +  Number(JSON.stringify(res[i].ERP7__Paid_Amount_Applied__c));
                                component.set("v.TotalPaidAdvance", PaidAmount);
                                console.log("not inv id "+ res[i].Id);
                            }
                        }
                        console.log("inv id "+ component.get("v.InvoiceId"));  
                        
                        console.log(" PaidAmount: "+ component.get("v.TotalPaidAdvance"));
                        
                        
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log('Error?',response.getError());
                    } 
                });
                
                $A.enqueueAction(action);
            }
        }
        
    },
    getInvoicesofOrder: function(cmp,event,helper){
        var action = cmp.get("c.getInvoicesofOrder");
        let ordId = cmp.get("v.StandardOrdId");
        console.log('inside getInvoicesofOrder StandardOrdId::'+ ordId);
        action.setParams({
            OrdId:cmp.get("v.StandardOrdId")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState(); 
            var res = response.getReturnValue();
            if(state ==='SUCCESS'){
                cmp.set("v.InvoicesOrder", res);
                console.log(" Invoice result::"+ response.getReturnValue());
                
                /*for(var i in res){  
                    if(res.ERP7__Order_S__c != '' || res.ERP7__Order_S__c != null)
                    console.log(" Invoice"+ i +" "+ JSON.stringify(res[i].Id));
                }*/
            }
            else{
                console.log('Error?',response.getError());
            } 
        });
        
        $A.enqueueAction(action);
    },
    
    getFieldsSetApiNameHandler: function(component,objectApiName,fieldSetApiName){
        var action = component.get("c.getFieldsSetApiName");
        action.setParams({
            sObjectName : objectApiName,
            fieldSetApiName :fieldSetApiName});
        action.setCallback(this,function(response){
            if(objectApiName==='ERP7__Invoice__c')
                component.set("v.invoiceFields",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    fetchOrderInfo: function(cmp){
        
        var action = cmp.get("c.fetchRecord");
        action.setParams({
            InvId:cmp.get("v.InvoiceId")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState(); 
            if(state ==='SUCCESS'){
                cmp.set('v.Rec',response.getReturnValue());
                console.log('Rec::',cmp.get("v.Rec"));
            }
            else{
                console.log('Error:',response.getError());
            } 
        });
        $A.enqueueAction(action);
        
        var renderedFields = cmp.find("inv_input_field");
        for(var  x in renderedFields){ 
            if(renderedFields[x].get('v.fieldName')==='ERP7__Order_S__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Order_S__c');
            if(renderedFields[x].get('v.fieldName')==='ERP7__Account__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Account__c');     
            if(renderedFields[x].get('v.fieldName')==='ERP7__Contact__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Contact__c');
            if(renderedFields[x].get('v.fieldName')==='ERP7__Organisation__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Organisation__c');
            if(renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Date__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Invoice_Date__c');
            if(renderedFields[x].get('v.fieldName')==='ERP7__Order__c')
                renderedFields[x].set('v.value','v.Rec.ERP7__Order__c');
            
        }
    },
    getInvoiceLineItem: function(component){
        var action = component.get("c.getInvoiceLineItems");
        action.setParams({
            InvoiceId : component.get("v.InvoiceId")
            
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                console.log('response getInvoiceLineItems : ',response.getReturnValue());
                component.set("v.INVLIList",response.getReturnValue());
            }else{
                console.log('Error:',response.getError());
            } 
            
        });
        $A.enqueueAction(action);
        
        
        //component.set("v.subtotal",list.ERP7__Sub_Total__c);
        
    },
    getPayTerms: function(component){
        var action = component.get("c.getPayTerms");
        action.setCallback(this,function(response){
            let resList = response.getReturnValue();
            console.log('resList',resList);
            component.set("v.PayTermsoptions",resList);                 
        });
        $A.enqueueAction(action);
    },
    beforedelete: function(c){
        var recs=c.get("v.INVLIList");
        var renderedFields=c.find("inv");
        var totalAmount=0;
        var totalDiscount=0;
        var taxAmount=0;
        for(var i in recs){
            if(recs[i].ERP7__Total_Price__c==null){
                recs[i].ERP7__Total_Price__c=0;  
            }
            totalDiscount= Number(totalDiscount) + Number(recs[i].ERP7__Discount_Amount__c);
            totalAmount=Number(totalAmount) + Number(recs[i].ERP7__Total_Price__c);
            taxAmount=Number(taxAmount) + Number(recs[i].ERP7__Total_Tax__c);
            
        }
        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c')
                renderedFields[x].set("v.value",taxAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c')
                renderedFields[x].set("v.value",totalDiscount);
        }
        var rec= c.get("v.Rec")
        rec.ERP7__Invoice_Amount__c=totalAmount;
        rec.ERP7__Tax_Amount__c=taxAmount;
        rec.ERP7__Discount_Amount__c=totalDiscount;
        
        var percentage = rec.ERP7__Down_Payment__c;
        var total=0;
        if(rec.ERP7__Paid_Amount_Applied__c!=null && rec.ERP7__Paid_Amount_Applied__c!= 0)
            total=rec.ERP7__Invoice_Amount__c - rec.ERP7__Paid_Amount_Applied__c;
        else
            total=rec.ERP7__Invoice_Amount__c;
        
        if(percentage != null){
            if(percentage>=1)
            {
                rec.ERP7__Total_Down_Payment_Amount__c = total*(percentage/100); 
            } 
            else{
                rec.ERP7__Total_Down_Payment_Amount__c =  total*percentage;
            }            
        }
        c.set("v.Rec",rec);
        
        
    },
    beforesave: function(comp){
        var invAmt =comp.get("v.InvAmt");
        var Rec= comp.get("v.Rec");
        //Schedule_Invoice
        console.log("invAmt value"+invAmt);
        console.log("outside if");
        var type=comp.get('v.Type');
        if(type==="Schedule_Invoice" && invAmt!=null && invAmt!= 0)
        {	console.log("inside if");
         Rec.ERP7__Invoice_Amount__c= invAmt;
         comp.set("v.Rec",Rec);
         var checkk=comp.get("v.Rec");
         console.log("V.rec"+ checkk.ERP7__Invoice_Amount__c);
        }
    },
    beforeSaveNew: function(component){
        var bool = false;
        var recs = component.get("v.INVLIList");
        for(var x in recs){
            if(x==1)console.log('1');
            if(recs[x].ERP7__Quantity__c == ''|| recs[x].ERP7__Quantity__c == null || recs[x].ERP7__Quantity__c == undefined || recs[x].ERP7__Quantity__c == 0 ||recs[x].ERP7__Quantity__c < 0){
                component.set('v.exceptionError','Please enter valid quantity for ' + recs[x].ERP7__Product__r.Name);
                return true;
            } else if(recs[x].ERP7__Unit_Price__c == ''|| recs[x].ERP7__Unit_Price__c == null || recs[x].ERP7__Unit_Price__c == undefined || recs[x].ERP7__Unit_Price__c == 0 || recs[x].ERP7__Unit_Price__c < 0 ){
                component.set('v.exceptionError','Please enter valid unit price for ' + recs[x].ERP7__Product__r.Name);
                return true;
            } else if(recs[x].ERP7__Sub_Total__c == ''|| recs[x].ERP7__Sub_Total__c == null || recs[x].ERP7__Sub_Total__c == undefined || recs[x].ERP7__Sub_Total__c == 0 || recs[x].ERP7__Sub_Total__c < 0){
                component.set('v.exceptionError','Sub Total cannot be 0');
                return true;
            }else if(recs[x].ERP7__Total_Price__c == ''|| recs[x].ERP7__Total_Price__c == null || recs[x].ERP7__Total_Price__c == undefined || recs[x].ERP7__Total_Price__c == 0 || recs[x].ERP7__Total_Price__c < 0){
                component.set('v.exceptionError','Total Price cannot be 0.');
                return true;
            } 
        }
        return bool;
    }
    /* var action = component.get("c.getPayTerms");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                console.log('response : ',response.getReturnValue());
                component.set("v.PayTermsoptions",response.getReturnValue());
            }else{
                console.log('Error:',response.getError());
            } 
            
        });
        $A.enqueueAction(action);*/
    
})