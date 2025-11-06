Global With Sharing Class Invoice_Email { 
    public Invoice__c currentInvoice                   { get; set; }  
    public Sales_Order__c currentSalesOrder            { get; set; } 
    global ERP7__Invoice__c InvoiceDownload                  { get; set; } 
    global list<ERP7__Invoice_Line_Item__c> invlist    {get; set; }
    public List<Sales_Order_Line_Item__c> currentItems { get; set; }
    public Address__c billingAddress                   { get; set; }
    public Address__c shippingAddress                  { get; set; }
    public Contact currentContact                      { get; set; }    
    public String invoiceName                          { get; set; }
    public Boolean pdf                                 { get; set; }
    public Decimal subtotal                            { get; set; }
    public Decimal discount                            { get; set; }
    public Decimal Vat                                 { get; set; }
    public Decimal tax                                 { get; set; }
    public Decimal totalDue                            { get; set; }
    public Decimal loyaltyAmount                       { get; set; }
    public Decimal AmountPaid                          { get; set; }
    public Decimal finalDue                            { get; set; }
    public Boolean returnItemsize                      { get; set; }
    public Boolean docInvoiceLogo                      { get; set; }
    public String DocumentLogoUrl                      { get; set; }
    public String EmailSubject                         { get; set; }
    public String EmailBody                            { get; set;  }
    public List<selectoption> AvailableRecipients      { get; set; }
    public List<selectoption> SelectedRecipients       { get; set; }
    public String selectedEmail                        { get; set; }
    public Map<string,string> ccEmails_map             { get; set; }
    public list<String>  ccEmails                       { get; set; } 
    public String contactids                               {get;set;}
    public Account org_details                    {get;set;}
    public Bank_details__c org_Bank_Account    {get;set;}
    public Invoice_Email() {
            currentInvoice =new Invoice__c();                   
            currentSalesOrder = new Sales_Order__c();  
            currentItems = new List<Sales_Order_Line_Item__c> ();
            billingAddress  = new Address__c();
            shippingAddress  = new Address__c();
            currentContact  = new Contact(); 
            invoiceName   ='';                      
            pdf  = false;                               
            subtotal =0.00;                            
            discount   =0.00;                          
            Vat        =0.00;                          
            tax  =0.00;                                
            totalDue  =0.00;                           
            loyaltyAmount   =0.00;                     
            AmountPaid  =0.00;                         
            finalDue    =0.00;                         
            returnItemsize =false;                   
            docInvoiceLogo =false;                        
            DocumentLogoUrl ='';                    
            EmailSubject   ='';                      
            EmailBody      ='';
            AvailableRecipients   =new List<selectoption>();  
            SelectedRecipients   = new List<selectoption>();   
            selectedEmail ='';                        
            ccEmails_map  = new   Map<string,string>();              
            ccEmails     = new list<String> ();                   
            contactids ='';
            org_details    =new Account();
            org_Bank_Account   = new Bank_details__c();
    }
     
    public Invoice_Email(ApexPages.StandardController controller){

    }
    public Invoice__c getCurrentInv(String Inv){
  
        return null;
    }
    
    public Sales_Order__c getCurrentOrder(Id Ord){
        return null;
    }
    
    public List<Sales_Order_Line_Item__c> getCurrentOrderItems(Id Ord){
      
        return null;
    }  
    
     public void buildCcEmail()
    {
    purchasedProductLineItem  = new List<wrapper>();
    returnedProductLineItem  = new List<wrapper>();
    } 
    public List<wrapper> purchasedProductLineItem { get; set;}   
    public List<wrapper> returnedProductLineItem { get; set;}
    public class wrapper{
        public String Code         { get; set; }
        public String Product      { get; set; }
        public Decimal BasePrice   { get; set; }
        public Decimal Discount    { get; set; }
        public Decimal Tax         { get; set; }
        public Decimal Vat         { get; set; }
        public Decimal TotalPrice  { get; set; }
        public Decimal quantity    { get; set; }
        public String  prod_Desc   { get; set;}
        public wrapper(){
            code   = '';
            product = '';
            BasePrice = 0;
            Discount = 0;
            Tax = 0;
            Vat = 0;
            TotalPrice = 0;
            quantity = 0;
            prod_Desc = '';
        }
    }
    
    public Void sendInvoice(){
     
    }
    
   
    public PageReference Back2Invoice() {
    
        return null;
    } 
  
    public void getInvoiceListDownload(){
        String pId = apexpages.currentpage().getparameters().get('Id');
        
        InvoiceDownload=[select Id,RecordType.Name,Name,ERP7__Order__r.Contact__r.Name,Account__r.Company__c,ERP7__Order__r.Bill_To_Address__r.Address_Line1__c,ERP7__Order__r.Bill_To_Address__r.Address_Line2__c,ERP7__Order__r.Bill_To_Address__r.Address_Line3__c,ERP7__Order__r.Bill_To_Address__r.City__c,ERP7__Order__r.Bill_To_Address__r.State__c,ERP7__Order__r.Bill_To_Address__r.Postal_Code__c,ERP7__Order__r.Bill_To_Address__r.Country__c,ERP7__Order__r.Contact__r.Phone,ERP7__Order__r.Ship_To_Address__r.Address_Line1__c,ERP7__Order__r.Ship_To_Address__r.Address_Line2__c,ERP7__Order__r.Ship_To_Address__r.Address_Line3__c,ERP7__Order__r.Ship_To_Address__r.City__c,ERP7__Order__r.Ship_To_Address__r.State__c,ERP7__Order__r.Ship_To_Address__r.Postal_Code__c,ERP7__Order__r.Ship_To_Address__r.Country__c,ERP7__Order__r.ERP7__Total_Shipping_Amount__c,ERP7__Final_Due_Amount__c,ERP7__Order__r.ERP7__Sales_Order_Amount__c,ERP7__Order__r.ERP7__Sub_Total__c,ERP7__Order__r.ERP7__TotalDiscount__c,ERP7__Invoice_Date__c,ERP7__Order__r.Name, ERP7__Organisation__r.Name,ERP7__Organisation__r.BillingCountry,ERP7__Organisation__r.Phone,ERP7__Organisation__r.Fax,ERP7__Organisation__r.BillingStreet,ERP7__Organisation__r.BillingCity,ERP7__Organisation__r.BillingState,ERP7__Organisation__r.ERP7__VAT_registration_number__c  FROM ERP7__Invoice__c WHERE Id =:pId];
        invlist=[select id,Name,ERP7__Product__r.Name,ERP7__Product__r.ProductCode,ERP7__Quantity__c,ERP7__Base_Price__c,ERP7__Discount_Amount__c,ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Return_Quantity__c,Total_Price__c from ERP7__Invoice_Line_Item__c where ERP7__Invoice__c =:pId];//EmployeeRequester__r.First_Name__c,EmployeeRequester__r.Last_Name__c,
   		
    }
   
}