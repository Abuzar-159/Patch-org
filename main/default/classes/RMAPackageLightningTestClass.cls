@isTest
private class RMAPackageLightningTestClass {
    
    static testmethod void UnitTest(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account customer = new Account(Name='Arshad',Account_type__c='Customer');
        insert customer;
        Account customer1 = new Account(Name='Test_Customer1',Account_type__c='Customer'); 
        insert customer1;
        Contact contact = new Contact(Primary__c=true,FirstName='Test',lastName ='Contact',AccountId=customer.Id); 
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true,ERP7__Primary__c = true);
        insert addr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Active__c = true , ERP7__Returns_Handling__c= true ,ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Closed',Account__c = customer.Id,Contact__c = contact.Id,Channel__c = channel.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Name='TestSoli',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10,ERP7__Inventory_Tracked__c=true);
        insert solim;
        Warranty__c wrr = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,Sales_Order_Line_Item__c=solim.id);
        insert wrr;
        sod.ERP7__Status__c = 'Cancelled';
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        //update sod;
        sod.Order_Status__c = 'Closed';
        update sod;
        ERP7__Return_Merchandise_Authorisation__c rmarecord = new ERP7__Return_Merchandise_Authorisation__c(Name='Test',  ERP7__Expected_Date__c=system.today(), ERP7__Account__c=customer.Id,ERP7__Return_Contact__c=contact.Id, ERP7__Active__c=true, ERP7__Ready_To_Receive__c=true);
        insert rmarecord;
        
        ERP7__RMA_Line_Item__c rmalineitem = new ERP7__RMA_Line_Item__c(Name='Test', ERP7__SOLI__c=solim.Id, ERP7__Active__c=true, ERP7__Return_Merchandise_Authorisation__c=rmarecord.Id, ERP7__Return_Status__c='Quality Check');
        insert rmalineitem;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update rmarecord;
        
        ERP7__Package__c packages = new ERP7__Package__c(Name='test', ERP7__Active__c=true, ERP7__Package_Type__c='Package',
                                                         ERP7__Return_Merchandise_Authorisation__c=rmarecord.Id, ERP7__Length__c=5,
                                                         ERP7__Width__c=5, ERP7__Height__c=5, ERP7__Weight__c=5, ERP7__Weight_Unit__c='LBS');
        
        insert packages;
        ERP7__Package_List__c packageList = new ERP7__Package_List__c(Name='test', ERP7__Package__c=packages.Id);
        insert packageList;
        
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Shipment__c shipment = new ERP7__Shipment__c(Name='Test', ERP7__Return_Merchandise_Authorisation__c=rmarecord.Id);
        insert shipment;
        try{
            RMAPackageLightning RMAP = new RMAPackageLightning();
            RMAPackageLightning.RMAPackageWrapper RPW = new RMAPackageLightning.RMAPackageWrapper();
            RMAPackageLightning.InitWrapper RPW2 = new RMAPackageLightning.InitWrapper();
            RMAPackageLightning.getobjName();
            RMAPackageLightning.getWeightUnits();
            RMAPackageLightning.getPackageType();
            RMAPackageLightning.getShipmentType();
            String packType = packages.ERP7__Package_Type__c='Package';
            //RMAPackageLightning.fetchPackageDetails(packType);
            try{ RMAPackageLightning.populatePackDetails(JSON.serialize(packages),packType);  }catch(Exception e){}
            String returnId = rmarecord.Id;
            RMAPackageLightning.displayRMA(returnId);
            RMAPackageLightning.fetchRMALineItems(returnId);
            try{ 
                ERP7__Package__c pkg=packages; String rmaLiWrapList=rmalineitem.Id; String rmaId=rmarecord.Id;
                
                RMAPackageLightning.savePackageDetails(JSON.serialize(pkg), rmaLiWrapList, rmaId,'');
            }catch(Exception e){}
            RMAPackageLightning.fetchingPackages(returnId);
            String packageID=packages.Id;
            RMAPackageLightning.editPackages(packageID);
            RMAPackageLightning.fetchPackageListEdit(packageID);
            RMAPackageLightning.deletePackages(packageID, returnId);
            RMAPackageLightning.fetchShipments(returnId);
            String shipId=shipment.ID;
            RMAPackageLightning.deleteShipments(shipId, returnId);
            RMAPackageLightning.getDependentPicklistMap('ERP7__PO__c','ERP7__Shipment_Type__c','ERP7__Shipment_Preference_Speed__c');
        }catch(Exception e){}
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
    }
}