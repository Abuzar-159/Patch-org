public with sharing class payBills {
    /*
    public List<Payment__c> paymentsToInsert { get; set;}
    public Integer selecttSize               { get; set;}
    public Integer first                     { get; set;}
    public Chart_of_Accounts__c paymentAcc   { get; set;}
    public Bill__c Bill                      { get; set;}
    public Account vendorInfo                { get; set;}
    public Voucher__c voucher                { get; set;}
    public Boolean selectAll                 { get; set;}
    public  Payment__c payment { get; set;}
    public List<Bill_Wrap> Bill_WrapList     { get; set;}
    public paybills(){
        first=0;
        selecttSize = 0;
        paymentsToInsert = new List<Payment__c>();
        bill = new Bill__c(Received_date__c = system.Today(),Total_Amount__c=0.00,Amount__c=0.00,Amount_Paid__c=0.00);
        voucher = new voucher__c(Credit_Used__c=0.00);
        payment = new Payment__c(posted__c=true,Posted_date__c=system.Today(),ERP7__Amount__c = 0.00 ,Type__c='Credit',Status__c='Paid');
        selectAll = false;
        vendorInfo  = new Account();
        Bill_WrapList = new List<Bill_Wrap>();
        fetchAllBills();
    }
    public pageReference fetchAllBills(){
        Integer i=0;
        Bill_WrapList = new List<Bill_Wrap>();
        voucher.Total_Amount__c=0.00;voucher.Credit_Used__c=0.00;voucher.Amount__c=0.00;voucher.Amount_Paid__c=0.00;
        String QueryFilter = '';
        if(Bill.vendor__c != null ) 
          QueryFilter += 'AND Vendor__c =\''+Bill.vendor__c+'\'';
          Date ddate = Bill.Due_Date__c;
          
        //if(Bill.Due_Date__c != null)
          //  QueryFilter +=' AND Due_Date__c <=: ddate';
       
        String Query = 'Select Id,Name,Amount__c,Purchase_Order__c,Total_Amount__c,Amount_Due__c,Status__c,Due_Date__c,Vendor__c,Vendor__r.Name,Amount_Paid__c,Credit_Used__c FROM Voucher__c Where Status__c !=\'Paid\' '+QueryFilter;
        for(Voucher__c v:[Select Id,Name, Vendor_invoice_Bill__c,Vendor_invoice_Bill__r.Name,Amount__c,ERP7__Date__c ,Purchase_Orders__c,Total_Amount__c,Amount_Due__c,Status__c,Vendor__c,Vendor__r.Name,Amount_Paid__c,Credit_Used__c FROM Voucher__c Where Status__c !='Paid' And Paid__c =false AND Posted__c=true]){// Database.Query(Query)
            Bill_Wrap bw = new Bill_Wrap();
            bw.index=i;
            bw.voucher= v;
            voucher.Credit_Used__c += v.Credit_Used__c;
            voucher.Total_Amount__c += v.Total_Amount__c;
            voucher.Amount__c += v.Amount_Due__c;
            //voucher.Amount_Paid__c +=v.Amount__c;
            Bill_WrapList.add(bw);
            i++;
        }
    return getCreditDetails();
    
    }
    public pageReference onselect(){
        selecttSize = 0;
        voucher.Amount_Paid__c=0.00;
        for(Integer i=0;i<Bill_WrapList.size();i++){
            if(Bill_WrapList[i].isSelect){
                selecttSize++;
               // Bill_WrapList[i].voucher.Amount__c =Bill_WrapList[i].bill.Amount_Due__c;
                voucher.Amount_Paid__c += Bill_WrapList[i].voucher.Amount__c;
            }else{
               // voucher.Amount_Paid__c -= Bill_WrapList[i].voucher.Amount__c;
                //Bill_WrapList[i].voucher.Amount__c =0.00;
                
            }
        }
        return null;
    }
    public PageReference refreshPage() {
   
         return null;
    }
    public PageReference ApplyCreditExit() {
       paymentsToInsert = new List<Payment__c>();
       List<Debit_Note__c> debitNoteList = [SELECT Id,ERP7__Active__c, ERP7__Account__c,ERP7__Amount__c FROM Debit_Note__c WHERE ERP7__Account__c =:bill.vendor__c Order by CreatedDate];
       for(Integer i=0;i<Bill_WrapList.size();i++){
       
        if(Bill_WrapList[i].isSelect){
            Decimal credit2Apply = Bill_WrapList[i].applycredit;
            for(Integer j=0;j<debitNoteList.size();){
                    Payment__c debitNote = new Payment__c(Voucher__c = Bill_WrapList[i].voucher.id,Type__c='Credit',Status__c='Paid',Payment_Type__c='Debit Note');
                    Boolean flag = false;
                    if(debitNoteList[j].Amount__c>0 && credit2Apply !=0.00){
                        if(credit2Apply > debitNoteList[j].Amount__c){
                            flag = true;
                            debitNote.Amount__c = debitNoteList[j].Amount__c;
                            debitNote.Debit_Note__c = debitNoteList[j].Id;
                            credit2Apply -= debitNoteList[j].Amount__c;
                            j++;
                        } else{
                            flag = true;
                            debitNote.Amount__c = credit2Apply;
                            debitNoteList[j].Amount__c -= credit2Apply;
                            debitNote.Debit_Note__c = debitNoteList[j].Id;
                            credit2Apply = 0.00;
                        }   
                        if(flag)paymentsToInsert.add(debitNote); 
                    }else
                        j++;
            }
         Bill_WrapList[i].applycredit = 0.00;   
        }
        }
       
        if(paymentsToInsert.size()>0)upsert paymentsToInsert;
        return null;
    }
    
    public pageReference select_All(){
    for(Integer i=0;i<Bill_WrapList.size();i++)
        Bill_WrapList[i].isSelect = selectAll;
        
    return onselect();
    }
     public PageReference prev() {
        first--;
        return null;
    }
        public PageReference next() {
        first++;
        return null;
    }


    public PageReference applyCredits() {
         bill.Credit_s_Used__c = 0.00;
         bill.Amount_Paid__c=0.00;
        Decimal appliedCredit =0.00;
        for(Integer i=0;i<Bill_WrapList.size();i++){
        if(Bill_WrapList[i].isSelect){
            appliedCredit  +=  Bill_WrapList[i].applycredit;
            if(appliedCredit > vendorInfo.ERP7__Available_Credit_Balance__c){
                 Bill_WrapList[i].errMsg = 'Total Applied Credit should be less than Available Credit'; 
            }else{
                Bill_WrapList[i].errMsg ='';
                Bill_WrapList[i].voucher.Amount__c = Bill_WrapList[i].bill.Amount_Due__c - Bill_WrapList[i].applycredit;
                Bill_WrapList[i].bill.Credit_s_Used__c  = Bill_WrapList[i].bill.Total_Amount__c -Bill_WrapList[i].bill.Amount_Due__c - Bill_WrapList[i].bill.Amount_Paid__c +Bill_WrapList[i].applycredit;
                bill.Amount_Paid__c += Bill_WrapList[i].voucher.Amount__c;
            }
            
        }
        bill.Credit_s_Used__c += Bill_WrapList[i].bill.Credit_s_Used__c; 
          
        }
            
        if(appliedCredit <= vendorInfo.ERP7__Available_Credit_Balance__c)
        vendorInfo.ERP7__Credit_Balance__c  = vendorInfo.ERP7__Available_Credit_Balance__c  - appliedCredit ;
        return null;
    }


    public PageReference SaveandPrint() {
        Save();
        return new PageReference('/apex/PrintedCheck_Pdf?Id='+Bill.Vendor__c);
    }


    public PageReference cancel() {
        return new PageReference('/');
    }
    

    public PageReference Save() {
        List<Bill__c> BillstoUpdate = new List<Bill__c>();
        List<Voucher__c> vouchertoUpdate = new List<Voucher__c>();
        if(voucher.Payment_Account__c != null ){
        Integer ref = (voucher.Payment_Methods__c =='Cheque' && voucher.Reference__c !=null)?Integer.valueOf(voucher.Reference__c):0;
        payment.ERP7__Amount__c =voucher.Amount_Paid__c ;
        payment.Payment_Account__c =voucher.Payment_Account__c;
        payment.ERP7__Reference_Cheque_No__c = String.valueOf(ref);
        payment.Payment_Type__c = 'Voucher';
        upsert payment;
        for(Integer i=0;i<Bill_WrapList.size();i++){
        if(Bill_WrapList[i].isSelect){
        Bill_WrapList[i].voucher.Paid__c = true;
        Bill_WrapList[i].voucher.Payment__c = payment.id;
        Bill_WrapList[i].voucher.Date__c = Bill.Received_date__c;
        Bill_WrapList[i].voucher.Payment_Account__c = voucher.Payment_Account__c;
        Bill_WrapList[i].voucher.Payment_Methods__c = voucher.Payment_Methods__c;
        if(voucher.Payment_Methods__c =='Cheque'){
                
                Bill_WrapList[i].voucher.Reference__c = String.valueOf(ref);//String.valueOf(ref+i+1);
        }
        vouchertoUpdate.add(Bill_WrapList[i].voucher);
        //BillstoUpdate.add(Bill_WrapList[i].bill);
        }
        }
        
        //if(BillstoUpdate.size()>0)upsert BillstoUpdate;
        if(vouchertoUpdate.size()>0)upsert vouchertoUpdate;
        if(selectAll)selectAll=false;
        getCoaDetails();
        voucher = new voucher__c(Credit_Used__c=0.00);
        payment = new Payment__c(posted__c=true,Posted_date__c=system.Today(),ERP7__Amount__c = 0.00 ,Type__c='Credit',Status__c='Paid');
        return fetchAllBills();
        }else{
            voucher.Payment_Account__c.addError('Please Select Payment Account');
            return null;
        }
    }
    public class Bill_Wrap {
        public Boolean isSelect { get; set; }
        public Bill__c bill { get; set; }
        public Integer index { get; set; }
        public Decimal applycredit { get; set; }
        public Voucher__c voucher {get;set;}
        
        public String errMsg {get;set;}
        public Bill_Wrap (){
            index = 0;
            errMsg = '';
            applycredit = 0.00;
            isSelect = false;
            bill = new Bill__c ();
            voucher = new Voucher__c();
        }
    }
    public pageReference getCoaDetails(){
        if(voucher.Payment_Account__c != null){
            paymentAcc = [Select Id,Name,Calculated_Ending_Balance__c FROM Chart_of_Accounts__c where id=:voucher.Payment_Account__c];
        
        }
    return null;
    }
    public pageReference getCreditDetails(){
        if(voucher != null && voucher.vendor__c != null){
            vendorInfo = [Select Id,Name,ERP7__Credit_Balance__c,Available_Credit_Balance__c FROM Account WHERE id =:voucher.vendor__c];
            vendorInfo.put('ERP7__Credit_Balance__c', vendorInfo.get('ERP7__Available_Credit_Balance__c'));
        }
        return null;
    }
    */
}