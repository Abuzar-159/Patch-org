global With Sharing Class WOTraveller{ 
    global BuildWorkOrder.comWrap comW { get; set; }
    global String Id { 
        get{ return Id; } 
        set{ 
            try{ Id = value; comW = BuildWorkOrder.getAll(Id); } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        } 
    }
}