Global With Sharing Class Generatepayslip{
    public Employee_Pay__c  emppay                                     { get; set; }
    public ID emppayId                                                 { get; set; }
    public Boolean pdf                                                 { get; set; }  Public Employee_Pay_Line_Item__c  EmpLI                            { get; set; }
    Public List <Pay_Adjustment_Line_Item__c> deductionPali            { get; set; }
    Public List <Pay_Adjustment_Line_Item__c> additionPali             { get; set; }
    Public List<List<Pay_Adjustment_Line_Item__c>> allAdditionPalis    { get; set; }
    Public List<List<Pay_Adjustment_Line_Item__c>> allDeductionpalis   { get; set; }  
    Public List<String>  categoryTypes                                 { get; set; } 
    
    public Generatepayslip(ApexPages.StandardController controller){
        try{
            String pdfname;
            if(ApexPages.currentPage().getParameters().get('pdf') != null) pdfname =  EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('pdf'),'UTF-8');
            if(ApexPages.currentPage().getParameters().get('id') != null)
                emppayId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8');     
            if(Schema.SObjectType.Employee_Pay__c.isAccessible())  {   
                utilClass.FLSCheck(new String[]{'Id','name','ERP7__Actual_Gross_Pay__c','ERP7__Employees__c','ERP7__Commission_Amount__c','ERP7__Calculated_Gross_Pay__c','ERP7__Date_of_Pay__c','ERP7__Net_Pay__c','ERP7__Tax_Amount__c','ERP7__Pay_Date__c','ERP7__Other_Tax_Amount__c','ERP7__Other_Deduction__c','ERP7__Other_Addition__c','ERP7__Total_Addition__c','ERP7__Total_Deduction__c'},'Employee_Pay__c');
                emppay = [Select Id,name, Actual_Gross_Pay__c, Employees__r.First_Name__c, Employees__r.Last_Name__c,Employees__r.Income_Tax_Number_PAN__c,Employees__r.Employee_Provident_Fund__c,Employees__r.National_Insurance_Number__c,Employees__r.PR_Account_Number__c,  Employees__r.Job_Title__c,Employees__r.First_Working_Day__c, Employees__r.Email__c, Employees__r.Name,Commission_Amount__c, Calculated_Gross_Pay__c, Date_of_Pay__c, Net_Pay__c,Tax_Amount__c, Pay_Date__c,      
                          Other_Tax_Amount__c, Other_Deduction__c, Other_Addition__c, Total_Addition__c, Total_Deduction__c,Employees__r.Bank_Details__c
                          From Employee_Pay__c 
                          Where id =: emppayId Limit 1 ];
            }
            alladditionPalis = new List <List<Pay_Adjustment_Line_Item__c>>();
            allDeductionpalis = new List <List<Pay_Adjustment_Line_Item__c>>();
            categoryTypes = new List<String>();
            Schema.DescribeFieldResult fieldResult = Pay_Adjustment_Line_Item__c.Category_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry val : pickListValues){
                categoryTypes.add(val.getValue());
            } 
            if(Schema.SObjectType.Pay_Adjustment_Line_Item__c.isAccessible()){ 
                utilClass.FLSCheck(new String[]{'Id','Name','ERP7__Adjustment_Category__c','ERP7__Adjustment_Category1__c','ERP7__Amount__c','ERP7__Category_Type__c','ERP7__End_Date__c','ERP7__Included_in_Payroll__c','ERP7__Is_Active__c','ERP7__Start_Date__c','ERP7__Adjustment_Category__c'},'ERP7__Resource_Allocation__c');
                additionPali = [Select Id,  Name, Adjustment_Category__c, Adjustment_Category1__c, Amount__c, Category_Type__c,  End_Date__c, Included_in_Payroll__c, Is_Active__c, Start_Date__c,
                                Adjustment_Category__r.Employee_Pay_Line_Item__r.Employee_Pay__c
                                From Pay_Adjustment_Line_Item__c
                                Where Adjustment_Category__r.Employee_Pay_Line_Item__r.Employee_Pay__c =:emppayId 
                                And Adjustment_Category1__c = 'Addition'
                                And Is_Active__c=true];
                deductionPali = [Select Id,  Name, Adjustment_Category__c, Adjustment_Category1__c, Amount__c, Category_Type__c, End_Date__c, Included_in_Payroll__c, Is_Active__c, Start_Date__c,
                                 Adjustment_Category__r.Employee_Pay_Line_Item__r.Employee_Pay__c
                                 From Pay_Adjustment_Line_Item__c
                                 Where Adjustment_Category__r.Employee_Pay_Line_Item__r.Employee_Pay__c =:emppayId 
                                 And Adjustment_Category1__c = 'deduction' 
                                 And Is_Active__c=true];
                
            }
            for (String val : categoryTypes){
                List<Pay_Adjustment_Line_Item__c> catList = new List<Pay_Adjustment_Line_Item__c>();            
                
                for (Pay_Adjustment_Line_Item__c p :additionPali){ if(p.Category_Type__c == val){catList.add(p);
                                                                                                }
                                                                 }
                if(catList.size() > 0){alladditionPalis.add(catList);
                                      }
            }
            
            for (String val : categoryTypes){
                List<Pay_Adjustment_Line_Item__c> catList = new List<Pay_Adjustment_Line_Item__c>();
                for (Pay_Adjustment_Line_Item__c p :deductionPali){ if(p.Category_Type__c == val){catList.add(p);
                                                                                                 }
                                                                  }
                if(catList.size() > 0){allDeductionpalis.add(catList);
                                      }
            }
            
            
            wrapperListAddition = new List<wrapper>();
            for (List<Pay_Adjustment_Line_Item__c> adp : alladditionPalis){ List<Pay_Adjustment_Line_Item__c> myList = adp; String currentCat = '';Decimal currentAmount = 0.00;
                                                                           wrapper wrap = new wrapper(); for (Pay_Adjustment_Line_Item__c dp : myList){ currentAmount += dp.Amount__c;currentCat = dp.Category_Type__c; }            
                                                                           wrap.category = currentCat; wrap.Amount = currentAmount; wrapperListAddition.add(wrap);
                                                                          }        
            wrapperListDeduction = new List<wrapper>();
            for (List<Pay_Adjustment_Line_Item__c> adp : allDeductionpalis){ List<Pay_Adjustment_Line_Item__c> myList = adp; String currentCat = '';Decimal currentAmount = 0.00;
                                                                            wrapper wrap = new wrapper(); for (Pay_Adjustment_Line_Item__c dp : myList){ currentAmount += dp.Amount__c;currentCat = dp.Category_Type__c; }            
                                                                            wrap.category = currentCat; wrap.Amount = currentAmount; wrapperListDeduction.add(wrap);
                                                                           } 
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
                           }  
    }      
    
    public Generatepayslip() {
    }
    
    public PageReference cancel() {
        PageReference page = new PageReference('/'+emppayId);
        page.setredirect(true);
        return page;
    } 
    
    public class wrapper {
        public String category {get; set;}
        public Decimal Amount  {get; set;}
        
        public wrapper(){
            category = '';
            Amount = 0.00;
        }
    }
    public String getCurrentMonthYear() {
        Date today = Date.today();
        String month = getMonthName(today.month());
        month+= ' '+today.year() ;
        return month;
    }
    
    public String getMonthName(Integer monthNumber) {
        String monthName;
        
        if (monthNumber == 1) {
            monthName = 'January';
        } else if (monthNumber == 2) {
            monthName = 'February';
        } else if (monthNumber == 3) {
            monthName = 'March';
        } else if (monthNumber == 4) {
            monthName = 'April';
        } else if (monthNumber == 5) {
            monthName = 'May';
        } else if (monthNumber == 6) {
            monthName = 'June';
        } else if (monthNumber == 7) {
            monthName = 'July';
        } else if (monthNumber == 8) {
            monthName = 'August';
        } else if (monthNumber == 9) {
            monthName = 'September';
        } else if (monthNumber == 10) {
            monthName = 'October';
        } else if (monthNumber == 11) {
            monthName = 'November';
        } else if (monthNumber == 12) {
            monthName = 'December';
        } else {
            monthName = 'Invalid month';
        }
        
        return monthName;
    }
    
    
    
    public List<wrapper> wrapperListAddition {get; set;}
    public List<wrapper> wrapperListDeduction {get; set;}
    
    public PageReference sendpayslip(){
        try{
            if(emppay != Null){
                pdf = true;        
                PageReference pdf = ApexPages.currentPage();
                pdf.getParameters().put('pdf','true');                        
                pdf.setRedirect(true);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('PaySlip');
                String [] toAddresses = new String[] {emppay.Employees__r.Email__c}; 
                    email.setToAddresses(toAddresses);
                email.setPlainTextBody('Hi '+emppay.Employees__r.First_Name__c+',\n\nPlease find the attachment of your PaySlip for this Month. \n\nThanks and Regards,\nApex Cloud Ltd.');             
                email.setBccSender(false);
                email.setUseSignature(false); 
                email.setSenderDisplayName('ERP Mark7');  
                email.setSaveAsActivity(false);                     
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setFileName(emppay.Name+'.pdf'); 
                Blob b = pdf.getContent(); attach.setBody(b); email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                Attachment attachment = new Attachment();
                if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) { attachment.Body = b; }
                if(Schema.sObjectType.Attachment.fields.Name.isCreateable()) { attachment.Name = String.valueOf('PaySlip.pdf'); }
                if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()) { attachment.ParentId = emppay.id; }       
                try { if(Schema.sObjectType.Attachment.isCreateable()) insert attachment; else{ } } catch(Exception e){}             
            }
            PageReference page = new PageReference('/'+emppayId);
            page.setredirect(true);
            return page;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    }
}