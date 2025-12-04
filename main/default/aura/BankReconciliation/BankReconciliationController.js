({
    doInit : function(component, event, helper) {
        helper.getDetails(component, event, helper);
        helper.getDocument(component, event, helper); 
        
        
    },
    
    closeAuto : function(component, event, helper) {
        component.set("v.AutoReconcile", false);
    },
    
    close : function(component, event, helper) {
        component.set("v.SaveErrorMsg", '');
    },
    fetchReconciliationRecords : function(component, event, helper) {
        var action=component.get("c.fetchAutoReconcileRecords");
        action.setParams({
            bReconcileId:component.get("v.BankRecon_obj.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue()!=null && response.getReturnValue().length>0){
                    component.set("v.banktranslist",response.getReturnValue());
                    component.set("v.AutoReconcile", true);
                }else{
                    helper.showToast('Error!','error','No matching transactions found');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    delete_Item : function(component, event, helper) {
        var billList = component.get("v.banktranslist");
        billList.splice(event.getSource().get("v.name"),1);
        component.set("v.banktranslist",billList);
    },
    
    navHome : function(component, event, helper){
        if(component.get("v.FromSP")){ 
             $A.createComponent(
                "c:ManageBankReconciliation", {
                    OrganisationId:component.get("v.OrganisationId"),
                    fetchRecordsBool:false
                },
                function(newComp) {
                    var content = component.find("body");
                    content.set("v.body", newComp);
                }
            );
       }else{
            history.back();
        }
    },
    
    searchUserRecord : function(cmp,event,helper){
        try{      
            cmp.set("v.NoSlotsMessage",'');
            var SearchString = cmp.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=cmp.get("v.bankStmtlistDum");
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.ERP7__Transaction_Summary__c).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                cmp.set("v.bankStmtlist",bankStmtlist);  if(bankStmtlist.length<=0)  cmp.set("v.NoSlotsMessage",'No statement available');                     
            }else{  cmp.set("v.bankStmtlist",cmp.get("v.bankStmtlistDum"));
                 }
            
        }catch(ex){
            console.log('searchUser exception=>'+ex);
        }    
    },  
    
    
    searchUser : function(component,event,helper){
        try{  
            var searchString = event.getParam("searchString").toString();
            console.log('searchString: ',searchString);
            if(searchString!='' && searchString.length>0){                     
                var UserList =[];
                UserList=component.get("v.bankStmtlistDum");
                UserList = UserList.filter(function (el) {
                    return (el.ERP7__Transaction_Summary__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                });
                component.set("v.bankStmtlist",UserList);            
            }    
            else component.set("v.bankStmtlist",component.get("v.bankStmtlistDum"));
            console.log('bankStmtlist: ',component.get("v.bankStmtlist"));
        }catch(ex){console.log('searchUser exception=>'+ex);}      
    },
    
    getTab:function(cmp, event, helper){
        cmp.switchTab();
        helper.getTab(cmp, event, helper, event.target.dataset.record);
    },
    switchTab: function(cmp, event, helper){
        var action=cmp.get("c.processUnReconcile");
        action.setParams({
            BankRecon_obj1:JSON.stringify(cmp.get("v.BankRecon_obj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.undoReconcile_Wrapperlist",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    saveEditBankRecon_obj :function(cmp, event, helper) {
        var action = cmp.get("c.updateBankReconciliation");
        action.setParams({"BRRec":JSON.stringify(cmp.get("v.BankRecon_obj"))});
        action.setCallback(this,function(response){
            var state= response.getState();
            //alert(state);
            if(state ==='SUCCESS'){
                if(response.getReturnValue() != ''){
                    cmp.set("v.exceptionError",response.getReturnValue());
                } else{
                    cmp.doInit();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    reRender : function(cmp, event, helper) { },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
     getTab2:function(cmp, event, helper){
         if(event.target.dataset.record != undefined && event.target.dataset.record == 'pay2'){
             var evt = $A.get("e.force:navigateToComponent");
             evt.setParams({
                 componentDef : "c:AdjustmentEntries",
                 componentAttributes: {
                     BRId : cmp.get("v.Bank_Reconciliation_Id"),
                     FromBR : true,
                     orgFromBrec :cmp.get("v.OrganisationId"),
                 }
             });
             evt.fire();
         }else{
             helper.getTab2(cmp, event, helper, event.target.dataset.record);
         }
         
    },
    
    saveAutoReconcile : function(component, event, helper){
        component.set("v.showMmainSpin",true);
        var invli=component.get("v.banktranslist");
        var action=component.get("c.processAutoReconcile");
        action.setParams({
            bankTrans:JSON.stringify(invli)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue()==null){
                    helper.showToast('Error!','error',JSON.stringify(response.getReturnValue()));
                }else{
                    component.set("v.AutoReconcile", false);
                    helper.showToast('Success!','success','Auto Reconciled Successfully');
                    component.set("v.showMmainSpin",false);
                    helper.getDetails(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //Selection of Bank Statement 
    selectedStatement: function(component, event, helper){
        component.set("v.selectedTransaction","");
        component.set("v.searchString2","");
        component.set("v.searchAmount","");
        component.set("v.TransactionWrapperList","");
        component.set("v.Total",0);
        component.set("v.TransactionWrapperList2","");
        //component.set("v.selectedTransaction2","");
        var invli=component.get("v.bankStmtlist");
        for(var ind in invli ){
            if(invli[ind].Id==event.currentTarget.getAttribute('data-record')){
                //cmp.set("v.Amount",invli[ind]);
                component.set("v.BankStatement",invli[ind]);
            }
        }
        var selectedStatement;
        if(component.get("v.BankStatement.ERP7__Withdrawals__c")>0)  selectedStatement=component.get("v.BankStatement.ERP7__Withdrawals__c");
        else selectedStatement=component.get("v.BankStatement.ERP7__Deposits__c");
        var action=component.get("c.MatchingTrasaction");
        action.setParams({
            searchAmount:selectedStatement,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                 component.set("v.TransactionWrapperList2",response.getReturnValue());
                 component.set("v.Total2",0);
                 component.set("v.selectedTransaction2","");
                 component.set("v.display2",false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    selectedTransaction2: function(cmp, event, helper){
        console.log('in here 1');
        //cmp.set("v.selectedTransaction2",null);
        var invli=cmp.get("v.TransactionWrapperList2");
        console.log('in here 2');
        //var transaction=cmp.get("v.selectedTransaction2");
        var transaction=[];
        console.log('in here 3');
        if(event.getSource().get("v.checked")){
            
            for(var ind in invli ) {
                if(ind==event.getSource().get("v.name")){
                    transaction.push(invli[ind]); 
                    cmp.set("v.selectedTransaction2",transaction);
                }
            }
        }
        else{
            var INVLIList=cmp.get("v.TransactionWrapperList2");
            var index=event.getSource().get("v.name");
            for(var j in INVLIList){
                if(j==index){
                    transaction.pop(INVLIList[j]);
                    cmp.set("v.selectedTransaction2",transaction);
                }
            }
        }
        console.log('in here 4');
        var selectTransaction=cmp.get("v.selectedTransaction2");
        console.log('in here 5');
        console.log('selectTransaction',selectTransaction);
        if (!selectTransaction) {
            // Show warning toast
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                title: "Warning",
                message: "Please select a transaction before proceeding.",
                type: "warning"
            });
            toast.fire();
            
            return; // ⛔ exit the method here
        }
        var sum=0;
        for(var j in selectTransaction){
            sum = sum + parseFloat(selectTransaction[j].ERP7__Amount__c);
            //sum+=selectTransaction[j].ERP7__Amount__c;
            /*if(selectTransaction[j].ERP7__Amount__c!=undefined && selectTransaction[j].ERP7__Amount__c!=null && !selectTransaction[j].ERP7__is_Adjustment__c) sum+=selectTransaction[j].ERP7__Amount__c;
            else if(selectTransaction[j].ERP7__is_Adjustment__c && selectTransaction[j].ERP7__Finance_Category_Type__c == 'Debit') sum+=selectTransaction[j].ERP7__Amount__c;
            else if(selectTransaction[j].ERP7__is_Adjustment__c && selectTransaction[j].ERP7__Finance_Category_Type__c == 'Credit') sum-=selectTransaction[j].ERP7__Amount__c;*/
        }
        cmp.set("v.Total2",sum);
        var selectedStatement;
        if(cmp.get("v.BankStatement.ERP7__Withdrawals__c")>0)  selectedStatement=cmp.get("v.BankStatement.ERP7__Withdrawals__c");
        else selectedStatement=cmp.get("v.BankStatement.ERP7__Deposits__c");
        if(sum.toFixed(2)==selectedStatement.toFixed(2)){
            cmp.set("v.display2",true);
        }else{
            cmp.set("v.display2",false);
        }
    },
    
    getSortedRecords : function(component,event,helper){
        component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');
        var action=component.get("c.Find_and_Match");
        action.setParams({
            searchString:component.get("v.searchString2"),
            searchAmount:component.get("v.searchAmount"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate"),
            orgId : component.get("v.BankRecon_obj.ERP7__Organisation__c"),
            OrderBy : component.get("v.OrderBy"),
            Order : component.get("v.Order")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                component.set("v.showMmainSpin",false);
                component.set("v.TransactionWrapperList",response.getReturnValue());
                component.set("v.Total",0);
                 //component.set("v.selectedTransaction","");
                 component.set("v.display",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    Find_And_Match: function (component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action=component.get("c.Find_and_Match");
        action.setParams({
            searchString:component.get("v.searchString2"),
            searchAmount:component.get("v.searchAmount"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate"),
            orgId : component.get("v.BankRecon_obj.ERP7__Organisation__c"),
            OrderBy : component.get("v.OrderBy"),
            Order : component.get("v.Order")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                component.set("v.showMmainSpin",false);
                component.set("v.TransactionWrapperList",response.getReturnValue());
                component.set("v.Total",0);
                 //component.set("v.selectedTransaction","");
                 component.set("v.display",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateEndDate : function(component, event, helper){
        if(component.get("v.endDate") == null){
            component.set("v.endDate", component.get("v.startDate"));
        }
    },
    
    selectedTransaction: function(cmp, event, helper){
        console.log('In here 1');
        var invli=cmp.get("v.TransactionWrapperList");
        var transaction=[];
        //Moin added this
        if(cmp.get("v.selectedTransaction")!=null && cmp.get("v.selectedTransaction")!= ''){
            transaction = cmp.get("v.selectedTransaction");
        }
        if(event.getSource().get("v.checked")){
             console.log('In here 2 if');
            console.log('selectedTransaction: ',cmp.get("v.selectedTransaction"));
            for(var ind in invli ) {
                if(ind==event.getSource().get("v.name")){
                    transaction.push(invli[ind]); 
                    cmp.set("v.selectedTransaction",transaction);
                }
            }
        }
        else{
             console.log('In here 2 else');
            var INVLIList=cmp.get("v.TransactionWrapperList");
            var index=event.getSource().get("v.name");
            for(var j in INVLIList){
                if(j==index){
                    transaction.pop(INVLIList[j]);
                    cmp.set("v.selectedTransaction",transaction);
                }
            }
        }
         console.log('In here 3');
        var selectTransaction=cmp.get("v.selectedTransaction");
        var sum=0;
        var Debitsum=0;
        var Creditsum=0;
         console.log('In here 4');
        for(var j in selectTransaction){
            if(selectTransaction[j].ERP7__Finance_Category_Type__c == 'Debit'){
                Debitsum = parseFloat(Debitsum) + parseFloat(selectTransaction[j].ERP7__Amount__c);
            }
            if(selectTransaction[j].ERP7__Finance_Category_Type__c == 'Credit'){
                Creditsum = parseFloat(Creditsum) + parseFloat(selectTransaction[j].ERP7__Amount__c);
            }
        }
         console.log('In here 5');
        if(Debitsum>0 && Creditsum == 0){
            sum = Debitsum;
        }
        if(Creditsum>0 && Debitsum == 0){
            sum = Creditsum;
        }
        if(Debitsum>0 && Creditsum>0 && Debitsum>Creditsum){
            sum = parseFloat(Debitsum) - parseFloat(Creditsum);
        }
        if(Debitsum>0 && Creditsum>0 && Creditsum>Debitsum){
            sum = parseFloat(Creditsum) - parseFloat(Debitsum);
        }
        /*var onlyAdjustment = true;
        if (onlyAdjustment && selectTransaction.every(item => item.ERP7__is_Adjustment__c)) {
            onlyAdjustment = true;
        } else {
            onlyAdjustment = false;
        }
        for(var j in selectTransaction){
            if(selectTransaction[j].ERP7__Amount__c!=undefined && selectTransaction[j].ERP7__Amount__c!=null && !selectTransaction[j].ERP7__is_Adjustment__c) sum+=selectTransaction[j].ERP7__Amount__c;
            else if(selectTransaction[j].ERP7__is_Adjustment__c && selectTransaction[j].ERP7__Finance_Category_Type__c == 'Debit') sum+=selectTransaction[j].ERP7__Amount__c;
            else if(selectTransaction[j].ERP7__is_Adjustment__c && selectTransaction[j].ERP7__Finance_Category_Type__c == 'Credit' && !onlyAdjustment) sum-=selectTransaction[j].ERP7__Amount__c;
            else if(selectTransaction[j].ERP7__is_Adjustment__c && selectTransaction[j].ERP7__Finance_Category_Type__c == 'Credit' && onlyAdjustment) sum+=selectTransaction[j].ERP7__Amount__c;
        }*/
         console.log('In here 6');
         console.log('BankStatement: ',cmp.get("v.BankStatement"));
        cmp.set("v.Total",sum.toFixed(2));
        var selectedStatement;
        if(cmp.get("v.BankStatement")!=null && cmp.get("v.BankStatement")!= ''){
            if(cmp.get("v.BankStatement.ERP7__Withdrawals__c")>0)  selectedStatement=cmp.get("v.BankStatement.ERP7__Withdrawals__c");
            else selectedStatement=cmp.get("v.BankStatement.ERP7__Deposits__c");
            if(sum.toFixed(2)==selectedStatement.toFixed(2)){
                cmp.set("v.display",true);
            }else{
                cmp.set("v.display",false);
            }
        }else{
            console.log('In here 7 else');
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                title: "Warning",
                message: "Please select a Bank Statement to Reconcile.",
                type: "warning"
            });
            toast.fire();
            return; 
        }
        
         console.log('In here 8');
    },
    
    
    
    
    
    processReconcile: function(cmp, event, helper){
        var action=cmp.get("c.ProcessReconcile");
        action.setParams({
            statement1:JSON.stringify(cmp.get("v.BankStatement")),
            translist1:JSON.stringify(cmp.get("v.selectedTransaction")),
            BankRecon_obj1:JSON.stringify(cmp.get("v.BankRecon_obj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.BankStatement","");
                cmp.set("v.selectedTransaction","");
                cmp.set("v.searchString2","");
                cmp.set("v.searchAmount","");
                cmp.set("v.TransactionWrapperList","");
                cmp.set("v.Total",0);
                cmp.set("v.display",false);
                cmp.doInit();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    processReconcile2: function(cmp, event, helper){
        var action=cmp.get("c.ProcessReconcile");
        action.setParams({
            statement1:JSON.stringify(cmp.get("v.BankStatement")),
            translist1:JSON.stringify(cmp.get("v.selectedTransaction2")),
            BankRecon_obj1:JSON.stringify(cmp.get("v.BankRecon_obj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.BankStatement","");
                cmp.set("v.selectedTransaction2","");
                cmp.set("v.searchString2","");
                cmp.set("v.searchAmount","");
                cmp.set("v.TransactionWrapperList2","");
                cmp.set("v.Total2",0);
                cmp.set("v.display2", false);
                cmp.doInit();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    undoReconcile: function(cmp, event, helper){
        var Index=event.getSource().get("v.name");
        var action=cmp.get("c.RemoveUndoList");
        action.setParams({
            ArrayIndex:Index,
            BankRecon_obj1:JSON.stringify(cmp.get("v.BankRecon_obj")),
            undoReconcile_Wrapperlist_A:JSON.stringify(cmp.get("v.undoReconcile_Wrapperlist")),
           
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.undoReconcile_Wrapperlist",null);
                cmp.doInit();
            }
        });
        $A.enqueueAction(action);
    },
    
     
 /*CreateRecord: function (component, event, helper) {
    component.set("v.showMmainSpin", true);
    var fileInput = component.find("file").get("v.files");
    var file = fileInput ? fileInput[0] : null;

    if (file) {
        var fileSize = file.size; // File size in bytes
        console.log('fileSize : ', fileSize);

        // Check individual file size (max 2 MB)
        if (fileSize > 2000000) {
            helper.showToast('Error', 'error', 'File exceeds the 2 MB limit.');
            component.set("v.showMmainSpin", false);
            return;
        }

        var totalRequestSize = fileSize; // Initialize total size with the current file size
        console.log('totalRequestSize : ', totalRequestSize);

        // Check total request size (assuming single file for now, extend logic if handling multiple files later)
        if (totalRequestSize > 6000000) {
            helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload a smaller file.');
            component.set("v.showMmainSpin", false);
            return;
        }

        var reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = function (evt) {
            var csv = evt.target.result;
            helper.CSV2JSON(component, csv);
        }
        reader.onerror = function (evt) {
            component.set("v.showMmainSpin", false);
        }
    } else {
        component.set("v.showMmainSpin", false);
        helper.showToast('Error', 'error', 'No file selected. Please choose a file to upload.');
    }
},*///Commented above above to include below for adding getCallback
    CreateRecord: function (component, event, helper) {
        component.set("v.showMmainSpin", true);
        console.log("in CreateRecord");
        
        var fileInput = component.find("file").get("v.files");
        var file = fileInput && fileInput[0];
        
        if (file) {
            console.log("in if of CreateRecord");
            var reader = new FileReader();
            
            reader.onload = $A.getCallback(function (evt) {
                console.log("in onload CreateRecord");
                var csv = evt.target.result;
                helper.CSV2JSON(component, csv);
            });
            
            reader.onerror = $A.getCallback(function (evt) {
                console.log("in onerror CreateRecord");
                component.set("v.showMmainSpin", false);
            });
            
            reader.readAsText(file, "UTF-8");
        } else {
            component.set("v.showMmainSpin", false);
        }
    },

   /*  CreateRecord: function (component, event, helper) {
        component.set("v.showMmainSpin",true);
         console.log("in CreateRecord");
        var fileInput = component.find("file").get("v.files");
        var file = fileInput[0];
        if (file) {
            console.log("in if of CreateRecord");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                console.log("in onload CreateRecord");
                //component.set("v.showMmainSpin",false);
                helper.CSV2JSON(component,csv);
                //component.set("v.showMmainSpin",false);
                
                //component.set("v.showMmainSpin",false);
                
            }
            reader.onerror = function (evt) {
                console.log("in onerro CreateRecord");
                component.set("v.showMmainSpin",false);
                //component.doInit();
            }
        }
        
    },*/
    
    CreateTransaction: function(cmp, event, helper){
        var action=cmp.get("c.CreateTransactionApex");
        action.setParams({
            statement1:JSON.stringify(cmp.get("v.BankStatement")),
            newTransaction1:JSON.stringify(cmp.get("v.newTransaction")),
            BankRecon_obj1:JSON.stringify(cmp.get("v.BankRecon_obj")),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.newTransaction.ERP7__Amount__c",'');
                cmp.set("v.TransactionWrapperList2",null);
                cmp.set("v.TransactionWrapperList",null);
                cmp.doInit();
            }
        });
        $A.enqueueAction(action);
    },
    
    ClearList: function(component, event, helper){
        //component.set("v.selectedTransaction","");
        component.set("v.selectedTransaction2",null);
        component.set("v.selectedTransaction", null);
        component.set("v.TransactionWrapperList2",null);
        component.set("v.searchString2","");
        component.set("v.searchAmount","");
        component.set("v.TransactionWrapperList",null);
        component.set("v.startDate", null);
        component.set("v.endDate", null);
        component.set("v.Total",0);
    },
    
   CreateOnlineRecord: function(component, event, helper){
       console.log('CreateOnlineRecord called');
       
       component.set("v.showMmainSpin",true);
       var yodleeTransaction = component.get("c.yodleeTransaction");
        yodleeTransaction.setParams({
            bankAccid:component.get("v.BankRecon_obj.ERP7__Bank_Account__r.Id"),
            bReconcileId:component.get("v.Bank_Reconciliation_Id"),
            startDate:component.get("v.BankRecon_obj.ERP7__Start_Date__c"),
            endDate:component.get("v.BankRecon_obj.ERP7__End_Date__c"),
            BankRecon_obj1:JSON.stringify(component.get("v.BankRecon_obj"))
        });
        yodleeTransaction.setCallback(this,function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") { 
                console.log('Respone Yodle-->',response.getReturnValue());
                component.doInit();
            }else{
                var errors = response.getError();
                console.log("server error in CreateOnlineRecord : ", JSON.stringify(errors));
            }
        });
        $A.enqueueAction(yodleeTransaction);
    },
})