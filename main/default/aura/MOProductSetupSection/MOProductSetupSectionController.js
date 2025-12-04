({
    doInit : function(component, event, helper) {
        try{
            component.set('v.showspinner',true);
            var sortedlist = [];
            helper.getFCVals(component);
            var processId = component.get('v.Process.Id');
            console.log('processId in setup initially Asra~>',processId);
            var prodId = component.get('v.Productdetails.Id');
            var verId = component.get('v.SelectedVersion.Id');
            var actiondetail = component.get('v.Action');
            if(actiondetail == 'clone'){
                console.log('inhere clone init');
                var action = component.get('c.getProcessdetails');
                action.setParams({
                    'selectedPR':processId,
                    'ProductId':prodId,
                    'versionId':verId,
                    'action' : actiondetail
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") { 
                        var result = response.getReturnValue();
                        console.log('result inhere clone init~>',response.getReturnValue());
                        
                        for(var x in result){
                            result[x].prcscycl.selected = false;
                            console.log('1');
                            var alldetails = result[x].allRelateddetails;
                            for(var y in alldetails.oprlst){
                                alldetails.oprlst[y].selected = false;
                            }
                            console.log('2');
                            for(var z in alldetails.bomlst){
                                alldetails.bomlst[z].selected = false;
                            }
                            console.log('3');
                            for(var b in alldetails.wiplinks){
                                alldetails.wiplinks[b].selected = false;
                            }
                            console.log('4');
                            for(var a in alldetails.availableResource){
                                alldetails.availableResource[a].selected = false;
                            }
                            console.log('5');
                            for(var c in alldetails.checklists){
                                alldetails.checklists[c].selected = false;
                            }
                            console.log('6');
                            for(var d in alldetails.med){
                                alldetails.med[c].selected = false;
                            }
                            console.log('7');
                        }
                        console.log('res after selected~>',JSON.stringify(result));
                        component.set('v.ProcessCycles',result);
                        console.log('res~>',response.getReturnValue());
                        console.log('ProcessCycles : ',JSON.stringify(result));
                        var TestResult = [];
                        TestResult = component.get('v.ProcessCycles');
                        for(var n in TestResult){
                            if(n == 0) {
                                TestResult[n].expanded = true;
                                sortedlist[n] = 1;
                            }
                            else{
                                TestResult[n].expanded = true;
                                sortedlist[n] = 0;
                            }
                        }
                        console.log('sortedlist?',sortedlist);
                        component.set('v.sortedlist',sortedlist);
                        component.set('v.ProcessCycles',TestResult);
                        console.log('result.expanded~>',JSON.stringify(component.get('v.ProcessCycles')));
                        var prcsId , prcsName;
                        /*  if(result != null){
                            if(result.length > 0){
                                //component.set('v.showsiteSelect',true); //result[0].showsite
                                prcsId = result[0].prcscycl.ERP7__Process__c;
                                prcsName = result[0].prcscycl.ERP7__Process__r.Name;
                                if(!$A.util.isEmpty(prcsName) && !$A.util.isEmpty(prcsId)){
                                    component.set('v.Process.Name',prcsName);
                                    component.set('v.Process.Id',prcsId); //change added arshad 05-06-23
                                }
                                
                                //below code added by Arshad 08 Aug 23
                                if(result[0].version != undefined && result[0].version != null){
                                    if(result[0].version.Id != undefined && result[0].version.Id != null){
                                        console.log('SelectedVersion~>'+JSON.stringify(result[0].version));
                                        component.set('v.SelectedVersion',result[0].version);
                                    }
                                }
                                //
                            }
                            else {
                                component.set('v.Process.Id','');
                                component.set('v.showsiteSelect',true);
                            }
                        }*/
                        component.set('v.showspinner',false);
                    }
                    else{
                        var err = response.getError();
                        console.log('error : '+JSON.stringify(err));
                        component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                        component.set('v.showspinner',false);
                        
                    }
                });
                $A.enqueueAction(action);
            }
            else if(actiondetail == 'Edit'){
                console.log('inside versionId:~>',verId);
                var action = component.get('c.getProcessdetails');
                action.setParams({
                    'ProductId' :prodId,
                    'selectedPR' :processId,
                    'versionId':verId,
                    'action' : actiondetail
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set('v.ProcessCycles',result);
                        console.log('Process Cycle Log:',JSON.stringify(result));
                        var TestResult = component.get('v.ProcessCycles');
                        console.log('in here in Edit');
                        for(var x=0;x<TestResult.length;x++){
                            if(x == 0) {
                                TestResult[x].expanded = true;
                                sortedlist[x] = 1;
                            }
                            else{
                                TestResult[x].expanded = false;
                                sortedlist[x] = 0;
                            }
                        }
                        console.log('sortedlist?',sortedlist);
                        component.set('v.sortedlist',sortedlist);
                        component.set('v.ProcessCycles',TestResult);
                        if(result.length > 0) {
                            component.set('v.showsiteSelect',result[0].showsite);
                            if(result[0].prcscycl.Id == null || result[0].prcscycl.Id == '') helper.helpershowToastss('Info!','info',$A.get('$Label.c.Create_Process_Cycle'));
                        }else component.set('v.showsiteSelect',true);
                        
                        component.set('v.showspinner',false);
                        
                    }
                    else{
                        var err = response.getError();
                        console.log('error : '+JSON.stringify(err));
                        component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                        component.set('v.showspinner',false);
                        
                    }
                });
                $A.enqueueAction(action);
                
            }
                else{
                    component.set('v.showsiteSelect',true); 
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy = today.getFullYear();
                    today = yyyy + '-' + mm + '-' + dd;
                    
                    //after5yrs = yyyy + '-' + mm + '-' + dd;
                    
                    var after5yrs = new Date();
                    var dd1 = String(after5yrs.getDate()).padStart(2, '0');
                    var mm1 = String(after5yrs.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy5 = after5yrs.getFullYear() +  5;
                    after5yrs = yyyy5 + '-' + mm1 + '-' + dd1;
                    var version = component.get('v.NewVersion');
                    version.Name = 'Version ' +component.get('v.Productdetails.Name');
                    version.ERP7__Start_Date__c = today;
                    version.ERP7__To_Date__c = after5yrs;
                    component.set('v.NewVersion',version);
                    component.set('v.showspinner',false);
                    var result = [];
                    component.set('v.ProcessCycles',result);
                    
                }
            
            var UOMpicklists= component.get('c.getBOMUOMPicklist');
            UOMpicklists.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('result BomUom'+JSON.stringify(result));
                    component.set('v.BomUom',result);
                }
            });
            $A.enqueueAction(UOMpicklists);
            var UOMWIPs= component.get('c.WIPUompickval');
            UOMWIPs.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.WIPUom',result);
                }
            });
            $A.enqueueAction(UOMWIPs);
            var checklstpicklists= component.get('c.getchecklstpicklists');
            checklstpicklists.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.cheklstval',result);
                }
            });
            $A.enqueueAction(checklstpicklists);
            var chekresult= component.get('c.getchekresult');
            chekresult.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.resultVal',result);
                }
            });
            $A.enqueueAction(chekresult);
            var controllingFieldAPI = component.get("v.controllingFieldAPI");
            var dependingFieldAPI = component.get("v.dependingFieldAPI");
            var objDetails = component.get("v.objDetail");
            // call the helper function
            helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
            helper.getFC(component);
            helper.getDependentPicklists(component, event, helper);
            
            /* let prodFamily = component.get("c.getFamily");
        prodFamily.setCallback(this,function(response){
            console.log('getFamily response : ',response.getReturnValue());
            let resList = response.getReturnValue();
            component.set("v.familylst",resList);                
            $A.util.addClass(component.find('mainSpin'), "slds-hide");            
        });
        $A.enqueueAction(prodFamily); 
        let prodSubFamily = component.get("c.getSubFamily");
        prodSubFamily.setCallback(this,function(response){
            console.log('subfamilylst response : ',response.getReturnValue());
            let resList = response.getReturnValue();
            component.set("v.subfamilylst",resList);                
            $A.util.addClass(component.find('mainSpin'), "slds-hide");            
        });
        $A.enqueueAction(prodSubFamily); */
        }
        catch(e){console.log('Error in Doinit:',e);}  
    },
    
    getSites : function(component, event, helper) {
        console.log('getSites called');
        var prod = component.get('v.Productdetails.Id');
        var verSel = component.get('v.NewVersion.ERP7__Default__c');
        console.log('versel ',component.get('v.NewVersion.ERP7__Default__c'));
        if(verSel && verSel==true){ //changes added by khaleeq on june 09 2025
            var action1 = component.get('c.checkDefaultVersion');
            action1.setParams({
                Id : prod
            });
            console.log('version  is selected '+component.get('v.NewVersion.ERP7__Default__c'));
            action1.setCallback(this, function(response){
                if (response.getState() == "SUCCESS") {
                    console.log('state-'+response.getState());
                    console.log('in');
                    //var errorResult = response.getReturnValue().proWrap;
                    //console.log('errorResult--'+errorResult);
                    //component.set('v.exceptionError', errorResult);
                    if(response.getReturnValue()!==null && response.getReturnValue()!==undefined && response.getReturnValue()==true){
                        //component.set('v.exceptionError', 'There is already an default version. PLease uncheck that to create a new default version');
                        console.log('inside true');
                        helper.helpershowToastss('Warning!','warning','Default version already exists. Please uncheck it before setting a new one.');  
                       

                        return;
                    }else{
                        console.log('insde elseee');
                        var rawsite = component.get('v.RawMaterialsite');
                        var finishsite = component.get('v.FinishedProductsite');
                        var err = false;
                        if(rawsite.Id == '' || rawsite.Id == null || rawsite.Id == undefined){
                            component.set('v.siteErr',$A.get('$Label.c.Please_Select_Raw_Material_site'));
                            err= true;
                        }
                        else if(finishsite.Id == '' || finishsite.Id == null || finishsite.Id == undefined){
                            component.set('v.siteErr',$A.get('$Label.c.Please_Select_Finished_Product_site')); 
                            err= true;
                        }
                        
                        if(!err){
                            component.set('v.showspinner',true);
                            var currver = component.get('v.SelectedVersion.Id');
                            if(currver == undefined || currver == null) currver = '';
                            var newver = component.get('v.NewVersion');
                            var action = component.get('c.createRouting');
                            action.setParams({
                                'ProdId' :component.get('v.Productdetails.Id'),
                                'FinshSiteId' : finishsite.Id,
                                'RawsiteId' :rawsite.Id,
                                'VersionId' : currver,
                                'NewVersion' : JSON.stringify(newver),
                                'ProcessId' : component.get('v.Process.Id'),
                            });
                            
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                    console.log('result createRouting : ',response.getReturnValue());
                                    if(!$A.util.isEmpty(result)){
                                        console.log('!$A.util.isEmpty(result.pr) : ',!$A.util.isEmpty(result.pr));
                                        if(!$A.util.isEmpty(result.pr)) component.set('v.Process',result.pr);
                                        if(!$A.util.isEmpty(result.vr)) component.set('v.SelectedVersion',result.vr);
                                    }
                                    component.set('v.routingexits',false); 
                                    component.set('v.showsiteSelect',false);
                                    
                                    component.set('v.showspinner',false);
                                    if(component.get('v.ProcessCycles').length == 0){
                                        helper.helpershowToastss('Info!','info',$A.get('$Label.c.Create_Process_Cycle'));  
                                    }
                                }
                                else{
                                    console.log('Error : '+JSON.stringify(response.getError()));
                                }
                            });
                            $A.enqueueAction(action);
                        }
                    }
                }
            });
            
            $A.enqueueAction(action1);
        }else{
            console.log('insde elseee');
            var rawsite = component.get('v.RawMaterialsite');
            var finishsite = component.get('v.FinishedProductsite');
            var err = false;
            if(rawsite.Id == '' || rawsite.Id == null || rawsite.Id == undefined){
                component.set('v.siteErr',$A.get('$Label.c.Please_Select_Raw_Material_site'));
                err= true;
            }
            else if(finishsite.Id == '' || finishsite.Id == null || finishsite.Id == undefined){
                component.set('v.siteErr',$A.get('$Label.c.Please_Select_Finished_Product_site')); 
                err= true;
            }
            
            if(!err){
                component.set('v.showspinner',true);
                var currver = component.get('v.SelectedVersion.Id');
                if(currver == undefined || currver == null) currver = '';
                var newver = component.get('v.NewVersion');
                var action = component.get('c.createRouting');
                action.setParams({
                    'ProdId' :component.get('v.Productdetails.Id'),
                    'FinshSiteId' : finishsite.Id,
                    'RawsiteId' :rawsite.Id,
                    'VersionId' : currver,
                    'NewVersion' : JSON.stringify(newver),
                    'ProcessId' : component.get('v.Process.Id'),
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('result createRouting : ',response.getReturnValue());
                        if(!$A.util.isEmpty(result)){
                            console.log('!$A.util.isEmpty(result.pr) : ',!$A.util.isEmpty(result.pr));
                            if(!$A.util.isEmpty(result.pr)) component.set('v.Process',result.pr);
                            if(!$A.util.isEmpty(result.vr)) component.set('v.SelectedVersion',result.vr);
                        }
                        component.set('v.routingexits',false); 
                        component.set('v.showsiteSelect',false);
                        
                        component.set('v.showspinner',false);
                        if(component.get('v.ProcessCycles').length == 0){
                            helper.helpershowToastss('Info!','info',$A.get('$Label.c.Create_Process_Cycle'));  
                        }
                    }
                    else{
                        console.log('Error : '+JSON.stringify(response.getError()));
                    }
                });
                $A.enqueueAction(action);
            }
        } 
    },
    
    
    OfsetChange : function(component,event,helper){
        
        var Offsetval = component.find("pageId").get("v.value");
        if(Offsetval != '' && Offsetval != null && Offsetval != undefined){
            var curOffset = component.get("v.Offsets");
            var show = parseInt(component.get("v.shows"));
            if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
                if(((curOffset+show)/show) != Offsetval){
                    var newOffset = (show*Offsetval)-show;
                    component.set("v.Offsets", newOffset);
                    //component.set("v.CheckOffset",true);
                    var pageNum = (newOffset + show)/show;
                    component.set("v.PageNum",pageNum);
                }
                component.popInit();
            } 
            else component.set("v.PageNum",((curOffset+show)/show));
        }
        
    },
    
    setShow : function(cmp,event,helper){
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offsets", 0);
        cmp.set("v.PageNum", 1);
        cmp.popInit();
    },
    
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offsets") + parseInt(component.get('v.shows')); 
            component.set("v.Offsets", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            component.popInit();
        }
    },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.shows"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offsets", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offsets")+show)/show));
            component.popInit();
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offsets") - parseInt(component.get('v.shows'));
            //alert(Offsetval);    
            component.set("v.Offsets", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            component.popInit();            }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.shows"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offsets", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offsets")+show)/show));
            component.popInit();
        }
    },
    getalldetails : function(component,event,helper){
        var prcyklId = event.currentTarget.dataset.recordId;
        var currentIndex = event.currentTarget.dataset.index;
        
        if(!$A.util.isEmpty(prcyklId)){
            component.set('v.showspinner',true);
            var isopen = false;
            var prolist = component.get('v.ProcessCycles');
            for(var x in prolist){
                if(prolist[x].prcscycl.Id == prcyklId || x==currentIndex){
                    if(prolist[x].isselected){
                        prolist[x].isselected = false;
                        isopen = true;
                    } 
                    
                }
            }
            component.set('v.ProcessCycles',prolist);
            if(!isopen){
                for(var x in prolist){
                    if(prolist[x].prcscycl.Id == prcyklId){
                        prolist[x].isselected = true;
                    } 
                    else{
                        prolist[x].isselected = false;
                    }
                }
            }
            // component.set('v.ProcessCycles',prolist); 
            var verId = component.get('v.SelectedVersion.Id');
            var getalldetails = component.get('c.getAll');
            getalldetails.setParams({ 
                'ProcesscycleId' : prcyklId,
                'finishsite' : component.get('v.FinishedProductsite.Id'),
                'versionId':verId
            });
            getalldetails.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    //component.set('v.RRGroupId',result.RRGroup);
                    component.set('v.showspinner',false);
                }
                else{
                    var err= response.getError();
                    console.log('error : '+err);
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false);  
                }
            });
            $A.enqueueAction(getalldetails);
        }
        
        
    },
    createNewWorkcenter : function(component,event,helper){
        component.set('v.showspinner',true);
        var site = component.get('v.RawMaterialsite.Id');
        
        var chnlId = component.get('v.ChannelId');
        var windowHash = window.location.hash;
        
        var defaults = {'ERP7__Active__c':true, 'ERP7__Is_Manufacturing__c':true,'ERP7__Shop_Floor_Warehouse__c':site,'ERP7__Plant__c':site,'ERP7__Channel__c':chnlId,'ERP7__Is_Service__c' : true};
        var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": 'ERP7__Work_Center__c',
                "defaultFieldValues":defaults,
                "panelOnDestroyCallback": function(event) {
                    window.location.hash = windowHash;
                }
            });
            createRecordEvent.fire();
            component.set('v.showspinner',false);
            
        }
    },
    
    backTOMOProducts : function(component,event,helper){
        console.log('backTOMOProducts called');
        component.set('v.showspinner',true);
        var ver = component.get('v.SelectedVersion');
        var pr = component.get('v.Process');
        var prod = component.get('v.Productdetails');
        var alldetail = {Product : prod,version : ver,process : pr};
        
        console.log('alldetail here~>',JSON.stringify(alldetail));
        
        /*if(component.get('v.Action') == 'clone') {
            helper.removecloned(component,event);
            component.set('v.showspinner',false);
        }
        else{*/
        var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MOProductConfiguration",
                componentAttributes: {
                   /* "CurrProdLst" : alldetail*/
                }
            });
            evt.fire();
        //window.location.reload();
        component.set('v.showspinner',false);
        
        // }
    },
    getselectedProcess : function(component,event,helper){
        component.set('v.showspinner',true);
        var procId = event.getSource().get('v.title');
        var checkval = event.getSource().get('v.checked');
        var allprocesscycl = component.get('v.ProcessCycles');
        var selectedPrkcl = component.get('v.selectedProcess');
        for( var i in allprocesscycl){
            if(allprocesscycl[i].prcscycl.Id == procId){
                allprocesscycl[i].processcycleSeleceted = checkval;
                if(checkval == true){
                    selectedPrkcl.push(allprocesscycl[i]);
                }
            }
        }
        component.set('v.selectedProcess',selectedPrkcl);
        component.set('v.ProcessCycles',allprocesscycl);
        component.set('v.showspinner',false);
    },
    
    NewProcesscylce : function(component,event,helper){
        var newpr = component.get('v.NewProcessCycles');
        newpr.Name='';
        newpr.ERP7__Process__c = component.get('v.Process.Id');
        newpr.ERP7__Work_Center__c = '';
        component.set('v.NewProcessCycles',newpr);
        component.set('v.ShowNewPr',true);
        
    },
    cancelNewPr : function(component,event,helper){
        component.set('v.ShowNewPr',false);
        
    },
    createNewPr : function(component,event,helper){
        
        var newpr = component.get('v.NewProcessCycles');
        var err =false;
        var allProcscycles = component.get('v.ProcessCycles');
        var count=0;
        for(var x in allProcscycles){
            if(allProcscycles[x].prcscycl){
                count++;
            }
        }
        newpr.ERP7__Sort__c = parseInt(count)+parseInt(1);
        console.log('new sort', newpr);
        var sortedlist = component.get('v.sortedlist');
        sortedlist.splice(count, 0, 1);
        component.set('v.sortedlist',sortedlist);
        console.log('sortedlist',sortedlist);
        if(newpr.Name == null || newpr.Name == '' || newpr.Name == undefined){
            component.set('v.ProcessErr',$A.get('$Label.c.Please_Enter_Name'));
            err= true;
        }
        else if(newpr.ERP7__Work_Center__c == null || newpr.ERP7__Work_Center__c == undefined || newpr.ERP7__Work_Center__c == ''){
            var msg = $A.get('$Label.c.PH_Please_assign_the_Product') + ' '+ $A.get('$Label.c.Work_Center_UserAvailabilities');
            component.set('v.ProcessErr',msg);
            err= true;
        } 
        if(!err){
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var savePr = component.get('c.SaveNewPrcycle');
            savePr.setParams({
                'NewPrc': JSON.stringify(newpr),
                'versionId':verId
            });
            savePr.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    var msg = $A.get('$Label.c.Process_Cycle') +' '+$A.get('$Label.c.Is_Created');
                    helper.helpershowToastss($A.get('$Label.c.Success1'),'success',msg);  
                    
                    component.set('v.ShowNewPr',false);
                    component.set('v.showspinner',false);
                }
                else{
                    var error = response.getError();
                    console.log('error :'+JSON.stringify(error));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false);
                    
                }
            });
            $A.enqueueAction(savePr);
        }
        
    },
    editProcesscycl : function(component,event,helper){
        var procscylId = event.currentTarget.dataset.recordId; 
        var allProcscycles = component.get('v.ProcessCycles');
        for(var x in allProcscycles){
            if(allProcscycles[x].prcscycl.Id == procscylId){
                component.set('v.EditProcessCycles',allProcscycles[x].prcscycl);
                component.set('v.oldSort',allProcscycles[x].prcscycl.ERP7__Sort__c);
            }
        }
        console.log('oldSort',component.get('v.oldSort'));
        $A.util.addClass(component.find("editProcssModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("myeditModalBackdrop"),"slds-backdrop_open");
        
    },
    updateProcsscycle :function(component,event,helper){
        var editresult = component.get('v.EditProcessCycles');
        var allProcscycles = component.get('v.ProcessCycles');
        var oldSort = component.get('v.oldSort');
        var count=0;
        for(var x in allProcscycles){
            if(allProcscycles[x].prcscycl){
                count++;
            }
        }
        console.log('count',count);
        console.log('oldSort',oldSort);
        
        console.log('bfr allProcscycles',allProcscycles);
        /*if(oldSort != editresult.ERP7__Sort__c){
            for(var x in allProcscycles){
            if(allProcscycles[x].prcscycl.ERP7__Sort__c == editresult.ERP7__Sort__c && allProcscycles[x].prcscycl.Name != editresult.Name){
                console.log('unchanged ERP7__Sort__c',allProcscycles[x].prcscycl.ERP7__Sort__c, ' name', allProcscycles[x].prcscycl.Name);
                allProcscycles[x].prcscycl.ERP7__Sort__c = oldSort;
                console.log('changed ERP7__Sort__c',allProcscycles[x].prcscycl.ERP7__Sort__c, ' name', allProcscycles[x].prcscycl.Name);
            }
        }
        }*/
        console.log('aftr allProcscycles',allProcscycles);
        component.set('v.ProcessCycles',allProcscycles);
        component.set('v.editErrorMsg','');
        var err =false;
        if(editresult.Name == null || editresult.Name == '' || editresult.Name == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.Please_Enter_Name'));
            err= true;
        }
        else if(editresult.ERP7__Work_Center__c == null || editresult.ERP7__Work_Center__c == undefined){
            var msg = $A.get('$Label.c.PH_Please_assign_the_Product') + ' '+ $A.get('$Label.c.Work_Center_UserAvailabilities');
            component.set('v.editErrorMsg',msg);
            err= true;
        } 
            else if(editresult.ERP7__Sort__c > count || editresult.ERP7__Sort__c < 1){
                var msg = $A.get('$Label.c.Please_Enter_the_valid_data') + ': ' +$A.get('$Label.c.Sort');
                component.set('v.editErrorMsg',msg);
                err= true;
            } 
        if(!err){
            component.set('v.editErrorMsg','');
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var savePr = component.get('c.updatePrcycle');
            savePr.setParams({
                'editPrc': JSON.stringify(editresult),
                'versionId':verId
            });
            savePr.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss($A.get('$Label.c.Success1'),'success','Process cycle updated');  
                    
                    $A.util.removeClass(component.find("editProcssModal"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("myeditModalBackdrop"),"slds-backdrop_open"); 
                    component.set('v.showspinner',false);
                }
            });
            $A.enqueueAction(savePr);
            
        }
    },
    closeModal : function(component,event,helper){
        $A.util.removeClass(component.find("editProcssModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("myeditModalBackdrop"),"slds-backdrop_open"); 
    },
    deleteProcesscycl : function(component,event,helper){
        var result = confirm("Are you sure?");
        var sort = event.target.getAttribute("data-index");
        var sortedlist = component.get('v.sortedlist');
        sortedlist.splice(sort, 1);
        component.set('v.sortedlist',sortedlist);
        console.log('sortedlist',sortedlist);
        var RecordId = event.currentTarget.dataset.recordId; 
        var obj = component.get('v.ProcessCycles');
        if(result){
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var deletePr = component.get('c.deletePrcycle');
            deletePr.setParams({
                'PrcssrecordId': RecordId,
                'versionId':verId
            });
            deletePr.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result.length == 0)   helper.helpershowToastss('Info!','info',$A.get('$Label.c.Create_Process_Cycle'));  
                    
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    component.set('v.showspinner',false);
                }
            });
            $A.enqueueAction(deletePr);
        }
    },
    Showallrelateds : function(component,event,helper){
        component.set('v.showspinner',true);
        var recordId = event.currentTarget.dataset.recordId; 
        if(!$A.util.isEmpty(recordId)){
            var isopen = false;
            var prolist = component.get('v.ProcessCycles');
            for(var x in prolist){
                if(prolist[x].prcscycl.Id == recordId){
                    if(prolist[x].isselected){
                        prolist[x].isselected = false;
                        isopen = true;
                    } 
                    
                }
            }
            component.set('v.ProcessCycles',prolist);
            if(!isopen){
                for(var x in prolist){
                    if(prolist[x].prcscycl.Id == recordId){
                        prolist[x].isselected = true;
                    } 
                }
            }
            component.set('v.ProcessCycles',prolist); 
            component.set('v.showspinner',false);
        }
    },
    openModal : function(component,event,helper){
        console.log('openModal called');
        component.set('v.editErrorMsg','');
        component.set('v.showspinner',true);
        var currentPr = event.currentTarget.dataset.recordId; 
        console.log('currentPr : ',currentPr);
        if(!$A.util.isEmpty(currentPr)){
            var obj = component.get('v.ProcessCycles');
            var currOp = component.get('v.NewOperation');
            currOp.ERP7__Process_Cycle__c = currentPr;
            currOp.Name = '';
            currOp.ERP7__Auto_Clock_In__c = false;
            currOp.ERP7__Is_Signature_Required__c = false;
            currOp.ERP7__Timer__c = false;
            component.set('v.NewOperation',currOp);
            $A.util.addClass(component.find("NewOPModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("NewOPModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false);
        }
        
        
    },
    closeOPModal : function(component,event,helper){
        $A.util.removeClass(component.find("NewOPModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewOPModalBackdrop"),"slds-backdrop_open"); 
    },
    createNewoperation : function(component,event,helper){
        var obj =component.get('v.NewOperation');
        var err =false;
        if(obj.Name == '' || obj.Name == null || obj.Name == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.Please_Enter_Name'));
            err = true;
        }
        if(!err){
            component.set('v.editErrorMsg',''); 
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var newaction = component.get('c.saveOperation');
            newaction.setParams({'Operation' : JSON.stringify(obj),'versionId':verId});
            newaction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    var msg = $A.get('$Label.c.Operation')+' ' +$A.get('$Label.c.Is_Created')
                    helper.helpershowToastss('Success!','success',msg);  
                    $A.util.removeClass(component.find("NewOPModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("NewOPModalBackdrop"),"slds-backdrop_open");
                    component.set('v.showspinner',false);
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false);  
                }
            });
            $A.enqueueAction(newaction);
            
        }
        
    },
    editoperation : function(component,event,helper){
        var newlst = [];
        component.set('v.EditOperation',newlst);
        var RecordId = event.currentTarget.dataset.recordId; 
        var PrRecord = event.currentTarget.dataset.index; 
        if(!$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var obj = component.get('v.ProcessCycles');
            for (var x in obj){
                if(obj[x].prcscycl.Id == PrRecord) {
                    for(var i in obj[x].allRelateddetails.oprlst){
                        if(obj[x].allRelateddetails.oprlst[i].Id == RecordId) component.set('v.EditOperation',obj[x].allRelateddetails.oprlst[i]);
                        
                    }
                    
                }
            }
            $A.util.addClass(component.find("EditOPModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("EditOPModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false); 
        }
    },
    deleteoperation : function(component,event,helper){
        var result = confirm("Are you sure?");
        
        var RecordId = event.currentTarget.dataset.recordId; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var verId = component.get('v.SelectedVersion.Id');
            var deleteOPAction = component.get('c.deleteOP');
            deleteOPAction.setParams({
                'opId':RecordId,
                'versionId':verId
            });
            deleteOPAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','Operation Deleted Successfully!!'); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deleteOPAction);
        }
    },
    closeOPeditModal : function(component,event,helper){
        $A.util.removeClass(component.find("EditOPModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditOPModalBackdrop"),"slds-backdrop_open"); 
    },
    
    updateoperation : function(component,event,helper){
        var updtaeOP = component.get('v.EditOperation');
        component.set('v.showspinner',true);
        var verId = component.get('v.SelectedVersion.Id');
        var action = component.get('c.updateOPeration');
        action.setParams({
            'OPtoUpdate' :JSON.stringify(updtaeOP),
            'versionId':verId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                helper.helpershowToastss('Success!','success','Operation Updated Successfully!!'); 
                component.set('v.showspinner',false); 
                $A.util.removeClass(component.find("EditOPModalshow"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("EditOPModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                var err = response.getError();
                console.log('error : '+ JSON.stringify(err));
                component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
        
    },
    openBOMModal :function(component,event,helper){
        try{
            component.set('v.disableAddProductsButton',false);
            console.log('inside openBOMModal');
            component.set('v.editErrorMsg','');
            component.set('v.exceptionError', '');
            component.set('v.showspinner',true);
            component.set('v.addProductsMsg','');
            component.set('v.searchItem','');
            component.set('v.seachItemFmily','');
            component.set('v.subItemFmily','');
            var currentPr = event.currentTarget.dataset.recordId; 
            if(!$A.util.isEmpty(currentPr)){
                 var obj = component.get('v.ProcessCycles');
                var currOp = component.get('v.NewBOM');
                currOp.ERP7__Process_Cycle__c = currentPr;
                currOp.Name ='';
                currOp.ERP7__BOM_Component__c = '';
                currOp.ERP7__Quantity__c = 0;
                currOp.ERP7__Unit_of_Measure__c = '';
                currOp.ERP7__Maximum_Variance__c = 0;
                currOp.ERP7__Minimum_Variance__c = 0;
                currOp.ERP7__For_Multiples__c = 0;
                currOp.ERP7__Cost_Price__c = 0;
                currOp.ERP7__Cost_Card__c = '';
                component.set('v.NewBOM',currOp);
                   // $A.util.addClass(component.find("NewBOMModalshow"), 'slds-fade-in-open');
              //  $A.util.addClass(component.find("NewBOMModalBackdrop"),"slds-backdrop_open"); 
              
                component.set('v.showAddProducts',true);
                component.set('v.BOMCreation',true);
                // component.set('v.Header','Bill Of Materials(BOMs)');
                component.set('v.Header',$A.get("$Label.c.Bill_of_Materials_BOM"));
                console.log("how is value printed ",component.get('v.Header'));
                component.set("v.ProcessCycleId",currentPr);
                component.set('v.selectedListOfProducts',[]);
                helper.getProducts(component);
                setTimeout(function() {
                    component.set('v.showspinner', false);
                }, 10000);
            }
        }catch(e){console.log(e);}   
    },
   /* deleteBillofM : function(component,event,helper){
        var result = confirm("Are you sure?");
        var verId = component.get('v.SelectedVersion.Id');
        var RecordId = event.currentTarget.dataset.recordId; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var deletebomAction = component.get('c.deleteBOM');
            deletebomAction.setParams({'BOMId':RecordId,
                                       'VersionId':verId,
                                      });
            deletebomAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','BOM Deleted Successfully!!'); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deletebomAction);
        }
        
    },
    */ // added a validation to not be able to delete the bom if there are existing MO's 
    deleteBillofM: function(component, event, helper) {
    var result = confirm("Are you sure?");
    var verId = component.get('v.SelectedVersion.Id');
    var RecordId = event.currentTarget.dataset.recordId; 
    if (result && !$A.util.isEmpty(RecordId)) {
        component.set('v.showspinner', true); 
        // First, check for existing Manufacturing Orders
        var checkMOAction = component.get('c.checkManufacturingOrders');
        checkMOAction.setParams({
            'VersionId': verId
        });
        checkMOAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var moExists = response.getReturnValue();
                if (moExists) {
                    component.set('v.showspinner', false);
                  //  helper.helpershowToastss('Error', 'error', 'Cannot delete BOM: Existing Manufacturing Orders in Draft or In Progress status found for this version.');
                   helper.helpershowToastss(
        ( $A.get("$Locale.language") === 'fr' ? 'Erreur' : 'Error'),
        'error',
        {
            en: "Cannot delete BOM: Existing Manufacturing Orders in Draft or In Progress status found for this version.",
            fr: "Impossible de supprimer la nomenclature : des ordres de fabrication en brouillon ou en cours existent pour cette version."
        }
    );

                } else {
                    // Proceed with deletion if no conflicting MOs
                    var deletebomAction = component.get('c.deleteBOM');
                    deletebomAction.setParams({
                        'BOMId': RecordId,
                        'VersionId': verId
                    });
                    deletebomAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set('v.ProcessCycles', result);
                            helper.fixSort(component);
                            helper.helpershowToastss('Success', 'success', 'BOM Deleted Successfully!!'); 
                            component.set('v.showspinner', false); 
                        } else {
                            component.set('v.showspinner', false);
                            helper.helpershowToastss('Error', 'error', 'Failed to delete BOM. Please try again.');
                        }
                    });
                    $A.enqueueAction(deletebomAction);
                }
            } else {
                component.set('v.showspinner', false);
                helper.helpershowToastss('Error', 'error', 'Error checking Manufacturing Orders. Please try again.');
            }
        });
        $A.enqueueAction(checkMOAction);
    }
},
    editBOM : function(component,event,helper){
        var newlst = [];
        component.set('v.EditBOM',newlst);
        var RecordId = event.currentTarget.dataset.recordId; 
        var PrRecord = event.currentTarget.dataset.index; 
        if(!$A.util.isEmpty(RecordId) && !$A.util.isEmpty(PrRecord)){
            component.set('v.showspinner',true); 
            var obj = component.get('v.ProcessCycles');
            for (var x in obj){
                if(obj[x].prcscycl.Id == PrRecord) {
                    for(var i in obj[x].allRelateddetails.bomlst){
                        if(obj[x].allRelateddetails.bomlst[i].Id == RecordId) component.set('v.EditBOM',obj[x].allRelateddetails.bomlst[i]);
                    }
                    
                }
            }
            $A.util.addClass(component.find("EditBOMModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("EditBOMModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false); 
        }
    },
    closeBOMeditModal : function(component,event,helper){
        $A.util.removeClass(component.find("EditBOMModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditBOMModalBackdrop"),"slds-backdrop_open"); 
    },
    updateBom : function(component,event,helper){
        
        var updtaeBOM = component.get('v.EditBOM');
        
        if(updtaeBOM.ERP7__Unit_of_Measure__c == null || updtaeBOM.ERP7__Unit_of_Measure__c == '' || updtaeBOM.ERP7__Unit_of_Measure__c == '--None--' || updtaeBOM.ERP7__Quantity__c == undefined){
            var msg = $A.get('$Label.c.Please_Enter_the_valid_data') +': '+$A.get('$Label.c.UOM');
            component.set('v.editErrorMsg',msg);
            return; 
        }
        component.set('v.showspinner',true);
        var verId = component.get('v.SelectedVersion.Id');
        var action = component.get('c.updateBOM');
        action.setParams({
            'BOMtoUpdate' :JSON.stringify(updtaeBOM),
            'versionId':verId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                helper.helpershowToastss('Success!','success','BOM Updated Successfully!!'); 
                component.set('v.showspinner',false); 
                $A.util.removeClass(component.find("EditBOMModalshow"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("EditBOMModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                var err = response.getError();
                console.log('error : '+ JSON.stringify(err));
                component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
        
    },
    CreateNewBom : function(component,event,helper){
        var obj =component.get('v.NewBOM');
        var err =false;
        if(obj.Name == '' || obj.Name == null || obj.Name == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.Please_Enter_Name'));
            err = true;
        }
        else if(obj.ERP7__BOM_Component__c == '' || obj.ERP7__BOM_Component__c == null || obj.ERP7__BOM_Component__c == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.PH_Please_Select_Product_to_proceed'));
            err = true;
        }
            else if(obj.ERP7__Quantity__c <= 0 || obj.ERP7__Quantity__c == '' || obj.ERP7__Quantity__c == null || obj.ERP7__Quantity__c == undefined){
                component.set('v.editErrorMsg',$A.get('$Label.c.Invalid_Quantity'));
                err = true;   
            }
                else if(obj.ERP7__Unit_of_Measure__c == null || obj.ERP7__Unit_of_Measure__c == '' || obj.ERP7__Unit_of_Measure__c == '--None--' || obj.ERP7__Quantity__c == undefined){
                    var msg = $A.get('$Label.c.Please_Enter_the_valid_data') +': '+$A.get('$Label.c.UOM');
                    component.set('v.editErrorMsg',msg);
                    err = true;   
                }
        
        if(!err){
            component.set('v.editErrorMsg',''); 
            component.set('v.showspinner',true);
            var newaction = component.get('c.saveBOM');
            newaction.setParams({'BOM' : JSON.stringify(obj)});
            newaction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    var msg=$A.get('$Label.c.BOM')+' '+$A.get('$Label.c.Is_Created');
                    helper.helpershowToastss($A.get('$Label.c.Success1'),'success',msg);  
                    $A.util.removeClass(component.find("NewBOMModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("NewBOMModalBackdrop"),"slds-backdrop_open");
                    component.set('v.showspinner',false);
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false);  
                }
            });
            $A.enqueueAction(newaction);
            
        }  
    },
    closeBOMModal : function(component,event,helper){
        $A.util.removeClass(component.find("NewBOMModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewBOMModalBackdrop"),"slds-backdrop_open"); 
    }, 
    /*  closeBOMeditModal : function(component,event,helper){
        $A.util.removeClass(component.find("EditOPModalBackdrop"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditBOMModalBackdrop"),"slds-backdrop_open"); 
    }, */
    openWIPModal : function(component,event,helper){
        component.set('v.editErrorMsg','');
        component.set('v.showspinner',true);
        component.set('v.exceptionError', '');
        component.set('v.addProductsMsg', '');
        component.set('v.searchItem','');
        component.set('v.seachItemFmily','');
        component.set('v.subItemFmily','');
        var currentPr = event.currentTarget.dataset.recordId; 
        if(!$A.util.isEmpty(currentPr)){
            /* var obj = component.get('v.ProcessCycles');
            var currOp = component.get('v.NewWIP');
            currOp.ERP7__Process_Cycle__c = currentPr;
            currOp.Name = '';
            currOp.ERP7__Process_Output_Product__c = '';
            currOp.ERP7__Quantity_Unit__c = 0;
            currOp.ERP7__Quantity_Unit_Of_Measure__c = '';
            component.set('v.NewWIP',currOp);
            
            $A.util.addClass(component.find("NewWIPModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false);*/
            component.set('v.showAddProducts',true);
            component.set('v.BOMCreation',false);
            component.set('v.Header',$A.get("$Label.c.Work_in_Progress_WIPs"));
            component.set("v.ProcessCycleId",currentPr);
            component.set('v.selectedListOfProducts',[]);
            helper.getProducts(component);
            setTimeout(function() {
                component.set('v.showspinner', false);
            }, 10000);
        }
        
    },
    closeNewWIPModal : function(component,event,helper){
        $A.util.removeClass(component.find("NewWIPModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open");
    },
    
    CreateNewWIP : function(component,event,helper){
        var obj =component.get('v.NewWIP');
        var err =false;
        if(obj.ERP7__Process_Output_Product__c == '' || obj.ERP7__Process_Output_Product__c == null || obj.ERP7__Process_Output_Product__c == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.PH_Please_Select_Product_to_proceed'));
            err = true;
        }
        else if(obj.ERP7__Quantity_Unit_Of_Measure__c == '' || obj.ERP7__Quantity_Unit_Of_Measure__c == null || obj.ERP7__Quantity_Unit_Of_Measure__c == undefined){
            component.set('v.editErrorMsg','Please select UOM for Product');
            err = true;
        }
            else if(obj.ERP7__Quantity_Unit__c <= 0 || obj.ERP7__Quantity_Unit__c == '' || obj.ERP7__Quantity_Unit__c == null || obj.ERP7__Quantity_Unit__c == undefined){
                component.set('v.editErrorMsg',$A.get('$Label.c.Enter_Quantity'));
                err = true;   
            }
        
        if(!err){
            component.set('v.editErrorMsg',''); 
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var newaction = component.get('c.saveWIP');
            newaction.setParams({'WIP' : JSON.stringify(obj) ,'versionId':verId});
            newaction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','WIP Created Successfully!!');  
                    $A.util.removeClass(component.find("NewWIPModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open");
                    component.set('v.showspinner',false);
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false);  
                }
            });
            $A.enqueueAction(newaction);
            
        }  
    },
 /*   deleteWIP : function(component,event,helper){
        var result = confirm("Are you sure?");
        
        var RecordId = event.currentTarget.dataset.recordId; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var verId = component.get('v.SelectedVersion.Id');
            var deleteWIPAction = component.get('c.deleteWIPlink');
            deleteWIPAction.setParams({
                'WIPId':RecordId,
                'versionId':verId
            });
            deleteWIPAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','WIP Deleted Successfully!!'); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deleteWIPAction);
        }
    },
   */
    deleteWIP: function(component, event, helper) {
    var result = confirm("Are you sure?");
    var RecordId = event.currentTarget.dataset.recordId; 
    if (result && !$A.util.isEmpty(RecordId)) {
        component.set('v.showspinner', true); 
        var verId = component.get('v.SelectedVersion.Id');
        // First, check for existing Manufacturing Orders
        var checkMOAction = component.get('c.checkManufacturingOrders');
        checkMOAction.setParams({
            'VersionId': verId
        });
        checkMOAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var moExists = response.getReturnValue();
                if (moExists) {
                    component.set('v.showspinner', false);
                    helper.helpershowToastss(
        ( $A.get("$Locale.language") === 'fr' ? 'Erreur' : 'Error'),
        'error',
        {
            en: "Cannot delete WIP: Existing Manufacturing Orders in Draft or In Progress status found for this version.",
            fr: "Impossible de supprimer le WIP : des ordres de fabrication existants à l’état Brouillon ou En cours sont associés à cette version."
        }
            );         

                   // helper.helpershowToastss('Error', 'error', 'Cannot delete WIP: Existing Manufacturing Orders in Draft or In Progress status found for this version.');
                } else {
                    // Proceed with deletion if no conflicting MOs
                    var deleteWIPAction = component.get('c.deleteWIPlink');
                    deleteWIPAction.setParams({
                        'WIPId': RecordId,
                        'versionId': verId
                    });
                    deleteWIPAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set('v.ProcessCycles', result);
                            helper.fixSort(component);
                            helper.helpershowToastss('Success', 'success', 'WIP Deleted Successfully!!'); 
                            component.set('v.showspinner', false); 
                        } else {
                            component.set('v.showspinner', false);
                            helper.helpershowToastss('Error', 'error', 'Failed to delete WIP. Please try again.');
                        }
                    });
                    $A.enqueueAction(deleteWIPAction);
                }
            } else {
                component.set('v.showspinner', false);
                helper.helpershowToastss('Error', 'error', 'Error checking Manufacturing Orders. Please try again.');
            }
        });
        $A.enqueueAction(checkMOAction);
    }
},
    editWIP : function(component,event,helper){
        var newlst =[];
        component.set('v.EditWIP',newlst);
        var RecordId = event.currentTarget.dataset.recordId; 
        var PrRecord = event.currentTarget.dataset.index; 
        if(!$A.util.isEmpty(RecordId) && !$A.util.isEmpty(PrRecord)){
            component.set('v.showspinner',true); 
            var obj = component.get('v.ProcessCycles');
            for (var x in obj){
                if(obj[x].prcscycl.Id == PrRecord) {
                    for(var i in obj[x].allRelateddetails.wiplinks){
                        if(obj[x].allRelateddetails.wiplinks[i].Id == RecordId) component.set('v.EditWIP',obj[x].allRelateddetails.wiplinks[i]);
                    }
                }
            }
            $A.util.addClass(component.find("EditWIPModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("EditWIPModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false); 
        }
    },
    closeEditWIPModal : function(component,event,helper){
        $A.util.removeClass(component.find("EditWIPModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditWIPModalBackdrop"),"slds-backdrop_open"); 
        
    },
    SaveEditWIP : function(component,event,helper){
        var updtaeWIP = component.get('v.EditWIP');
        component.set('v.showspinner',true);
        var verId = component.get('v.SelectedVersion.Id');
        var action = component.get('c.updateWIP');
        action.setParams({
            'WIPtoUpdate' :JSON.stringify(updtaeWIP),
            'versionId':verId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                helper.helpershowToastss($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.WIP_updated_successfully')); 
                component.set('v.showspinner',false); 
                $A.util.removeClass(component.find("EditWIPModalshow"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("EditWIPModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                var err = response.getError();
                console.log('error : '+ JSON.stringify(err));
                component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
    },
    openAttachmentModal : function(component,event,helper){
        var currPr =  event.currentTarget.dataset.recordId;
        var fileItem = [];
        component.set("v.filleList",fileItem);
        component.set("v.showDelete",false);
        var newmed  = component.get("v.Newmedia");
        newmed.Name ='';
        newmed.ERP7__Operation__c = '';
        component.set("v.Newmedia",newmed);
        
        var qry = '';
        qry += ' AND ERP7__Process_Cycle__c  =\'' + currPr + '\'';
        component.set('v.oppQry',qry);
        $A.util.addClass(component.find("NewattchModalshow"), 'slds-fade-in-open');
        $A.util.addClass(component.find("NewattchModalBackdrop"),"slds-backdrop_open"); 
        
    },
   handleFilesChange: function (component, event, helper) {
    component.set("v.showDelete", true);
    var fileName = "No File Selected..";
    var fileItem = [];
    var totalRequestSize = 0;

    // Get all files from the input
    var allfiles = component.find("fileId").get("v.files");
    if (allfiles && allfiles.length > 0) {
        for (var i = 0; i < allfiles.length; i++) {
            var fileSize = allfiles[i].size; // Use the 'size' property for file size
            console.log("fileSize : ", fileSize);

            // Check individual file size (max 2 MB)
            if (fileSize > 2000000) {
                helper.helpershowToastss("Error", "error", "File " + allfiles[i].name + " exceeds the 2 MB limit.");
                component.set("v.filleList",[]);
                component.set("v.fileName", []);
                component.set("v.showDelete",false);
                return;
            }

            // Accumulate total request size
            totalRequestSize += fileSize;
            console.log("totalRequestSize : ", totalRequestSize);

            // Check total request size (max 6 MB)
            if (totalRequestSize > 6000000) {
                helper.helpershowToastss(
                    "Error",
                    "error",
                    "Total request size exceeds the 6 MB limit. Please upload fewer or smaller files."
                );
                component.set("v.filleList",[]);
                component.set("v.fileName", []);
                component.set("v.showDelete",false);
                return;
            }

            // Add file name to fileItem array
            fileItem.push(allfiles[i].name);
        }

        // Set file name for the first file
        fileName = allfiles[0].name;
    }

    // Update component attributes
    //component.set("v.fillList", fileItem);
    component.set("v.filleList",fileItem);
    component.set("v.fileName", fileName);
},

    removeAttachment : function(component, event, helper) {
        component.set("v.showDelete",false);
        var fileName = 'No File Selected..';
        component.set("v.fileName", fileName);
        
        var fillList=component.get("v.filleList");
        fillList.splice(0, fillList.length); 
        component.set("v.filleList",fillList);
    },
    SaveNewMedia : function(component, event, helper) {
        component.set('v.editErrorMsg','');
        var media = component.get('v.Newmedia');
        var err =false;
        if(media.Name == '' || media.Name == null || media.Name == undefined){
            component.set('v.editErrorMsg',$A.get('$Label.c.ProductBundleManagement_Name_Error')); 
            err = true;
        }
        else if(media.ERP7__Operation__c == null || media.ERP7__Operation__c == undefined || media.ERP7__Operation__c == ''){
            component.set('v.editErrorMsg',$A.get('$Label.c.Please_Select_the_Operation')); 
            err = true;
        }
        var fillList11=component.get("v.filleList");
        
        if((component.find("fileId").get("v.files")==null || fillList11.length == 0)){
            helper.helpershowToastss('Error!','error',$A.get('$Label.c.ContractConsole_Add_Attachment'));
            err = true;
        }
        if(!err){
            component.set('v.showspinner',true); 
            var saveMedia =   component.get('c.CreateMedia');
            saveMedia.setParams({'media' : JSON.stringify(media)});
            saveMedia.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (component.find("fileId").get("v.files").length > 0 && fillList11.length > 0) {                                
                        //var fileInput = component.find("fileId").get("v.files");
                        var fileInput = component.get("v.FileList");
                        for(var i=0;i<fileInput.length;i++)
                            helper.saveAtt(component,event,fileInput[i],result,helper);
                        helper.helpershowToastss($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.Attachment_added_Successfully')); 
                        $A.util.removeClass(component.find("NewattchModalshow"), 'slds-fade-in-open');
                        $A.util.removeClass(component.find("NewattchModalBackdrop"),"slds-backdrop_open"); 
                        component.set('v.showspinner',false); 
                    }
                }
            });
            $A.enqueueAction(saveMedia);
        }
        
    },
    closemediaModal : function(component, event, helper) {
        $A.util.removeClass(component.find("NewattchModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewattchModalBackdrop"),"slds-backdrop_open"); 
        
    },
    editmedia : function(component, event, helper) {
        var newlst =[];
        var fillList11=component.get("v.filleList");
        if(fillList11.length > 0) component.set('v.filleList',newlst);
        component.set('v.editMedia',newlst);
        var currmediaId =  event.currentTarget.dataset.recordId;
        if(!$A.util.isEmpty(currmediaId)){
            var obj = component.get('v.ProcessCycles.allRelateddetails.med');
            for(var x in obj){
                if(obj[x].Id == currmediaId) {
                    component.set('v.editMedia',obj[x]);
                }
            }
            var allattch = component.get('v.ProcessCycles.allRelateddetails.attchment');
            for(var i in allattch){
                if(allattch[i].ParentId == currmediaId) component.set('v.SelectedAttachments',allattch[i]);
            }
            
            $A.util.addClass(component.find("EditattchModalshow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("EditattchModalBackdrop"),"slds-backdrop_open");
        }
        
    },
    closeEditmediaModal : function(component, event, helper) {
        $A.util.removeClass(component.find("EditattchModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditattchModalBackdrop"),"slds-backdrop_open");
    },
    DeleteRecordAT : function(component, event, helper) {
        var RecordId = event.getSource().get("v.name");
        var verId = component.get('v.SelectedVersion.Id');
        if (!$A.util.isEmpty(RecordId)) {
            component.set('v.showspinner',true); 
            var action = component.get("c.DeleteAT");
            action.setParams({ AttachId: RecordId , 'versionId':verId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    var emptylst =[];
                    component.set('v.SelectedAttachments',emptylst);
                    var allattch = component.get('v.ProcessCycles.allRelateddetails.attchment');
                    for(var i in allattch){
                        if(allattch[i].Id == RecordId) component.set('v.SelectedAttachments',allattch[i]);
                    }
                    
                }
                helper.helpershowToastss($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.PH_OrderPRod_Item_Removed'));
                component.set('v.showspinner',false); 
            });
            $A.enqueueAction(action);
        }
    },
    SaveEditMedia : function(component, event, helper) {
        var obj = component.get('v.editMedia');
        var attchment = component.get('v.SelectedAttachments');
        var fillList11=component.get("v.filleList");
        component.set('v.showspinner',true);
        var action = component.get('c.updatemedia');
        action.setParams({'Media' : JSON.stringify(obj)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                
            }
        });
        $A.enqueueAction(action);
        
        if(attchment.length == 0  && fillList11.length > 0 && component.find("fileId123").get("v.files").length > 0) { 
            var fileInput = component.get("v.FileList");
            for(var i=0;i<fileInput.length;i++)
                helper.saveAtt(component,event,fileInput[i],obj.Id,helper);
            helper.helpershowToastss($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.Attachment_added_Successfully')); 
            
            
        }
        $A.util.removeClass(component.find("EditattchModalshow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditattchModalBackdrop"),"slds-backdrop_open"); 
        component.set('v.showspinner',false); 
        
    },
    deletemedia : function(component, event, helper) {
        var result = confirm("Are you sure?");
        var verId = component.get('v.SelectedVersion.Id');
        var RecordId = event.currentTarget.dataset.recordId; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var deleteAction = component.get('c.deleteattchMedia');
            deleteAction.setParams({
                'mediaId':RecordId,
                'versionId':verId
            });
            deleteAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.PH_OrderPRod_Item_Removed')); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deleteAction);
        }
    },
    openResouceModal : function(component, event, helper) {
        component.set('v.showspinner',true);
        var PrRecord = event.currentTarget.dataset.recordId; 
        if(!$A.util.isEmpty(PrRecord)){
            var obj = component.get('v.ProcessCycles');
            for (var x in obj){
                if(obj[x].prcscycl.Id == PrRecord) {
                    if(!$A.util.isUndefined(obj[x].allRelateddetails.RRGroup)){
                        component.set('v.RRGroupId',obj[x].allRelateddetails.RRGroup);
                        
                    }
                    
                }
            }
        }
        var resourcegroup = component.get('v.RRGroupId.Id');
        console.log('resourcegroup : '+resourcegroup);
        var windowHash = window.location.hash;
        
        var defaults ;
        if(!$A.util.isUndefined(resourcegroup)) defaults = {'ERP7__Resource_Group__c':resourcegroup};
        var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": 'ERP7__Resource__c',
                "defaultFieldValues":defaults,
                "navigationLocation": "LOOKUP",
                "panelOnDestroyCallback": function(event) {
                    var evt = $A.get("e.force:navigateToComponent");
                    if(evt) {
                        evt.setParams({
                            componentDef : "c:MOProductSetupSection",
                            componentAttributes: {
                                "Productdetails":component.get('v.Productdetails'),
                                "Process" : component.get('v.Process'),
                                "SelectedVersion" : component.get('v.SelectedVersion'),
                                "Action" : 'Edit',
                                "showsiteSelect" : false
                            }
                        });
                        evt.fire();
                    }
                    
                }
            });
            createRecordEvent.fire();
            component.set('v.showspinner',false);
            
        }
        
    },
    deleteResource : function(component, event, helper) {
        var result = confirm("Are you sure?");
        var verId = component.get('v.SelectedVersion.Id');
        var RecordId = event.currentTarget.dataset.recordId; 
        var PrcycleId = event.currentTarget.dataset.index; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var deleteRRAction = component.get('c.deleteRR');
            deleteRRAction.setParams({'RRId':RecordId,'PRID' : PrcycleId,'versionId':verId});
            deleteRRAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','Resource Deleted Successfully!!'); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deleteRRAction);
        }
        
    },
    editResource : function(component, event, helper) {
        component.set('v.showspinner',true);
        var resourceId= event.currentTarget.dataset.recordId;
        var windowHash = window.location.hash;
        if(!$A.util.isUndefined(resourceId)){
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId" : resourceId
            });
            editRecordEvent.fire();
            
            component.set('v.showspinner',false);
            
        }  
    },
    
    CompletesetUp : function(component, event, helper) {
        console.log('CompletesetUp called');
        var prodId = component.get('v.Productdetails.Id');
        var verID = component.get('v.SelectedVersion.Id');
        var ProcessId = component.get('v.Process.Id');
        //component.set('v.showConfirmDialog',true);
        if(component.get('v.Action') == 'clone'){
            component.set('v.showspinner',true);
            var allitems = component.get('v.ProcessCycles');
            var datatocreate = [];
            var medIds = [];
            var itemsselected = 0;
            for(var x in allitems){
                if(allitems[x].prcscycl.selected){
                    itemsselected++;
                }
            }
            if(itemsselected == 0) {
                helper.helpershowToastss('Warning!','warning','Please select the items to clone'); 
                component.set('v.showspinner',false);
                return;
            }
            for(var x in allitems){
                console.log('allitems[x].selected : ',allitems[x].prcscycl.selected);
                if(allitems[x].prcscycl.selected){
                   // itemsselected++;
                    allitems[x].prcscycl.Id = null;
                    var relateditems =  allitems[x].allRelateddetails;
                    for(var y in relateditems.oprlst){
                        if(relateditems.oprlst[y].selected) relateditems.oprlst[y].Id = null;
                        else relateditems.oprlst.splice(y,1);
                    }
                    for(var z in relateditems.bomlst){
                        console.log('relateditems.bomlst[z].selected : ',relateditems.bomlst[z].selected);
                        if(relateditems.bomlst[z].selected) relateditems.bomlst[z].Id = null;
                        else relateditems.bomlst.splice(z,1);
                    }
                    console.log('relateditems.bomlst : ',JSON.stringify(relateditems.bomlst));
                    for(var b in relateditems.wiplinks){
                        if(relateditems.wiplinks[b].selected) relateditems.wiplinks[b].Id = null;
                        else relateditems.wiplinks.splice(b,1);
                    }
                    for(var a in relateditems.availableResource){
                        if(relateditems.availableResource[a].selected) relateditems.availableResource[a].Id = null;
                        else relateditems.availableResource.splice(a,1);
                    }
                    for(var c in relateditems.checklists){
                        if(relateditems.checklists[c].selected) relateditems.checklists[c].Id = null;
                        else relateditems.checklists.splice(c,1);
                    }
                    
                    for(var d in relateditems.med){
                        if(relateditems.med[d].selected) {
                            medIds.push(relateditems.med[d].Id);
                            relateditems.med[d].Id = null;
                        }
                        else relateditems.med.splice(d,1);
                    }
                    
                }
                else allitems.splice(x,1);
            }
            console.log('ProcessCycles : ', JSON.stringify(component.get('v.ProcessCycles')));
            console.log('medIds : ',medIds);
            
            var action = component.get('c.cloneDataSave');
            action.setParams({'PId':prodId,'PRID' : ProcessId,'VRId' : verID,'alldetails' : JSON.stringify(allitems),mediaIds : medIds});
            action.setCallback(this, function(response){
                if (response.getState() === "SUCCESS") {
                    var reslt = response.getReturnValue();
                    console.log('reslt : ',response.getReturnValue());
                    if(reslt !=null && reslt.length > 0){
                        component.set('v.Process',reslt[0].process);
                        console.log('process ~>',reslt[0].process);
                        component.set('v.Productdetails',reslt[0].product);
                        component.set('v.SelectedVersion',reslt[0].version);
                        var prodId = reslt[0].product.Id;
                        var processId = reslt[0].process.Id;
                        var versionId = reslt[0].version.Id;
                        helper.getProcessdetails(component,prodId,processId,versionId);
                        //component.set('v.showspinner',false);
                    }
                    
                }
            });
            $A.enqueueAction(action); 
        }
        else{
            
            var allitems = component.get('v.ProcessCycles');
            console.log('allitems.length : ',allitems.length);
            console.log('allowWIPValidation : ',component.get('v.allowWIPValidation'));
            if(allitems.length == 1 && component.get('v.allowWIPValidation')){
                var wips = allitems[0].allRelateddetails.wiplinks;
                console.log('wips : ',wips);
                let endProductWipExists = true;
                if(wips != undefined){
                    if(wips.length == 0) {
                        helper.helpershowToastss('Warning!','warning','Please add the WIP for the End Product'); 
                        return;
                    }
                    else{
                        for(var x in wips){
                            console.log('prodId : ',prodId);
                            console.log('wips[x].ERP7__Process_Output_Product__c : ',wips[x].ERP7__Process_Output_Product__c);
                            if(wips[x].ERP7__Process_Output_Product__c == prodId){
                                endProductWipExists = true;
                                break;
                            }
                            else {
                                endProductWipExists = false;
                            }
                        }
                    }
                    console.log('endProductWipExists : ',endProductWipExists);
                    if(!endProductWipExists){
                        //component.set('v.exceptionError','Please add the WIP for the End Product');
                        helper.helpershowToastss('Warning!','warning','Please add the WIP for the End Product'); 
                        return; 
                    }
                }
                else{
                    helper.helpershowToastss('Warning!','warning','Please add the WIP for the End Product'); 
                    return;
                }
            }
            for(var x in allitems){
                var opr = allitems[x].allRelateddetails.oprlst;
                if(opr == null || opr == undefined || opr.length == 0){
                    helper.helpershowToastss('Warning!','warning','Please add atleast 1 operation for the process cycle : '+allitems[x].prcscycl.Name); 
                    return;  
                }
            }
            console.log('calling Updatealldetails');
            
            component.set('v.showspinner',true);
            var action = component.get('c.Updatealldetails');
            action.setParams({'PId':prodId,'PRID' : ProcessId,'VRId' : verID});
            action.setCallback(this, function(response){
                if (response.getState() === "SUCCESS") {
                    console.log("Updatealldetails resp: ", JSON.stringify(response.getReturnValue()));
                    var result = response.getReturnValue();
                    helper.helpershowToastss('Success!','success','Manufacturing Setup completed Successfully');
                    var RecUrl = "/lightning/r/Product2/" + prodId + "/view";
                    window.open(RecUrl,'_parent');
                    //component.set('v.showConfirmDialog',false);
                    component.set('v.showspinner',false); 
                }else{
                    var errors = response.getError();
                    console.log("server error in Updatealldetails : ", JSON.stringify(errors));
                }
            });
            $A.enqueueAction(action); 
        }
        
        
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        var prodId = component.get('v.Productdetails.Id');
        var verID = component.get('v.SelectedVersion.Id');
        var ProcessId = component.get('v.Process.Id');
        
        component.set('v.showspinner',true);
        var action = component.get('c.Updatealldetails');
        action.setParams({'PId':prodId,'PRID' : ProcessId,'VRId' : verID});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                helper.helpershowToastss('Success!','success','Manufacturing Setup completed Successfully');
                var RecUrl = "/lightning/r/Product2/" + prodId + "/view";
                window.open(RecUrl,'_parent');
                component.set('v.showConfirmDialog',false);
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
        
    },
    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog',false);
    },
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    openchecklistModal : function(component, event, helper) {
        var newval = component.get('v.NewChklst');
        var PRID = event.currentTarget.dataset.recordId;
        newval.ERP7__Process_Cycle__c = PRID;
        newval.Name = ''
        newval.ERP7__Action_Detail__c ='';
        newval.ERP7__Is_Mandatory__c = false;
        newval.ERP7__Comply__c = '';
        newval.ERP7__Result__c ='';
        newval.ERP7__Operation__c = '';
        component.set('v.NewChklst',newval);
        var qry = '';
        qry += ' AND ERP7__Process_Cycle__c  =\'' + PRID + '\'';
        component.set('v.oppQry',qry);
        $A.util.addClass(component.find("newChecklistModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newChecklistModalBackdrop"),"slds-backdrop_open"); 
        
    },
    closechecklistModal : function(component, event, helper){
        $A.util.removeClass(component.find("newChecklistModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newChecklistModalBackdrop"),"slds-backdrop_open"); 
    },
    Newchecklist : function(component, event, helper){
        component.set('v.showspinner',true);
        var newcheck = component.get('v.NewChklst');
        var verId = component.get('v.SelectedVersion.Id');
        if(newcheck.ERP7__Comply__c == '--None--' || newcheck.ERP7__Comply__c == '--- None ---') newcheck.ERP7__Comply__c = '';
        if(newcheck.ERP7__Result__c == '--None--' || newcheck.ERP7__Result__c == '--- None ---') newcheck.ERP7__Result__c = '';
        var action = component.get('c.CreateNewChklst');
        action.setParams({'check' : JSON.stringify(newcheck) ,'versionId':verId});
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                component.set('v.showspinner',false);
                $A.util.removeClass(component.find("newChecklistModal"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newChecklistModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                console.log('Error : '+JSON.stringify(response.getError()));
                component.set('v.showspinner',false);
            }
        });
        $A.enqueueAction(action);
        
    },
    editchecklists : function(component, event, helper){
        var newlst =[];
        component.set('v.EditChklst',newlst);
        var RecordId = event.currentTarget.dataset.recordId; 
        var PrRecord = event.currentTarget.dataset.index; 
        if(!$A.util.isEmpty(RecordId) && !$A.util.isEmpty(PrRecord)){
            component.set('v.showspinner',true); 
            var qry = '';
            qry += ' AND ERP7__Process_Cycle__c  =\'' + PrRecord + '\'';
            component.set('v.oppQry',qry);
            var obj = component.get('v.ProcessCycles');
            for (var x in obj){
                if(obj[x].prcscycl.Id == PrRecord) {
                    for(var i in obj[x].allRelateddetails.checklists){
                        if(obj[x].allRelateddetails.checklists[i].Id == RecordId) component.set('v.EditChklst',obj[x].allRelateddetails.checklists[i]);
                        
                    }
                    
                }
            }
            $A.util.addClass(component.find("editChecklistModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("editChecklistModalBackdrop"),"slds-backdrop_open"); 
            component.set('v.showspinner',false); 
        }
        
    },
    closeeditchecklistModal : function(component, event, helper){
        $A.util.removeClass(component.find("editChecklistModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("editChecklistModalBackdrop"),"slds-backdrop_open"); 
        
    },
    SaveEditchecks :  function(component, event, helper){
        var updtaechcek = component.get('v.EditChklst');
        if(updtaechcek.ERP7__Comply__c == '--None--' || updtaechcek.ERP7__Comply__c == '--- None ---') updtaechcek.ERP7__Comply__c = '';
        if(updtaechcek.ERP7__Result__c == '--None--' || updtaechcek.ERP7__Result__c == '--- None ---') updtaechcek.ERP7__Result__c = '';
        component.set('v.showspinner',true);
        var verId = component.get('v.SelectedVersion.Id');
        var action = component.get('c.updatechklist');
        action.setParams({
            'checktoUpdate' :JSON.stringify(updtaechcek),
            'versionId':verId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component);
                helper.helpershowToastss('Success!','success','Checklist Updated Successfully!!'); 
                component.set('v.showspinner',false); 
                $A.util.removeClass(component.find("editChecklistModal"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("editChecklistModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                var err = response.getError();
                console.log('error : '+ JSON.stringify(err));
                component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
        
        
    },
    deletechecklist : function(component, event, helper){
        var result = confirm("Are you sure?");
        var verId = component.get('v.SelectedVersion.Id');
        var RecordId = event.currentTarget.dataset.recordId; 
        if(result && !$A.util.isEmpty(RecordId)){
            component.set('v.showspinner',true); 
            var deleteCheckAction = component.get('c.deletechecks');
            deleteCheckAction.setParams({
                'chklstId':RecordId,
                'versionId':verId 
            });
            deleteCheckAction.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','Checklist Deleted Successfully!!'); 
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(deleteCheckAction);
        }
    },
    getUOM : function(component, event, helper){
        var name=event.currentTarget.name;
        var prodId =''
        if(name == 'NewWIP'){
            var editWIPdetails = component.get('v.NewWIP');
            prodId = editWIPdetails.ERP7__Process_Output_Product__c;
        }
        else if(name == 'NewBOM'){
            var newBom = component.get('v.NewBOM');
            prodId = newBom.ERP7__BOM_Component__c;
        }
        if(!$A.util.isUndefinedOrNull(prodId) && prodId != ''){
            var getUOMaction = component.get('c.getProductUOM');
            getUOMaction.setParams({'ProductId': prodId});
            getUOMaction.setCallback(this, function (res) {
                var state = res.getState();
                if(state === 'SUCCESS'){
                    if(name == 'NewWIP'){
                        var editWIPdetails = component.get('v.NewWIP');
                        var prod = res.getReturnValue().prod;
                        if(prod != null && prod != '' && prod != undefined){
                            editWIPdetails.ERP7__Quantity_Unit_Of_Measure__c = res.getReturnValue().prod.QuantityUnitOfMeasure;
                            editWIPdetails.Name = res.getReturnValue().prod.Name;
                            component.set('v.NewWIP',editWIPdetails); 
                        }
                        
                    }
                    else if(name == 'NewBOM'){
                        var newBom = component.get('v.NewBOM');
                        var prod = res.getReturnValue().prod;
                        if(prod != null && prod != '' && prod != undefined){
                            newBom.Name = res.getReturnValue().prod.Name;
                            newBom.ERP7__Unit_of_Measure__c = res.getReturnValue().prod.QuantityUnitOfMeasure;
                        }
                        var cc = res.getReturnValue().costCard;
                        if(cc != null && cc != '' && cc != undefined){
                            newBom.ERP7__Cost_Price__c = res.getReturnValue().costCard.ERP7__Cost__c;
                            newBom.ERP7__Cost_Card__c = res.getReturnValue().costCard.Id;
                        }
                        component.set('v.NewBOM',newBom);
                    }
                }
                else{
                    console.log('error : '+JSON.stringify(res.getError()));
                }
                
            });
            $A.enqueueAction(getUOMaction);
        }
        
    },
    onControllerFieldChange : function(component, event, helper) {  
        var getchecks = component.get('v.NewChklst');
        var editchecks = component.get('v.EditChklst');
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        if(getchecks.ERP7__Comply__c == controllerValueKey) {
            getchecks.Name = controllerValueKey;
            component.set('v.NewChklst',getchecks);
        }
        if(editchecks.ERP7__Comply__c == controllerValueKey) {
            editchecks.Name = controllerValueKey;
            component.set('v.EditChklst',editchecks);
        }
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    handleDrag : function(component, event, helper) {
        console.log("Inside drag");
        let DrgIndx = event.currentTarget.dataset.index;
        component.set("v.DragIndex" ,DrgIndx);
    },
    
    handleDrop : function(component, event, helper) {  
        try{
            
            let processCyleId = event.currentTarget.dataset.recordId;
            console.log('processCyleId::',processCyleId);
            component.set("v.ProcessCycleId",processCyleId);
            
            var RecordId = event.currentTarget.dataset.recordId; 
            var PrRecord = event.currentTarget.dataset.index; 
            
            let bomList = [];
            let bomListToUpdate = [];
            var ObjProcessCycles = component.get('v.ProcessCycles');
            
            for (var x in ObjProcessCycles){
                if(ObjProcessCycles[x].prcscycl.Id == RecordId) {
                    for(var i in ObjProcessCycles[x].allRelateddetails.bomlst){
                        bomList = ObjProcessCycles[x].allRelateddetails.bomlst;
                    }  
                }
            }
            
            let DrgIndx = component.get('v.DragIndex');
            let DragIndex = parseInt(DrgIndx);
            let indexVal = parseInt(event.currentTarget.getAttribute('data-index'));
            let listOfLineItems = JSON.parse(JSON.stringify(bomList));
            let ShiftElement = listOfLineItems[DragIndex];
            if (!ShiftElement) { component.set('v.showspinner',false); return; }
            listOfLineItems.splice(DragIndex, 1);
            listOfLineItems.splice(indexVal, 0, ShiftElement);
            bomList = listOfLineItems;
            for(var j in bomList){
                bomListToUpdate[j]={};
                
                bomListToUpdate[j].ERP7__Sort__c = j;
                bomListToUpdate[j].Name = bomList[j].Name;
                bomListToUpdate[j].Id = bomList[j].Id;
                //bomListToUpdate[j].ERP7__BOM_Component__r =    Object.assign({}, bomListToUpdate[j].ERP7__BOM_Component__r, { Name: bomList[j].Name });
                bomListToUpdate[j].ERP7__BOM_Component__c =    bomList[j].ERP7__BOM_Component__c;
                bomListToUpdate[j].ERP7__Quantity__c      =    bomList[j].ERP7__Quantity__c;
                bomListToUpdate[j].ERP7__Unit_of_Measure__c =  bomList[j].ERP7__Unit_of_Measure__c;
                bomListToUpdate[j].ERP7__Maximum_Variance__c = bomList[j].ERP7__Maximum_Variance__c;
                bomListToUpdate[j].ERP7__Minimum_Variance__c = bomList[j].ERP7__Minimum_Variance__c;
                bomListToUpdate[j].ERP7__For_Multiples__c    = bomList[j].ERP7__For_Multiples__c; 	
            }
            
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var action = component.get('c.updateBOMList');
            action.setParams({'BomsToUpdate' :bomListToUpdate,
                              'PrcsId' : component.get("v.ProcessCycleId"),
                              'versionId':verId
                             });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    //var TestResult = component.get('v.ProcessCycles');
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','BOM Updated Successfully!!'); 
                    component.set('v.showspinner',false); 
                    $A.util.removeClass(component.find("EditBOMModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("EditBOMModalBackdrop"),"slds-backdrop_open"); 
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(action);
            
            console.log("bomListToUpdate::",bomListToUpdate);
            //ObjProcessCycles[0].allRelateddetails.bomlst = bomListToUpdate;
            //component.set('v.ProcessCycles',ObjProcessCycles); 
            component.set('v.allowNew',false); 
            component.set('v.allowNew',true);
            
        }catch(e){console.log('Error-->',e);}
        
        
    },
    handleOpDrop : function(component, event, helper) {  
        try{
            
            let processCyleId = event.currentTarget.dataset.recordId;
            console.log('processCyleId::',processCyleId);
            component.set("v.ProcessCycleId",processCyleId);
            
            var RecordId = event.currentTarget.dataset.recordId; 
            var PrRecord = event.currentTarget.dataset.index; 
            let OpList = [];
            let OpListToUpdate = [];
            var ObjProcessCycles = component.get('v.ProcessCycles');
            for (var x in ObjProcessCycles){
                if(ObjProcessCycles[x].prcscycl.Id == RecordId) {
                    for(var i in ObjProcessCycles[x].allRelateddetails.oprlst){
                        OpList = ObjProcessCycles[x].allRelateddetails.oprlst;
                    }  
                }
            }
            let DrgIndx = component.get('v.DragIndex');
            let DragIndex = parseInt(DrgIndx);
            let indexVal = parseInt(event.currentTarget.getAttribute('data-index'));
            let listOfLineItems = JSON.parse(JSON.stringify(OpList));
            let ShiftElement = listOfLineItems[DragIndex];
            if (!ShiftElement) { component.set('v.showspinner',false); return; }
            listOfLineItems.splice(DragIndex, 1);
            listOfLineItems.splice(indexVal, 0, ShiftElement);
            OpList = listOfLineItems;
            for(var j in OpList){
                OpListToUpdate[j]={};
                
                OpListToUpdate[j].ERP7__Sort__c = j;//create
                OpListToUpdate[j].Name = OpList[j].Name;
                OpListToUpdate[j].Id = OpList[j].Id;
                //
                OpListToUpdate[j].ERP7__Auto_Clock_In__c =    OpList[j].ERP7__Auto_Clock_In__c;
                OpListToUpdate[j].ERP7__Timer__c      =    OpList[j].ERP7__Timer__c;
                OpListToUpdate[j].ERP7__Is_Signature_Required__c =  OpList[j].ERP7__Is_Signature_Required__c;
                
            }
            
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var action = component.get('c.updateOpList');
            action.setParams({'OperationsToUpdate' :OpListToUpdate,
                              'PrcsId' : component.get("v.ProcessCycleId"),
                              'versionId':verId
                             });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('result : ',result);
                    component.set('v.ProcessCycles',result);
                    //var TestResult = component.get('v.ProcessCycles');
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','Operation Updated Successfully!!'); 
                    component.set('v.showspinner',false); 
                    $A.util.removeClass(component.find("EditOPModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("EditOPModalBackdrop"),"slds-backdrop_open"); 
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(action);
            
            console.log("OpListToUpdate::",OpListToUpdate);
            //ObjProcessCycles[0].allRelateddetails.bomlst = OpListToUpdate;
            //component.set('v.ProcessCycles',ObjProcessCycles); 
            component.set('v.allowNew',false); 
            component.set('v.allowNew',true);
            
        }catch(e){console.log('Error-->',e);}
        
        
    },
    handleWiPDrop : function(component, event, helper) {  
        try{
            
            let processCyleId = event.currentTarget.dataset.recordId;
            console.log('processCyleId::',processCyleId);
            component.set("v.ProcessCycleId",processCyleId);
            
            var RecordId = event.currentTarget.dataset.recordId; 
            var PrRecord = event.currentTarget.dataset.index; 
            
            let WiPList = [];
            let WiPListToUpdate = [];
            var ObjProcessCycles = component.get('v.ProcessCycles');
            
            for (var x in ObjProcessCycles){
                if(ObjProcessCycles[x].prcscycl.Id == RecordId) {
                    for(var i in ObjProcessCycles[x].allRelateddetails.wiplinks){
                        WiPList = ObjProcessCycles[x].allRelateddetails.wiplinks;
                    }  
                }
            }
            
            let DrgIndx = component.get('v.DragIndex');
            let DragIndex = parseInt(DrgIndx);
            let indexVal = parseInt(event.currentTarget.getAttribute('data-index'));
            let listOfLineItems = JSON.parse(JSON.stringify(WiPList));
            let ShiftElement = listOfLineItems[DragIndex];
            if (!ShiftElement) { component.set('v.showspinner',false); return; }
            listOfLineItems.splice(DragIndex, 1);
            listOfLineItems.splice(indexVal, 0, ShiftElement);
            WiPList = listOfLineItems;
            for(var j in WiPList){
                WiPListToUpdate[j]={};
                
                WiPListToUpdate[j].ERP7__Sort__c = j;//create
                WiPListToUpdate[j].Name = WiPList[j].Name;
                WiPListToUpdate[j].Id = WiPList[j].Id;
                //
                //WiPListToUpdate[j].ERP7__Process_Output_Product__r.Name = WiPList[j].ERP7__Process_Output_Product__r.Name;
                WiPListToUpdate[j].ERP7__Quantity_Unit__c = WiPList[j].ERP7__Quantity_Unit__c;
                WiPListToUpdate[j].ERP7__Quantity_Unit_Of_Measure__c =  WiPList[j].ERP7__Quantity_Unit_Of_Measure__c;
                
            }
            
            component.set('v.showspinner',true);
            var verId = component.get('v.SelectedVersion.Id');
            var action = component.get('c.updateWiPList');
            action.setParams({'WiPToUpdate' :WiPListToUpdate,
                              'PrcsId' : component.get("v.ProcessCycleId"),
                              'versionId':verId
                             });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                    helper.helpershowToastss('Success!','success','WiP Updated Successfully!!'); 
                    component.set('v.showspinner',false); 
                    $A.util.removeClass(component.find("EditWIPModalshow"), 'slds-fade-in-open');
                    $A.util.removeClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open"); 
                }
                else{
                    var err = response.getError();
                    console.log('error : '+ JSON.stringify(err));
                    component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                    component.set('v.showspinner',false); 
                }
            });
            $A.enqueueAction(action);
            
            console.log("WiPListToUpdate::",WiPListToUpdate);
            //ObjProcessCycles[0].allRelateddetails.bomlst = WiPListToUpdate;
            //component.set('v.ProcessCycles',ObjProcessCycles); 
            component.set('v.allowNew',false); 
            component.set('v.allowNew',true);
            
        }catch(e){console.log('Error-->',e);}
        
        
    },
    handleProcessDrop: function(component, event, helper) {  
        console.log('inside handleProcessDrop');
        let ProcessList = [];
        let ProcessListToUpdate = [];
        let processId = '';
        var ObjProcessCycles = component.get('v.ProcessCycles');
        
        for (var x in ObjProcessCycles){
            ProcessList[x] = (ObjProcessCycles[x].prcscycl);  
            processId = ObjProcessCycles[x].prcscycl.ERP7__Process__c;
        }
        console.log('ProcessList changed',ProcessList);
        console.log('processId',processId);
        let DrgIndx = component.get('v.DragIndex');
        let DragIndex = parseInt(DrgIndx);
        console.log('DragIndex',DragIndex);
        let indexVal = parseInt(event.currentTarget.getAttribute('data-index'));
        console.log('indexVal',indexVal);
        let listOfLineItems = JSON.parse(JSON.stringify(ProcessList));
        let ShiftElement = listOfLineItems[DragIndex];
        if (!ShiftElement) { component.set('v.showspinner',false); return; }
        listOfLineItems.splice(DragIndex, 1);
        listOfLineItems.splice(indexVal, 0, ShiftElement);
        ProcessList = listOfLineItems;
        for(var j in ProcessList){
            ProcessListToUpdate[j]={};
            
            ProcessListToUpdate[j].ERP7__Sort__c = parseInt(j)+parseInt(1);//create
            ProcessListToUpdate[j].Name = ProcessList[j].Name;
            ProcessListToUpdate[j].Id = ProcessList[j].Id;
            console.log('sorted? ',ProcessListToUpdate);
        }
        component.set('v.showspinner',true);
        var verId = component.get('v.SelectedVersion.Id');
        var action = component.get('c.updateProcessList');
        action.setParams({'ProcessToUpdate' :ProcessListToUpdate,
                          'processId' : processId,
                          'versionId':verId
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProcessCycles',result);
                helper.fixSort(component); 
                console.log('result : ', result);
                helper.helpershowToastss('Success!','success','Process Updated Successfully!!'); 
                component.set('v.showspinner',false); 
                $A.util.removeClass(component.find("EditWIPModalshow"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open"); 
            }
            else{
                var err = response.getError();
                console.log('error : '+ JSON.stringify(err));
                component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner',false); 
            }
        });
        $A.enqueueAction(action);
        
        console.log("ProcessListToUpdate::",ProcessListToUpdate);
        //ObjProcessCycles[0].allRelateddetails.bomlst = ProcessListToUpdate;
        //component.set('v.ProcessCycles',ObjProcessCycles); 
        component.set('v.allowNew',false); 
        component.set('v.allowNew',true);
    },
    
    allowDrop : function(component, event, helper) { 
        console.log('inside all drop');
        event.preventDefault();
    },
    backToMainPage : function(component, event, helper) { 
        component.set('v.showAddProducts',false);
        component.set('v.addProductsMsg','');
    },
    
    addProducts : function(component, event, helper) { 
        try{
            let selectedProds = component.get('v.selectedListOfProducts');
            if(selectedProds != undefined && selectedProds != null && selectedProds.length > 0){
                component.set('v.showspinner',true);
                component.set('v.disableAddProductsButton',true);
                let Boms = [];
                let WIPs = [];
                for(var x in selectedProds){
                    if(selectedProds[x].quantity == null || selectedProds[x].quantity == '' || selectedProds[x].quantity == undefined || selectedProds[x].quantity == 0){
                        component.set("v.addProductsMsg",$A.get('$Label.c.PH_Enter_Quantity_for_Product') +selectedProds[x].prod.Name); 
                        component.set('v.showspinner',false);  
                        component.set('v.disableAddProductsButton',false);
                        return;
                    }
                    else if(selectedProds[x].UOM == null || selectedProds[x].UOM == '' || selectedProds[x].UOM == undefined || selectedProds[x].UOM == '--None--'){
                        component.set("v.addProductsMsg",'Please enter UOM for Product : '+selectedProds[x].prod.Name); 
                        component.set('v.showspinner',false);  
                        component.set('v.disableAddProductsButton',false);
                        return; 
                    }
                    
                    if(component.get('v.Header') === $A.get("$Label.c.Bill_of_Materials_BOM")){
                        
                        let bomstoAdd = {};
                        console.log('inside bom');
                        var name = selectedProds[x].prod.Name;
                        bomstoAdd.Name = (name.length >= 80) ? name.substr(0,79) : name;
                        bomstoAdd.ERP7__Active__c = true;
                        bomstoAdd.ERP7__BOM_Component__c = selectedProds[x].prod.Id;
                        bomstoAdd.ERP7__BOM_Product__c = component.get('v.Productdetails.Id');
                        bomstoAdd.ERP7__BOM_Version__c = component.get('v.SelectedVersion.Id');
                        bomstoAdd.ERP7__Description__c = selectedProds[x].prod.Description;
                        bomstoAdd.ERP7__For_Multiples__c = selectedProds[x].Multiples;
                        bomstoAdd.ERP7__Minimum_Variance__c = selectedProds[x].MinVariance;
                        bomstoAdd.ERP7__Maximum_Variance__c = selectedProds[x].MaxVariance;
                        bomstoAdd.ERP7__Unit_of_Measure__c = selectedProds[x].UOM;
                        bomstoAdd.ERP7__Quantity__c = selectedProds[x].quantity;
                        bomstoAdd.ERP7__Process_Cycle__c = component.get('v.ProcessCycleId');
                        bomstoAdd.ERP7__Cost_Price__c = selectedProds[x].CostPrice;
                        bomstoAdd.ERP7__Cost_Card__c = selectedProds[x].CostcardId;
                        Boms.push(bomstoAdd);                    
                    }
                    else if(component.get('v.Header') === $A.get("$Label.c.Work_in_Progress_WIPs")){
                        let newWip = {};
                        var name = selectedProds[x].prod.Name;
                        console.log('name : ',name);
                        newWip.Name = (name.length >= 80) ? name.substr(0,79) : name;
                        console.log('newWip.Name : ',newWip.Name);
                        newWip.ERP7__Process_Output_Product__c = selectedProds[x].prod.Id;
                        newWip.ERP7__Quantity_Unit__c =  selectedProds[x].quantity;
                        newWip.ERP7__Quantity_Unit_Of_Measure__c = selectedProds[x].UOM;
                        newWip.ERP7__Process_Cycle__c = component.get('v.ProcessCycleId');
                        WIPs.push(newWip);
                    }
                }
                var verId = component.get('v.SelectedVersion.Id');
                if(Boms.length > 0){
                    var newaction = component.get('c.saveBOM');
                    newaction.setParams({
                        'BOM' : JSON.stringify(Boms),
                        'versionId':verId,
                    });
                    newaction.setCallback(this, function(response){
                        if (response.getState() === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set('v.ProcessCycles',result);
                            helper.fixSort(component);
                            helper.helpershowToastss('Success!','success','BOMs Created Successfully!!');  
                            component.set('v.showAddProducts',false);
                            component.set('v.showspinner',false);  
                            component.set('v.disableAddProductsButton',false);
                        }
                        else{
                            var err = response.getError();
                            console.log('error : '+ JSON.stringify(err));
                            component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                            component.set('v.showspinner',false);  
                            component.set('v.disableAddProductsButton',false);
                        }
                    });
                    $A.enqueueAction(newaction); 
                }
                else if(WIPs.length > 0){
                    var verId = component.get('v.SelectedVersion.Id');
                    var newaction = component.get('c.saveWIP');
                    newaction.setParams({'WIP' : JSON.stringify(WIPs) ,'versionId':verId});
                    newaction.setCallback(this, function(response){
                        if (response.getState() === "SUCCESS") {
                            var result = response.getReturnValue();
                            component.set('v.ProcessCycles',result);
                            helper.fixSort(component);
                            helper.helpershowToastss('Success!','success','WIP Created Successfully!!'); 
                            component.set('v.showAddProducts',false);
                            // $A.util.removeClass(component.find("NewWIPModalshow"), 'slds-fade-in-open');
                            // $A.util.removeClass(component.find("NewWIPModalBackdrop"),"slds-backdrop_open");
                            component.set('v.showspinner',false);  
                            component.set('v.disableAddProductsButton',false);
                        }
                        else{
                            var err = response.getError();
                            console.log('error : '+ JSON.stringify(err));
                            component.set('v.exceptionError',$A.get('$Label.c.Error_UsersShiftMatch'));
                            component.set('v.showspinner',false);  
                            component.set('v.disableAddProductsButton',false);
                        }
                    });
                    $A.enqueueAction(newaction);
                }else{
                    console.log('inhere else');
                    component.set('v.showspinner',false);  
                    component.set('v.disableAddProductsButton',false);
                }
            }
            else{
                component.set("v.addProductsMsg",$A.get('$Label.c.PH_Please_Select_Product_to_proceed')); 
                component.set('v.showspinner',false);  
                component.set('v.disableAddProductsButton',false);
            }
        }
        catch(e){console.log('Error in Addproducts',e);}
    },
    
    fetchProducts : function(component, event, helper) { 
        let searchval = component.get('v.searchItem');
        if(searchval != null && searchval != undefined){
            let selectedProds = component.get('v.selectedListOfProducts');
            if(selectedProds != undefined){
                for(var x in selectedProds){
                    if(selectedProds[x].quantity == null || selectedProds[x].quantity == '' || selectedProds[x].quantity == undefined || selectedProds[x].quantity == 0){
                        component.set("v.addProductsMsg",$A.get('$Label.c.PH_Enter_Quantity_for_Product')+' '+selectedProds[x].prod.Name); 
                        component.set('v.searchItem','');
                        return;
                    }
                    else if(selectedProds[x].UOM == null || selectedProds[x].UOM == '' || selectedProds[x].UOM == undefined || selectedProds[x].UOM == '--None--'){
                        component.set("v.addProductsMsg",'Please enter UOM for Product : '+selectedProds[x].prod.Name); 
                        component.set('v.searchItem','');
                        return; 
                    }
                }
            }
            component.set('v.showspinner',true);
            helper.getProducts(component);
            setTimeout(function() {
                component.set('v.showspinner', false);
            }, 10000);
        }
    },
    fetchFamilyProducts : function(component, event, helper) { 
        let searchfamily = component.get('v.seachItemFmily');
        if(searchfamily != null && searchfamily != '' && searchfamily != undefined){
            let selectedProds = component.get('v.selectedListOfProducts');
            if(selectedProds != undefined){
                for(var x in selectedProds){
                    if(selectedProds[x].quantity == null || selectedProds[x].quantity == '' || selectedProds[x].quantity == undefined || selectedProds[x].quantity == 0){
                        component.set("v.addProductsMsg",$A.get('$Label.c.PH_Enter_Quantity_for_Product')+' '+selectedProds[x].prod.Name); 
                        component.set('v.seachItemFmily','--None--');
                        return;
                    }
                    else if(selectedProds[x].UOM == null || selectedProds[x].UOM == '' || selectedProds[x].UOM == undefined || selectedProds[x].UOM == '--None--'){
                        component.set("v.addProductsMsg",'Please enter UOM for Product : '+selectedProds[x].prod.Name); 
                        component.set('v.seachItemFmily','--None--');
                        return; 
                    }
                }
            }
            component.set('v.showspinner',true);
            helper.getProducts(component);
            helper.parentFieldChange(component, event, helper);
            setTimeout(function() {
                component.set('v.showspinner', false);
            }, 10000);
        }
    },
    fetchSubFamilyProducts : function(component, event, helper) { 
        let searchval = component.get('v.subItemFmily');
        if(searchval != null && searchval != '' && searchval != undefined){
            let selectedProds = component.get('v.selectedListOfProducts');
            if(selectedProds != undefined){
                for(var x in selectedProds){
                    if(selectedProds[x].quantity == null || selectedProds[x].quantity == '' || selectedProds[x].quantity == undefined || selectedProds[x].quantity == 0){
                        component.set("v.addProductsMsg",$A.get('$Label.c.PH_Enter_Quantity_for_Product')+' '+selectedProds[x].prod.Name); 
                        component.set('v.subItemFmily','--None--');
                        return;
                    }
                    else if(selectedProds[x].UOM == null || selectedProds[x].UOM == '' || selectedProds[x].UOM == undefined || selectedProds[x].UOM == '--None--'){
                        component.set("v.addProductsMsg",'Please enter UOM for Product : '+selectedProds[x].prod.Name); 
                        component.set('v.subItemFmily','--None--');
                        return; 
                    }
                }
            }
            component.set('v.showspinner',true);
            helper.getProducts(component);
            setTimeout(function() {
                component.set('v.showspinner', false);
            }, 10000);
        }
    },
    closeaddProductsMsg : function(component, event, helper) { 
        component.set('v.addProductsMsg','');
    },
    handleCheckbox : function(component, event, helper) {
        let prodId = event.getSource().get('v.name');
        console.log('prodId : ',prodId);
        let valcheck = event.getSource().get('v.checked');
        console.log('valcheck : ',valcheck);
        if(prodId != null && prodId != undefined && prodId != ''){
            component.set('v.showspinner',true);
            let allprods = component.get('v.listOfProducts');
            let selectedProds = component.get('v.selectedListOfProducts');
            if(selectedProds == null && selectedProds == undefined && selectedProds.length == 0) selectedProds = [];
            for(var x in allprods){
                if(allprods[x].prod.Id == prodId){
                    var index = selectedProds.findIndex(item => item.prod.Id === prodId);
                    console.log('index : ',index);
                    if (valcheck) {
                        if (index === -1) {
                            selectedProds.push(allprods[x]);
                        }
                    } else {
                        if (index !== -1) {
                            selectedProds.splice(index, 1);
                        }
                    }
                }
            }
            component.set('v.selectedListOfProducts',selectedProds);
            console.log('selectedListOfProducts : ',JSON.stringify(selectedProds));
            component.set('v.showspinner',false);
        }
    },
    createProduct: function(component, event, helper) {
        console.log('createProduct called');
        try{
            var createRecordEvent = $A.get("e.force:createRecord");
            if (!$A.util.isUndefined(createRecordEvent)) {
                createRecordEvent.setParams({
                    "entityApiName": "Product2",
                    "navigationLocation" : "LOOKUP",
                    "panelOnDestroyCallback": function(event) {
                        var navigateEvent = $A.get("e.force:navigateToComponent");           
                        navigateEvent.setParams({
                            componentDef : "c:MOProductSetupSection",
                            componentAttributes: {
                                'Productdetails':component.get("v.Productdetails"),
                                'Process':component.get("v.Process"),
                                'SelectedVersion':component.get("v.SelectedVersion"),
                                'Action':component.get("v.Action"),
                                'showAddProducts' : component.get("v.showAddProducts"),
                                'BOMCreation' : component.get("v.BOMCreation"),
                                'Header' : component.get("v.Header"),
                                'ProcessCycleId' : component.get("v.ProcessCycleId"),
                            }
                        })
                    }
                });
                createRecordEvent.fire();
                helper.getProducts(component);
                
            }
        }catch(e){
            console.log('Error catch : ',e);
        }
    },
    toggle : function(cmp, event, helper) {
        
        var items = cmp.get("v.ProcessCycles");
        var index = event.getSource().get("v.value");
        console.log('index : ',index);
        var expanded = event.getSource().get("v.title");
        console.log('expanded : ',expanded);
        var sortedlist = cmp.get("v.sortedlist");
        if(!expanded) {
            sortedlist[index]=1;
        }
        else {
            sortedlist[index]=0;
        }
        console.log("sortedlist?", sortedlist);
        cmp.set("v.sortedlist",sortedlist);
        for(var x in items){
            console.log('items[index].expanded : ',items[index].expanded);
            console.log('sortedlist[index] : ',sortedlist[index]);
            if(x == index) items[x].expanded = !items[x].expanded;
            else if(!expanded) items[x].expanded = false;
        }
        // items[index].expanded = !items[index].expanded;
        cmp.set("v.ProcessCycles", items);
        //event.stopPropagation();
        
    },
    setPcsSelected : function(cmp, event, helper) {
        try{
        console.log('setPcsSelected called');
        cmp.set('v.showspinner',true);
        let pcsId = event.getSource().get("v.title");
        console.log('pcsId : ',pcsId);
        var checkedval = event.getSource().get("v.checked");
        console.log('checkedval : ',checkedval);
        if(pcsId != null && pcsId != undefined &&  pcsId != ''){
            var result = cmp.get("v.ProcessCycles");
            console.log('ProcessCycles after: ',JSON.stringify(result));
            for(var x in result){
                if(result[x].prcscycl.Id == pcsId){
                    var alldetails = result[x].allRelateddetails;
                    for(var y in alldetails.oprlst){
                        alldetails.oprlst[y].selected = checkedval;
                    }
                    for(var z in alldetails.bomlst){
                        alldetails.bomlst[z].selected = checkedval;
                    }
                    for(var b in alldetails.wiplinks){
                        alldetails.wiplinks[b].selected = checkedval;
                    }
                    for(var a in alldetails.availableResource){
                        alldetails.availableResource[a].selected = checkedval;
                    }
                    for(var c in alldetails.checklists){
                        alldetails.checklists[c].selected = checkedval;
                    }
                    for(var d in alldetails.med){
                        alldetails.med[d].selected = checkedval;
                    }
                }
            }
            console.log('ProcessCycles after: ',JSON.stringify(result));
            cmp.set('v.showspinner',false);
            cmp.set("v.ProcessCycles",result); 
        }
        
        cmp.set('v.showspinner',false);
        }catch(e){
            console.log('error : ',e);
        }
    }
})