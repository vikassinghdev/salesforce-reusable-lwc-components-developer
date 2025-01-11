public class FatchDynamicFieldName {
    @AuraEnabled(cacheable=true)
    public static list<fieldNameWrapper>  getFieldsAndTypes(String objectName) {
        Map<String, String> fieldInfo = new Map<String, String>();
        list<fieldNameWrapper> letfofField = new list<fieldNameWrapper>();
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType != null) {
                Schema.DescribeSObjectResult describeResult = objType.getDescribe();
                Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
                for (String fieldName : fields.keySet()) {
                    Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
                    String fieldType = fieldDescribe.getType().name(); // Get field data type
                    fieldNameWrapper wrp = new fieldNameWrapper();
                    wrp.fName = fieldName;
                    wrp.fType = fieldType;
                    letfofField.add(wrp);
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return letfofField;
    }
    
    public class fieldNameWrapper{
      @AuraEnabled public  string fName;
      @AuraEnabled public  string fType;
    }
    
    

    }