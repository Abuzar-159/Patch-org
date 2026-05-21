({
    hideRegister : function(cmp, event, helper) {
        //var url = window.location.href;
        //window.open(url,"_self" );
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ hideRegister: true});
        evt.fire(); 
    },
    
    //validation of form
    registerUser : function(cmp, event, helper){
        cmp.set("v.errMsg","");
        var emailToRegister = cmp.get("v.emailInfo");
        if (emailToRegister.endsWith('erp.com'))
        {
            cmp.set("v.errMsg","For employees, if you are registering as a resident, please use your personal email.");
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
                if (!isConsentSelected){
                    cmp.set("v.errMsg","Please agree Terms and conditions to proceed");
                }                
                if (isConsentSelected){
                    helper.registerUser(cmp, event);
                }
            }
        }  
    },
})