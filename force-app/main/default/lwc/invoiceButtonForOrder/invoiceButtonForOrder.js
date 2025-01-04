import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class InvoiceButtonForOrder extends NavigationMixin(LightningElement) {

    @api recordId;

    handleClick()
    {
        let redirectURL = '/apex/createinvoice?origin_record='+this.recordId+'&account=accountid&invoice_date=EffectiveDate&invoice_due_date=EndDate&child_relationship_name=OrderItems&line_item_description=Description&line_item_quantity=Quantity&line_item_unit_price=UnitPrice';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: redirectURL
            }
        });
    }
}