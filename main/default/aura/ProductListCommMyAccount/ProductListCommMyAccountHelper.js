({
	initial : function(cmp, event) {
        var action=cmp.get("c.fetchAdd");
        action.setParams({
            accId : cmp.get("v.AccId"),
        });
        action.setCallback(this, function(response){
            var state=response.getState();		
            if(state==="SUCCESS"){
                cmp.set("v.Name",response.getReturnValue().acc.Name);
                //cmp.set("v.Email",response.getReturnValue().con.Email);
                cmp.set("v.Mobile",response.getReturnValue().con.MobilePhone);
                cmp.set("v.conId",response.getReturnValue().con.Id);
                cmp.set("v.State",response.getReturnValue().State);
                cmp.set("v.Country",response.getReturnValue().country);
                
                cmp.set("v.addDefault",response.getReturnValue().addPrimary);
                cmp.set("v.addBilling",response.getReturnValue().addBilling);
                cmp.set("v.addShipping",response.getReturnValue().addShipping);
                cmp.set("v.addAll",response.getReturnValue().addList);
                cmp.set("v.showContent",true);
                
                /*var res=response.getReturnValue().addPrimary;
               
                if(!(Object.keys(res).length === 0)){
                    cmp.set("v.Name1",res.Name);
                    cmp.set("v.addLine1",res.ERP7__Address_Line1__c);
                    cmp.set("v.addLine2",res.ERP7__Address_Line2__c);
                    cmp.set("v.addLine3",res.ERP7__Address_Line3__c);
                    cmp.set("v.City",res.ERP7__City__c);
                    cmp.set("v.CountrySel",res.ERP7__Country__c);                
                    cmp.set("v.StateSel",res.ERP7__State__c);                    
                    cmp.set("v.Zip",res.ERP7__Code__c);
                    cmp.set("v.addId",res.Id);                    
                }*/
            }
        });
        $A.enqueueAction(action);
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
                        'message': 'Please enter your name'
                    });
                    toastEvent.fire();
            nameValid=false;
        }else{
            nameValid=true;
        }
        
        if(nameValid){
            var inputMobile = cmp.find('mobile');
            var Mvalue = inputMobile.get('v.value');
            var mobileRegexFormat = /^\d{10}$/;
            if(Mvalue == undefined || Mvalue == ''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter a valid mobile number'
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
                        'message': 'Please enter a valid mobile number'
                    });
                    toastEvent.fire();
                mobileValid=false;
            }else{
                mobileValid=true;
            }
        }
        
        if(mobileValid){
            var add1=cmp.find("add1")
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter a valid Address'
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
                        'message': 'Please enter your city'
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
                        'message': 'Please enter zip code'
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
    
    validatefieldsBill : function(cmp,event){
              
        var nameValid=false;
        var mobileValid=false;
        var add1Valid=false;
        var cityValid=false;
        var countryValid=false;
        var stateValid=false;
        var zipValid=false;
        
        var name=cmp.find("bilname");
        var nameValue=name.get("v.value");
        if(nameValue == undefined || nameValue ==''){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter your name'
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
            var add1=cmp.find("biladd1");
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter a valid Address'
                    });
                    toastEvent.fire();
                add1Valid=false;
            }else{
                add1Valid=true;
            }
        }
        
        if(add1Valid){
            var city=cmp.find("bilcity");
            var cityValue=city.get("v.value");
            if(cityValue == undefined || cityValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter your city'
                    });
                    toastEvent.fire();
                cityValid=false;
            }else{
                cityValid=true;
            }
        }
        
        if(cityValid){
            var country=cmp.find("bilcountry");
            var countryValue=country.get("v.value");
            if(countryValue == "--None--" || countryValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg4","Please select your Country");
                countryValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg4","");
                countryValid=true;
            }
        }
        
        if(countryValid){
            var state=cmp.find("bilstate");
            var stateValue=state.get("v.value");
            if(stateValue == "--None--" || stateValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg5","Please select your State");
                stateValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg5","");
                stateValid=true;
            }
        }
        
        if(stateValid){
            var zip=cmp.find("bilzip");
            var zipValue=zip.get("v.value");
            if(zipValue == undefined || zipValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter zip code'
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
    
    validatefieldsShip : function(cmp,event){
              
        var nameValid=false;
        var mobileValid=false;
        var add1Valid=false;
        var cityValid=false;
        var countryValid=false;
        var stateValid=false;
        var zipValid=false;
        
        var name=cmp.find("sipname");
        var nameValue=name.get("v.value");
        if(nameValue == undefined || nameValue ==''){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter your name'
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
            var add1=cmp.find("sipadd1");
            var add1Value=add1.get("v.value");
            if(add1Value == undefined || add1Value ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter a valid Address'
                    });
                    toastEvent.fire();
                add1Valid=false;
            }else{
                add1Valid=true;
            }
        }
        
        if(add1Valid){
            var city=cmp.find("sipcity");
            var cityValue=city.get("v.value");
            if(cityValue == undefined || cityValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter your city'
                    });
                    toastEvent.fire();
                cityValid=false;
            }else{
                cityValid=true;
            }
        }
        
        if(cityValid){
            var country=cmp.find("sipcountry");
            var countryValue=country.get("v.value");
            if(countryValue == "--None--" || countryValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg6","Please select your Country");
                countryValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg6","");
                countryValid=true;
            }
        }
        
        if(countryValid){
            var state=cmp.find("sipstate");
            var stateValue=state.get("v.value");
            if(stateValue == "--None--" || stateValue == ""){               
                //state.set("v.errors", [{message:"Please select your State"}]);
                cmp.set("v.errorMsg7","Please select your State");
                stateValid=false;
            }else{
                //state.set("v.errors", null);
                cmp.set("v.errorMsg7","");
                stateValid=true;
            }
        }
        
        if(stateValid){
            var zip=cmp.find("sipzip");
            var zipValue=zip.get("v.value");
            if(zipValue == undefined || zipValue ==''){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter zip code'
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
        try{
        console.log('validateNewfields')
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
                        'message': 'Please enter your name'
                    });
                    toastEvent.fire();
            nameValid=false;
        }else{
            nameValid=true;           
        }
        if(nameValid){
            console.log('nameValid');
            var inputMobile = cmp.find('newMobile');
            var Mvalue = inputMobile.get('v.value');
            var mobileRegexFormat = /^\d{10}$/;
             
            if(Mvalue == undefined || Mvalue == ''){
                 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Please enter a valid mobile number'
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
                        'message': 'Please enter a valid mobile number'
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
                        'message': 'Please enter a valid Address'
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
                        'message': 'Please enter your city'
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
                        'message': 'Please enter zip code'
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
        }catch(e){
            console.log('err~>'+e);
        }
    },
    
    setFieldsForUpdate : function(cmp,event){
        var priAddToUpdate=cmp.get("v.priAddToUpdate");
        var res=[];
        var addList=cmp.get("v.addAll");
        for(var i=0; i<addList.length; i++){
            if(priAddToUpdate == addList[i].Id){
                res.push(addList[i]);
                break;
            }
        }
        cmp.find("name").set("v.value",res[0].Name);
        cmp.find("add1").set("v.value",res[0].ERP7__Address_Line1__c);
        cmp.find("add2").set("v.value",res[0].ERP7__Address_Line2__c);
        cmp.find("add3").set("v.value",res[0].ERP7__Address_Line3__c);
        cmp.find("city").set("v.value",res[0].ERP7__City__c);
        cmp.set("v.CountrySel",res[0].ERP7__Country__c);                
        cmp.set("v.StateSel",res[0].ERP7__State__c);                    
        cmp.find("zip").set("v.value",res[0].ERP7__Code__c);
        //cmp.set("v.addId",res[0].Id); 
    },
    
    setFieldsForUpdateBill : function(cmp,event){
        var billAddToUpdate=cmp.get("v.billAddToUpdate");
        var res=[];
        var addList=cmp.get("v.addAll");
        for(var i=0; i<addList.length; i++){
            if(billAddToUpdate == addList[i].Id){
                res.push(addList[i]);
                break;
            }
        }
        cmp.find("bilname").set("v.value",res[0].Name);
        cmp.find("biladd1").set("v.value",res[0].ERP7__Address_Line1__c);
        cmp.find("biladd2").set("v.value",res[0].ERP7__Address_Line2__c);
        cmp.find("biladd3").set("v.value",res[0].ERP7__Address_Line3__c);
        cmp.find("bilcity").set("v.value",res[0].ERP7__City__c);
        cmp.set("v.CountrySel",res[0].ERP7__Country__c);                
        cmp.set("v.StateSel",res[0].ERP7__State__c);                    
        cmp.find("bilzip").set("v.value",res[0].ERP7__Code__c);
        //cmp.set("v.addId",res[0].Id); 
    },
    
    setFieldsForUpdateShip : function(cmp,event){
        var shipAddToUpdate=cmp.get("v.shipAddToUpdate");
        var res=[];
        var addList=cmp.get("v.addAll");
        for(var i=0; i<addList.length; i++){
            if(shipAddToUpdate == addList[i].Id){
                res.push(addList[i]);
                break;
            }
        }
        cmp.find("sipname").set("v.value",res[0].Name);
        cmp.find("sipadd1").set("v.value",res[0].ERP7__Address_Line1__c);
        cmp.find("sipadd2").set("v.value",res[0].ERP7__Address_Line2__c);
        cmp.find("sipadd3").set("v.value",res[0].ERP7__Address_Line3__c);
        cmp.find("sipcity").set("v.value",res[0].ERP7__City__c);
        cmp.set("v.CountrySel",res[0].ERP7__Country__c);                
        cmp.set("v.StateSel",res[0].ERP7__State__c);                    
        cmp.find("sipzip").set("v.value",res[0].ERP7__Code__c);
        //cmp.set("v.addId",res[0].Id); 
    },
    
    EditCloseModal: function(cmp, event) {
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        //this.initial(cmp, event);
    },
})