public with sharing class InvoiceController {
    public transient String origin_record { get; set; }
    public transient String child_relationship_name {get;set;}
    public transient Map<String,String> fieldMap {get;set;}
    public transient List<Map<String,String>> lineItems {get;set;}
    public InvoiceController(ApexPages.StandardController stdController) {
        fieldMap = new Map<String,String>();
        lineItems = new List<Map<String,String>>();
        origin_record = ApexPages.currentPage().getParameters().get('origin_record');
        String account = ApexPages.currentPage().getParameters().get('account');
        String invoice_date = ApexPages.currentPage().getParameters().get('invoice_date');
        String invoice_due_date = ApexPages.currentPage().getParameters().get('invoice_due_date');
        child_relationship_name = ApexPages.currentPage().getParameters().get('child_relationship_name');
        String line_item_description = ApexPages.currentPage().getParameters().get('line_item_description');
        String line_item_quantity = ApexPages.currentPage().getParameters().get('line_item_quantity');
        String line_item_unit_price = ApexPages.currentPage().getParameters().get('line_item_unit_price');

        String objectName = getObjectName(origin_record);
        String childquery = '(select id,'+line_item_description+','+line_item_quantity+','+line_item_unit_price+' from '+child_relationship_name+')';
        String query = 'SELECT Id, '+ invoice_due_date +','+account+','+invoice_date+', '+childquery+' FROM ' + objectName +' where Id =\''+origin_record+'\''; 
        List<SObject> records = Database.query(query);
        SObject record = records.get(0);
        fieldMap.put('account',record.get(account)!=null?String.valueOf(record.get(account)):'');
        fieldMap.put('invoice_due_date',record.get(invoice_due_date)!=null?String.valueOf(record.get(invoice_due_date)):'');
        fieldMap.put('invoice_date',record.get(invoice_date)!=null?String.valueOf(record.get(invoice_date)):'');
        for(SObject childObject : (List<SObject>)record.getSObjects(child_relationship_name))
        {
            Map<String,String> lineItemMap = new Map<String,String>();
            lineItemMap.put('line_item_description',childObject.get(line_item_description)!=null?String.valueOf(childObject.get(line_item_description)):'');
            lineItemMap.put('line_item_quantity',childObject.get(line_item_quantity)!=null?String.valueOf(childObject.get(line_item_quantity)):'');
            lineItemMap.put('line_item_unit_price',childObject.get(line_item_unit_price)!=null?String.valueOf(childObject.get(line_item_unit_price)):'');
            lineItems.add(lineItemMap);
        }
    }

    public void controllerAction() {

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
}