({
    initial : function(cmp,event,helper){
        var UserName;
        var action = cmp.get("c.getProfileId2");
        action.setCallback(this, function(response){
            var STATE=response.getState();
            if(STATE === "SUCCESS"){                
                var UserName = response.getReturnValue().name;
                cmp.set("v.UserRegProfName",UserName);
            }
        });
         $A.enqueueAction(action);
    },
    
    hideRegister : function(cmp, event, helper) {
        //var url = window.location.href;
        //window.open(url,"_self" );
        cmp.set("v.registerSuccess", false);
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ hideRegister: true});
        evt.fire(); 
    },
    
    SignInAction : function(cmp,event){
        var Action = event.currentTarget.getAttribute('data-Action');
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ actionName: Action});
        evt.fire();
    },
    
    //validation of form
    registerUser : function(cmp, event, helper){
        try{
            console.log('ars registerUser called');
            cmp.set("v.errMsg","");
            var emailToRegister = cmp.get("v.emailInfo");
            if (emailToRegister.endsWith('erp.com'))
            {
                cmp.set("v.errMsg","For employees, if you are registering as a resident, please use your personal email.");
                return;
            }
            else{
                console.log('ars registerUser 1');
                var fnameValue = cmp.get("v.firstNameInfo");
                var lnameValue = cmp.get("v.lastNameInfo");
                var eValue = cmp.get("v.emailInfo");
                console.log('here 1.5');
                var ln = false;  var efrm = false; var fn = false;  var check = false;  var emr = false;
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                
                console.log('here a');
                if(fnameValue == undefined || fnameValue == '' || fnameValue== null){
                    fn = true; 
                    cmp.set("v.errMsg",'*Please enter your first name');
                }
                else if(lnameValue == undefined || lnameValue == '' || lnameValue == null){
                    ln= true;
                    cmp.set("v.errMsg",'*Please enter your last name');
                }
                else if(eValue == undefined || eValue == '' || eValue == null){
                    efrm=true;
                    cmp.set("v.errMsg",'*Please enter your email address');
                }
                else if(eValue!=undefined || eValue!='' || eValue!=null){
                    if(!eValue.match(regExpEmailformat)){
                        emr=true;
                        cmp.set("v.errMsg",'*Please enter a valid email address');
                    }
                }
                if(!fn && !ln && !efrm && !emr){ check = true; }
                
                console.log('check is~>'+check);
                if(check){
                    console.log('ars registerUser 2');
                    var isConsentSelected = document.getElementById("acceptTerms").checked;
                    if (!isConsentSelected){
                        cmp.set("v.errMsg","Please agree Terms and conditions to proceed");
                    }                
                    if (isConsentSelected){
                        console.log('ars registerUser 3');
                        helper.registerUser(cmp, event);
                    }
                }else console.log('check false');
            }  
        }catch(e){
            console.log('error~>'+e);
        }
    },
})