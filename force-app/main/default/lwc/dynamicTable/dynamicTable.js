import { LightningElement, track, wire } from "lwc";
import getfieldName from "@salesforce/apex/FatchDynamicFieldName.getFieldsAndTypes";
export default class DynamicTable extends LightningElement {
  @track tablehadder = [];
  @track storeValue = {};
  @track fieldId = 0;
  @track dynamcFieldName = {
    mainfield: [],
  };
  @track initialhadder = ["name", "billingstreet", "type", "phone"];
  @track avilableForSelection = [];
  @track selectedFields = [];
  currentObjectName = "Account";
  @track showMoreFields = false
  @wire(getfieldName, { objectName: "$currentObjectName" })
  setallthewrapper({ data, error }) {
    // createing header for the table
    data?.map((item, index) => {
     // console.log(JSON.stringify(item));
      if (this.initialhadder.includes(item.fName)) {
        this.tablehadder.push({
          fName: item.fName,
          fType: item.fType,
      });
      }else{
        this.avilableForSelection.push({
          label: item.fName,
          value: item.fType,
      });
      }
    });
    // creating row for the table where value will populate
    data?.map((item, index) => {
      if (index == 0) {
        var innderFields = {
          innderField: [],
        };
        this.tablehadder?.map((item) => {
          if(item.fType=='STRING' || item.fType=='PHONE' || item.fType=='EMAIL'){
            innderFields.innderField.push({
              id: index,
              Name: "",
              dataType: item.fType,
              fieldName: item.fName,
              text:true,
              checkbox:false,
              picklist:false,
              textaria:false
            })
          }else if(item.fType=='BOOLEAN'){
            innderFields.innderField.push({
              id: index,
              Name: "",
              dataType: item.fType,
              fieldName: item.fName,
              text:false,
              checkbox:true,
              picklist:false,
              textaria:false
            })
            }else if(item.fType=='PICKLIST'){
              innderFields.innderField.push({
                id: index,
                Name: "",
                dataType: item.fType,
                fieldName: item.fName,
                text:false,
                checkbox:false,
                picklist:true,
                textaria:false,
                options:[{ label: 'New', value: 'new' },
                    { label: 'In Progress', value: 'inProgress' },
                  { label: 'Finished', value: 'finished' },]
              })
            }else if(item.fType=='TEXTAREA'){
              innderFields.innderField.push({
                id: index,
                Name: "",
                dataType: item.fType,
                fieldName: item.fName,
                text:false,
                checkbox:false,
                picklist:false,
                textaria:true
              })
            }
          
        });
        this.dynamcFieldName.mainfield.push(innderFields);
      }
    });
    console.log('data::::',JSON.stringify(this.dynamcFieldName));
    // creating data for field secelction 
  }
  addMoreRow() {
    try {
      console.log('called add row'); 
      this.fieldId += 1;
    var innderFields = {
        innderField: [],
      };
    this.tablehadder?.map((item) => {
      if(item.fType=='STRING' || item.fType=='PHONE' || item.fType=='EMAIL'){
        innderFields.innderField.push({
          id: this.fieldId,
          Name: "",
          dataType: item.fType,
          fieldName: item.fName,
          text:true,
          checkbox:false,
          picklist:false,
          textaria:false
        })
      }else if(item.fType=='BOOLEAN'){
        innderFields.innderField.push({
          id: this.fieldId,
          Name: "",
          dataType: item.fType,
          fieldName: item.fName,
          text:false,
          checkbox:true,
          picklist:false,
          textaria:false
        })
        }else if(item.fType=='PICKLIST'){
          innderFields.innderField.push({
            id: this.fieldId,
            Name: "",
            dataType: item.fType,
            fieldName: item.fName,
            text:false,
            checkbox:false,
            picklist:true,
            textaria:false,
            options:[{value:'1',label:'1'},{value:'2',label:'2'},{value:'3',label:'3'}]
          })
        }else if(item.fType=='TEXTAREA'){
          innderFields.innderField.push({
            id: this.fieldId,
            Name: "",
            dataType: item.fType,
            fieldName: item.fName,
            text:false,
            checkbox:false,
            picklist:false,
            textaria:true
          })
        }
      });
      this.dynamcFieldName.mainfield.push(innderFields);
      console.log('data::::',JSON.stringify(this.dynamcFieldName));
    } catch (error) {
      console.log('error',JSON.stringify(error));
      
    }  
    }
  getFieldValue(event) {
    const { id, field } = event.target.dataset;
    let value = event.target.value;
    this.dynamcFieldName.mainfield.map(item=>{
        item.innderField.map(value=>{
            if(value.id == id && value.fieldName == field){
                    value.Name = event.target.value;
            }
        }) 
    })

    //Object.assign(this.storeValue)
  }
  handleSave(){
    console.log(JSON.stringify(this.dynamcFieldName));
  }
  handleAddColumn(){
  this.showMoreFields = true
  }
  ShowMoreColumn(event){
    this.selectedFields.map(item=>{
      this.tablehadder.push({
        fName: item,
        value: item,
    });
    })
    this.dynamcFieldName.mainfield.map((item,index)=>{
      this.selectedFields.map(value=>{
        item.innderField.push({
          id: item.innderField[index].id,
          Name: "",
          dataType: "String",
          fieldName: value,})
      })
      
    })
  this.handleAddColumnClose()
  console.log(JSON.stringify(this.dynamcFieldName.mainfield));
  
 
  }
  handleAddColumnClose(){
    this.showMoreFields = false
    console.log(JSON.stringify(this.tablehadder));
    
    }
   handleColumnSelection(event){
    var finalSelectedList=[]
    this.selectedFields = event.detail.value; 
    this.avilableForSelection = this.avilableForSelection.filter(item => !this.selectedFields.includes(item));
    finalSelectedList =this.selectedFields.map(item=>{
      this.avilableForSelection.find(value=>{
       if(value.value== item){
         return value;
       }
      })
    })
    console.log('data value',JSON.stringify(this.avilableForSelection));
    
   }
}