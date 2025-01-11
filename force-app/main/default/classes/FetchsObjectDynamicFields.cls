public class FetchsObjectDynamicFields {
    
    // get the sObject required fields...
    @AuraEnabled
    public static String getObjectSchmeaFields(String objectApiName){
        try{
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
            Map<String,Schema.SObjectField> fieldsMap =  sobjectType.getDescribe().fields.getMap();
            List<sObjectRequiredFieldWrapper> sObjectfieldWrapperObjList = new List<sObjectRequiredFieldWrapper>();
            
            for(String fieldApiName : fieldsMap.keySet()) {
                Schema.DescribeFieldResult field = fieldsMap.get(fieldApiName).getDescribe();
                Boolean isRequired = field.isNillable();
                String fieldType = String.valueOf(field.getType());
                
                if(FetchsObjectDynamicFields.ignoreAuditRequiredField(field.getName())){
                    sObjectRequiredFieldWrapper fieldWrapperObj = new sObjectRequiredFieldWrapper();
                    fieldWrapperObj.label = field.getLabel();
                    fieldWrapperObj.apiName = field.getName();
                    fieldWrapperObj.lenght = field.getLength();
                    fieldWrapperObj.fieldType = fieldType;
                    fieldWrapperObj.referanceObjectApiName = fieldType.equalsIgnoreCase('REFERENCE') ? field.getRelationshipName()?.replace('__r','__c') : '';
                    if(fieldType.contains('PICKLIST')){
                        fieldWrapperObj.options = FetchsObjectDynamicFields.getPicklistOptions(sobjectType, field.getName());
                    }
                    
                    if((!isRequired && !fieldType.equalsIgnoreCase('BOOLEAN')) || (field.isNameField() && field.isCreateable())){
                        fieldWrapperObj.required = field.isNameField() ? isRequired : !isRequired;
                    }
                    else{
                        fieldWrapperObj.required = fieldType.equalsIgnoreCase('BOOLEAN') ? false : !isRequired;
                    }
                    sObjectfieldWrapperObjList.add(fieldWrapperObj);
                    //System.debug('Label : '+field.getLabel()+' Api Name :: '+field.getName()+' is Required :: '+(field.isNillable())+' Tyep of field >> '+field.getType()+' Length >> '+field.getLength());
                    
                }
            }
            if(!sObjectfieldWrapperObjList.isEmpty())
                return JSON.serialize(sObjectfieldWrapperObjList);
        }
        catch(Exception ex){
            System.debug('Class Name : BulkRecordInsert -> Method Name : getObjectSchmeaFields  Message : '+ex.getMessage()+' Line No : '+ex.getLineNumber());
        }
        return null;
    }
    
    // Remove the standrad required field of object....
    public static Boolean ignoreAuditRequiredField(String fieldApiName){
        Boolean isRequired = true;
        if(fieldApiName.equalsIgnoreCase('Id') || fieldApiName.equalsIgnoreCase('IsDeleted') || fieldApiName.equalsIgnoreCase('CreatedDate') || fieldApiName.equalsIgnoreCase('OwnerId')
             || fieldApiName.equalsIgnoreCase('CreatedById') || fieldApiName.equalsIgnoreCase('LastModifiedDate') || fieldApiName.equalsIgnoreCase('LastModifiedById') || fieldApiName.equalsIgnoreCase('LastActivityDate') ||
             fieldApiName.equalsIgnoreCase('SystemModstamp') || fieldApiName.equalsIgnoreCase('LastViewedDate') || fieldApiName.equalsIgnoreCase('LastReferencedDate')){ 
                 isRequired = false;
             }
        return isRequired;
    }
	
    // get picklist value from the sObject....
    public static List<Map<String,String>> getPicklistOptions(Schema.SObjectType sobjectType, String fieldApiName){
        List<Map<String,String>> picklistOptions = new List<Map<String,String>>(); 
        try{
            Map<String,Schema.SObjectField> fields = sobjectType.getDescribe().fields.getMap() ;
            for(Schema.PicklistEntry field : fields.get(fieldApiName).getDescribe().getPicklistValues()){
                picklistOptions.add(new Map<String,String>{'label'=>field.getLabel(), 'value'=>field.getValue()});
            }
        }
        catch(Exception ex){
            System.debug('Class Name : BulkRecordInsert -> Method Name : getPicklistOptions  Message : '+ex.getMessage()+' Line No : '+ex.getLineNumber());
        }
        return picklistOptions;
    }    
    
    public class sObjectRequiredFieldWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Boolean required;
        @AuraEnabled public Integer lenght;
        @AuraEnabled public String referanceObjectApiName;
        @AuraEnabled public List<Map<String,String>> options;
    }
}