public With Sharing class InternalShipmentLightning {
    public InternalShipmentLightning(){ }
    
    @AuraEnabled 
    public static Contact getShiptoContact(String packId){
        system.debug('--> inside getShiptoContact packageId is :' +packId);
         List<String> pakIds = new List<String>();
        if(String.isNotEmpty(packId)) pakIds = (List<String>) JSON.deserialize(packId, List<String> .class);
        if(pakIds.size()>0){
            ERP7__Package__c packages = new ERP7__Package__c();
            contact con = new contact();
            packages = [Select Id, Name,ERP7__Order__c,ERP7__Order__r.ERP7__Contact__c,ERP7__Order__r.ERP7__Contact__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.ERP7__Contact__c,ERP7__Sales_Order__r.ERP7__Contact__r.Name,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.ERP7__Contact__c,ERP7__Transfer_Order__r.ERP7__Contact__r.Name,ERP7__Return_Merchandise_Authorisation__c ,ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__r.Name from ERP7__Package__c where Id IN:pakIds limit 1];
            if(packages != null){
                system.debug('packages.ERP7__Order__c : '+packages.ERP7__Order__c);
                if(packages.ERP7__Order__c != null) {system.debug('packages.ERP7__Order__r.ERP7__Contact__c : '+packages.ERP7__Order__r.ERP7__Contact__c); if(packages.ERP7__Order__r.ERP7__Contact__c != null) { con = [Select Id,Name from Contact where Id=:packages.ERP7__Order__r.ERP7__Contact__c]; system.debug('con : '+con); return con; } else return null; }
                else if(packages.ERP7__Sales_Order__c != null) { if(packages.ERP7__Sales_Order__r.ERP7__Contact__c != null) { con = [Select Id,Name from Contact where Id=:packages.ERP7__Sales_Order__r.ERP7__Contact__c]; return con; } else return null; }
                else if(packages.ERP7__Transfer_Order__c != null) { if(packages.ERP7__Transfer_Order__r.ERP7__Contact__c != null) { con = [Select Id,Name from Contact where Id=:packages.ERP7__Transfer_Order__r.ERP7__Contact__c]; return con; } else return null; } else if(packages.ERP7__Return_Merchandise_Authorisation__c != null) { if(packages.ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c != null) { con = [Select Id,Name from Contact where Id=:packages.ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c]; return con; } else return null; } else return null;
            }
            else return null;
        }
        else return null;
    }
    
    @AuraEnabled
    public static wrapper initSetUp1(List<String> packageID, String shipmentid){
        /*'packageID=>'+packageID+' *** shipmentid=>'+shipmentid); */
        wrapper wrapper=new Wrapper();
        /* Visibility Control */
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){
                wrapper.showDimension = FC.ERP7__Show_Dimensions_in_internal_shipment__c;
                wrapper.hideShipment = FC.ERP7__Hide_shipment_section_in_outbound__c;//Asra 10/4/24
            }
        Schema.DescribeFieldResult fieldResultCntry = ERP7__Shipment__c.ERP7__Package_Weight_Unit__c.getDescribe();
        List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
        for(Schema.PicklistEntry f: cntry) {
            wrapper.WeightUnit.add(new SelectOptions(f.getValue(), f.getLabel()));
        }
         fieldResultCntry = ERP7__Shipment__c.ERP7__Dimension__c.getDescribe();
        cntry = fieldResultCntry.getPicklistValues();
        for(Schema.PicklistEntry f: cntry) {
            wrapper.DimensionUnit.add(new SelectOptions(f.getValue(), f.getLabel()));
        }
        try{
            if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}   
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Identification_Number__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}  
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipping_Amount__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}  
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Admin_Shipping_Amount__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}  
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Declared_Value__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}  
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Description__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}  
            
            if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Transportation_Allocation__c.isAccessible()){wrapper.renderFields.add(true);} else{wrapper.renderFields.add(false);} 
            if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Shipping_point__c.isAccessible()){wrapper.renderFields.add(true);} else{wrapper.renderFields.add(false);} 
            if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Loading_point__c.isAccessible()){wrapper.renderFields.add(true);} else{wrapper.renderFields.add(false);} 
            if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Description__c.isAccessible()){wrapper.renderFields.add(true);} else{wrapper.renderFields.add(false);} 
            
            if(Schema.sObjectType.Shipment__c.fields.Shipment_Type__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.UPS_Package_Type__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Declared_Value__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Invoice_Number__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Tax_Number__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Bill_Number__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Carrier_Forwarder__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Purchase_Orders__c.isAccessible()){wrapper.renderFields.add(true);}else{wrapper.renderFields.add(false);}
            
            /*'packageID==>'+packageID+' package size '+packageID.size()+', shipmentid==> '+shipmentid);*/
            
            if( packageID.size() == 0 ){  
                wrapper.fetchPackage=[Select Id, Name, ERP7__Package_Quantity__c, ERP7__Dimension__c,ERP7__Weight__c,Return_Merchandise_Authorisation__c,Logistic__r.Sales_Order__c,Logistic__r.ERP7__Order_S__c,ERP7__Transfer_Order__r.ERP7__Customer_Name__c,ERP7__Transfer_Order__r.ERP7__Expected_Date__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.Name,
                                      ERP7__Weight_Unit__c,ERP7__Shipment__c, ERP7__Length__c,ERP7__Order__c ,ERP7__Sales_Order__c,ERP7__Order__r.Name,ERP7__Order__r.OrderNumber ,ERP7__Sales_Order__r.Name, ERP7__Width__c, ERP7__Height__c, ERP7__Package_Type__c,ERP7__Purchase_Order__c,
                                      ERP7__Declared_Value__c,ERP7__Logistic__c,ERP7__Order__r.ERP7__Expected_Date__c ,ERP7__Sales_Order__r.ERP7__Expected_Date__c,ERP7__Order__r.ERP7__Customer_Name__c, ERP7__Sales_Order__r.ERP7__Customer_Name__c  FROM  ERP7__Package__c where ERP7__Shipment__c=:shipmentid];
                
            }
            
            if( packageID.size() > 0) { 
                wrapper.fetchPackage=[Select Id, ERP7__Dimension__c,Name, ERP7__Package_Quantity__c, ERP7__Weight__c,Return_Merchandise_Authorisation__c,Logistic__r.Sales_Order__c,Logistic__r.ERP7__Order_S__c,ERP7__Transfer_Order__r.ERP7__Customer_Name__c,ERP7__Transfer_Order__r.ERP7__Expected_Date__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.Name,
                                      ERP7__Weight_Unit__c, ERP7__Length__c,ERP7__Order__c,ERP7__Sales_Order__c,ERP7__Order__r.Name ,ERP7__Order__r.OrderNumber ,ERP7__Sales_Order__r.Name, ERP7__Width__c, ERP7__Height__c, ERP7__Package_Type__c,ERP7__Purchase_Order__c,
                                      ERP7__Declared_Value__c,ERP7__Logistic__c,ERP7__Order__r.ERP7__Expected_Date__c ,ERP7__Sales_Order__r.ERP7__Expected_Date__c,ERP7__Order__r.ERP7__Customer_Name__c ,ERP7__Sales_Order__r.ERP7__Customer_Name__c  FROM  ERP7__Package__c where Id IN : packageID];
                
            }
            /*'fetchPackage=>'+wrapper.fetchPackage.size()); */
            set<String> packageIDS = new Set<string>();   
            if(wrapper.fetchPackage.size()>0 && packageID.size() == 0 ){ for(ERP7__Package__c p : wrapper.fetchPackage) packageIDS.add(p.Id); }   
            if(wrapper.fetchPackage.size()>0){
                /*'wrapper.fetchPackage[0].ERP7__Purchase_Order__c  : '+wrapper.fetchPackage[0].ERP7__Purchase_Order__c );*/
                if(wrapper.fetchPackage[0].ERP7__Purchase_Order__c != null){wrapper.showPO = false;}
                if(packageID.size() > 0){
                    List<packWrapper> pcwrp = new List<packWrapper>();
                    List<ERP7__Package_List__c> pklst=[Select Id,ERP7__Active__c,ERP7__Order_Product__r.Product2.Name , ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__RemaingQuantity__c,
                                                       ERP7__Order_Product__r.Quantity ,ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c,ERP7__Delivered_Quantity__c,ERP7__Status__c,
                                                       ERP7__MRP_Material_Requirement_Planning__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__r.Name,
                                                       ERP7__RMA_Line_Item__r.ERP7__Product__r.Name, ERP7__RMA_Line_Item__r.ERP7__Quantity_Return__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Transfer_Order_Line_Item__r.ERP7__Products__r.Name
                                                       From ERP7__Package_List__c where ERP7__Package__c IN : packageID];
                    for(ERP7__Package_List__c pc : pklst){ pcwrp.add(new packWrapper(pc,false)); }
                    wrapper.packageList = pcwrp;
                    
                }
                else if( packageIDS.size() > 0 ){ List<packWrapper> pcwrp = new List<packWrapper>(); List<ERP7__Package_List__c> pklst=[Select Id,ERP7__Active__c,ERP7__Order_Product__r.Product2.Name ,ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__RemaingQuantity__c, ERP7__Order_Product__r.Quantity , ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c,ERP7__Delivered_Quantity__c,ERP7__Status__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__r.Name, ERP7__RMA_Line_Item__r.ERP7__Product__r.Name, ERP7__RMA_Line_Item__r.ERP7__Quantity_Return__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Transfer_Order_Line_Item__r.ERP7__Products__r.Name From ERP7__Package_List__c where ERP7__Package__c IN : packageIDS]; for(ERP7__Package_List__c pc : pklst){ pcwrp.add(new packWrapper(pc,false)); } wrapper.packageList = pcwrp; }
            } 
            
            Set<String> checkDelivered=new Set<String>();   
            for(integer i=0;i<wrapper.packageList.size();i++){if(wrapper.packageList[i].pack.ERP7__Status__c!=null){ checkDelivered.add(wrapper.packageList[i].pack.ERP7__Status__c); }}
            if(checkDelivered.contains('Item(s) Missing')) {wrapper.hideDeliveredTab=false;} 
            /*size===>'+checkDelivered.size()+checkDelivered);   */
            if(checkDelivered.size()==0 || checkDelivered.size()<wrapper.packageList.size()){wrapper.hideDeliveredTab=false;}
            
            String toAddressId = ''; String fromAddressId = '';    
            List<ERP7__Return_Merchandise_Authorisation__c> fetchRma = new List<ERP7__Return_Merchandise_Authorisation__c>();
            /*'wrapper.fetchPackage[0].ERP7__Logistic__c : '+wrapper.fetchPackage[0].ERP7__Logistic__c);*/
            if(wrapper.fetchPackage.size()>0){
                if(wrapper.fetchPackage[0].ERP7__Logistic__c != null){
                    List<ERP7__Logistic__c> fetchlogistic=[Select Id,ERP7__From_Address__c,ERP7__To_Address__c From ERP7__Logistic__c where Id=:wrapper.fetchPackage[0].ERP7__Logistic__c ];       
                    if(fetchlogistic[0].ERP7__To_Address__c != null) toAddressId = fetchlogistic[0].ERP7__To_Address__c;
                    if(fetchlogistic[0].ERP7__From_Address__c != null) fromAddressId = fetchlogistic[0].ERP7__From_Address__c;
                    wrapper.isSoliPresent = True;
                } else if(wrapper.fetchPackage[0].ERP7__Return_Merchandise_Authorisation__c != null){ fetchRma = [Select Id, ERP7__Address__c, ERP7__Site__c,ERP7__Site__r.ERP7__Address__c From ERP7__Return_Merchandise_Authorisation__c where Id=:wrapper.fetchPackage[0].ERP7__Return_Merchandise_Authorisation__c ]; if(fetchRma[0].ERP7__Site__c != null){ if(fetchRma[0].ERP7__Site__r.ERP7__Address__c != null) toAddressId = fetchRma[0].ERP7__Site__r.ERP7__Address__c; } if(fetchRma[0].ERP7__Address__c != null) fromAddressId = fetchRma[0].ERP7__Address__c; wrapper.isSoliPresent = False; }  
            }
            if(String.isNotEmpty(fromAddressId)){
                wrapper.fromaddress = [Select Id, Name, ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Customer__r.ERP7__Company__c, ERP7__Contact__c, ERP7__Active__c,ERP7__Is_Shipping_Address__c, ERP7__Is_Billing_Address__c, ERP7__Address_Line1__c,ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c,
                                       ERP7__State__c, ERP7__Postal_Code__c, ERP7__Contact__r.ERP7__Company__c, ERP7__Contact__r.Name,ERP7__Contact__r.phone,ERP7__Contact__r.Email From ERP7__Address__c where Id=:fromAddressId]; 
            }
            /*wrapper.fromaddress : '+wrapper.fromaddress);*/
            if(String.isNotEmpty(toAddressId)){
                wrapper.toaddress = [Select Id, Name, ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Customer__r.ERP7__Company__c, ERP7__Contact__c, ERP7__Active__c,ERP7__Is_Shipping_Address__c, ERP7__Is_Billing_Address__c, ERP7__Address_Line1__c,ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c,
                                     ERP7__State__c, ERP7__Postal_Code__c, ERP7__Contact__r.ERP7__Company__c, ERP7__Contact__r.Name, ERP7__Contact__r.Email,ERP7__Contact__r.phone From ERP7__Address__c where Id=:toAddressId];
            }
            /*wrapper.toaddress : '+wrapper.toaddress);*/
            if(shipmentid!=null){   
                wrapper.shipment=[Select Id,Name,ERP7__Shipment_Date__c,ERP7__Dimension__c,ERP7__Length__c,ERP7__Width__c,ERP7__Height__c,ERP7__Package_Weight__c,ERP7__Package_Weight_Unit__c,ERP7__Status__c,ERP7__Tax_Number__c,ERP7__Invoice_Number__c,ERP7__Bill_Number__c,ERP7__Shipment_Type__c,ERP7__Shipment_Delivery_Date__c,ERP7__Supplier__c,
                                  ERP7__Tracking_Number__c,ERP7__TrackingNumber__c,ERP7__Shipment_Identification_Number__c,ERP7__Shipping_Amount__c,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__c,
                                  ERP7__Admin_Shipping_Amount__c,ERP7__Declared_Value__c,ERP7__Description__c,ERP7__Received_By__c,ERP7__Carrier_Forwarder__c,ERP7__Carrier_Forwarder__r.Name,ERP7__UPS_Package_Type__c,ERP7__Product_Unit_Code__c
                                  From ERP7__Shipment__c where Id=:shipmentid]; 
                /*'wrapper.shipment[0].ERP7__Purchase_Orders__c : '+wrapper.shipment[0].ERP7__Purchase_Orders__c);*/
                if(wrapper.shipment[0].ERP7__Purchase_Orders__c != null)  {wrapper.showPO = false;}
                Id pickupRT = ERP7.RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment_Flow__c','Pickup');
                Id DropOffRT = ERP7.RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment_Flow__c','DropOff');
                Id DeliveryRT = ERP7.RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment_Flow__c','Delivery');
                
                List<ERP7__Shipment_Flow__c> SFD=new List<ERP7__Shipment_Flow__c>(); 
                if(shipmentid != null && shipmentid != '' ){SFD=[Select Id From ERP7__Shipment_Flow__c  where ERP7__Shipment__c=:wrapper.shipment[0].Id  and RecordTypeId=:DeliveryRT];} 
                if(SFD.size()>=1){wrapper.Delivered=False;}  
                if(shipmentid != null && shipmentid != '' ){  
                    wrapper.allSF=[Select Id,Name,ERP7__Time__c,ERP7__Shipment_Flow_Status__c From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:wrapper.shipment[0].Id ];
                    
                    wrapper.pickupshipmentFlow=[Select Id,Name,ERP7__Shipment_Flow_Status__c,Shipment__c,ERP7__Transportation_Allocation__c,ERP7__Time__c,ERP7__Shipping_point__c,ERP7__Description__c 
                                                From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:wrapper.shipment[0].Id  and RecordTypeId=:pickupRT];  
                    wrapper.pickupshipmentFlow=null;
                    wrapper.deliveryshipmentFlow=[Select Id,Name,ERP7__Shipment_Flow_Status__c,Shipment__c,ERP7__Transportation_Allocation__c,ERP7__Time__c,ERP7__Shipping_point__c,ERP7__Description__c 
                                                  From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:wrapper.shipment[0].Id  and RecordTypeId=:DeliveryRT];  
                    
                    wrapper.dropoffshipmentFlow=[Select Id,Name,ERP7__Shipment_Flow_Status__c,Shipment__c,ERP7__Transportation_Allocation__c,ERP7__Time__c,ERP7__Shipping_point__c,ERP7__Description__c 
                                                 From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:wrapper.shipment[0].Id  and RecordTypeId=:DropOffRT];  
                    String name='Signature - '+wrapper.shipment[0].Name;
                    
                    wrapper.Attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:wrapper.shipment[0].Id AND Name=:name  Order By CreatedDate Asc]; 
                    
                } 
            }
            
            if(shipmentid==null || shipmentid==''){
                /*'wrapper.fetchPackage.size() : '+wrapper.fetchPackage.size());*/
                if(wrapper.fetchPackage.size()>0){ ERP7__Shipment__c ship=new ERP7__Shipment__c(); ship.ERP7__Shipment_Date__c=(System.now()).Date() ; if(wrapper.fetchPackage[0].ERP7__Sales_Order__c != null){ ship.ERP7__Received_By__c=wrapper.fetchPackage[0].ERP7__Sales_Order__r.ERP7__Customer_Name__c; ship.Name=wrapper.fetchPackage[0].ERP7__Sales_Order__r.Name; ship.ERP7__Shipment_Delivery_Date__c=wrapper.fetchPackage[0].ERP7__Sales_Order__r.ERP7__Expected_Date__c; } else if(wrapper.fetchPackage[0].ERP7__Order__c != null){ ship.ERP7__Received_By__c=wrapper.fetchPackage[0].ERP7__Order__r.ERP7__Customer_Name__c; ship.Name=wrapper.fetchPackage[0].ERP7__Order__r.Name; ship.ERP7__Order__c = wrapper.fetchPackage[0].ERP7__Order__c; ship.ERP7__Shipment_Delivery_Date__c=wrapper.fetchPackage[0].ERP7__Order__r.ERP7__Expected_Date__c; } else if(wrapper.fetchPackage[0].ERP7__Transfer_Order__c != null){ ship.ERP7__Received_By__c=wrapper.fetchPackage[0].ERP7__Transfer_Order__r.ERP7__Customer_Name__c; ship.Name=wrapper.fetchPackage[0].ERP7__Transfer_Order__r.Name; ship.ERP7__Shipment_Delivery_Date__c=wrapper.fetchPackage[0].ERP7__Transfer_Order__r.ERP7__Expected_Date__c; ship.ERP7__Transfer_Order__c = wrapper.fetchPackage[0].ERP7__Transfer_Order__c; } else if(wrapper.fetchPackage[0].ERP7__Return_Merchandise_Authorisation__c != null && wrapper.toaddress.size() > 0){ if(wrapper.toaddress[0].ERP7__Contact__c != null) ship.ERP7__Received_By__c = wrapper.toaddress[0].ERP7__Contact__r.Name; } /*'ship.ERP7__Purchase_Orders__c : '+ship.ERP7__Purchase_Orders__c);*/ ship.ERP7__Purchase_Orders__c = wrapper.fetchPackage[0].ERP7__Purchase_Order__c; wrapper.shipment.add(ship); } 
            }  
            if(wrapper.fetchPackage.size()>0){
                Decimal totalLength = 0;
                Decimal totalWidth = 0;
                Decimal totalheight = 0;
                Decimal  totalWeight = 0;
                for(ERP7__Package__c pack : wrapper.fetchPackage){ totalLength += pack.ERP7__Length__c; totalWidth += pack.ERP7__Width__c; totalheight += pack.ERP7__Height__c; totalWeight += pack.ERP7__Weight__c; } 
                wrapper.shipment[0].ERP7__Length__c = totalLength; wrapper.shipment[0].ERP7__Width__c = totalWidth; wrapper.shipment[0].ERP7__Height__c = totalheight; wrapper.shipment[0].ERP7__Package_Weight__c = totalWeight; wrapper.shipment[0].ERP7__Package_Weight_Unit__c = wrapper.fetchPackage[0].ERP7__Weight_Unit__c; wrapper.shipment[0].ERP7__Dimension__c = wrapper.fetchPackage[0].ERP7__Dimension__c;
            }
            wrapper.shipmentTypePicklist.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Shipment__c.ERP7__Shipment_Type__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {wrapper.shipmentTypePicklist.add(f.getLabel());} wrapper.packageTypePicklist.add('--None--'); Schema.DescribeFieldResult fieldResult2 = ERP7__Shipment__c.UPS_Package_Type__c.getDescribe(); List<Schema.PicklistEntry> packageple = fieldResult2.getPicklistValues(); for (Schema.PicklistEntry f: packageple) {wrapper.packageTypePicklist.add(f.getLabel());} wrapper.productUnitPicklist.add('--None--'); Schema.DescribeFieldResult fieldResult3 = ERP7__Shipment__c.ERP7__Product_Unit_Code__c.getDescribe(); List<Schema.PicklistEntry> punitcodeple = fieldResult3.getPicklistValues(); for (Schema.PicklistEntry f: punitcodeple) {wrapper.productUnitPicklist.add(f.getLabel());} wrapper.SFSPicklist.add('--None--'); Schema.DescribeFieldResult fieldResult5 = ERP7__Shipment_Flow__c.ERP7__Shipment_Flow_Status__c.getDescribe(); List<Schema.PicklistEntry> sfsple = fieldResult5.getPicklistValues(); for (Schema.PicklistEntry f: sfsple) {wrapper.SFSPicklist.add(f.getLabel());} wrapper.pckListStatus.add('--None--'); Schema.DescribeFieldResult fieldResult6 = ERP7__Package_List__c.ERP7__Status__c.getDescribe(); List<Schema.PicklistEntry> pckstatus = fieldResult6.getPicklistValues(); for (Schema.PicklistEntry f: pckstatus) {wrapper.pckListStatus.add(f.getLabel());} Schema.DescribeFieldResult fieldResult7 = ERP7__Package_List__c.ERP7__Status__c.getDescribe(); List<Schema.PicklistEntry> ple7 = fieldResult7.getPicklistValues(); for (Schema.PicklistEntry f: ple7) { wrapper.pckLstSts.add(new selectOptions(f.getLabel(), f.getValue())); } wrapper.pckLstStatus.add(new selectOptions('Delivered','Delivered')); for(integer i=0;i<=wrapper.pckListStatus.size()-1;i++){ if(wrapper.pckListStatus[i]!='Delivered'){ wrapper.pckLstStatus.add(new selectOptions(wrapper.pckListStatus[i], wrapper.pckListStatus[i])); } } wrapper.SSPicklist.add('--None--'); Schema.DescribeFieldResult fieldResult4 = ERP7__Shipment__c.ERP7__Status__c.getDescribe(); List<Schema.PicklistEntry> ssple = fieldResult4.getPicklistValues(); wrapper.shipmentStageOption.add(new selectOptions('--None--','')); for (Schema.PicklistEntry f: ssple) { wrapper.SSPicklist.add(f.getLabel()); wrapper.shipmentStageOption.add(new selectOptions(f.getLabel(), f.getValue())); }
            
            for(integer i=0;i<=wrapper.shipmentTypePicklist.size()-1;i++){ wrapper.STPickList.add(new selectOptions(wrapper.shipmentTypePicklist[i], wrapper.shipmentTypePicklist[i])); }
            
            for(integer i=0;i<=wrapper.SFSPicklist.size()-1;i++){ wrapper.SFSPKLST.add(new selectOptions(wrapper.SFSPicklist[i], wrapper.SFSPicklist[i])); }
            
            if(shipmentid!=null){ wrapper.Notes = [Select Id, Title, ParentId From Note Where ParentId=:shipmentid Order By CreatedDate Asc]; wrapper.allAttachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:shipmentid Order By CreatedDate Asc]; }
            /* 'attach===>'+wrapper.allAttachments);
'Notes===>'+wrapper.Notes);
'shipment===>'+wrapper.shipment);
'wrapper===>'+wrapper);*/
            Wrapper.DT=System.now(); 
        }catch(Exception e){ /*'Error  at : '+e.getLineNumber()+' Message : '+e.getMessage());*/ wrapper.errMsg =' Error at : '+e.getLineNumber()+' Message : '+e.getMessage();}
        return wrapper;   
    }
    
    @AuraEnabled
    public static wrapper saveTheShipment(String selShp,String toAddress1,String fromaddress1, String Packages1){
        Wrapper wrapper=new Wrapper();
        try{
            List<ERP7__Address__c> toAddress = new List<ERP7__Address__c>();
            if(String.isNotEmpty(toAddress1)) toAddress = (List<ERP7__Address__c>) JSON.deserialize(toAddress1,list<ERP7__Address__c> .class); 
            List<ERP7__Address__c> fromaddress = new List<ERP7__Address__c>();
            if(String.isNotEmpty(fromaddress1)) fromaddress = (List<ERP7__Address__c>) JSON.deserialize(fromaddress1,list<ERP7__Address__c> .class); 
            List<ERP7__Package__c> Packages = new List<ERP7__Package__c>();
            if(String.isNotEmpty(Packages1)) Packages = (List<ERP7__Package__c>) JSON.deserialize(Packages1,list<ERP7__Package__c> .class); 
            
            List<ERP7__Shipment__c> selShipment = new List<ERP7__Shipment__c>();
            if(String.isNotEmpty(selShp)) selShipment = (List<ERP7__Shipment__c>) JSON.deserialize(selShp,list<ERP7__Shipment__c> .class);    
            
            ERP7__Shipment__c Shipment=new ERP7__Shipment__c();ERP7__Address__c toAddrss=new ERP7__Address__c();ERP7__Address__c fromaddrss=new ERP7__Address__c();
            if(toAddress.size()>0){ toAddrss=toAddress[0]; if(Schema.sObjectType.ERP7__Address__c.isUpdateable()) { update toAddrss; } else{ } }
            if(fromaddress.size()>0){ fromaddrss=fromaddress[0]; if(Schema.sObjectType.ERP7__Address__c.isUpdateable()) {  update fromaddrss; } else{ } }
            /*'selShipment==>'+selShipment+'selShipment[0].ERP7__TrackingNumber__c;  : '+selShipment[0].ERP7__TrackingNumber__c);'shipment==>'+shipment);*/
            Id intershippingRTID; intershippingRTID = Schema.SObjectType.ERP7__Shipment__c.getRecordTypeInfosByDeveloperName().get('Shipping').getRecordTypeId();
            
            if(selShipment.size()>0){
                if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; } else{}       
                if(toAddress.size()>0){
                    if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = toAddress[0].Id; }   else{}                      
                    if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Shipment.Customer__c == Null) { Shipment.Customer__c = toAddress[0].Customer__c; } else{}
                    if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = toAddress[0].Contact__c; } else{}
                    if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = toAddress[0].Id; }   else{} 
                }
                system.debug('selShipment[0].ERP7__Status__c : '+selShipment[0].ERP7__Status__c);
                if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = (selShipment[0].ERP7__Status__c == null) ? 'Shipped' : selShipment[0].ERP7__Status__c; }             else{}   //Shipment.Status__c = 'Shipped';           
                if(intershippingRTID != null){
                    if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable()) { Shipment.RecordTypeId = intershippingRTID; } else{}
                }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Date__c.isUpdateable()) { shipment.ERP7__Shipment_Date__c=selShipment[0].ERP7__Shipment_Date__c; } else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Delivery_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Delivery_Date__c.isUpdateable()) { shipment.ERP7__Shipment_Delivery_Date__c=selShipment[0].ERP7__Shipment_Delivery_Date__c;} else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isUpdateable()) { shipment.ERP7__TrackingNumber__c=selShipment[0].ERP7__TrackingNumber__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Identification_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Identification_Number__c.isUpdateable()) { shipment.ERP7__Shipment_Identification_Number__c=selShipment[0].ERP7__Shipment_Identification_Number__c;} else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Shipping_Amount__c.isUpdateable()) { shipment.ERP7__Shipping_Amount__c=selShipment[0].ERP7__Shipping_Amount__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Admin_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Admin_Shipping_Amount__c.isUpdateable()) { shipment.ERP7__Admin_Shipping_Amount__c=selShipment[0].ERP7__Admin_Shipping_Amount__c;} else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Declared_Value__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Declared_Value__c.isUpdateable()) {  shipment.ERP7__Declared_Value__c=selShipment[0].ERP7__Declared_Value__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Description__c.isUpdateable()) { shipment.ERP7__Description__c=selShipment[0].ERP7__Description__c;} else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Invoice_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Invoice_Number__c.isUpdateable()) { shipment.ERP7__Invoice_Number__c=selShipment[0].ERP7__Invoice_Number__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Tax_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Tax_Number__c.isUpdateable()) { shipment.ERP7__Tax_Number__c=selShipment[0].ERP7__Tax_Number__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Bill_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Bill_Number__c.isUpdateable()) { shipment.ERP7__Bill_Number__c=selShipment[0].ERP7__Bill_Number__c; } else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Carrier_Forwarder__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Carrier_Forwarder__c.isUpdateable()) { shipment.ERP7__Carrier_Forwarder__c = selShipment[0].ERP7__Carrier_Forwarder__c;} else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Purchase_Orders__c.isUpdateable()) { shipment.ERP7__Purchase_Orders__c = selShipment[0].ERP7__Purchase_Orders__c;} else{}
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Shipment_Type__c.isUpdateable()) { shipment.ERP7__Shipment_Type__c = selShipment[0].ERP7__Shipment_Type__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__UPS_Package_Type__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__UPS_Package_Type__c.isUpdateable()) { shipment.ERP7__UPS_Package_Type__c = selShipment[0].ERP7__UPS_Package_Type__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.ERP7__Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Product_Unit_Code__c.isUpdateable()) { shipment.ERP7__Product_Unit_Code__c = selShipment[0].ERP7__Product_Unit_Code__c; } else{ }
                if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { shipment.Name=selShipment[0].Name; } else{ }
                if(selShipment[0].Id!=null){ Shipment.Id=selShipment[0].Id; }
            }
            Decimal totalPackQty = 0;
            if(Packages.size()>0){
                for(ERP7__Package__c pK : Packages) {
                    system.debug('ERP7__Package_Quantity__c : '+pK.ERP7__Package_Quantity__c);
                    totalPackQty += pK.ERP7__Package_Quantity__c;
                }
                if(Packages[0].Logistic__c!= null) {//recordIdMap.get('LO') != null
                    if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) { Shipment.Logistic__c =Packages[0].Logistic__c;} else{ } // recordIdMap.get('LO');
                    if(Packages[0].Logistic__r.Sales_Order__c != null){
                        if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) { Shipment.Sales_Order__c = Packages[0].Logistic__r.Sales_Order__c; } else{ }                             
                    }
                    if(Packages[0].Logistic__r.ERP7__Order_S__c != null){
                        if(Schema.sObjectType.Shipment__c.fields.Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Order__c.isUpdateable()) { Shipment.Order__c = Packages[0].Logistic__r.ERP7__Order_S__c;   } else{ }                          
                    }
                    
                } else //if(recordIdMap.get('SR') != null) 
                {
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'SR-Shipment'; } else{ }
                    if(Packages[0].Return_Merchandise_Authorisation__c != null){
                        if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) { Shipment.Return_Merchandise_Authorisation__c = Packages[0].Return_Merchandise_Authorisation__c;} else{ }//recordIdMap.get('SR');
                    }
                    if(Packages[0].Sales_Order__c != null){
                        if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) { Shipment.Sales_Order__c = Packages[0].Sales_Order__c;} else{ }
                    }
                    if(Packages[0].ERP7__Order__c != null){
                        if(Schema.sObjectType.Shipment__c.fields.Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Order__c.isUpdateable()) { Shipment.Order__c = Packages[0].ERP7__Order__c;    } else{ }                         
                    }
                }
            }
            if(Schema.sObjectType.Shipment__c.fields.ERP7__Total_Package_items__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Total_Package_items__c.isUpdateable())  Shipment.ERP7__Total_Package_items__c = totalPackQty;
            if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;  upsert Shipment; }
            
            wrapper.SSPicklist.add('--None--');
            Schema.DescribeFieldResult fieldResult4 = ERP7__Shipment__c.ERP7__Status__c.getDescribe();
            List<Schema.PicklistEntry> ssple = fieldResult4.getPicklistValues(); 
            wrapper.shipmentStageOption.add(new selectOptions('--None--',''));
            for (Schema.PicklistEntry f: ssple) {
                wrapper.SSPicklist.add(f.getLabel());
                wrapper.shipmentStageOption.add(new selectOptions(f.getLabel(), f.getValue()));
            }
            
            String shipmentId = '';
            if(Shipment.Id!=null) shipmentId=  Shipment.Id;
            if(String.isNotEmpty(shipmentId)){
                Shipment =   [Select Id,Name,ERP7__Shipment_Date__c,ERP7__Status__c,ERP7__Shipment_Type__c,ERP7__Shipment_Delivery_Date__c,ERP7__Supplier__c,
                              ERP7__Tracking_Number__c,ERP7__TrackingNumber__c,ERP7__Shipment_Identification_Number__c,ERP7__Shipping_Amount__c,ERP7__Carrier_Forwarder__c,ERP7__Purchase_Orders__c,
                              ERP7__Admin_Shipping_Amount__c,ERP7__Declared_Value__c,ERP7__Description__c,ERP7__UPS_Package_Type__c,ERP7__Product_Unit_Code__c,ERP7__Received_By__c 
                              From ERP7__Shipment__c where Id=:shipmentId]; 
                
                for(Package__c pac : Packages) { 
                    if(Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) pac.Shipment__c = Shipment.Id;
                    if(Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) pac.Status__c = Shipment.Status__c;
                   // if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable()) pac.Tracking_Number__c = Shipment.Tracking_Number__c;
                    
                } 
            }
            if(Packages.size() > 0) { if(Schema.sObjectType.Package__c.isUpdateable()) {  update Packages; } else{ } }
            
            // Adding below code to assign tracking number in sales order.
            ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c();
            Order Ord = new Order();
            if(Packages.size()>0){
                if(Packages[0].Sales_Order__c!=null){
                    if(Packages[0].Sales_Order__r.Id!=null){
                        SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c,ERP7__Total_Logistic_Quantity__c,ERP7__Shipped_QuantityR__c,ERP7__Status__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(Packages[0].Sales_Order__r.Id) + '\') Limit 1');
                    }
                    if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()){ SalesOrder.ERP7__Tracking_Number__c = Shipment.ERP7__TrackingNumber__c; } else{ } 
                    if(Packages[0].Sales_Order__r.Id!=null && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){
                        if(SalesOrder.ERP7__Total_Logistic_Quantity__c == SalesOrder.ERP7__Shipped_QuantityR__c && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable()){ SalesOrder.ERP7__Status__c='Shipped'; } else{ }
                        if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { update SalesOrder; }else{ }
                    }
                    else{
                        
                    }
                }
               
                
                // Adding below code to assign tracking number in Standard order.
                if(Packages[0].ERP7__Order__c!=null){
                    if(Packages[0].ERP7__Order__r.Id!=null){ Ord = Database.query('select Id, Name, ERP7__Shipped_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,ERP7__Tracking_Number__c,Status from Order where (Id =\'' + String.escapeSingleQuotes(Packages[0].ERP7__Order__r.Id) + '\') Limit 1'); if(Schema.sObjectType.Order.fields.ERP7__Tracking_Number__c.isUpdateable()) { Ord.ERP7__Tracking_Number__c = Shipment.ERP7__TrackingNumber__c; } else{ }
                                                            system.debug('Shipment.ERP7__Status__c : '+Shipment.ERP7__Status__c);
                                                            if(Ord.ERP7__Total_Logistic_Quantity_U__c == Ord.ERP7__Shipped_Quantity__c && Schema.sObjectType.Order.fields.Status.isUpdateable()) { Ord.Status= Shipment.ERP7__Status__c; } else{ }
                                                             system.debug('Ord.Status : '+Ord.Status);
                                                            if(Schema.sObjectType.Order.isUpdateable()) {update Ord;}else{ } }//Ord.Status='Shipped';
                }
                if(Packages[0].Sales_Order__c == null && Packages[0].ERP7__Order__c  == null && Packages[0].ERP7__Logistic__c != null){ List<ERP7__Logistic_Line_Item__c> loglist = [Select Id,Name,ERP7__Order_Product__r.OrderId,ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = : Packages[0].ERP7__Logistic__c]; set<Id> standOrder = new set<Id>(); set<Id> SalesOrderIds = new set<Id>(); for(ERP7__Logistic_Line_Item__c log : loglist){ if(log.ERP7__Order_Product__r.OrderId != null ) standOrder.add(log.ERP7__Order_Product__r.OrderId); else if(log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != null) SalesOrderIds.add(log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c); } if(standOrder.size() > 0){ List<Order> ordList = Database.query('select Id, Name, ERP7__Shipped_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,ERP7__Tracking_Number__c,Status from Order where Id In :standOrder Limit 1'); for(Order so : ordList){ so.ERP7__Tracking_Number__c = Shipment.ERP7__TrackingNumber__c; if(so.ERP7__Total_Logistic_Quantity_U__c == so.ERP7__Shipped_Quantity__c) so.Status='Shipped'; } update ordList; } if(SalesOrderIds.size() > 0){ List<ERP7__Sales_Order__c> salesorders = Database.query('select Id, Name, ERP7__Tracking_Number__c,ERP7__Total_Logistic_Quantity__c,ERP7__Shipped_QuantityR__c,ERP7__Status__c from ERP7__Sales_Order__c where Id In:SalesOrderIds Limit 1'); for(ERP7__Sales_Order__c so : salesorders){ so.ERP7__Tracking_Number__c = Shipment.ERP7__TrackingNumber__c; if(so.ERP7__Total_Logistic_Quantity__c == so.ERP7__Shipped_QuantityR__c) so.ERP7__Status__c='Shipped'; } update salesorders; } }
            }
            if(String.isNotEmpty(shipmentId)){
                wrapper.shipment=[Select Id,Name,ERP7__Shipment_Date__c,ERP7__Tax_Number__c,ERP7__Status__c,ERP7__Bill_Number__c,ERP7__Invoice_Number__c,ERP7__Shipment_Type__c,ERP7__Shipment_Delivery_Date__c,ERP7__Supplier__c,
                                  ERP7__Tracking_Number__c,ERP7__TrackingNumber__c,ERP7__Shipment_Identification_Number__c,ERP7__Shipping_Amount__c,ERP7__Carrier_Forwarder__c,ERP7__Purchase_Orders__c,
                                  ERP7__Admin_Shipping_Amount__c,ERP7__Declared_Value__c,ERP7__Description__c,ERP7__Received_By__c,ERP7__UPS_Package_Type__c,ERP7__Product_Unit_Code__c
                                  From ERP7__Shipment__c where Id=:shipmentId];
            }
            if(wrapper.shipment.size()>0){ if(wrapper.shipment[0].ERP7__Purchase_Orders__c != null) { wrapper.showPO = false;} else{ wrapper.showPO = true; } } else{ wrapper.showPO = true; }
            //if(wrapper.shipment[0].Id != null && wrapper.shipment[0].Id != '') 
            if(wrapper.shipment.size()>0 && Packages.size()>0) {
                if(Packages[0].ERP7__Sales_Order__c != null) wrapper.shipment[0].ERP7__Received_By__c=Packages[0].ERP7__Sales_Order__r.ERP7__Customer_Name__c;
                if(Packages[0].ERP7__Order__c != null) wrapper.shipment[0].ERP7__Received_By__c=Packages[0].ERP7__Order__r.ERP7__Customer_Name__c;
            }
            Wrapper.DT=system.now();
        }catch (Exception e){ system.debug('Error Occured : '+e.getLineNumber()+ ' Message : '+e.getMessage()); wrapper.errMsg = 'Error Occured : '+e.getLineNumber()+ ' Message : '+e.getMessage();  }
        return wrapper;
    }
    
    @AuraEnabled
    public static wrapper saveSF(String pupSF,String recordType,String selShipment1,String imageData ,String SelPackage1,Boolean CreateLogistic){
        Wrapper wrapper=new Wrapper();
        try{
            List<ERP7__Shipment__c> selShipment = new  List<ERP7__Shipment__c>();
            if(String.isNotEmpty(selShipment1)) selShipment = (List<ERP7__Shipment__c>) JSON.deserialize(selShipment1, List<ERP7__Shipment__c>.class);
            List<ERP7__Package__c> SelPackage = new List<ERP7__Package__c>();
            if(String.isNotEmpty(SelPackage1)) SelPackage = (List<ERP7__Package__c>) JSON.deserialize(SelPackage1, List<ERP7__Package__c>.class);
            set<Id> SelPackageIds = new  set<Id>();
            String pid = '';
            
            if(SelPackage.size()>0){
                for(ERP7__Package__c p : SelPackage) SelPackageIds.add(p.id); 
                pid = SelPackage[0].Id;
            }
            
            if(CreateLogistic){
                List<ERP7__Package_List__c> pckg=[Select Id,ERP7__Status__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__r.Name,ERP7__Logistic_Line_Item__c,ERP7__Delivered_Quantity__c from ERP7__Package_List__c where ERP7__Package__c IN : SelPackageIds];
                Set<String> loloids=new Set<String>();
                for(ERP7__Package_List__c pkglist : pckg ) loloids.add(pkglist.ERP7__Logistic_Line_Item__c);
                
                List<ERP7__Logistic_Line_Item__c> LOLIS=[Select Id,ERP7__Packed_Quantity__c,ERP7__Shipped_Quantity__c,ERP7__DeliveredQuantity__c From ERP7__Logistic_Line_Item__c where Id in: loloids ];
                for(integer i=0;i<LOLIS.size();i++ ){
                    if(pckg[i].ERP7__Status__c=='Item(s) Missing'){ if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Packed_Quantity__c.isUpdateable()) LOLIS[i].ERP7__Packed_Quantity__c   = pckg[i].ERP7__Delivered_Quantity__c; if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__DeliveredQuantity__c.isUpdateable()) LOLIS[i].ERP7__DeliveredQuantity__c = pckg[i].ERP7__Delivered_Quantity__c; if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Quantity__c.isUpdateable()) pckg[i].ERP7__Quantity__c = pckg[i].ERP7__Delivered_Quantity__c; }
                    /*if(pckg[i].ERP7__Status__c=='Delivered' && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__DeliveredQuantity__c.isUpdateable()){ 
                        if(LOLIS[i].ERP7__DeliveredQuantity__c==null)LOLIS[i].ERP7__DeliveredQuantity__c=0;
                        LOLIS[i].ERP7__DeliveredQuantity__c += pckg[i].ERP7__Delivered_Quantity__c;
                    }*/
                }
                PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;
                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()){ update LOLIS;} else{ wrapper.errMsg = 'User cannot update logistic linitem';} 
                if(Schema.sObjectType.ERP7__Package_List__c.isUpdateable()) { update pckg; } else{ wrapper.errMsg = 'User cannot update packlists';}
            }
            
            List<ERP7__Shipment_Flow__c> pickupSF = new List<ERP7__Shipment_Flow__c>();
            if(String.isNotEmpty(pupSF)) pickupSF = (List<ERP7__Shipment_Flow__c>) JSON.deserialize(pupSF,list<ERP7__Shipment_Flow__c> .class); 
            
            ERP7__Shipment_Flow__c PSF = new ERP7__Shipment_Flow__c();
            if(pickupSF.size()>0) PSF = pickupSF[0];
            
            Id RT; if(String.isNotEmpty(recordType)) RT = Schema.SObjectType.ERP7__Shipment_Flow__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            if(RT != null) PSF.RecordTypeId=RT;
            if(PSF.Shipment__c == null){ PSF.Shipment__c=selShipment[0].Id; }
            
            ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c();
            Order Ord = new Order();
            if(SelPackage.size()>0){
                if(SelPackage[0].Sales_Order__r.Id!=null){ SalesOrder = Database.query('select Id, Name,ERP7__Status__c,ERP7__Shipped_QuantityR__c,ERP7__Total_Logistic_Quantity__c, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(SelPackage[0].Sales_Order__r.Id) + '\') Limit 1');
                }
                if(SelPackage[0].ERP7__Order__r.Id!=null){ Ord = Database.query('select Id, Name, Status, ERP7__Total_Logistic_Quantity_U__c,ERP7__Shipped_Quantity__c,ERP7__Tracking_Number__c from Order where (Id =\'' + String.escapeSingleQuotes(SelPackage[0].ERP7__Order__r.Id) + '\') Limit 1');
                }
                if(SelPackage[0].Sales_Order__c == null && SelPackage[0].ERP7__Order__c  == null && SelPackage[0].ERP7__Logistic__c != null){
                    List<ERP7__Logistic_Line_Item__c> loglist = [Select Id,Name,ERP7__Order_Product__r.OrderId,ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = : SelPackage[0].ERP7__Logistic__c]; set<Id> standOrder = new set<Id>(); set<Id> SalesOrderIds = new set<Id>(); for(ERP7__Logistic_Line_Item__c log : loglist){ if(log.ERP7__Order_Product__r.OrderId != null ) standOrder.add(log.ERP7__Order_Product__r.OrderId); else if(log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != null) SalesOrderIds.add(log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c); }
                    system.debug('standOrder : '+standOrder);
                    system.debug('recordType : '+recordType);
                    if(standOrder.size() > 0){ List<Order> ordList = Database.query('select Id, Name, ERP7__Shipped_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,ERP7__Tracking_Number__c,Status from Order where Id In :standOrder Limit 1'); for(Order so : ordList){ if(so.ERP7__Total_Logistic_Quantity_U__c == so.ERP7__Shipped_Quantity__c){ if(recordType=='Delivery') so.Status='Delivered';  else so.Status='Picked Up'; } } update ordList; }
                    
                    if(SalesOrderIds.size() > 0){ List<ERP7__Sales_Order__c> salesorders = Database.query('select Id, Name, ERP7__Tracking_Number__c,ERP7__Total_Logistic_Quantity__c,ERP7__Shipped_QuantityR__c,ERP7__Status__c from ERP7__Sales_Order__c where Id In:SalesOrderIds Limit 1'); for(ERP7__Sales_Order__c so : salesorders){ if(so.ERP7__Total_Logistic_Quantity__c == so.ERP7__Shipped_QuantityR__c ){ if(recordType=='Delivery') so.ERP7__Status__c='Delivered';  else so.ERP7__Status__c='Picked Up'; } } update salesorders; }
                }
            }
            if(recordType=='Delivery'){
                if(Schema.sObjectType.ERP7__Shipment__c.fields.ERP7__Status__c.isUpdateable()) selShipment[0].ERP7__Status__c='Delivered'; 
                wrapper.Delivered=False;
                if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Shipment_Flow__c.fields.Name.isUpdateable()) PSF.Name=selShipment[0].Name+selShipment[0].ERP7__Received_By__c;
                if(Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Shipment_Flow_Status__c.isCreateable() && Schema.sObjectType.ERP7__Shipment_Flow__c.fields.ERP7__Shipment_Flow_Status__c.isUpdateable()) PSF.ERP7__Shipment_Flow_Status__c='Delivered'; 
                for(ERP7__Package__c p : SelPackage) if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Status__c.isUpdateable()) p.ERP7__Status__c='Delivered';
            }
            else{
                if(SelPackage[0].Sales_Order__r.Id!=null && (SalesOrder.ERP7__Total_Logistic_Quantity__c == SalesOrder.ERP7__Shipped_QuantityR__c) && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable())  SalesOrder.ERP7__Status__c='Picked Up'; else if(SelPackage[0].ERP7__Order__r.Id!=null && (Ord.ERP7__Total_Logistic_Quantity_U__c == Ord.ERP7__Shipped_Quantity__c) && Schema.sObjectType.Order.fields.Status.isUpdateable())   Ord.Status='Picked Up';
                if(Schema.sObjectType.ERP7__Shipment__c.fields.ERP7__Status__c.isUpdateable()) selShipment[0].ERP7__Status__c='Picked Up';
                for(ERP7__Package__c p : SelPackage) if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Status__c.isUpdateable()) p.ERP7__Status__c='Picked Up';
            }
            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; 
            
            if(SelPackage[0].Sales_Order__r.Id!=null && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){ update SalesOrder; } else{ wrapper.errMsg = 'User is not allowed to update salesorder';}
            if(SelPackage[0].ERP7__Order__r.Id!=null && Schema.sObjectType.Order.fields.Status.isUpdateable()){ update Ord; } else{ wrapper.errMsg = 'User is not allowed to update order'; }
            if(Schema.sObjectType.ERP7__Shipment_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Shipment_Flow__c.isUpdateable()) { upsert PSF; } else{wrapper.errMsg = 'uers cannot update shipment flow';}
            if(Schema.sObjectType.ERP7__Shipment__c.isUpdateable()) { update selShipment; }  else{ }
            if(Schema.sObjectType.ERP7__Package__c.isUpdateable()) { update SelPackage; } else{ }
            
            List<ERP7__Logistic__c> logistic = new List<ERP7__Logistic__c>();
            if(SelPackage.size()>0) if(SelPackage[0].ERP7__Logistic__c != null) logistic=[Select Id from ERP7__Logistic__c where id=:SelPackage[0].ERP7__Logistic__c ];
            List<ERP7__Package__c> allpckgs = new List<ERP7__Package__c>();
            if(logistic.size()>0) if(logistic[0].Id != null) allpckgs =[Select id,ERP7__Status__c from ERP7__Package__c where ERP7__Logistic__c=:logistic[0].Id];
            integer count=0;
            if(allpckgs.size()>0){
                for(ERP7__Package__c pck : allpckgs){
                    if(pck.ERP7__Status__c=='Delivered'){
                        count=count+1;
                    }
                }
            } 
            /*'count==>'+count+' ,allpckgs size==>'+allpckgs.size());*/
            if(count==allpckgs.size()){ 
                PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; 
                
                if(SelPackage[0].Sales_Order__c != null){
                    SalesOrder=[select Id, Name,ERP7__Status__c, ERP7__Total_Logistic_Quantity__c, ERP7__Shipped_QuantityR__c,ERP7__Tracking_Number__c from ERP7__Sales_Order__c where Id =: SelPackage[0].Sales_Order__c  Limit 1]; 
                    if(SalesOrder.ERP7__Total_Logistic_Quantity__c == SalesOrder.ERP7__Shipped_QuantityR__c && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable()) SalesOrder.ERP7__Status__c='Delivered';
                    
                    if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { update SalesOrder; } else{ }
                }
                if(SelPackage[0].ERP7__Order__c != null){
                    Ord=[select Id, Name,Status, ERP7__Total_Logistic_Quantity_U__c,ERP7__Shipped_Quantity__c,ERP7__Tracking_Number__c from Order where Id =: SelPackage[0].ERP7__Order__c  Limit 1]; if(Ord.ERP7__Total_Logistic_Quantity_U__c == Ord.ERP7__Shipped_Quantity__c && Schema.sObjectType.Order.fields.Status.isUpdateable()) Ord.Status='Delivered'; system.debug('Ord.Status : '+Ord.Status); update Ord;
                   // if(Schema.sObjectType.Order.isUpdateable()) { update Ord; }else{}
                }
            }
            wrapper.allSF=[Select Id,Name,ERP7__Time__c,ERP7__Shipment_Flow_Status__c From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:selShipment[0].Id  Order By createdDate ASC];
            String name='Signature - '+selShipment[0].Name;
            try{if(imageData!=null && imageData!=''){ captureSignature(imageData,selShipment[0].id,name); } }catch(Exception e){ system.debug('arshad exception~>'+e.getMessage()+' at line~>'+e.getLineNumber()); /*'Exception occured.');*/}
            wrapper.shipment=[Select Id,Name,ERP7__Shipment_Date__c,ERP7__Status__c,ERP7__Shipment_Type__c,ERP7__Shipment_Delivery_Date__c,ERP7__Supplier__c,
                              ERP7__Tracking_Number__c,ERP7__TrackingNumber__c,ERP7__Shipment_Identification_Number__c,ERP7__Shipping_Amount__c,
                              ERP7__Admin_Shipping_Amount__c,ERP7__Declared_Value__c,ERP7__Description__c,ERP7__Received_By__c
                              From ERP7__Shipment__c where Id=:selShipment[0].Id];

            Id DeliveryRT; DeliveryRT = Schema.SObjectType.ERP7__Shipment_Flow__c.getRecordTypeInfosByDeveloperName().get('Delivery').getRecordTypeId();
            
            if(recordType=='Delivery'){
                wrapper.deliveryshipmentFlow=[Select Id,Name,ERP7__Shipment_Flow_Status__c,Shipment__c,ERP7__Transportation_Allocation__c,ERP7__Time__c,ERP7__Shipping_point__c,ERP7__Description__c 
                                              From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:selShipment[0].Id and RecordTypeId=:DeliveryRT];  
                wrapper.Attachments = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:selShipment[0].Id AND Name=:name Order By CreatedDate Asc]; 
            }
        }catch(Exception e){ wrapper.errMsg  = ' Error Occured : '+e.getMessage()+' at line : '+e.getLineNumber();
        }
        return wrapper;
    }        
    
    public static void captureSignature(String imageData, String recId, String name) { 
        try {   
            String imgSig=imageData;
            imgSig=imgSig.substringAfter(',');
            
            Attachment a = new Attachment(ParentId = recId, Body =EncodingUtil.base64Decode(imgSig), ContentType = 'image/png', Name=name);        
            try {
                if(Schema.sObjectType.Attachment.isCreateable()) DMLManager.insertAsUser(a); else{ }
                
            } catch(DMLException ex) { /*'FAILURE'+ex)*/ }       } catch(Exception e) {/*'Error==>'+e)*/}
        
    }
    
    @AuraEnabled
    public static wrapper DeleteShipF(String currentSFID,String selShipment1){
        Wrapper wrapper=new Wrapper();
        List<ERP7__Shipment__c> selShipment = (List<ERP7__Shipment__c>) JSON.deserialize(selShipment1, List<ERP7__Shipment__c>.class);
        if(currentSFID != null && currentSFID != '' && Shipment_Flow__c.sObjectType.getDescribe().isDeletable()) { delete new Shipment_Flow__c(Id = currentSFID); } else{ }
        wrapper.allSF=[Select Id,Name,ERP7__Time__c,ERP7__Shipment_Flow_Status__c From ERP7__Shipment_Flow__c where ERP7__Shipment__c=:selShipment[0].Id Order By createdDate ASC ];
        
        return wrapper;
    }
    
   @AuraEnabled
    public static wrapper EditShipF(String currentSFID,String selShipment1){
        Wrapper wrapper=new Wrapper();
        List<ERP7__Shipment__c> selShipment = (List<ERP7__Shipment__c>) JSON.deserialize(selShipment1, List<ERP7__Shipment__c>.class);
        wrapper.EdtSF=[ Select Id,Name,RecordTypeId,ERP7__Shipment_Flow_Status__c,Shipment__c,ERP7__Transportation_Allocation__c,ERP7__Time__c,ERP7__Shipping_point__c,ERP7__Description__c 
                       From ERP7__Shipment_Flow__c where Id=:currentSFID ];
        RecordType RT=[Select Id,DeveloperName From  RecordType where Id=:wrapper.EdtSF[0].RecordTypeId];
        wrapper.RT=RT.DeveloperName; 
        return wrapper;
    }
    
    @AuraEnabled
    public static wrapper getAddress(String packageID){
        Wrapper wrapper=new Wrapper();
        wrapper.address = [Select Id, Name, ERP7__Customer__c, ERP7__Contact__c, ERP7__Active__c,
                           ERP7__Is_Shipping_Address__c, ERP7__Is_Billing_Address__c, ERP7__Address_Line1__c,
                           ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c,
                           ERP7__State__c, ERP7__Postal_Code__c, ERP7__Contact__r.ERP7__Company__c, ERP7__Contact__r.Name,
                           ERP7__Contact__r.Email,ERP7__Contact__r.phone From ERP7__Address__c where Id=:packageID];
        
        return wrapper;
    }
    
    @AuraEnabled
    public static wrapper updatepackageList(String pacStrId,String packStr,String counts,String quantityValues){
        Wrapper wrapper=new Wrapper();
        /*('packageId===>'+packageId);
'packList==>'+packList);
('counts==>'+counts);*/
        List<packWrapper> pckList=new List<packWrapper>(); List<integer> c=new List<integer>(); list<ERP7__Package__c> packageId=(list<ERP7__Package__c>) JSON.deserialize(pacStrId, list<ERP7__Package__c> .class);
        list<packWrapper> packList=(list<packWrapper>) JSON.deserialize(packStr, list<packWrapper> .class); list<Integer> quantityNew=(list<Integer>) JSON.deserialize(quantityValues, list<Integer> .class); list<Integer> countsNew=(list<Integer>) JSON.deserialize(counts, list<Integer> .class); List<ERP7__Package_List__c> pack2upsert = new List<ERP7__Package_List__c>();
        for(integer i=0;i<countsNew.size();i++){ pack2upsert.add(packList[countsNew[i]].pack); system.debug('pack2upsert[i].ERP7__RemaingQuantity__c : '+pack2upsert[i].ERP7__RemaingQuantity__c); system.debug('pack2upsert[i].ERP7__Delivered_Quantity__c : '+pack2upsert[i].ERP7__Delivered_Quantity__c); /*pckList.add(packList[countsNew[i]]);*/ if(pack2upsert[i].ERP7__Delivered_Quantity__c==null){pack2upsert[i].ERP7__Delivered_Quantity__c=0;} if((pack2upsert[i].ERP7__RemaingQuantity__c+pack2upsert[i].ERP7__Delivered_Quantity__c)<= pack2upsert[i].ERP7__Quantity__c) { if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Delivered_Quantity__c.isUpdateable())   pack2upsert[i].ERP7__Delivered_Quantity__c=pack2upsert[i].ERP7__RemaingQuantity__c+pack2upsert[i].ERP7__Delivered_Quantity__c; } system.debug('pack2upsert[i].ERP7__Delivered_Quantity__c after: '+pack2upsert[i].ERP7__Delivered_Quantity__c); if( pack2upsert[i].ERP7__Delivered_Quantity__c< pack2upsert[i].ERP7__Quantity__c) { if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Status__c.isUpdateable()) pack2upsert[i].ERP7__Status__c='Item(s) Missing';} else { pack2upsert[i].ERP7__Status__c='Delivered';} }  
        PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;
        
        if(Schema.sObjectType.ERP7__Package_List__c.isUpdateable()){ update pack2upsert; }else{ }
        List<ERP7__Package_List__c> pckg=[Select Id,ERP7__Status__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__r.Name,ERP7__Logistic_Line_Item__c,ERP7__Delivered_Quantity__c from ERP7__Package_List__c where Id IN : pack2upsert];
        
        Set<String> loloids=new Set<String>();
        for(ERP7__Package_List__c pkglist : pckg) loloids.add(pkglist.ERP7__Logistic_Line_Item__c);
        List<ERP7__Logistic_Line_Item__c> LOLIS=[Select Id,ERP7__Packed_Quantity__c,ERP7__Shipped_Quantity__c,ERP7__DeliveredQuantity__c From ERP7__Logistic_Line_Item__c where Id in: loloids ];
        for(ERP7__Logistic_Line_Item__c loli : LOLIS){ for(ERP7__Package_List__c pkglist : pckg){ if(loli.Id == pkglist.ERP7__Logistic_Line_Item__c){ if(loli.ERP7__DeliveredQuantity__c == null) loli.ERP7__DeliveredQuantity__c = 0; if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__DeliveredQuantity__c.isUpdateable())  loli.ERP7__DeliveredQuantity__c = loli.ERP7__DeliveredQuantity__c + pkglist.ERP7__Delivered_Quantity__c; } } }
        
        if(LOLIS.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()) update LOLIS;
        List<packWrapper> pcwrp = new List<packWrapper>();
        List<ERP7__Package_List__c> pklst=[Select Id,ERP7__Active__c,ERP7__Order_Product__r.Product2.Name ,ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.Name,ERP7__Quantity__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__c, ERP7__MRP_Material_Requirement_Planning__r.ERP7__MRP_Product__r.Name, ERP7__Order_Product__r.Quantity ,ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c,ERP7__Delivered_Quantity__c,ERP7__Status__c,ERP7__RemaingQuantity__c, ERP7__RMA_Line_Item__r.ERP7__Product__r.Name, ERP7__RMA_Line_Item__r.ERP7__Quantity_Return__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Transfer_Order_Line_Item__r.ERP7__Products__r.Name From ERP7__Package_List__c where ERP7__Package__c IN : packageId ]; for(ERP7__Package_List__c pc : pklst){ pcwrp.add(new packWrapper(pc,false)); } wrapper.packageList = pcwrp; Set<String> checkDelivered=new Set<String>(); for(integer i=0;i<wrapper.packageList.size();i++) { if(wrapper.packageList[i].pack.ERP7__Status__c!=null){ checkDelivered.add(wrapper.packageList[i].pack.ERP7__Status__c);} } if(checkDelivered.contains('Item(s) Missing')) {wrapper.hideDeliveredTab=False;}   if(checkDelivered.size()==0){wrapper.hideDeliveredTab=false;} 
        return wrapper;
    }
    
    @AuraEnabled
    public static  List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType,String pckgForSoId1) { 
        try{
            List<ERP7__Package__c> pckgForSoId = (List<ERP7__Package__c>) JSON.deserialize(pckgForSoId1, List<ERP7__Package__c>.class);
            System.debug('pckgForSoId : '+pckgForSoId.size());
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment(); 
            if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()) a.parentId = parent; 
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) a.Body = EncodingUtil.base64Decode(base64Data); 
            if(Schema.sObjectType.Attachment.fields.Name.isCreateable()) a.Name = fileName; 
            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) a.ContentType = contentType; 
            if(Schema.sObjectType.Attachment.isCreateable()) { insert a; } else{ }
            if(pckgForSoId.size() > 0){
                Attachment aForSO = new Attachment(); 
                if(Schema.sObjectType.Attachment.fields.parentId.isCreateable() && pckgForSoId[0].Sales_Order__c != null) aForSO.parentId = pckgForSoId[0].Sales_Order__c;  else if(Schema.sObjectType.Attachment.fields.parentId.isCreateable() && pckgForSoId[0].ERP7__Order__c != null) aForSO.parentId = pckgForSoId[0].ERP7__Order__c;  else if(Schema.sObjectType.Attachment.fields.parentId.isCreateable() && pckgForSoId[0].ERP7__Transfer_Order__c != null) aForSO.parentId = pckgForSoId[0].ERP7__Transfer_Order__c; 
                if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) aForSO.Body = EncodingUtil.base64Decode(base64Data);  if(Schema.sObjectType.Attachment.fields.Name.isCreateable()) aForSO.Name = fileName; if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) aForSO.ContentType = contentType; 
                if(Schema.sObjectType.Attachment.isCreateable() && aForSO.parentId != null) { insert aForSO; } else{ } 
            }
            List<Attachment> MYATS = [Select Id, Name, ParentId, ContentType From Attachment Where ParentId  =:parent Order By CreatedDate Asc];
            return MYATS;        
        }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()); }
    }
    
    @AuraEnabled
    public static List<Note> SaveNotes(String NN, String regID){   
        Note myNote = (Note) JSON.deserialize(NN, Note.class); wrapper wrapper=new wrapper();
        try{ if(Schema.sObjectType.Note.isCreateable() && Schema.sObjectType.Note.isUpdateable()){ upsert myNote; } else{ }  } catch(Exception e) { /*Errro=>'+e.getMessage()); */ }
        List<Note> MYATS = [Select Id, Title, ParentId From Note Where ParentId=:regID Order By CreatedDate Asc];
        return MYATS;
    }
    
    @AuraEnabled
    public static wrapper  DeleteAT(String RAId, String ObjName,String pckgForSoId1,String index){  
        List<ERP7__Package__c> pckgForSoId = (List<ERP7__Package__c>) JSON.deserialize(pckgForSoId1, List<ERP7__Package__c>.class);
        String soid=pckgForSoId[0].Logistic__r.Sales_Order__c;
        Integer recIndex=Integer.valueOf(index);
        Wrapper wrapper=new Wrapper();
        try{ String query = 'select Id from ' +String.escapeSingleQuotes(ObjName)+ ' Where Id =:RAId'; 
            SObject AT = Database.query(query); List<SObject> SoAT=new List<SObject>();
            if(ObjName=='Attachment'){ SoAT=[Select id from Attachment where ParentId=:soid Order By CreatedDate Asc ]; }else{ SoAT=[Select id from Note where ParentId=:soid  Order By CreatedDate Asc]; } SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType(); if(sObjType.getDescribe().isDeletable()){ delete AT;}else{/*No access*/} if(SoAT.size()>0){ List<SObject> So=new List<SObject>(); So.add(SoAT[recIndex]); if(sObjType.getDescribe().isDeletable()){ delete So;}else{/*No access*/} }
           } catch(Exception e) { /*'Errorr occured...'+e.getMessage());*/  }
        return wrapper;
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; } @AuraEnabled public String value     { get; set; } @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) { label = lab; value = val; selected = sel;
        }
    }
    
    public class Wrapper{
        @AuraEnabled public String RT {get;set;}
        @AuraEnabled public Boolean Delivered {get;set;}
        @AuraEnabled public Boolean isSoliPresent {get;set;}
        @AuraEnabled public List<ERP7__Shipment_Flow__c> allSF { get;set;}
        @AuraEnabled public List<ERP7__Shipment_Flow__c> EdtSF {get;set;}
        @AuraEnabled public List<Selectoptions> shipmentStageOption { get;set;} 
        @AuraEnabled public List<Selectoptions> pckLstStatus { get;set;} 
        @AuraEnabled public List<Selectoptions> STPickList {get;set;}
        @AuraEnabled public List<Selectoptions> SFSPKLST {get;set;}
        @AuraEnabled public List<Selectoptions> pckLstSts {get;set;}
         @AuraEnabled public List<SelectOptions> WeightUnit                           { get; set; }
         @AuraEnabled public List<SelectOptions> DimensionUnit  { get; set; }
        @AuraEnabled public List<ERP7__Package__c> fetchPackage    { get; set;}
        @AuraEnabled public List<ERP7__Address__c> address     { get; set;}
        @AuraEnabled public List<ERP7__Address__c> fromaddress     { get; set;}
        @AuraEnabled public List<ERP7__Address__c> toaddress       { get; set;}
        @AuraEnabled public List<ERP7__Shipment__c> shipment       { get; set; }
        @AuraEnabled  public List<ERP7__Shipment_Flow__c> pickupshipmentFlow              { get; set; }
        @AuraEnabled  public List<ERP7__Shipment_Flow__c> deliveryshipmentFlow            { get; set; }
        @AuraEnabled  public List<ERP7__Shipment_Flow__c> dropoffshipmentFlow             { get; set; }
        @AuraEnabled  public List<String> shipmentTypePicklist      {get;set;}
        @AuraEnabled  public List<String> packageTypePicklist      {get;set;}
        @AuraEnabled  public List<String> productUnitPicklist      {get;set;}  
        @AuraEnabled  public List<String> SSPicklist      {get;set;}  
        @AuraEnabled  public List<String> SFSPicklist      {get;set;}
        @AuraEnabled  public List<String> pckListStatus      {get;set;}    
        @AuraEnabled public List<Attachment> attachments {get;set;}
        @AuraEnabled public List<Boolean> renderFields {get;set;}
        @AuraEnabled public Boolean hideDeliveredTab {get;set;}
        @AuraEnabled public Boolean  showPO {get;set;}
        @AuraEnabled public List<packWrapper> packageList {get;set;}
        @AuraEnabled  public List<Attachment> allAttachments                       {get;set;} 
        @AuraEnabled  public List<Note> Notes                                   {get;set;}
        @AuraEnabled  public DateTime DT                                   {get;set;}
        @AuraEnabled  public string errMsg                                   {get;set;}
        @AuraEnabled public Boolean showDimension                       {get;set;}
         @AuraEnabled public Boolean hideShipment                       {get;set;}//Asra 10/4/24
        public Wrapper(){
            hideDeliveredTab=True;   
            packageList=new List<packWrapper>();   
            attachments=new List<Attachment>();   
            Delivered=True;
            isSoliPresent = True; 
            allSF=new List<ERP7__Shipment_Flow__c> ();  
            EdtSF=new List<ERP7__Shipment_Flow__c> ();   
            shipmentStageOption = new List<Selectoptions>();
            pckLstStatus   = new List<Selectoptions>();
            STPickList = new List<Selectoptions>();
            SFSPKLST =new List<Selectoptions>();   
            pckLstSts =new List<Selectoptions>(); 
            WeightUnit = new List<Selectoptions>(); 
            DimensionUnit = new List<Selectoptions>(); 
            fetchPackage = new List<ERP7__Package__c>(); 
            fromaddress  = new List<ERP7__Address__c>();
            address    = new List<ERP7__Address__c>();
            toaddress    = new List<ERP7__Address__c>(); 
            shipment     = new List<ERP7__Shipment__c>();
            pickupshipmentFlow   = new List<ERP7__Shipment_Flow__c>(); 
            deliveryshipmentFlow = new List<ERP7__Shipment_Flow__c>();
            dropoffshipmentFlow  = new List<ERP7__Shipment_Flow__c>(); 
            shipmentTypePicklist = new List<String>();   
            packageTypePicklist = new List<String>();  
            productUnitPicklist = new List<String>();   
            SSPicklist = new List<String>();  
            SFSPicklist = new List<String>(); 
            pckListStatus = new List<String>();   
            renderFields = new List<Boolean>(); 
            allAttachments=new List<Attachment>();
            Notes=new List<Note>();
            showPO = true;
            errMsg = '';
            showDimension = false;
            hideShipment = false;//Asra 10/4/24
            
        }
    }
    
   public class packWrapper{ @AuraEnabled public ERP7__Package_List__c pack  {get;set;} @AuraEnabled public Boolean selected            {get;set;} public packWrapper(ERP7__Package_List__c pc,boolean yes){pack = pc; selected = yes;} }
    
}