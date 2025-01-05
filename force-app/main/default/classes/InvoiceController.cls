public with sharing class InvoiceController {
    public transient String child_relationship_name {get;set;}
    public Invoice__c invoice {get;set;}
    public List<LineItem__c> lineItemObjs {get;set;}
    public String jsonstr {get;set;}
    public InvoiceController(ApexPages.StandardController stdController) {
        invoice = new Invoice__c();
        lineItemObjs = new List<LineItem__c>();
        invoice.InvoiceReference__c = ApexPages.currentPage().getParameters().get('origin_record');
        String account = ApexPages.currentPage().getParameters().get('account');
        String invoice_date = ApexPages.currentPage().getParameters().get('invoice_date');
        String invoice_due_date = ApexPages.currentPage().getParameters().get('invoice_due_date');
        child_relationship_name = ApexPages.currentPage().getParameters().get('child_relationship_name');
        String line_item_description = ApexPages.currentPage().getParameters().get('line_item_description');
        String line_item_quantity = ApexPages.currentPage().getParameters().get('line_item_quantity');
        String line_item_unit_price = ApexPages.currentPage().getParameters().get('line_item_unit_price');

        String objectName = getObjectName(invoice.InvoiceReference__c);
        String childquery = '(select id,'+line_item_description+','+line_item_quantity+','+line_item_unit_price+' from '+child_relationship_name+')';
        String query = 'SELECT Id, '+ invoice_due_date +','+account+','+invoice_date+', '+childquery+' FROM ' + objectName +' where Id =\''+invoice.InvoiceReference__c+'\''; 
        List<SObject> records = Database.query(query);
        SObject record = records.get(0);
        invoice.Account__c = record.get(account)!=null?String.valueOf(record.get(account)):null;
        invoice.DueDate__c = record.get(invoice_due_date)!=null?(Date)record.get(invoice_due_date):null;
        invoice.InvoiceDate__c=record.get(invoice_date)!=null?(Date)record.get(invoice_date):null;
        if(record.getSObjects(child_relationship_name) != null)
        {
        for(SObject childObject : (List<SObject>)record.getSObjects(child_relationship_name))
        {
            LineItem__c lineItem = new LineItem__c();
            lineItem.LineDescription__c = childObject.get(line_item_description)!=null?String.valueOf(childObject.get(line_item_description)):null;
            lineItem.Quantity__c= childObject.get(line_item_quantity)!=null?(Decimal)childObject.get(line_item_quantity):null;
            lineItem.UnitPrice__c = childObject.get(line_item_unit_price)!=null?(Decimal)childObject.get(line_item_unit_price):null;
            lineItemObjs.add(lineItem);
        }
        }
        jsonstr = generateJSON();
    }

    public void controllerAction() {
        /*
        insert invoice;
        for(LineItem__c lineItem: lineItemObjs)
        {
            lineItem.Invoice__c = invoice.Id;
        }
        insert lineItemObjs;
        invoice = [Select Id,InvoiceNumber__c,Account__r.Name,Total__c,InvoiceReference__c,Account__c,DueDate__c,InvoiceDate__c,(Select Id,LineDescription__c,Quantity__c,UnitPrice__c,Amount__c from LineItems__r) from Invoice__c where Id=:invoice.Id];
        jsonstr = generateJSON();
        */
    }

    public String getObjectName(String origin_record)
    {
        String recordprefix =  origin_record.substring(0, 3); 
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for (String objectName : globalDescribe.keySet()) {
            Schema.SObjectType sObjectType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            String prefix = describeResult.getKeyPrefix();
            if(prefix == recordprefix)
            {
                    return objectName;
            }
        }
        return null;
    }

    public String generateJSON()
    {
        InvoiceDTO dto = new InvoiceDTO();
        dto.Type = 'ACCREC';
        InvoiceDTO.Contact contact = new  InvoiceDTO.Contact();
        contact.ContactID = '0000000';
        dto.Contact = contact;
        DateTime dt = DateTime.newInstance(invoice.InvoiceDate__c.year(), invoice.InvoiceDate__c.month(), invoice.InvoiceDate__c.day(), 0, 0, 0);
        Long unixTimestamp = dt.getTime(); 
        String timezoneOffset = '+0000'; 
        dto.dt = '\\/Date(' + unixTimestamp + timezoneOffset + ')\\/';
        dto.DateString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss');
        dt = DateTime.newInstance(invoice.DueDate__c.year(), invoice.DueDate__c.month(), invoice.DueDate__c.day(), 0, 0, 0);
        unixTimestamp = dt.getTime(); 
        timezoneOffset = '+0000'; 
        dto.DueDate = '\\/Date(' + unixTimestamp + timezoneOffset + ')\\/';
        dto.DueDateString = dt.format('yyyy-MM-dd\'T\'HH:mm:ss');
        dto.LineAmountTypes = 'Exclusive';
        List<InvoiceDTO.LineItem> lineItems = new  List<InvoiceDTO.LineItem>();
        for(LineItem__c item: lineItemObjs)
        {
            InvoiceDTO.LineItem itemdto = new InvoiceDTO.LineItem();
            itemdto.Description = item.LineDescription__c;
            itemdto.Quantity = item.Quantity__c;
            itemdto.UnitAmount = item.UnitPrice__c;
            itemdto.AccountCode = '200';
            itemdto.DiscountRate = '20';
            lineItems.add(itemdto);
        }
        dto.LineItems = lineItems;
        String result = JSON.serialize(dto).replace('\\\\', '\\');
        return result;
    }

    public PageReference redirectToVFPage() {
        PageReference pageRef = Page.displayjson;
        pageRef.getParameters().put('jsonstr', jsonstr);
        return pageRef;
    }
}