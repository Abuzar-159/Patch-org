global With Sharing Class pjtDocument{ 
    global ManageProjects.comWrap comW { get; set; }
    global String Id { 
        get{ return Id; } 
        set{ 
            try{ Id = value; comW = ManageProjects.getAll(Id); } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        } 
    }
}