({
    getAddresses1 : function(cmp,event){
        var action=cmp.get("c.getAddresses");
        action.setParams({accId:cmp.get("v.AccId")});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.addList",response.getReturnValue().addList);
                if(cmp.get("v.addList").length == 0)
                    cmp.set("v.showAddress",true);
                else{
                    cmp.set("v.showAddress",false);
                    var addList=cmp.get("v.addList");
                    for(var i=0;i<addList.length;i++){
                        if(addList[i].ERP7__Primary__c = true){
                            cmp.set("v.showOneAddress",addList[i]);
                			break;
                        }
                    }
					this.cartItems(cmp, event);                    
                }
                cmp.set("v.newName",response.getReturnValue().acc.Name);
                cmp.set("v.newMobile",response.getReturnValue().con.MobilePhone);
                
                cmp.set("v.Mobile",response.getReturnValue().con.MobilePhone);
                cmp.set("v.conId",response.getReturnValue().con.Id);
                cmp.set("v.State",response.getReturnValue().State);
                cmp.set("v.Country",response.getReturnValue().country);
            }
        });
        $A.enqueueAction(action);
    },
    
    getAddresses2 : function(cmp,event,SOId,addId){
        var action=cmp.get("c.getAddresses");
        action.setParams({accId:cmp.get("v.AccId")});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.addList",response.getReturnValue().addList);
                //this.cartItems(cmp, event);     
                this.saveAddToSO(cmp,event,SOId,addId);             
             } 
        });
        $A.enqueueAction(action);
    },
    getAddresses3 : function(cmp,event){
        var action=cmp.get("c.getAddresses");
        action.setParams({accId:cmp.get("v.AccId")});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.addList",response.getReturnValue().addList);         
             } 
        });
        $A.enqueueAction(action);
    },
    
    getUserDetails : function(cmp, event){
        var action=cmp.get("c.getUserDetails");
        action.setCallback(this,function(response){
           	var state = response.getState();   
            if(state === "SUCCESS"){
                cmp.set('v.changeSPN',response.getReturnValue().newsLetter);
            }
        });
        $A.enqueueAction(action); 
    },
    cartItems : function(cmp,event) {
        var action = cmp.get('c.viewCart');//getCatList
        action.setParams({accId : cmp.get("v.AccId")});
      	action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            cmp.set("v.noOfItemsOnCart",response.getReturnValue().cartpickitemList.length);
            cmp.set("v.cartProducts",response.getReturnValue().cartproductWrapper);
            var totalcount;
            if(response.getReturnValue().cartpickitemList.length > 2)
                totalcount=response.getReturnValue().cartpickitemList.length-2;            	
            else
                totalcount=response.getReturnValue().cartpickitemList.length; 
                
            cmp.set("v.totalPro",totalcount);            
            var cartItems=[];
            for(var i=0 ;i<2; i++)
                cartItems.push(response.getReturnValue().cartproduct[i]);             
            cmp.set("v.cartItems",cartItems);
            this.createSalesOrder(cmp, event);
        }
      });
      $A.enqueueAction(action); 
	},
    
    createSalesOrder: function(cmp, event){
        try{
        var cartProducts=cmp.get("v.cartProducts");
        
        //var coupon = cmp.get("v.coupon");        
        var coupon=cmp.get("v.coupon");
        if(coupon != undefined){
            if(coupon.length == 0)
        		coupon = undefined;
        }        
        var action=cmp.get("c.createSO");
        action.setParams({
            AccId:cmp.get("v.AccId"),
            cartProducts : JSON.stringify(cmp.get("v.cartProducts")),
            coupon : JSON.stringify(coupon)
        });
        action.setCallback(this, function(response){
            var state=response.getState(); 
            console.log(state);
            if(state==="SUCCESS"){                 
                cmp.set("v.SOId",response.getReturnValue().so[0].Id);
                cmp.set("v.delay",true);
                if(cmp.get("v.showAddress") == false){
                    this.UPSServices1(cmp,event);
                	this.FedExServices(cmp,event);
                }
                
            }
        });
        $A.enqueueAction(action); 
        }catch(e){
            console.log('err~>'+e);
        }
    },
    
    UPSServices1: function(cmp, event) {
        //cmp.set("v.hideShipping",true);
        var SalesOrder = cmp.get("v.SOId");	
        
        
        if(SalesOrder != undefined){
            cmp.set("v.UPSError", '');
        } else{
            cmp.set("v.UPSError", 'Sales order in not Found');
        }
        if(SalesOrder != undefined){
            var packType = cmp.get("v.UPS_Services.PackageType");
            var packNo = cmp.get("v.UPS_Services.NoofPackage");
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var action = cmp.get("c.UPSServices");	//a0e1o0000180CkHAAU		00016837
            action.setParams({ 
                soId: SalesOrder,
                packType: packType,
                packNo: packNo,
                shipDate: shipDate
            });            
            action.setCallback(this, function(response) {
                var state = response.getState();	
                
                if (state === "SUCCESS") { 
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services.length > 0){
                        response.getReturnValue().Services[0].Selected = true;
                    }
                    var UPSServices=[];
                    for(var i=0;i<5;i++){                        
                        UPSServices.push(response.getReturnValue().Services[i]);
                    }
                    cmp.set("v.shippingServices",UPSServices);
                    cmp.set("v.hideShipping",false);
                    
                    var shippingServices=cmp.get("v.shippingServices");
                    var count=0;
                    for(var j=0;j<shippingServices.length;j++){
                        if(shippingServices[j] == undefined){
                            count++;
                        }
                    }
                    if(count == 5){
                        cmp.set("v.shippingNotAvailable",true);
                    }
                    //cmp.set("v.UPS_Services",UPSServices);                    
                    cmp.set("v.UPS_Services",response.getReturnValue());
                    if(packType == null || packType == undefined || packType == '') cmp.find("packType").set("v.options", response.getReturnValue().PackageTypes);
                    cmp.set("v.UPS_Services.PackageType",response.getReturnValue().PackageType);
                   
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    FedExServices: function(cmp, event) {
        var SalesOrder = cmp.get("v.SOId");	
        if(SalesOrder != undefined){
            cmp.set("v.FedExError", '');
        } else{
            cmp.set("v.FedExError", 'Sales order in not Found');
        }
        if(SalesOrder != undefined){
            
            var packType = cmp.get("v.FEDEX_Services.PackageType");
            var packNo = cmp.get("v.FEDEX_Services.NoofPackage");
            var shipDate = cmp.get("v.FEDEX_Services.ShipmentDate");
            var action = cmp.get("c.FedServices");
            action.setParams({ 
                soId: SalesOrder,
                packType: packType,
                packNo: packNo,
                shipDate: shipDate
            });            
            action.setCallback(this, function(response) {
                var state = response.getState();	
                
                if (state === "SUCCESS") { 
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services.length > 0){
                        response.getReturnValue().Services[0].Selected = true;
                    }
                    
                    var FEDEXServices=[];
                    for(var i=0;i<5;i++){        
                        if(response.getReturnValue().Services[i] != undefined)
                        	FEDEXServices.push(response.getReturnValue().Services[i]);
                    }
                    if(FEDEXServices.length >0){
                        var shippingServices=cmp.get("v.shippingServices");
                        shippingServices.push(FEDEXServices);
                        cmp.set("v.shippingServices",shippingServices);
                        cmp.set("v.hideShipping",false);
                    }                    
                    //cmp.set("v.FEDEX_Services",FEDEXServices); 
                    //For checking FeDex service is working or not
                    cmp.set("v.FEDEX_Services",response.getReturnValue());
                    if(packType == null) cmp.find("packType1").set("v.options", response.getReturnValue().PackageTypes);
                    cmp.set("v.FEDEX_Services.PackageType",response.getReturnValue().PackageType);
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                }                
            });
            $A.enqueueAction(action);
        } 
    },
    
    setFieldsForUpdate : function(cmp,event){
        var addToDel=cmp.get("v.addToUpdate");
        var res=[];
        var addList=cmp.get("v.addList");
        for(var i=0; i<addList.length; i++){
            if(addToDel == addList[i].Id){
                res.push(addList[i]);
                break;
            }
        }
        cmp.set("v.Name",res[0].Name);
        cmp.set("v.addLine1",res[0].ERP7__Address_Line1__c);
        cmp.set("v.addLine2",res[0].ERP7__Address_Line2__c);
        cmp.set("v.addLine3",res[0].ERP7__Address_Line3__c);
        cmp.set("v.City",res[0].ERP7__City__c);
        cmp.set("v.CountrySel",res[0].ERP7__Country__c);                
        cmp.set("v.StateSel",res[0].ERP7__State__c);                    
        cmp.set("v.Zip",res[0].ERP7__Code__c);
        cmp.set("v.addId",res[0].Id); 
    },
    
    validatefields : function(cmp,event){
        
        var nameValid=false;
        var mobileValid=false;
        var add1Valid=false;
        var cityValid=false;
        var countryValid=false;
        var stateValid=false;
        var zipValid=false;
        
        var name=cmp.find("name");
        var nameValue=name.get("v.value");
        if(nameValue == undefined || nameValue ==''){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your name"
                });
                toastEvent.fire();
            nameValid=false;
        }else{
            nameValid=true;
        }
        
        /*if(nameValid){
            var inputMobile = cmp.find('mobile');
            var Mvalue = inputMobile.get('v.value');
            var mobileRegexFormat = /^\d{10}$/;
            if(Mvalue == undefined || Mvalue == ''){
                inputMobile.set("v.errors", [{message:"Please enter a valid mobile number"}]);
                mobileValid=false;
            }
            if(!Mvalue.match(mobileRegexFormat)){ 
                inputMobile.set("v.errors", [{message:"Please enter a valid mobile number"}]);
                mobileValid=false;
            }else{
                inputMobile.set("v.errors", null);
                mobileValid=true;
            }
        }*/
        
        if(nameValid){
            var add1=cmp.find("add1")
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter a valid Address"
                });
                toastEvent.fire();
                add1Valid=false;
            }else{
                add1Valid=true;
            }
        }
        
        if(add1Valid){
            var city=cmp.find("city");
            var cityValue=city.get("v.value");
            if(cityValue == undefined || cityValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your city"
                });
                toastEvent.fire();
                cityValid=false;
            }else{
                cityValid=true;
            }
        }
        
        if(cityValid){
            var country=cmp.find("country");
            var countryValue=country.get("v.value");
            if(countryValue == "--None--" || countryValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg1","Please select your Country");
                countryValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg1","");
                countryValid=true;
            }
        }
        
        if(countryValid){
            var state=cmp.find("state");
            var stateValue=state.get("v.value");
            if(stateValue == "--None--" || stateValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg","Please select your State");
                stateValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg","");
                stateValid=true;
            }
        }
        
        if(stateValid){
            var zip=cmp.find("zip");
            var zipValue=zip.get("v.value");
            if(zipValue == undefined || zipValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter zip code"
                });
                toastEvent.fire();
                zipValid=false;
            }else{
                zipValid=true;
            }
        }
        
        if(zipValid)
            return true;
        else
            return false;
    },
    
    validatefields1 : function(cmp,event){
        
        var nameValid=false;
        var mobileValid=false;
        var add1Valid=false;
        var cityValid=false;
        var countryValid=false;
        var stateValid=false;
        var zipValid=false;
        
        var name=cmp.find("newName11");
        var nameValue=name.get("v.value");
        if(nameValue == undefined || nameValue ==''){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your name"
                });
                toastEvent.fire();
            nameValid=false;
        }else{
            nameValid=true;
        }
        
        /*if(nameValid){
            var inputMobile = cmp.find('newMobile1');
            var Mvalue = inputMobile.get('v.value');
            var mobileRegexFormat = /^\d{10}$/;
            if(Mvalue == undefined || Mvalue == ''){
                inputMobile.set("v.errors", [{message:"Please enter a valid mobile number"}]);
                mobileValid=false;
            }
            if(!Mvalue.match(mobileRegexFormat)){ 
                inputMobile.set("v.errors", [{message:"Please enter a valid mobile number"}]);
                mobileValid=false;
            }else{
                inputMobile.set("v.errors", null);
                mobileValid=true;
            }
        }*/
        
        if(nameValid){
            var add1=cmp.find("newAdd11")
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter a valid Address"
                });
                toastEvent.fire();
                add1Valid=false;
            }else{
                add1Valid=true;
            }
        }
        
        if(add1Valid){
            var city=cmp.find("newCity1");
            var cityValue=city.get("v.value");
            if(cityValue == undefined || cityValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your city"
                });
                toastEvent.fire();
                cityValid=false;
            }else{
                cityValid=true;
            }
        }
        
        if(cityValid){
            var country=cmp.find("newCountry1");
            var countryValue=country.get("v.value");
            if(countryValue == "--None--" || countryValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg1","Please select your Country");
                countryValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg1","");
                countryValid=true;
            }
        }
        
        if(countryValid){
            var state=cmp.find("newState1");
            var stateValue=state.get("v.value");
            if(stateValue == "--None--" || stateValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg","Please select your State");
                stateValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg","");
                stateValid=true;
            }
        }
        
        if(stateValid){
            var zip=cmp.find("newZip1");
            var zipValue=zip.get("v.value");
            if(zipValue == undefined || zipValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter zip code"
                });
                toastEvent.fire();
                zipValid=false;
            }else{
                zipValid=true;
            }
        }
        
        if(zipValid)
            return true;
        else
            return false;
    },
    
    validateNewfields : function(cmp,event){
        var nameValid=false;
        var mobileValid=false;
        var add1Valid=false;
        var cityValid=false;
        var countryValid=false;
        var stateValid=false;
        var zipValid=false;
        
        var name=cmp.find("newName1");
        var nameValue=name.get("v.value");
        if(nameValue == undefined || nameValue ==''){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your name"
                });
                toastEvent.fire();
            nameValid=false;
        }else{
            nameValid=true;
        }
        if(nameValid){
            var inputMobile = cmp.find('newMobile');
            var Mvalue = inputMobile.get('v.value');
            var mobileRegexFormat = /^\d{10}$/;
            if(Mvalue == undefined || Mvalue == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter a valid mobile number"
                });
                toastEvent.fire();
                mobileValid=false;
            }
            if(!Mvalue.match(mobileRegexFormat)){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter a valid mobile number"
                });
                toastEvent.fire();
                mobileValid=false;
            }else{
                mobileValid=true;
            }
        }
        if(mobileValid){
            var add1=cmp.find("newAdd1")
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter a valid Address"
                });
                toastEvent.fire();
                add1Valid=false;
            }else{
                add1Valid=true;
            }
        }
        if(add1Valid){
            var city=cmp.find("newCity");
            var cityValue=city.get("v.value");
            if(cityValue == undefined || cityValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter your city"
                });
                toastEvent.fire();
                cityValid=false;
            }else{
                cityValid=true;
            }
        }
        if(cityValid){
            var country=cmp.find("newCountry");
            var countryValue=country.get("v.value");
            if(countryValue == "--None--" || countryValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg2","Please select your Country");
                countryValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg2","");
                countryValid=true;
            }
        }
        if(countryValid){
            var state=cmp.find("newState");
            var stateValue=state.get("v.value");
            if(stateValue == "--None--" || stateValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg3","Please select your State");
                stateValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg3","");
                stateValid=true;
            }
        }
        if(stateValid){
            var zip=cmp.find("newZip");
            var zipValue=zip.get("v.value");
            if(zipValue == undefined || zipValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Please enter zip code"
                });
                toastEvent.fire();
                zipValid=false;
            }else{
                zipValid=true;
            }
        }
        if(zipValid)
            return true;
        else
            return false;
    },
    
    showAddOnConfirmAndPay : function(cmp,event,addId){
        var addList=cmp.get("v.addList");
        for(var i=0;i<addList.length;i++){
            if(addList[i].Id == addId){
                cmp.set("v.showOneAddress",addList[i]);
                break;
            }
        }
    },
    
    saveAddToSO : function(cmp,event,SOId,addId){
        this.showAddOnConfirmAndPay(cmp,event,addId);
        var action=cmp.get("c.addAddrToSO");
        action.setParams({
            SOId:SOId,
            addId:addId
        });
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.showAddress",false);
                this.cartItems(cmp, event);
                //this.UPSServices1(cmp,event);
                //this.FedExServices(cmp,event);
            }
        });
        $A.enqueueAction(action);
    },
    saveAddToSO1 : function(cmp,event,SOId,addId){
        var action=cmp.get("c.addAddrToSO");
        action.setParams({
            SOId:SOId,
            addId:addId
        });
        $A.enqueueAction(action);
    },
    
})