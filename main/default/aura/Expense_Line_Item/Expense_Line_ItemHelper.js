({
    //MAX_FILE_SIZE: 750 000,
    /* 1 000 000 * 3/4 to account for base64 */
    save: function(component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var flag = false;
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(component, file, fileContents);
        };
        fr.readAsDataURL(file);
    },
    upload: function(component, file, fileContents) {
        var action = component.get("c.saveTheFile");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            attachId = a.getReturnValue();
        });
        $A.enqueueAction(action);
    }
})