({
    after : function(component, event, helper){
        if(component.get("v.UserName1") != $A.get("$Label.c.Supplier_Community_Guest_User")) //"ERP Supplier Portal Community Site Guest User"
            component.set("v.PortalUser",true);
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    
    showdropdownmenu : function(component,event,helper){
        if(component.get("v.showdropdown")){
            component.set("v.showdropdown", false);
        }else component.set("v.showdropdown", true);
        
    },
    
    showSignIn: function(cmp, event, helper) {
        cmp.set("v.errMsg","");
        var Action = event.currentTarget.getAttribute('data-Action');
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", Action);
        
        if (Action == 'SignIn') cmp.set("v.ActionName", 'Sign In');
        else if (Action == 'Register') cmp.set("v.ActionName", 'Register an account');
        //else cmp.set("v.ActionName", 'Password Reset');
        component.set("v.Spinner", false);
    },
    hidereset:function(cmp, event, helper){
        cmp.set("v.forgotPassword",false);
    },
    eventHandle1:function(cmp, event, helper){
        
        if(event.getParam("hideRegister")){
            cmp.set("v.showSignIn", false);
            component.set("v.Spinner", false);
        }
        
        if(event.getParam("actionName") != undefined){
            if (event.getParam("actionName") == 'Password Reset') 
                cmp.set("v.ActionName", 'Password Reset');
            if(event.getParam("actionName") == 'Register'){
                //cmp.set("v.errMsg","");
                cmp.set("v.showSignIn", false);
                helper.showSignIn(cmp,event);
            }
            
        }
        
        
    },
    eventHandle2 : function(cmp,event,helper){
        //cmp.set("v.show", 'Register');
        if(event.getParam("actionName") != undefined){
            if (event.getParam("actionName") == 'Password Reset')
                cmp.set("v.ActionName", 'Password Reset');
            if(event.getParam("actionName") == 'Register'){
                cmp.set("v.show", 'Register');
            }
            else if(event.getParam("actionName") == 'SignIn'){
                cmp.set("v.show", 'login');
            }
            
        }
        if(event.getParam("hideRegister")){
        cmp.set("v.forgotPassword",false);
        }
        
    },
    initial : function(cmp, event, helper) {
      
        //cmp.set("v.PortalUser", true);
        
        helper.profile(cmp,event);
        
        /*         
        cmp.set("v.AccId","0011o00001U1SQ0AAN");
        if(cmp.get("v.AccId") != ""){
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({"AccId":cmp.get("v.AccId")});
            evt.fire();
        }*/
    },
    
    signIn : function(cmp, event, helper){
        cmp.set("v.errMsg","");
        cmp.set("v.mylabel1","");
        
        var urlReturn = helper.getParameterByName(cmp, event, 'returl');	//null
        urlReturn = window.location.href;	//current URL
        
        //community event content
        
        var validForm = cmp.find('FormVal').reduce(
            function(validSoFar,inputCmp) {
                // Displays error messages for invalid fields
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar &&
                    inputCmp.get(
                    'v.validity'
                ).valid;
            }, true);
        // If we pass error checking, do some real work
        if (validForm) {
            // Get the Username from Component
            var user = cmp.get(
                "v.Username");
            var Pass = cmp.get(
                "v.Password");
            
            var action = cmp.get("c.checkPortal");
            var showSecQuestion = cmp.get("v.askForSecurityQuestion");
            action.setParams({
                username: user,
                password: Pass,
                urlReturn: urlReturn,
                navigateToSec: showSecQuestion
            });
            // Add callback behavior for when response is received
            action.setCallback(this,function(response) {
                var state = response.getState();	
                var rtnValue = response.getReturnValue().url;
                var ndqn = response.getReturnValue().needQuestion;
                if (rtnValue.indexOf('failed') !== -1) {
                    
                    cmp.set("v.errMsg",rtnValue);
                    //cmp.set("v.showError",true);
                } else {
                    cmp.set("v.mainURL", rtnValue);
                    var showSequeriryQues = helper.needToGetASecurityQuestion(cmp, event, user);
                    //showSequeriryQues == true
                    if (showSequeriryQues == true && ndqn == true) {
                        helper.getSecurityQuestion(cmp, event, rtnValue);
                        
                    } else {
                        window.open(rtnValue, '_top');
                    }
                    
                }
            });
            
            $A.enqueueAction(action);            
        }        
    },
    
    verifySequrityQuestion: function(cmp, event, helper) {
        helper.verifySequrityQuestionAndProceed(cmp, event);
    },
    
    passwordReset :function(cmp, event, helper){        
        cmp.set("v.forgotPassword",true);
        var Action = event.currentTarget.getAttribute('data-Action');
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ actionName: "Password Reset"});
        evt.fire(); 
        //cmp.set("v.forgotPassword",true);
    },
    
    registerNow : function(cmp, event, helper){
        cmp.set("v.show", 'Register');
        /*var Action = event.currentTarget.getAttribute('data-Action');
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ actionName: Action});
        evt.fire();*/
    },
    
    submitresetPass: function(cmp, event, helper) {
        cmp.set("v.errMsg","");
        cmp.set("v.mylabel","");
        
        
        var validResetForm1 = cmp.find("FormReset").get("v.validity");
        // If we pass error checking, do some real work
        if (validResetForm1.valid) {
            var Reuser1 = cmp.get("v.ResetUsername");
            var action = cmp.get("c.forgotPassword");
            action.setParams({
                username: Reuser1
            });
            action.setCallback(this, function(response) {
                var rtnValue = response.getReturnValue();
                cmp.set("v.mylabel1",rtnValue);
                
                if (rtnValue !== null) {
                    cmp.set("v.errMsg",rtnValue);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    hideRegister : function(cmp, event, helper) {
        /*
        //var url = window.location.href;
        //window.open(url,"_self" );
        var evt = $A.get("c:ProductListCommEvent");
        evt.setParams({ hideRegister: true});
        evt.fire(); */
        cmp.set("v.show", 'login');
    },
    
    //validation of form
    registerUser : function(cmp, event, helper){
        cmp.set("v.RegistererrMsg","");
        var emailToRegister = cmp.get("v.RegisteremailInfo");
        if (emailToRegister.endsWith('erp.com'))
        {
            cmp.set("v.RegistererrMsg","For employees, if you are registering as a resident, please use your personal email.");
            return;
        }
        else{
            var fnameForm= cmp.find("firstName");
            var fnameValue = fnameForm.get("v.value");
            var lnameForm= cmp.find("lastName");
            var lnameValue = lnameForm.get("v.value");
            var eForm= cmp.find("emailAddress");
            var eValue = eForm.get("v.value");
            var ln='false';  var efrm='false';  var fn='false';  var check='false';  var emr='false';
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            
            if(!fnameValue){
                fn='true'; 
                fnameForm.set("v.errors", [{
                    message: "* Please enter your first name"                    
                }]);
            }
            if(fn=='false')
            {  fnameForm.set("v.errors", null);}
            if(!lnameValue){
                ln='true';
                lnameForm.set("v.errors", [{
                    message: "* Please enter your last name"                    
                }]);
            }
            if(ln=='false')
            {lnameForm.set("v.errors", null); }
            if(!eValue){
                efrm='true';
                eForm.set("v.errors", [{
                    message: "* Please enter your email address"                    
                }]);
            }
            if(efrm=='false')
            { eForm.set("v.errors", null);}
            if(eValue!=undefined && eValue!='' && eValue!=null){
                if(!eValue.match(regExpEmailformat)){
                    emr='true';
                    eForm.set("v.errors", [{
                        message: "Please enter a valid email address."
                    }]);
                }
            }
            if( emr=='false' && efrm=='false' ) {  eForm.set("v.errors", null); }
            if(fn=='false' && ln=='false' && efrm=='false' && emr=='false'){
                check='true'; 
            }
            
            if(check=='true'){
                var isConsentSelected = document.getElementById("acceptTerms").checked;
                if (!isConsentSelected)
                {
                    cmp.set("v.RegistererrMsg","Please agree Terms and conditions to proceed");
                }                
                if (isConsentSelected)
                {
                    helper.registerUser(cmp, event);
                }
            }
        }  
    },
    
    home :function(component, event, helper){
        component.set("v.revert",false);
        location.reload();
        var evt = $A.get("e.c:SupplierPortalCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
        /*$A.createComponent("c:SupplierPortalCommHome",{
            AccId:component.get("v.AccId")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
        });*/
    },
    getUserProfile: function(component,event,helper){
     /* component.set("v.revert",false);
                $A.createComponent( "c:UserProfile", {
        },
         function(newCmp) {
            if (component.isValid()) {
               var body = component.find("sldshide");
               body.set("v.body", newCmp);        
            }
         }
         );
        $A.enqueueAction(action);*/

    }
})