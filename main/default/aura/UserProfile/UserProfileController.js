({
    doInit : function(component, event, helper) {     
        var action=component.get("c.getUserDetails");
        action.setParams({UserName:component.get("v.UserEmail")})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.UserName',response.getReturnValue().username);
                component.set('v.SQ',response.getReturnValue().SecurityQuestions); 
                component.set('v.PortalUser',response.getReturnValue().PortalUser); 
                component.set('v.imageURL',response.getReturnValue().imageURL); 
                component.set('v.allSecQues1',response.getReturnValue().optns);
                component.set('v.allSecQues2',response.getReturnValue().SQ2); 
                component.set('v.SQForPassword',response.getReturnValue().SQForPassword); 
                component.set('v.SAForPassword',response.getReturnValue().SAForPassword); 
                component.set('v.changeSPN',response.getReturnValue().isActive);
            }
            else{
            }
        });
        $A.enqueueAction(action); 
    },
    
    changeQuestions:function(component, event, helper) {
        component.set('v.showSQ',false);
        component.set('v.showallSQ',true);
        
        component.find("SecQ1").set("v.options", component.get('v.allSecQues1'));
        component.find("SecQ2").set("v.options", component.get('v.allSecQues2'));
    },
    
    saveQuestions:function(component, event, helper) {
        var sq2ans=component.find('SQ2Ans');
        var sq1ans=component.find('SQ1Ans');
        var sq1ansValue = sq1ans.get("v.value");
        var sq2ansValue = sq2ans.get("v.value");
        
         if(!sq1ansValue){
            sq1ans.set("v.errors", [{
                message: "* Enter the Answer For Security Question 1"
            }]);
        }
        else if(!sq2ansValue){
            sq1ans.set("v.errors", null);
            sq2ans.set("v.errors", [{
                message: "* Enter the Answer For Security Question 2"
            }]);
        }
       else{
            sq2ans.set("v.errors", null);
            var action=component.get("c.updateSecurityQuestions");
           action.setParams({
               SQ1:component.get('v.selSQ1'), 
               SQ2:component.get('v.selSQ2'),
               SQAns1:sq1ansValue,
               SQAns2:sq2ansValue,
               UserName:component.get("v.UserEmail")
           });
            action.setCallback(this,function(response){
                               var state = response.getState();
                               if(state === "SUCCESS"){
                                 component.set('v.SQ',response.getReturnValue().SecurityQuestions);
                                 component.set('v.showSQ',true); 
                                 component.set('v.showallSQ',false);
                                 component.set('v.selSQ1',undefined);
                                 component.set('v.selSQ2',undefined);
                                
                               }else{
                               }
                           });
             $A.enqueueAction(action);
           
            }
    },
    DeactivateUser:function(component,event,helper){
        var action=component.get('c.deactivateUser');
        action.setCallback(this,function(response){
           var state=response.getState();
            if(state==="SUCCESS"){
                var staticLabel = $A.get("$Label.c.SiteURL");
                window.history.back();
                //window.open('/secur/logout.jsp?startURL='+staticLabel, '_top');
            }else{
            } 
        });
        $A.enqueueAction(action);
    },
    subscribe:function(component,event,helper){
         var action=component.get("c.updateSPNCheckbox");
            action.setParams({
                subsActive:component.get('v.changeSPN'),
            });
             action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS"){
                               }else{
                               }
                           });
        $A.enqueueAction(action);
                     
    },
    showChangePass:function(component,event,helper){
        component.set('v.showPass',false);
        component.set('v.EditPass',true);
        
    },
    updatePass:function(component,event,helper){
        var SQAns=component.find('SQAns');
        var SQAnsValue=SQAns.get("v.value");
        var oldPass=component.find('OP');
        var oldPassValue=oldPass.get('v.value');
        var match=false;
        var Npass =component.find('NP');
        var VNPass=component.find('VFNP'); 
        var NpassValue="";
        NpassValue=Npass.get("v.value");
        var VNPassValue="";
        VNPassValue=VNPass.get("v.value");
        
        var oldBoolean=false;var secAnsBoolean=false;
          if(!oldPassValue){
            oldBoolean=true;   
            oldPass.set("v.errors", [{
                message: "* Enter the Old Password."
            }]);
        }
        if(!SQAnsValue){
            secAnsBoolean=true;
            SQAns.set("v.errors", [{
                message: "* Enter the Security Answer."
            }]);
        }
        
        if(!NpassValue){
            Npass.set("v.errors", [{
                message: "* Enter a password."
            }]);
        }
        else if(NpassValue.length<8){
                Npass.set("v.errors", [{
                message: "* Use 8 characters or more for your password."
            }]);
        } else  if(!VNPassValue){
            Npass.set("v.errors", null);
            VNPass.set("v.errors", [{
                message: "* The passwords didn't match. Try again."
            }]);
        }else if(VNPassValue === NpassValue){
            Npass.set("v.errors", null);
            VNPass.set("v.errors", null);
            match=true;
        }
        if(oldBoolean==false)oldPass.set("v.errors", null);
        if(secAnsBoolean==false)SQAns.set("v.errors", null);
        if(match==true && oldBoolean==false && secAnsBoolean==false){
            if(SQAnsValue!=component.get('v.SAForPassword')){
                
                component.set('v.errmsg','Security answer did not matched.')
            }else{
            var action=component.get("c.updatePassword");
            action.setParams({
                newPass:NpassValue,
                verifyNewPass:VNPassValue,
                oldPass:oldPassValue,
            });
             action.setCallback(this,function(response){
                               var state = response.getState();
                               if(state === "SUCCESS"){
                                   if(response.getReturnValue().errmsg!=''){
                                        
                                        var s = response.getReturnValue().errmsg.replace(/System.SecurityException: /g," ");
                                        component.set("v.errmsg",s);
                                       
                                   }else{
                                        component.set("v.ShowTM",true);
                                        component.set("v.message",'Change Password successfully');
                                       setTimeout(
                                           $A.getCallback(function() {
                                               component.set("v.ShowTM",false);
                                           }), 3000
                                       );
                                       component.set('v.showPass',true);
       							        component.set('v.EditPass',false);
                                   }
                               }
                               else{
                               }
                           });
            $A.enqueueAction(action);
            }
        }else{
             VNPass.set("v.errors", [{
                message: "* The passwords didn't match. Try again."
            }]);
        }
      
        
        
    },
    CancelPassword:function(component,event,helper){
        component.set('v.errmsg',undefined);
        component.set('v.showPass',true);
        component.set('v.EditPass',false);
        
    },
    CancelQuestions:function(component,event,helper){
        component.set('v.showallSQ',false);
        component.set('v.showSQ',true);
        
    },
    hideNotification:function(component,event,helper){
        component.set('v.ShowTM',false);
    },
    CancelPopup:function(component,event,helper){
        component.set('v.isOpen',false);
    },
    openPopup:function(component,event,helper){
        component.set('v.isOpen',true);
    },
    
    goBack:function(component, event, helper){
        window.history.back();
    },
    
})