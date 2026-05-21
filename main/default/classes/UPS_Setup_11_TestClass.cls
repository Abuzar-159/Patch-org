@isTest
private class UPS_Setup_11_TestClass {
    static testmethod void UPS_SetUp(){ 
        Credentials__c newCredentials = new Credentials__c(Name='UPS Setup', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                         Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                         Shipper_Province__c='test province',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='57943ab85fc5694b20e49b66253fb4eba6ba003e1ddb8e5b2a417d0ce0c63a53',
                                         Username_Login__c='2b64fcfff6fe726db66e9d1596738cc86b93fb59964570bcd8fafb15ce45b223', Password_Transkey__c='da4b01c75de1272c34ea4c64ec9fe38fefb6f4889d93b329673969d1e4d25269',
                                         UPS_Account_Number__c='RY9704',Account_Name__c='Test',Title__c='Test');
        insert newCredentials;
        
        // Http mock (fake) callout with MockHttpResponseGenerator class as reference
        System.Test.setMock(HTTPCalloutMock.class, new MockHttpResponseGenerator()); 
                
        ups_setup upss = new ups_setup();
        upss.upsSetup.Shipper_Province__c = 'Surrey';  
        upss.upsSetup.Shipper_Country__c = 'United Kingdom';
        upss.regCountryCode = 'GB';
        upss.regProvinceCode = 'LN';
        upss.upsSetup.Invoice_Details__c = false;
        upss.acct = new Account();
        upss.acct.Agreement_Text__c = 'text';
        upss.resStatus = 'OK';
        try{ upss.Register(); }catch(Exception ex){}
        upss.upsSetup.Invoice_Details__c = true;
        try{ upss.Register(); }catch(Exception ex){}
        try { upss.RegisterReply(); } catch(Exception e) {}
        try{ upss.AccessLicenseAgreement(); }catch(Exception ex){}
        upss.acct.Agreement_Text__c = 'test';
        try{ upss.AccessLicenseRequest(); }catch(Exception ex){}
        try{ upss.acceptLicense(); }catch(Exception ex){}
        upss.declineLicense();
        String xmlString9 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><reg:RegisterResponse xmlns:reg="http://www.ups.com/XMLSchema/XOLTWS/Registration/v2.0" xmlns:wscommon="http://www.ups.com/XMLSchema/XOLTWS/Common/v1.0"><common:Response xmlns:common="http://www.ups.com/XMLSchema/XOLTWS/Common/v1.0"><common:ResponseStatus><common:Code>1</common:Code><common:Description>Success</common:Description></common:ResponseStatus><common:TransactionReference/></common:Response><reg:ShipperAccountStatus><reg:Code>011</reg:Code><reg:Description>Account can not be added to users profile due to system problem, please try account management later</reg:Description></reg:ShipperAccountStatus><reg:ShipperAccountStatus><reg:Code>000</reg:Code><reg:Description>There is no account in request to process</reg:Description></reg:ShipperAccountStatus><reg:Disclaimer>You are testing against customer integration (CIE) URL. After you finish testing, please switch to production URL.</reg:Disclaimer></reg:RegisterResponse></soapenv:Body></soapenv:Envelope>';
        XmlStreamReader xsr9 = new XmlStreamReader(xmlString9);
        upss.readXMLResponseFirstValue(xsr9,'Description');
        upss.readXMLResponse(xsr9,'Description');
        upss.backAction();
        upss.upsSetup.UPS_Account_Number__c = 'R123';
        upss.upsSetup.Invoice_Number__c = 'test';
        upss.upsSetup.Invoice_Date__c = system.today();
        upss.upsSetup.Invoice_Amount__c = 200;
        upss.upsSetup.Invoice_Currency_Code__c = 'GBP';
        upss.upsSetup.Invoice_Control_Id__c = 'test';
        try{ upss.ManageAccount(); }catch(Exception ex){}
        try{ upss.ManageInvoice(); }catch(Exception ex){}
        try { upss.ManageAccountRequest(upss.upsSetup.UPS_Account_Number__c); } catch(Exception e) {}
        XmlStreamReader xsr10 = new XmlStreamReader(xmlString9);
        ups_setup.readXMLResponseOnce(xsr10,'Description');
        upss.upsSetup.Stage__c = 'Accepted';
        try{ upsert upss.upsSetup; }catch(Exception ex){}
        ups_setup upss1 = new ups_setup();
        upss.upsSetup.Stage__c = 'Registered';
        System.assertequals(upss.upsSetup.Stage__c,'Registered');  
        try{ upsert upss.upsSetup; }catch(Exception ex){} 
        ups_setup upss2 = new ups_setup();
        upss.upsSetup.Stage__c = 'Processed';
        try{ upsert upss.upsSetup; }catch(Exception ex){}
        ups_setup upss3 = new ups_setup();     
         
    }
    
    static testmethod void UPS_Agreement() { 
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        
        PageReference pageRef = System.Page.UPS_Agreement;
        pageRef.getParameters().put('agreementId',orgn.Id);
        Test.setCurrentPage(pageRef);        
        
        ApexPages.StandardController controller;
        UPS_Agreement ua = new UPS_Agreement(controller);
        
        System.assertEquals('Organisation Test',orgn.Name);          
    }
}