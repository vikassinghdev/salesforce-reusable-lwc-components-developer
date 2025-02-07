import { LightningElement,track,wire } from 'lwc';
import {publish,MessageContext} from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/storage__c';
export default class LeftBar extends LightningElement {
    @track allObjectList =[
        { label: 'Account', value: 'Account' ,id:1},
        { label: 'Contact', value: 'Contact' ,id:2},
        { label: 'Opportunity', value: 'Opportunity' ,id:3},
        { label: 'Lead', value: 'Lead',id:4 },
        { label: 'Case', value: 'Case' ,id:5},
        { label: 'Custom Object', value: 'CustomObject' ,id:6},
    ]
    
 @wire(MessageContext)
      MessageContext;

handleClick(event) {
        const {id,value} = event.target.dataset;
        const payload = {'objectName': id};
        publish(this.MessageContext, SAMPLEMC,payload );
    }
}