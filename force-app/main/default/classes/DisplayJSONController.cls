public with sharing class DisplayJSONController {
    public Invoice__c invoice {get;set;}
    public List<LineItem__c> lineItemObjs {get;set;}
    public DisplayJSONController(ApexPages.StandardController stdController) {
        String invoicestr = ApexPages.currentPage().getParameters().get('invoicestr');
        String lineitemsstr = ApexPages.currentPage().getParameters().get('lineitemsstr');
        invoice = (Invoice__c) JSON.deserialize(invoicestr,Invoice__c.class);
        lineItemObjs = (List<LineItem__c>) JSON.deserialize(lineitemsstr,List<LineItem__c>.class);
    }

    
    public PageReference redirectToRecordPage() {
        insert invoice;
        for(LineItem__c item: lineItemObjs)
        {
            item.Invoice__c = invoice.Id;
        }
        insert lineItemObjs;
        Id recordId = invoice.Id;
        PageReference recordPage = new PageReference('/' + recordId);
        recordPage.setRedirect(true);
        return recordPage;
    }
        
}