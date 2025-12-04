({
    doInit : function(cmp, event, helper) {
        helper.getInvoiceRecord(cmp,event,helper); 
        helper.getPayTerms(cmp,event,helper);  
        helper.getInvoiceLineItem(cmp);
    },
    
    handleInvoiceSuccess: function(c,e,h){
        helper.getInvoiceLineItem(c);
    },
    
    CancelCalled : function(comp, event, helper){ 
        history.back();  
    },
    
    quanchange: function(comp,event,helper){
        var invrec = comp.get("v.Rec");
        var index=event.getSource().get("v.title");
        console.log('checking===>'+ index);
        var recs = comp.get("v.INVLIList");
        recs[index][event.target.name] = event.getSource().get("v.value");
        var qty = event.getSource().get("v.value");
        var subtotal;
        var total;
        var dis;
        var tax;
        let unitprice = recs[index].ERP7__Unit_Price__c;
        subtotal = qty*unitprice;
        recs[index].ERP7__Sub_Total__c=subtotal;
        dis= recs[index].ERP7__Discount_Amount__c;
        if(dis == null){
            dis=0.00;
        }
        tax= recs[index].ERP7__Total_Tax__c;
        if(tax == null){
            tax=0.00;
        }
        total= Number(subtotal) -dis + Number(tax) ;
        if(recs[index].ERP7__Sub_Total__c!= 0 && recs[index].ERP7__Sub_Total__c!= null) {
            
            recs[index].ERP7__Total_Price__c= total;
            
            // recs[index].ERP7__Total_Price__c= (recs[index].ERP7__Sub_Total__c) - (recs[index].ERP7__Discount_Amount__c); 
            
            // recs[index].ERP7__Total_Price__c= total;
            
        }        
        comp.set("v.INVLIList", recs);
        
        var renderedFields = comp.find("inv");
        var taxAmount = 0.00;
        var totalAmount = 0.00;
        var totalDiscount=0.00;
        
        for(var i in recs){
            totalDiscount= Number(totalDiscount) + Number(recs[i].ERP7__Discount_Amount__c);
            totalAmount=Number(totalAmount) + Number(recs[i].ERP7__Total_Price__c);
            taxAmount=Number(taxAmount) + Number(recs[i].ERP7__Total_Tax__c);
            
        }
        
        console.log('-->'+totalDiscount);
        
        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c')
                renderedFields[x].set("v.value",taxAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c')
                renderedFields[x].set("v.value",totalDiscount);
        }
        var rec= comp.get("v.Rec")
        rec.ERP7__Invoice_Amount__c=totalAmount;
        rec.ERP7__Tax_Amount__c=taxAmount;
        rec.ERP7__Discount_Amount__c=totalDiscount;
        comp.set("v.InvAmt",totalAmount);
        comp.set("v.TaxAmt",taxAmount);
        comp.set("v.Discount",totalDiscount);
        comp.set("v.Rec",rec);
        var checkk=comp.get("v.Rec");
        console.log("V.rec"+ checkk.ERP7__Invoice_Amount__c);
        console.log('V.rec',checkk);
        
    },
    unitpricechange: function(comp,event,helper){
        var invrec = comp.get("v.Rec");
        var index=event.getSource().get("v.title");
        console.log('checking===>'+ index);
        var recs = comp.get("v.INVLIList");
        recs[index][event.target.name] = event.getSource().get("v.value");
        var qty = recs[index].ERP7__Quantity__c;
        var subtotal;
        var total;
        var dis;
        var tax;
        let unitprice = event.getSource().get("v.value");
        subtotal = qty*unitprice;
        recs[index].ERP7__Sub_Total__c=subtotal;
        dis= recs[index].ERP7__Discount_Amount__c;
        if(dis == null){
            dis=0.00;
        }
        tax= recs[index].ERP7__Total_Tax__c;
        if(tax == null){
            tax=0.00;
        }
        total= Number(subtotal) -dis + Number(tax) ;
        if(recs[index].ERP7__Sub_Total__c!= 0 && recs[index].ERP7__Sub_Total__c!= null) {
            
            recs[index].ERP7__Total_Price__c= total;
        }        
        comp.set("v.INVLIList", recs);
        
        var renderedFields = comp.find("inv");
        var taxAmount = 0.00;
        var totalAmount = 0.00;
        var totalDiscount=0.00;
        
        for(var i in recs){
            totalDiscount= Number(totalDiscount) + Number(recs[i].ERP7__Discount_Amount__c);
            totalAmount=Number(totalAmount) + Number(recs[i].ERP7__Total_Price__c);
            taxAmount=Number(taxAmount) + Number(recs[i].ERP7__Total_Tax__c);
            
        }
        
        console.log('-->'+totalDiscount)
        
        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c')
                renderedFields[x].set("v.value",taxAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c')
                renderedFields[x].set("v.value",totalDiscount);
        }
        var rec= comp.get("v.Rec")
        rec.ERP7__Invoice_Amount__c=totalAmount;
        rec.ERP7__Tax_Amount__c=taxAmount;
        rec.ERP7__Discount_Amount__c=totalDiscount;
        comp.set("v.InvAmt",totalAmount);
        comp.set("v.TaxAmt",taxAmount);
        comp.set("v.Discount",totalDiscount);
        comp.set("v.Rec",rec);
        var checkk=comp.get("v.Rec");
        console.log("V.rec"+ checkk.ERP7__Invoice_Amount__c);
        console.log('V.rec',checkk);
        
    },
    taxchange: function(comp,event,helper){
        var index=event.getSource().get("v.title");
        var recs = comp.get("v.INVLIList");
        recs[index].ERP7__VAT_Amount__c = event.getSource().get("v.value");
        
        var tax=event.getSource().get("v.value");
        console.log("-->"+ tax);
        var sub= (recs[index].ERP7__Sub_Total__c);
        var dis =(recs[index].ERP7__Discount_Amount__c);
        if(dis == null){
            dis=0.00;
        }
        var t= Number(sub)+Number(tax);
        var total = t - dis;
        if(recs[index].ERP7__Sub_Total__c!= 0 && recs[index].ERP7__Sub_Total__c!= null) {
            recs[index].ERP7__Total_Price__c= total; 
        }
        
        
        comp.set("v.INVLIList", recs);
        console.log('V.INVLIList',recs);
        var renderedFields = comp.find("inv");
        var taxAmount = 0.00;
        var totalAmount = 0.00;
        var totalDiscount=0.00;
        
        for(var i in recs){
            totalDiscount= Number(totalDiscount) + Number(recs[i].ERP7__Discount_Amount__c);
            totalAmount=Number(totalAmount) + Number(recs[i].ERP7__Total_Price__c);
            taxAmount=Number(taxAmount) + Number(recs[i].ERP7__Total_Tax__c);
            
        }
        
        
        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                renderedFields[x].set("v.value",taxAmount);
                
            }
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c')
                renderedFields[x].set("v.value",totalDiscount);
        }
        var rec= comp.get("v.Rec")
        rec.ERP7__Invoice_Amount__c=totalAmount;
        rec.ERP7__Tax_Amount__c=taxAmount;
        rec.ERP7__Discount_Amount__c=totalDiscount;
        comp.set("v.InvAmt",totalAmount);
        comp.set("v.TaxAmt",taxAmount);
        comp.set("v.Discount",totalDiscount);
        comp.set("v.Rec",rec);
        var checkk=comp.get("v.Rec");
        console.log("V.rec"+ checkk.ERP7__Invoice_Amount__c);
        console.log('V.rec',checkk);
        
    },
    
    dischange:function(comp,event,helper){
        var index=event.getSource().get("v.title");
        var recs = comp.get("v.INVLIList");
        
        recs[index][event.target.name] = event.getSource().get("v.value");
        
        //var dis =event.getSource().get("v.value");
        
        
        if(recs[index].ERP7__Sub_Total__c!= 0 && recs[index].ERP7__Sub_Total__c!= null &&  recs[index].ERP7__Discount_Amount__c!= null &&  recs[index].ERP7__Discount_Amount__c!= 0 ) {
            recs[index].ERP7__Total_Price__c=  Number(recs[index].ERP7__Sub_Total__c) + Number(recs[index].ERP7__Total_Tax__c) - recs[index].ERP7__Discount_Amount__c; 
        }
        else if(recs[index].ERP7__Sub_Total__c!= 0 && recs[index].ERP7__Sub_Total__c!= null &&  recs[index].ERP7__Discount_Amount__c== null  ) {
            recs[index].ERP7__Discount_Amount__c= 0.00;
            recs[index].ERP7__Total_Price__c=  Number(recs[index].ERP7__Sub_Total__c) + Number(recs[index].ERP7__Total_Tax__c) - recs[index].ERP7__Discount_Amount__c; 
        }
        
        comp.set("v.INVLIList", recs); 
        var renderedFields = comp.find("inv");
        var taxAmount = 0.00;
        var totalAmount = 0.00;
        var totalDiscount=0.00;
        
        for(var i in recs){
            totalDiscount= Number(totalDiscount) + Number(recs[i].ERP7__Discount_Amount__c);
            totalAmount=Number(totalAmount) + Number(recs[i].ERP7__Total_Price__c);
            taxAmount=Number(taxAmount) + Number(recs[i].ERP7__Total_Tax__c);
            
        }
        
        console.log('-->'+totalDiscount)
        
        for(var  x in renderedFields){
            if( renderedFields[x].get('v.fieldName')==='ERP7__Tax_Amount__c'){
                renderedFields[x].set("v.value",taxAmount);
                
            }
            if( renderedFields[x].get('v.fieldName')==='ERP7__Invoice_Amount__c')
                renderedFields[x].set("v.value",totalAmount);
            
            if( renderedFields[x].get('v.fieldName')==='ERP7__Discount_Amount__c')
                renderedFields[x].set("v.value",totalDiscount);
        }
        var rec= comp.get("v.Rec")
        rec.ERP7__Invoice_Amount__c=totalAmount;
        rec.ERP7__Tax_Amount__c=taxAmount;
        rec.ERP7__Discount_Amount__c=totalDiscount;
        comp.set("v.InvAmt",totalAmount);
        comp.set("v.TaxAmt",taxAmount);
        comp.set("v.Discount",totalDiscount);
        comp.set("v.Rec",rec);
        console.log('V.rec',rec);
    },
    
    deschange:function(comp,event,helper){
        var index=event.getSource().get("v.title");
        var recs = comp.get("v.INVLIList");
        recs[index][event.target.name] = event.getSource().get("v.value");
        comp.set("v.INVLIList", recs);  
        console.log('V.rec',recs);
    },
    
    advchange:function(comp,event,helper){
        var Rec=comp.get("v.Rec");
        var adv=event.getSource().get("v.value");
        var totalpaid=comp.get("v.TotalPaidAdvance");
        console.log("Amount_Paid: "+ Rec.ERP7__Amount_Paid__c);
        console.log("Total paid advance: "+ totalpaid);
        var cond;
        if(Rec.ERP7__Amount_Paid__c > 0 && totalpaid >= 0){// For checking changed values in the org
            cond=Rec.ERP7__Amount_Paid__c - totalpaid;
            console.log("cond: "+ cond);
            if( adv < cond){
                console.log(Rec.ERP7__Amount_Paid__c+ ">"+ adv);
                Rec.ERP7__Paid_Amount_Applied__c =adv;
                Rec.ERP7__Total_Due__c= Rec.ERP7__Invoice_Amount__c - Rec.ERP7__Paid_Amount_Applied__c;
                console.log("total due" + Rec.ERP7__Total_Due__c);
                comp.set("v.Rec",Rec);
                console.log("after total due" + JSON.stringify(comp.get("v.Rec")));
                var renderedFields = comp.find("inv");
                for(var  x in renderedFields)
                    if( renderedFields[x].get('v.fieldName')==='ERP7__Total_Due__c')
                        renderedFields[x].set("v.value",Rec.ERP7__Total_Due__c);
            }
        }
        
        if(Rec.ERP7__Amount_Paid__c ==0.00 || Rec.ERP7__Amount_Paid__c==null || adv > cond )
        {  console.log(Rec.ERP7__Amount_Paid__c+ "<"+ adv);
         sforce.one.showToast({
             "title": "ALERT!",
             "message": "Advance Amount Applied cannot be greater than Amount Paid."
         }); 
         var renderedFields = comp.find("inv");
         for(var  x in renderedFields){
             if( renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c')
                 renderedFields[x].set("v.value",0.00);
             if( renderedFields[x].get('v.label')==='Advance Amount Applied')
                 renderedFields[x].set("v.value",0.00);
             if( renderedFields[x].get('v.label')==='Paid Amount Applied')
                 renderedFields[x].set("v.value",0.00);
         }
         
         
        }
        if(adv > Rec.ERP7__Amount_Paid__c ){
            sforce.one.showToast({
                "title": "ALERT!",
                "message": "Advance Amount Applied cannot be greater than Amount Paid."
            });
            var renderedFields = comp.find("inv");
            for(var  x in renderedFields){
                if( renderedFields[x].get('v.fieldName')==='ERP7__Paid_Amount_Applied__c')
                    renderedFields[x].set("v.value",0.00);
                if( renderedFields[x].get('v.label')==='Advance Amount Applied')
                    renderedFields[x].set("v.value",0.00);
            }
            
            
        }
        
    },
    dwpayperchange:function(comp,event,helper){
        //Percentage = (Amount / Total) * 100
        var total;
        var totalpay;
        var Rec=comp.get("v.Rec");
        
        var dpay= event.getSource().get("v.value");
        
        if(Rec.ERP7__Paid_Amount_Applied__c!=null && Rec.ERP7__Paid_Amount_Applied__c!= 0)
            total=Rec.ERP7__Invoice_Amount__c - Rec.ERP7__Paid_Amount_Applied__c;
        else
            total=Rec.ERP7__Invoice_Amount__c;
        
        totalpay= dpay/total *100;
        var renderedFields = comp.find("inv");
        for(var x in renderedFields)
        {
            if( renderedFields[x].get('v.fieldName')==='ERP7__Down_Payment__c')
                renderedFields[x].set("v.value",totalpay);
        }
        Rec.ERP7__Down_Payment__c=totalpay;
        Rec.ERP7__Total_Down_Payment_Amount__c =dpay;
        comp.set("v.Rec", Rec);
    },
    dwpaychange :function(comp,event,helper){
        
        var total;
        var Rec=comp.get("v.Rec");
        console.log('Invoice_Amount:',Rec.ERP7__Invoice_Amount__c);
        let percentage = event.getSource().get("v.value");
        
        Rec.ERP7__Down_Payment__c=percentage;
        if(Rec.ERP7__Paid_Amount_Applied__c!=null && Rec.ERP7__Paid_Amount_Applied__c!= 0)
            total=Rec.ERP7__Invoice_Amount__c - Rec.ERP7__Paid_Amount_Applied__c;
        else
            total=Rec.ERP7__Invoice_Amount__c;
        
        if(percentage != null){
            if(percentage>=1)
            {
                Rec.ERP7__Total_Down_Payment_Amount__c = total*(percentage/100); 
            } 
            else{
                Rec.ERP7__Total_Down_Payment_Amount__c =  total*percentage;
            }            
        }
        var renderedFields = comp.find("inv");
        for(var x in renderedFields)
        {
            if( renderedFields[x].get('v.fieldName')==='ERP7__Total_Down_Payment_Amount__c')
                renderedFields[x].set("v.value",Rec.ERP7__Down_Payment__c);
        }
        comp.set("v.Rec", Rec);
        console.log('ERP7__Total_Down_Payment_Amount__c:',Rec.ERP7__Total_Down_Payment_Amount__c);
        console.log("v.Rec", Rec);
    },
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    handleSaveNew:function(component,event,helper){
        var errorInvList=helper.beforeSaveNew(component,event,helper);
        var Rec = component.get("v.Rec");
        if(Rec.ERP7__Account__c == ''|| Rec.ERP7__Account__c == null || Rec.ERP7__Account__c == undefined ){
            component.set('v.exceptionError','Customer account cannot be empty');
        }
        else if(Rec.ERP7__Organisation__c == ''|| Rec.ERP7__Organisation__c == null || Rec.ERP7__Organisation__c == undefined ){
            component.set('v.exceptionError','Organisation cannot be empty');
        }
            else if(Rec.ERP7__Invoice_Date__c == ''|| Rec.ERP7__Invoice_Date__c == null || Rec.ERP7__Invoice_Date__c == undefined ){
                component.set('v.exceptionError','Invoice date cannot be empty');
            } 
                else if(Rec.ERP7__Invoice_Due_Date__c == ''|| Rec.ERP7__Invoice_Due_Date__c == null || Rec.ERP7__Invoice_Due_Date__c == undefined ){
                    component.set('v.exceptionError','Invoice due date cannot be empty');
                }
                    else {
                        if(errorInvList == false){
                        console.log('2');
                        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                        var action = component.get("c.updateRecords");
                        action.setParams({
                            "recs": component.get("v.INVLIList"),
                            "rec": component.get("v.Rec"),
                            "DeleteItems":component.get("v.ItemstoDelete")
                            
                        });
                        action.setCallback(this,function(response){
                            var state = response.getState();
                            if(state==='SUCCESS'){
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                console.log('response getInvoiceLineItems : ',response.getReturnValue());
                                //component.set("v.INVLIList",response.getReturnValue());
                                sforce.one.showToast({
                                    "title": "Success!",
                                    "message": "Invoice updated successfully.",
                                    "type": "success"
                                });
                                var RecUrl = "/" + component.get("v.recordId");
                                sforce.one.navigateToURL(RecUrl);
                                $A.get('e.force:refreshView').fire();
                            }else{
                                console.log('Error:',response.getError());
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            } 
                            
                        });
                        $A.enqueueAction(action);
                        }else{
                             console.log('Error in Invoice Line items');
                        }
                    }
        
    },
    handleSave:function(comp,event,helper){
        helper.beforesave(comp);
        var recordId = comp.get("v.recordId");
        var rec = comp.get("v.Rec");
        console.log("saved!" +recordId);
        var action = comp.get("c.updateRecords");
        action.setParams({
            "recs": comp.get("v.INVLIList"),
            "rec": comp.get("v.Rec"),
            "DeleteItems":comp.get("v.ItemstoDelete")
        });
        $A.enqueueAction(action);
        
        if(rec.ERP7__Paid_Amount_Applied__c > rec.ERP7__Amount_Paid__c){
            rec.ERP7__Paid_Amount_Applied__c =0;
        }
        console.log("verify validation"+ rec.ERP7__Paid_Amount_Applied__c);
        var renderedFields = comp.find("inv");
        for(var x in renderedFields)
        {
            if( renderedFields[x].get('v.label')==='Advance Amount Applied')
                renderedFields[x].set("v.value",0.00);
        }
        var RecUrl = "/" + comp.get("v.recordId");
        sforce.one.navigateToURL(RecUrl);
        $A.get('e.force:refreshView').fire();
        
    },
    handledelete: function(c,event,helper){
        
        var editable = c.get("v.allowEdit");
        //if(!editable){
        let dellist = [];
        dellist = c.get('v.INVLIList');
        var index=event.getSource().get("v.title");
        var deletionId =  dellist[index].Id; 
        let deleteIds = [];
        deleteIds = c.get('v.ItemstoDelete');
        deleteIds.push(deletionId);
        c.set("v.ItemstoDelete", deleteIds);        
        console.log('checking===>'+ index); 
        console.log('deletionId===>'+ deletionId);   
        console.log('deletionId Length ===>'+ c.get("v.ItemstoDelete"));  
        dellist.splice(index, 1);
        c.set('v.INVLIList',dellist);
        helper.beforedelete(c);        
        //}
        /*
        
        else{
            sforce.one.showToast({
                "title": "ALERT!",
                "message": "The record cannot be deleted."
            });
            console.log("Delete abled!");
        }*/
    },
    invperchange: function(c,event,h){
        
        var Rec=c.get("v.Rec");
        let percentage = event.getSource().get("v.value");
        var amt=Rec.ERP7__Sub_Total_Amount__c;
        var tamt;
        tamt= Number(amt)*Number(percentage)/100;
        
        
        var renderedFields = c.find("inv");
        for(var x in renderedFields)
        {
            if( renderedFields[x].get('v.label')==='Invoice Amount')
                renderedFields[x].set("v.value",tamt);
            if( renderedFields[x].get('v.fieldName')==='ERP7__Sub_Total_Amount__c')
                renderedFields[x].set("v.value",tamt);
        }
        console.log("hello");
        c.set("v.InvAmt",tamt);     
        Rec.ERP7__Sub_Total_Amount__c = tamt;     
        console.log("ERP7__Sub_Total_Amount__c" + Rec.ERP7__Sub_Total_Amount__c);      
        c.set("v.Rec",Rec);       
    },
    invchange: function(component,event,helper){
      let invlist = component.get('v.INVLIList');
        var Rec=component.get("v.Rec");
        let percentage = event.getSource().get("v.value");
        var subtotal =0;
        var tax=0;
        var discount=0;
        for( var x in invlist){
            subtotal = Number(subtotal) + Number(invlist[x].ERP7__Unit_Price__c);
            tax = Number(tax) + Number(invlist[x].ERP7__Total_Tax__c);
            discount = Number(discount) + Number(invlist[x].ERP7__Discount_Amount__c);
        }
        var invAmt=Rec.ERP7__Sales_Order_Amount__c;
        Rec.ERP7__Invoice_Amount__c=Number(invAmt)*Number(percentage)/100;
        Rec.ERP7__Sub_Total_Amount__c=Number(subtotal)*Number(percentage)/100;
        Rec.ERP7__Tax_Amount__c=Number(tax)*Number(percentage)/100;
        Rec.ERP7__Discount_Amount__c=Number(discount)*Number(percentage)/100;
        Rec.ERP7__Total_Due__c=Number(Rec.ERP7__Sub_Total_Amount__c)+Number(Rec.ERP7__Tax_Amount__c);
        component.set("v.Rec",Rec); 
    }
})