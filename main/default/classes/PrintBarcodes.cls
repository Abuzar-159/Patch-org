global with sharing class PrintBarcodes {
    
    global List<String> myFields                                            { get; set; }
    global List<SelectOption> myFieldOptions                                { get; set; }
    global String mySelFields                                               { get; set; }
    global List<sObject> Records                                            { get; set; }           
    global List<BarcodeWrapper> BarcodeWrapperList                          { get; set; }
    global String BarcodeField                                              { get; set; }
    global String LabelField                                                { get; set; }
    global String myObject                                                  { get; set; }
    global String headVal                                                   { get; set; }
    global String footVal                                                   { get; set; }
    global String RecordName                                                { get; set; }
    global String brcdType                                                  { get; set; }
    global String BarcodeLoc                                                { get; set; }
    global String LabelLoc                                                  { get; set; }
    global Boolean BarcodeDisplay                                           { get; set; }
    global Boolean LabelDisplay                                             { get; set; }
    global Boolean Frame                                                    { get; set; }
    global Integer NoofColumns                                              { get; set; }
    global Integer NoofRows                                                 { get; set; }
    global String PageSize                                                  { get; set; }
    global String  errMsg                                                   { get; set; }
    global List<SelectOption> ObjectList                                    { get; set; }
    global List<SelectOption> BarcodeList                                   { get; set; }
    global List<SelectOption> LabelList                                     { get; set; }
    global List<SelectOption> FieldList                                     { get; set; }
    global List<String> FieldListSelecteds                                  { get; set; }
    global List<SelectOption> FieldListSelected                             { get; set; }
    global List<SelectOption> FieldListSelectedsOptions                     { get; set; }
    global Boolean selectAll                                                { get; set; }
    global integer selectAllCount                                                { get; set; }
    global List<BarcodeWrapper> BarcodeWrapperCol1                          { get; set; }
    global List<BarcodeWrapper> BarcodeWrapperCol2                          { get; set; }
    global List<BarcodeWrapper> BarcodeWrapperCol3                          { get; set; }
    global Map<String, String> valueLabel                                   { get; set; } 
    global Boolean showBarcode                                              { get; set; }
    global String pageTarget                                                { get; set; }
    
    global static Map<String, Schema.SObjectType> schemaMap                 { get; set; } 
    global Map<String, Schema.SObjectField> fieldMap                        { get; set; }       
  
    global PrintBarcodes() {             
       //errMsg = 'There is no data';
        List<Object> selectedIso = new List<Object>();
        ObjectList = new List<SelectOption>();
        BarcodeList = new List<SelectOption>();
        LabelList = new List<SelectOption>();
        FieldList = new List<SelectOption>();
        FieldListSelecteds = new List<String>();
        FieldListSelectedsOptions = new List<SelectOption>();
        myFields = new List<String>();
        valueLabel = new Map<String, String>();
        schemaMap = Schema.getGlobalDescribe();
        selectAll = false;
        selectAllCount = 0;
        BarcodeLoc = 'Bottom';
        LabelLoc = 'Top';
        RecordName = '';
        NoofColumns = 1;
        NoofRows = 1;
        PageSize = '6in 4in';
        BarcodeDisplay = false;
        LabelDisplay = false;
        showBarcode = true;
        Frame = false;
        BarcodeWrapperList = new List<BarcodeWrapper>();
        BarcodeWrapperCol1 = new List<BarcodeWrapper>();
        BarcodeWrapperCol2 = new List<BarcodeWrapper>();
        BarcodeWrapperCol3 = new List<BarcodeWrapper>();
        Records = new List<sObject>();
        list_size = 10; 
        brcdType = 'code128';
        headVal = footVal = '';
        ObjectList.add(new SelectOption('', 'Select Object'));
        List<Schema.SObjectType> items = ProcessInstance.TargetObjectId.getDescribe().getReferenceTo();
        for(Schema.SObjectType item : items){
            if(!item.getDescribe().CustomSetting  && !item.getDescribe().getLabel().containsIgnoreCase('Deprecated')){
                  ObjectList.add(new SelectOption(item.getDescribe().getLocalName().toLowerCase() , item.getDescribe().getLabel() ));
            }
        }
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        Integer counter = 1;
        for (Selectoption opt : ObjectList) {
            mapping.put((opt.getLabel() + counter++),opt);  
        }
        List<String> sortingKeys = new List<String>();
        sortingKeys.addAll(mapping.keySet());
        sortingKeys.sort();
        ObjectList.clear();
        for (String key : sortingKeys) {
            if(mapping.get(key).getValue() == 'Product2') ObjectList.add(mapping.get(key));
        }
        for (String key : sortingKeys) {
            if(mapping.get(key).getValue() != 'Product2') ObjectList.add(mapping.get(key));
        }
        myObject = 'Product2';        
        InitialfieldProps();
    }
    
    global void initLoad(){
        myObject = 'Product2';
        fieldProps(); 
    }
    
    global PageReference loadBarcodes(){
        showBarcode = true;
        return null;
    }
    
    global void fieldProps() {
        try{
        FieldList = new List<SelectOption>();
        FieldListSelecteds = new List<String>();
        FieldListSelectedsOptions = new List<SelectOption>();
        myFields = new List<String>();
        valueLabel = new Map<String, String>();
        schemaMap = Schema.getglobalDescribe();
        BarcodeList = new List<SelectOption>();
        LabelList = new List<SelectOption>();
        BarcodeWrapperList = new List<BarcodeWrapper>();
        BarcodeWrapperCol1 = new List<BarcodeWrapper>();
        BarcodeWrapperCol2 = new List<BarcodeWrapper>();
        BarcodeWrapperCol3 = new List<BarcodeWrapper>();
        Records = new List<sObject>();
        BarcodeField = '';
        LabelField = '';
        RecordName = ''; 
        
        if(myObject != '' && myObject != Null){
            fieldMap = (schemaMap.containsKey(myObject))?  schemaMap.get(myObject).getDescribe().fields.getMap() : schemaMap.get('ERP7__'+myObject).getDescribe().fields.getMap();
            if(fieldMap.Values().size() > 0) {
                LabelList.add(new SelectOption('', '--None--'));
            }
            boolean assign = true;
            for(Schema.SObjectField sof : fieldMap.Values()){
                valueLabel.put(sof.getDescribe().getLocalName().toLowerCase(),sof.getDescribe().getLabel() );
                //if(sof.getDescribe().isAccessible() && sof.getDescribe().isUpdateable()){
                    if(String.valueof(sof.getDescribe().getType()) == 'String'){
                        if(assign) { BarcodeField = sof.getDescribe().getLocalName().toLowerCase(); assign = false;}
                        BarcodeList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                        LabelList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                    }
                //}
            }
            
            for(Schema.SObjectField sof : fieldMap.Values()){
                //if(sof.getDescribe().isAccessible() && sof.getDescribe().isUpdateable()){ 
                    FieldList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                //} 
            }
            
            Map<String, Selectoption> mapping = new Map<String, Selectoption>();
            Integer counter = 1;
            for (Selectoption opt : FieldList) {
                mapping.put((opt.getLabel() + counter++),opt);
            }
            List<String> sortingKeys = new List<String>();
            sortingKeys.addAll(mapping.keySet());
            sortingKeys.sort();
            FieldList.clear();
            for (String key : sortingKeys) {
                FieldList.add(mapping.get(key));
            }
            Evaluate();
        }
        }catch(Exception e){}
    }
    
    global void InitialfieldProps() {
        try{
        valueLabel = new Map<String, String>();
        schemaMap = Schema.getGlobalDescribe();
        BarcodeList = new List<SelectOption>();
        LabelList = new List<SelectOption>();
        BarcodeWrapperList = new List<BarcodeWrapper>();
        BarcodeWrapperCol1 = new List<BarcodeWrapper>();
        BarcodeWrapperCol2 = new List<BarcodeWrapper>();
        BarcodeWrapperCol3 = new List<BarcodeWrapper>();
        Records = new List<sObject>();
        BarcodeField = 'barcode__c';
        LabelField = 'name';
        mySelFields = '';
        if(myObject != '' && myObject != Null){
            fieldMap = (schemaMap.containsKey(myObject))?  schemaMap.get(myObject).getDescribe().fields.getMap() : schemaMap.get('ERP7__'+myObject).getDescribe().fields.getMap();
            if(fieldMap.Values().size() > 0) {
                LabelList.add(new SelectOption('', '--None--'));
            }
            boolean assign = true;
            for(Schema.SObjectField sof : fieldMap.Values()){
                valueLabel.put(sof.getDescribe().getLocalName().toLowerCase(),sof.getDescribe().getLabel() );
                //if(sof.getDescribe().isAccessible() && sof.getDescribe().isUpdateable()){
                    if(String.valueof(sof.getDescribe().getType()) == 'String'){
                        if(assign) { BarcodeField = sof.getDescribe().getLocalName().toLowerCase(); assign = false;}
                        BarcodeList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                        LabelList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                    }
                //}
            }
            
            for(Schema.SObjectField sof : fieldMap.Values()){
                //if(sof.getDescribe().isAccessible() && sof.getDescribe().isUpdateable()){ 
                    FieldList.add(new SelectOption(sof.getDescribe().getLocalName().toLowerCase() , sof.getDescribe().getLabel() ));
                //}                
            }
            
            Map<String, Selectoption> mapping = new Map<String, Selectoption>();
            Integer counter = 1;
            for (Selectoption opt : FieldList) {
                mapping.put((opt.getLabel() + counter++),opt);  
            }
            List<String> sortingKeys = new List<String>();
            sortingKeys.addAll(mapping.keySet());
            sortingKeys.sort();
            FieldList.clear();
            for (String key : sortingKeys) {
                FieldList.add(mapping.get(key));
            }
            Evaluate();
        }
        }catch(Exception e){}
    }
    
    global Void AddFields(){
        try{
       mySelFields = '';
       for(String s : myFields) {
           FieldListSelectedsOptions.add(new SelectOption(s,valueLabel.get(s)));
       }
       for(SelectOption SF : FieldListSelectedsOptions){
           Integer i = FieldList.size()-1;
           while(i>=0) {
               if(FieldList[i].getValue() == SF.getValue()){
                   FieldList.remove(i);
                   break;
               }
               i--;
           }
       }
       Evaluate();
       mySelFields = '';
       myFields = new List<String>();
        }catch(Exception e){}
    }
    
    global Void RemoveFields(){
        mySelFields = '';
        List<String> RL = new List<String>();
        for(String s : FieldListSelecteds) {
           Integer i = FieldListSelectedsOptions.size()-1;
           while(i>=0) {
               if(FieldListSelectedsOptions[i].getValue() == s){
                   FieldList.add(FieldListSelectedsOptions.remove(i));
                   break;
               }
               i--;
           }
        } 
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        Integer counter = 1;
        for (Selectoption opt : FieldList) {
            mapping.put((opt.getLabel() + counter++),opt);  
        }
        List<String> sortingKeys = new List<String>();
        sortingKeys.addAll(mapping.keySet());
        sortingKeys.sort();
        FieldList.clear();
        for (String key : sortingKeys) {
            FieldList.add(mapping.get(key));
        }
        Evaluate();
    }
    
    global PageReference Evaluate() {
        try{
        selectAll = false;
        String recordNamePattern = '%'+recordName+'%';
        for(SelectOption s : FieldListSelectedsOptions){
           if(s.getValue() != 'Id' && LabelField != s.getValue() && BarcodeField != s.getValue()) mySelFields = mySelFields+','+s.getValue();
        }
        if(LabelField == 'name' || BarcodeField == 'name'){
            if(LabelField != BarcodeField && LabelField != Null && LabelField != '')
                Records = Database.query('Select Id, '+String.escapeSingleQuotes(LabelField)+', '+String.escapeSingleQuotes(BarcodeField)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(LabelField)+' != null and '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit 10000');
            else if(LabelField == Null || LabelField == '' || LabelField == BarcodeField) 
                Records = Database.query('Select Id, '+String.escapeSingleQuotes(BarcodeField)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit 10000');
        }else{
            if(LabelField != BarcodeField && LabelField != Null && LabelField != '')
                Records = Database.query('Select Id, Name, '+String.escapeSingleQuotes(LabelField)+', '+String.escapeSingleQuotes(BarcodeField)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(LabelField)+' != null and '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit 10000');
            else if(LabelField == Null || LabelField == '' || LabelField == BarcodeField) 
                Records = Database.query('Select Id, Name, '+String.escapeSingleQuotes(BarcodeField)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit 10000');
        }
        total_size = Records.size();
        if(LabelField == 'name' || BarcodeField == 'name'){
            if(LabelField != BarcodeField && LabelField != Null && LabelField != '')
                Records = Database.query('Select Id, '+String.escapeSingleQuotes(LabelField)+', '+String.escapeSingleQuotes(BarcodeField)+' ' +String.escapeSingleQuotes(mySelFields)+' From ' +String.escapeSingleQuotes(myObject)+' Where '+String.escapeSingleQuotes(LabelField)+' != null and '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit :list_size offset :counter');
            else if(LabelField == Null || LabelField == '' || LabelField == BarcodeField) 
                Records = Database.query('Select Id, '+String.escapeSingleQuotes(BarcodeField)+' '+String.escapeSingleQuotes(mySelFields)+' From ' +String.escapeSingleQuotes(myObject)+' Where '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit :list_size offset :counter');
        }else{if(LabelField != BarcodeField && LabelField != Null && LabelField != '')
                Records = Database.query('Select Id, Name, '+String.escapeSingleQuotes(LabelField)+' '+String.escapeSingleQuotes(BarcodeField)+', '+String.escapeSingleQuotes(mySelFields)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(LabelField)+' != null and '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit :list_size offset :counter');
            else if(LabelField == Null || LabelField == '' || LabelField == BarcodeField) Records = Database.query('Select Id, Name, '+String.escapeSingleQuotes(BarcodeField)+ ' '+String.escapeSingleQuotes(mySelFields)+' From ' +String.escapeSingleQuotes(myObject)+ ' Where '+String.escapeSingleQuotes(BarcodeField)+' != null and Name Like :recordNamePattern limit :list_size offset :counter');
        }
        BarcodeWrapperList = new List<BarcodeWrapper>();
        
        for(SObject sObj : Records){
            BarcodeWrapper BW;
            if(LabelField != Null && LabelField != '') BW = new BarcodeWrapper(String.valueof(sObj.get(BarcodeField)), String.valueof(sObj.get(LabelField)), String.valueof(sObj.get('Name')) );
            else  BW = new BarcodeWrapper(String.valueof(sObj.get(BarcodeField)), '', String.valueof(sObj.get('Name')) );
            BW.Id = String.valueof(sObj.Id);
            BW.sObj = sObj;
            for(SelectOption s : FieldListSelectedsOptions){
                //BW.sObj.put(s.getValue(),sObj.get(s.getValue()));
            }
            BarcodeWrapperList.add(BW);
        }
        mySelFields = '';
        FieldListSelecteds = new List<String>();
        //myFields = new List<String>();
        }catch(Exception e){}
        return Null;        
    }    
   
    global PageReference Evaluate2() {
        
        return null;             
    }
    
    
    global PageReference PrintPreview() {
        try{
        BarcodeWrapperCol1 = new List<BarcodeWrapper>();
        BarcodeWrapperCol2 = new List<BarcodeWrapper>();
        BarcodeWrapperCol3 = new List<BarcodeWrapper>();
        Integer i, j, k;  
        i = j = k = 0;
        Boolean exist = false;
        
        for(BarcodeWrapper PW : BarcodeWrapperList){
            if(PW.selected){
                exist = true;
                if(NoofColumns == 3){
                    if(i==j && i==k) { BarcodeWrapperCol1.add(PW); i++; }
                    else if(j==k) { BarcodeWrapperCol2.add(PW); j++;  }
                    else { BarcodeWrapperCol3.add(PW); k++; }
                }
                else if(NoofColumns == 2){
                    if(i==j) { BarcodeWrapperCol1.add(PW); i++; }
                    else { BarcodeWrapperCol2.add(PW); j++;  }
                }
                else BarcodeWrapperCol1.add(PW);
            }
        }
        if(!exist) BarcodeWrapperCol1.add(new BarcodeWrapper('', '',''));
       }catch(Exception e){}
        if(brcdType =='code128' || brcdType == 'code39' || brcdType =='ean8' || brcdType == 'ean13'){return Page.PrintBarcodesPDF;}
        else if(brcdType =='qrcode' || brcdType == 'pdf417') {return Page.PrintBarcodes2DPDF;} 
        else return null;  
         //return Page.PrintBarcodesPDF;
        
    }
        
   global Void selectAll(){
        Boolean showPreview=false;
         for(BarcodeWrapper PW : BarcodeWrapperList){
           
            if(selectAll) PW.selected = true; else PW.selected = false;
            if(PW.selected)showPreview=true;
        }
          if(pageTarget=='showPreview' && showPreview==false){pageTarget='';}
        else{
            pageTarget='showPreview';
        }
    }
    
    global Void deselect(){          
          selectAll = false;
        Boolean showPreview=false;
        for(BarcodeWrapper PW : BarcodeWrapperList){
            if(PW.selected)showPreview=true;
        }
        if(showPreview){pageTarget='showPreview';}
        else{
            pageTarget='';
        }
         /* if(list_size == selectAllCount)
            selectAll = true;
           else selectAll = false;*/
          
    }    
    
    global Void Top(){
        List<SelectOption> mysel = new List<SelectOption>();
        for(Integer ik=0; ik<FieldListSelecteds.size(); ik++) {
            Integer i = 0;
            while(i<FieldListSelectedsOptions.size()) {
               if(FieldListSelectedsOptions[i].getValue() == FieldListSelecteds[ik]){
                   mysel.add(FieldListSelectedsOptions.remove(i));
                   break;
               }
               i++;
            }
        }
        for(Integer ik=0; ik<FieldListSelectedsOptions.size(); ik++) {
            mysel.add(FieldListSelectedsOptions[ik]);
        }
        FieldListSelectedsOptions = mysel;
    }
    global Void Bottom(){
        List<SelectOption> mysel = new List<SelectOption>();
        for(Integer ik=0; ik<FieldListSelecteds.size(); ik++) {
            Integer i = 0;
            while(i<FieldListSelectedsOptions.size()) {
               if(FieldListSelectedsOptions[i].getValue() == FieldListSelecteds[ik]){
                   mysel.add(FieldListSelectedsOptions.remove(i));
                   break;
               }
               i++;
            }
        }
        for(Integer ik=0; ik<mysel.size(); ik++) {
            FieldListSelectedsOptions.add(mysel[ik]);
        }
    }
    
    global Void Up(){
        for(Integer ik=0; ik<FieldListSelecteds.size(); ik++) {
            Integer i = 1;
            while(i<FieldListSelectedsOptions.size()) {
               if(FieldListSelectedsOptions[i].getValue() == FieldListSelecteds[ik]){
                   SelectOption temp = FieldListSelectedsOptions[i-1];
                   FieldListSelectedsOptions[i-1] = FieldListSelectedsOptions[i];
                   FieldListSelectedsOptions[i] = temp;
                   break;
               }
               i++;
            }
        }
    }
    
    global Void Down(){
        for(Integer ik=FieldListSelecteds.size()-1; ik>=0; ik--) {
            Integer i = FieldListSelectedsOptions.size()-2;
            while(i>=0) {
               if(FieldListSelectedsOptions[i].getValue() == FieldListSelecteds[ik]){
                   SelectOption temp = FieldListSelectedsOptions[i+1];
                   FieldListSelectedsOptions[i+1] = FieldListSelectedsOptions[i];
                   FieldListSelectedsOptions[i] = temp;
                   break;
               }
               i--;
            }
        }
    }
    
    global Void BarcodeLocSwitch(){
       BarcodeLoc = (LabelLoc == 'Top')? 'Bottom' : 'Top';
    }
    
    global Void LabelLocSwitch(){
       LabelLoc = (BarcodeLoc == 'Top')? 'Bottom' : 'Top';
    }
    
    global PageReference customCon() { return null; }
    
    global PageReference customConEval() { return null; }
   
   /* ------------------------------------ Custom Pagination Start --------------------------------------*/
   
   global integer counter=0;  
   global integer list_size { get; set; } 
   global integer total_size; 

   global PageReference Beginning() { 
      Evaluate();
      counter = 0;
      return null;
   }

   global PageReference Previous() { 
      
      counter = (counter - list_size > 0)? counter - list_size : 0;
      Evaluate();
      return null;
   }

   global PageReference Next() { 
      counter += list_size;
      Evaluate();
      return null;
   }

   global PageReference End() { 
      counter = total_size - math.mod(total_size, list_size);
      Evaluate();
      return null;
   }

   global Boolean getDisablePrevious() { 
      if (counter>0) return false; else return true;
   }

   global Boolean getDisableNext() { 
      if (counter + list_size < total_size) return false; else return true;
   }

   global Integer getTotal_size() {
      return total_size;
   }
   
   global Integer getlistsize() {
      return list_size;
   }

   global Integer getPageNumber() {
      return counter/list_size + 1;
   }
   
   global Integer getcounter() {
      return counter;
   }

   global Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
   
   /* ------------------------------------ Custom Pagination End --------------------------------------*/
   
    global class BarcodeWrapper {
        global String Name                    { get; set; }
        global String Barcode                 { get; set; }
        global String Label                   { get; set; }
        global Boolean selected               { get; set; }
        global Product2 products              { get; set; }
        global Product_Service__c product     { get; set; }
        global String Id                      { get; set; }
        global sObject sObj                   { get; set; }
        
        global BarcodeWrapper(String bar, String lab) { }
        global BarcodeWrapper(String bar, String lab, String nam) { 
            Name = nam;
            Barcode = bar;
            Label = lab;
            selected = false;
            product = new Product_Service__c();
            products = new Product2();
            Id = ''; 
        }
    }   
   
}